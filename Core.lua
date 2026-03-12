-- GroupAutoMarker: Core.lua
-- Simplified, manual-trigger marking engine.

local addonName = "GroupAutoMarker"
GroupAutoMarker = {}

-- Returns true if the current instance is a dungeon.
local function IsInDungeon()
    local _, instanceType = GetInstanceInfo()
    return instanceType == "party" or instanceType == "scenario"
end

-- Builds the full list of unit tokens for all group members including the player.
local function GetAllGroupUnits()
    local units = {}
    local numMembers = GetNumGroupMembers()
    if IsInRaid() then
        for i = 1, numMembers do
            table.insert(units, "raid" .. i)
        end
    else
        table.insert(units, "player")
        for i = 1, numMembers - 1 do
            table.insert(units, "party" .. i)
        end
    end
    return units
end

-- Returns an ordered list of group members sorted by role: Tank, Healer, DPS...
local function GetMembersOrderedByRole()
    local tanks, healers = {}, {}
    for _, unit in ipairs(GetAllGroupUnits()) do
        if UnitExists(unit) and UnitIsConnected(unit) then
            local role = UnitGroupRolesAssigned(unit)
            if role == "TANK" then
                table.insert(tanks, unit)
            elseif role == "HEALER" then
                table.insert(healers, unit)
            end
        end
    end
    return tanks, healers
end

-- Clears all existing raid markers from the group.
local function ClearAllMarkers()
    for _, unit in ipairs(GetAllGroupUnits()) do
        if UnitExists(unit) then
            SetRaidTarget(unit, 0)
        end
    end
end

-- Core marking function, triggered by a secure button click.
function GroupAutoMarker.ApplyMarkers()
    -- Check for leadership is still good practice
    if not (UnitIsGroupLeader("player") or (C_Player and C_Player.IsOfficer and C_Player.IsOfficer())) then
        print(addonName .. ": You must be the group leader or an assistant to set markers.")
        return
    end

    ClearAllMarkers()

    local tanks, healers = GetMembersOrderedByRole()
    local markerSet = false

    -- Mark Tank with Square (2)
    if tanks[1] then
        SetRaidTarget(tanks[1], 2)
        markerSet = true
    end

    -- Mark Healer with Star (4)
    if healers[1] then
        SetRaidTarget(healers[1], 4)
        markerSet = true
    end

    -- Hide the button after a successful marking.
    if markerSet and GAM_IconButton then
        GAM_IconButton:Hide()
    end
end

-- This frame manages the visibility of the manual-marker button.
local visibilityFrame = CreateFrame("Frame", "GroupAutoMarkerVisibilityFrame")
visibilityFrame:SetScript("OnEvent", function(self, event, ...)
    if IsInDungeon() and (UnitIsGroupLeader("player") or (C_Player and C_Player.IsOfficer and C_Player.IsOfficer())) then
        if GAM_IconButton then
            GAM_IconButton:Show()
        end
    else
        if GAM_IconButton then
            GAM_IconButton:Hide()
        end
    end
end)
visibilityFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
visibilityFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
visibilityFrame:RegisterEvent("GROUP_ROSTER_UPDATE") -- Also check when roles/leader changes
