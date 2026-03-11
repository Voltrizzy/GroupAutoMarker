-- GroupAutoMarker: Core.lua
-- Main auto-marking engine. Listens for group/zone events and applies markers.

local addonName = "GroupAutoMarker"

-- Event handler frame
local frame = CreateFrame("Frame", "GroupAutoMarkerFrame")
local isUpdatePending = false

-- Returns true if the current instance is a Midnight dungeon.
local function IsInMidnightMythic()
    local _, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()

    if instanceType ~= "party" then
        return false
    end

    return GroupAutoMarkerData.MidnightDungeons[instanceID] ~= nil
end

-- Builds the full list of unit tokens for all group members including the player.
-- In a party, party1-party4 covers other members; "player" must be added separately.
-- In a raid, raid1-raidN covers everyone including the player.
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
    local tanks, healers, dps = {}, {}, {}
    for _, unit in ipairs(GetAllGroupUnits()) do
        if UnitExists(unit) and UnitIsConnected(unit) then
            local role = UnitGroupRolesAssigned(unit)
            if role == "TANK" then
                table.insert(tanks, unit)
            elseif role == "HEALER" then
                table.insert(healers, unit)
            else
                table.insert(dps, unit)
            end
        end
    end
    return tanks, healers, dps
end

-- Clears all raid markers from party members including the player.
local function ClearAllMarkers()
    for _, unit in ipairs(GetAllGroupUnits()) do
        if UnitExists(unit) then
            SetRaidTarget(unit, 0)
        end
    end
end

-- Core marking function: assigns configured markers to each role slot.
local function ApplyMarkers()
    if not IsInMidnightMythic() then return end
    if not IsPartyLeader() and not IsRaidOfficer() then return end

    ClearAllMarkers()

    local tanks, healers, dps = GetMembersOrderedByRole()

    -- Map role keys to their ordered unit lists and slot counts
    local roleMapping = {
        { units = tanks,   keys = { "TANK" } },
        { units = healers, keys = { "HEALER" } },
        { units = dps,     keys = { "DPS1", "DPS2", "DPS3" } },
    }

    for _, group in ipairs(roleMapping) do
        for slotIndex, roleKey in ipairs(group.keys) do
            local unit = group.units[slotIndex]
            if unit then
                local markerIndex = GroupAutoMarkerOptions.GetMarkerForRole(roleKey)
                if markerIndex ~= 0 then
                    SetRaidTarget(unit, markerIndex)
                end
            end
        end
    end
end

-- Event dispatcher
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            GroupAutoMarkerOptions.InitSavedVars()
            GroupAutoMarkerOptions.BuildPanel()
            self:UnregisterEvent("ADDON_LOADED")
        end

    elseif event == "GROUP_ROSTER_UPDATE"
        or event == "ZONE_CHANGED_NEW_AREA"
        or event == "PLAYER_ENTERING_WORLD"
    then
        if not isUpdatePending then
            isUpdatePending = true
            C_Timer.After(2, function()
                isUpdatePending = false
                ApplyMarkers()
            end)
        end
    end
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
