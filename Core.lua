-- GroupAutoMarker: Core.lua
-- Main auto-marking engine. Listens for group/zone events and applies markers.

local addonName = "GroupAutoMarker"

-- Event handler frame
local frame = CreateFrame("Frame", "GroupAutoMarkerFrame")

-- Returns true if the current instance is a Midnight Mythic dungeon.
local function IsInMidnightMythic()
    local _, instanceType, difficulty, _, _, _, _, instanceID = GetInstanceInfo()

    -- difficulty 8 = Mythic (5-player)
    if instanceType ~= "party" or difficulty ~= 8 then
        return false
    end

    return GroupAutoMarkerData.MidnightDungeons[instanceID] ~= nil
end

-- Returns an ordered list of group members sorted by role: Tank, Healer, DPS...
local function GetMembersOrderedByRole()
    local tanks, healers, dps = {}, {}, {}
    local numMembers = GetNumGroupMembers()

    for i = 1, numMembers do
        local unit = "party" .. i
        -- In a 5-man party, we are not included in the party units;
        -- check if we are in a raid group just in case.
        if IsInRaid() then
            unit = "raid" .. i
        end

        if UnitExists(unit) then
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

-- Clears all raid markers from party members.
local function ClearAllMarkers()
    local numMembers = GetNumGroupMembers()
    for i = 1, numMembers do
        local unit = IsInRaid() and ("raid" .. i) or ("party" .. i)
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
                local markerIndex = GroupAutoMarkerDB and GroupAutoMarkerDB[roleKey] or 0
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
        -- Small delay to let role assignments and instance data settle
        C_Timer.After(2, ApplyMarkers)
    end
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
