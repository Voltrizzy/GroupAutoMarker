-- GroupAutoMarker: Data.lua
-- Contains the list of Midnight expansion Mythic dungeon map IDs.
-- These are placeholder names/IDs until official data is available.

GroupAutoMarkerData = {}

-- Instance map IDs for Midnight expansion dungeons, as returned by GetInstanceInfo().
-- IDs sourced from Wowhead dungeon guide (patch 12.0.0).
GroupAutoMarkerData.MidnightDungeons = {
    [15808] = "Windrunner Spire",
    [15829] = "Magister's Terrace",
    [16091] = "Murder Row",
    [16359] = "The Blinding Vale",
    [16368] = "Den of Nalorakk",
    [16395] = "Maisara Caverns",
    [16425] = "Voidscar Arena",
    [16573] = "Nexus Point Xenas",
}

-- Raid marker data: index matches {RAW_ICON, name, texture}
GroupAutoMarkerData.Markers = {
    { index = 0, name = "No Marker",   texture = nil },
    { index = 1, name = "Star",        texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1" },
    { index = 2, name = "Circle",      texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2" },
    { index = 3, name = "Diamond",     texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3" },
    { index = 4, name = "Triangle",    texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4" },
    { index = 5, name = "Moon",        texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5" },
    { index = 6, name = "Square",      texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6" },
    { index = 7, name = "Cross",       texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7" },
    { index = 8, name = "Skull",       texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8" },
}

-- Role definitions used by the addon
GroupAutoMarkerData.Roles = {
    { key = "TANK",   label = "Tank",   defaultMarker = 6 }, -- Square
    { key = "HEALER", label = "Healer", defaultMarker = 0 }, -- No Marker
    { key = "DPS1",   label = "DPS 1",  defaultMarker = 0 }, -- No Marker
    { key = "DPS2",   label = "DPS 2",  defaultMarker = 0 }, -- No Marker
    { key = "DPS3",   label = "DPS 3",  defaultMarker = 0 }, -- No Marker
}
