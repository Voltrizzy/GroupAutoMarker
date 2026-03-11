-- GroupAutoMarker: Options.lua
-- Handles the options panel: creates the settings UI using the Blizzard_Menu
-- DropdownButton API (WowStyle1DropdownTemplate), which replaces the removed
-- UIDropDownMenu framework as of patch 12.0.0.

GroupAutoMarkerOptions = {}

-- ── Saved variable helpers ────────────────────────────────────────────────────

local defaults = {}

local function BuildDefaults()
    for _, role in ipairs(GroupAutoMarkerData.Roles) do
        defaults[role.key] = role.defaultMarker
    end
end

local function GetMarkerForRole(roleKey)
    if GroupAutoMarkerDB and GroupAutoMarkerDB[roleKey] ~= nil then
        return GroupAutoMarkerDB[roleKey]
    end
    return defaults[roleKey] or 0
end
GroupAutoMarkerOptions.GetMarkerForRole = GetMarkerForRole

-- Saves a marker assignment, resetting any other role that already holds the
-- same marker to 0 (No Marker) to enforce uniqueness.
local function SetMarkerForRole(roleKey, markerIndex)
    if markerIndex ~= 0 then
        for _, role in ipairs(GroupAutoMarkerData.Roles) do
            if role.key ~= roleKey and GetMarkerForRole(role.key) == markerIndex then
                GroupAutoMarkerDB[role.key] = 0
            end
        end
    end
    GroupAutoMarkerDB[roleKey] = markerIndex
end

-- ── Dropdown helpers ──────────────────────────────────────────────────────────

-- Rebuilds all dropdowns so their display text and radio states stay in sync
-- after any selection (including duplicate-clearing side effects).
local function RefreshAllDropdowns()
    for _, role in ipairs(GroupAutoMarkerData.Roles) do
        local dropdown = _G["GroupAutoMarker_Dropdown_" .. role.key]
        if dropdown then
            dropdown:GenerateMenu()
        end
    end
end

-- Returns the generator function used by SetupMenu for a given role.
local function CreateMenuGenerator(roleKey)
    return function(owner, rootDescription)
        for _, marker in ipairs(GroupAutoMarkerData.Markers) do
            local markerIndex = marker.index
            local displayText = "|cFF" .. marker.color .. marker.name .. "|r"
            rootDescription:CreateRadio(
                displayText,
                function() return GetMarkerForRole(roleKey) == markerIndex end,
                function()
                    SetMarkerForRole(roleKey, markerIndex)
                    RefreshAllDropdowns()
                end,
                markerIndex,
                marker.texture
            )
        end
    end
end

-- ── Panel construction ────────────────────────────────────────────────────────

-- Called from Core.lua on ADDON_LOADED.  Builds the settings panel and
-- registers it under Esc > Options > AddOns.
function GroupAutoMarkerOptions.BuildPanel()
    local panel = CreateFrame("Frame")
    panel.name = "Group Auto Marker"

    -- Title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetJustifyH("LEFT")
    title:SetText("Group Auto Marker")

    -- Subtitle
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
    subtitle:SetJustifyH("LEFT")
    subtitle:SetText(
        "Assign raid markers to each role. " 
    )

    -- One row per role
    local prevAnchor = subtitle
    for _, role in ipairs(GroupAutoMarkerData.Roles) do
        -- Role label (fixed width so all dropdowns left-align together)
        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", 0, -20)
        label:SetJustifyH("LEFT")
        label:SetWidth(64)
        label:SetText(role.label)

        -- Dropdown (Blizzard_Menu DropdownButton, replaces UIDropDownMenu)
        local dropdown = CreateFrame(
            "DropdownButton",
            "GroupAutoMarker_Dropdown_" .. role.key,
            panel,
            "WowStyle1DropdownTemplate"
        )
        dropdown:SetPoint("LEFT", label, "RIGHT", 8, 0)
        dropdown:SetWidth(160)
        dropdown:SetupMenu(CreateMenuGenerator(role.key))

        prevAnchor = label
    end

    -- Register the panel in the game settings system (introduced in 10.0,
    -- confirmed still present in 12.0.0).
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)

    -- Expose panel so OnShow can refresh dropdowns.
    GroupAutoMarkerOptions.panel = panel
    panel:SetScript("OnShow", function()
        RefreshAllDropdowns()
    end)
end

-- ── SavedVariables initialisation ─────────────────────────────────────────────

function GroupAutoMarkerOptions.InitSavedVars()
    BuildDefaults()
    if not GroupAutoMarkerDB then
        GroupAutoMarkerDB = {}
    end
    for key, value in pairs(defaults) do
        if GroupAutoMarkerDB[key] == nil then
            GroupAutoMarkerDB[key] = value
        end
    end

    -- Enforce uniqueness on the initialized data
    local usedMarkers = {}
    for _, role in ipairs(GroupAutoMarkerData.Roles) do
        local roleKey = role.key
        local marker = GroupAutoMarkerDB[roleKey]
        if marker and marker ~= 0 then
            if usedMarkers[marker] then
                -- This marker is already used, so reset this role's marker to 0 (none)
                GroupAutoMarkerDB[roleKey] = 0
            else
                -- This marker is not used yet, claim it
                usedMarkers[marker] = true
            end
        end
    end
end
