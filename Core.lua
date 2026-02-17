--[[
================================================================================
Dirty Tricks - Core Module
================================================================================
Description:
    Automatically creates and manages macros for Tricks of the Trade (Rogue)
    and Misdirection (Hunter) that dynamically target your group's tank.
    
    Updates in real-time as group composition changes, ensuring your redirect
    abilities always go to the right tank with zero manual intervention.

Author: PorterFC85
Version: 1.1.0
Date: February 16, 2026

================================================================================
All Rights Reserved

Copyright (c) 2026 PorterFC85

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
================================================================================
--]]

local ADDON_NAME = ...
local Addon = CreateFrame("Frame")

-- Simple class-check: only load behavior for Rogue or Hunter
local _, playerClass = UnitClass("player")
if playerClass ~= "ROGUE" and playerClass ~= "HUNTER" then
  -- keep saved vars but do not initialize behavior
  return
end

-- Ensure saved vars
if not SARDB then SARDB = { enabled = true, preferredTankName = nil } end

-- Track the last selected tank to avoid printing the message on every update
local lastSelectedTank = nil

-- Class color information
local CLASS_COLORS = {
  DEATHKNIGHT = { r = 0.77, g = 0.12, b = 0.23 },
  DEMONHUNTER = { r = 0.64, g = 0.19, b = 0.79 },
  DRUID = { r = 1.00, g = 0.49, b = 0.04 },
  EVOKER = { r = 0.33, g = 0.59, b = 0.33 },
  HUNTER = { r = 0.67, g = 0.83, b = 0.45 },
  MAGE = { r = 0.41, g = 0.80, b = 0.94 },
  MONK = { r = 0.00, g = 1.00, b = 0.59 },
  PALADIN = { r = 0.96, g = 0.55, b = 0.73 },
  PRIEST = { r = 1.00, g = 1.00, b = 1.00 },
  ROGUE = { r = 1.00, g = 0.96, b = 0.41 },
  SHAMAN = { r = 0.14, g = 0.35, b = 1.00 },
  WARLOCK = { r = 0.53, g = 0.53, b = 0.93 },
  WARRIOR = { r = 0.78, g = 0.61, b = 0.43 }
}

-- Get WoW format for colored text
local function ColorizeText(text, r, g, b)
  return string.format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, text)
end

-- Get class color for a unit
local function GetClassColorForUnit(unitId)
  if not UnitExists(unitId) then return { r = 1, g = 1, b = 1 } end
  local _, class = UnitClass(unitId)
  return CLASS_COLORS[class] or { r = 1, g = 1, b = 1 }
end

-- Colors for addon messages
local ADDON_COLOR = { r = 0.3, g = 0.8, b = 0.3 } -- Green
local PROFILE_COLOR = { r = 0.8, g = 0.8, b = 0.3 } -- Yellow
local STATUS_COLOR = { r = 0.7, g = 0.7, b = 1 } -- Light blue

-- Macro configuration
local MACRO_SPELLS = { "Tricks of the Trade", "Misdirection" }
local MACRO_PREFIX = "Dirty "
local MACRO_TEMPLATE = "#showtooltip %s\n/cast "
local MACRO_TARGET_TEMPLATE = "[@%s,help,nodead]"
local MACRO_PET_TARGET_TEMPLATE = "[@pet]" -- Simpler conditional for pet targeting

-- Find all tanks in current group (returns table of {name, unitId})
local function FindTanks()
  local tanks = {}
  
  -- Determine group type
  local groupType = (IsInRaid() and "raid") or (IsInGroup() and "party") or nil
  if not groupType then return tanks end
  
  -- Search for up to 2 tanks
  for i = 1, GetNumGroupMembers() do
    local unitId = groupType .. i
    if UnitExists(unitId) and UnitGroupRolesAssigned(unitId) == "TANK" and not UnitIsDead(unitId) then
      local name = UnitName(unitId)
      if name and name ~= "" then
        table.insert(tanks, {
          name = name,
          unitId = unitId
        })
        if #tanks >= 2 then break end
      end
    end
  end
  
  return tanks
end

-- Find first available tank or pet
local function FindPrimaryTank()
  local tanks = FindTanks()
  if #tanks > 0 then
    return tanks[1].unitId
  end
  
  -- If hunter solo with pet
  if playerClass == "HUNTER" and not IsInGroup() then
    if UnitExists("pet") and not UnitIsDead("pet") then
      return "pet"
    end
  end
  
  return nil
end

-- Get current profile type string
local function GetProfileTypeString()
  if IsInRaid() then
    return "Raid"
  elseif IsInGroup() then
    return "Party"
  else
    -- Solo: check if hunter with pet
    if playerClass == "HUNTER" and UnitExists("pet") and not UnitIsDead("pet") then
      return "Solo with pet"
    end
    return "Solo"
  end
end

-- Create or update macros
function UpdateMacros(shouldPrintMessage)
  local tanks = FindTanks()
  local profileType = GetProfileTypeString()
  
  -- Determine the current tank selection
  local currentSelectedTank = SARDB.preferredTankName
  if not currentSelectedTank and #tanks > 0 then
    currentSelectedTank = tanks[1].name
  end
  
  -- Special case: solo hunter with pet
  if not currentSelectedTank and playerClass == "HUNTER" and not IsInGroup() then
    if UnitExists("pet") and not UnitIsDead("pet") then
      currentSelectedTank = "pet"
    end
  end
  
  -- Only print messages if explicitly requested or if the selection changed
  local shouldPrintOutput = shouldPrintMessage or (lastSelectedTank ~= currentSelectedTank)
  
  if shouldPrintOutput and currentSelectedTank then
    -- Show which tank is selected
    if SARDB.preferredTankName then
      -- User has set a preferred tank
      local msg = ColorizeText("[Dirty Tricks]", ADDON_COLOR.r, ADDON_COLOR.g, ADDON_COLOR.b) .. " " ..
                  ColorizeText(playerClass .. " - " .. profileType, PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b) .. " | " ..
                  ColorizeText("Redirecting to:", STATUS_COLOR.r, STATUS_COLOR.g, STATUS_COLOR.b) .. " " ..
                  ColorizeText(SARDB.preferredTankName, 1, 1, 0.8)
      print(msg)
    elseif #tanks > 0 then
      -- Auto-detected tanks
      local tankNames = {}
      for _, tank in ipairs(tanks) do
        if tank and tank.name and tank.unitId then
          local color = GetClassColorForUnit(tank.unitId)
          table.insert(tankNames, ColorizeText(tank.name, color.r, color.g, color.b))
        end
      end
      if #tankNames > 0 then
        local msg = ColorizeText("[Dirty Tricks]", ADDON_COLOR.r, ADDON_COLOR.g, ADDON_COLOR.b) .. " " ..
                    ColorizeText(playerClass .. " - " .. profileType, PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b) .. " | " ..
                    ColorizeText("Redirecting to:", STATUS_COLOR.r, STATUS_COLOR.g, STATUS_COLOR.b) .. " " .. table.concat(tankNames, ", ")
        print(msg)
      end
    elseif currentSelectedTank == "pet" then
      -- Solo hunter with pet
      local msg = ColorizeText("[Dirty Tricks]", ADDON_COLOR.r, ADDON_COLOR.g, ADDON_COLOR.b) .. " " ..
                  ColorizeText(playerClass .. " - " .. profileType, PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b) .. " | " ..
                  ColorizeText("Redirecting to:", STATUS_COLOR.r, STATUS_COLOR.g, STATUS_COLOR.b) .. " " ..
                  ColorizeText("Pet", 1, 1, 0.8)
      print(msg)
    end
    
    -- Update the last selected tank
    lastSelectedTank = currentSelectedTank
  end
  
  for _, spellName in ipairs(MACRO_SPELLS) do
    -- Use modern API for current WoW version
    local spellInfo = C_Spell.GetSpellInfo(spellName)
    
    if spellInfo then
      local icon = spellInfo.iconID
      
      -- Build macro name
      local macroName = MACRO_PREFIX .. spellName
      
      -- Build macro body with conditional targeting
      local body = string.format(MACRO_TEMPLATE, spellName)

      -- Special-case: Hunter solo should target pet for Misdirection
      if spellName == "Misdirection" and playerClass == "HUNTER" and not IsInGroup() then
        if UnitExists("pet") and not UnitIsDead("pet") then
          body = body .. MACRO_PET_TARGET_TEMPLATE
        end
      else
        -- If preferred tank is set, use that instead of auto-detection
        if SARDB.preferredTankName then
          body = body .. string.format(MACRO_TARGET_TEMPLATE, SARDB.preferredTankName)
        else
          -- Add tank targets from auto-detection
          for _, tank in ipairs(tanks) do
            if tank and tank.unitId then
              body = body .. string.format(MACRO_TARGET_TEMPLATE, tank.unitId)
            end
          end
        end
      end

      -- Add player as fallback
      body = body .. string.format(MACRO_TARGET_TEMPLATE, "player")
      
      -- Complete the macro
      body = body .. " " .. spellName
      
      -- Get existing macro
      local existingMacro, _, existingBody = GetMacroInfo(macroName)
      
      -- Trim whitespace for comparison
      if existingBody then
        existingBody = existingBody:gsub("^%s+|^%s+$", "")
      end
      
      -- Create or update the macro - ONLY print on actual changes
      if not existingMacro then
        CreateMacro(macroName, icon, body)
        local msg = ColorizeText("[Dirty Tricks]", ADDON_COLOR.r, ADDON_COLOR.g, ADDON_COLOR.b) .. " " ..
                    ColorizeText("Created macro:", STATUS_COLOR.r, STATUS_COLOR.g, STATUS_COLOR.b) .. " " ..
                    macroName .. " " .. ColorizeText("(" .. profileType .. ")", PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b)
        print(msg)
      elseif existingBody ~= body then
        EditMacro(macroName, macroName, icon, body)
        local msg = ColorizeText("[Dirty Tricks]", ADDON_COLOR.r, ADDON_COLOR.g, ADDON_COLOR.b) .. " " ..
                    ColorizeText("Macro updated:", STATUS_COLOR.r, STATUS_COLOR.g, STATUS_COLOR.b) .. " " ..
                    macroName .. " " .. ColorizeText("(" .. profileType .. ")", PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b)
        print(msg)
      end
    end
  end
end

-- Event frame for group changes
Addon:RegisterEvent("GROUP_JOINED")
Addon:RegisterEvent("GROUP_ROSTER_UPDATE")
Addon:RegisterEvent("PLAYER_ENTERING_WORLD")
Addon:SetScript("OnEvent", function(self, event, ...)
  if SARDB.enabled then
    UpdateMacros()
  end
end)

-- Slash commands
SLASH_SAR1 = "/sar"
SlashCmdList["SAR"] = function(msg)
  local cmd, rest = msg:match("^(%S*)%s*(.-)$")
  local profileType = GetProfileTypeString()
  
  -- If no command given, open settings dialog
  if cmd == "" then
    if DirtyTricksSettingsDialog then
      if DirtyTricksSettingsDialog:IsShown() then
        DirtyTricksSettingsDialog:Hide()
      else
        DirtyTricksSettingsDialog:Show()
      end
    end
    return
  end
  
  if cmd == "toggle" then
    SARDB.enabled = not SARDB.enabled
    local status = SARDB.enabled and ColorizeText("Enabled", 0.3, 0.8, 0.3) or ColorizeText("Disabled", 1, 0.3, 0.3)
    print(ColorizeText("[Dirty Tricks]", ADDON_COLOR.r, ADDON_COLOR.g, ADDON_COLOR.b) .. " Addon " .. status)
    if SARDB.enabled then UpdateMacros(true) end
  elseif cmd == "settank" and rest ~= "" then
    SARDB.preferredTankName = rest:trim()
    local msg = ColorizeText("[Dirty Tricks]", ADDON_COLOR.r, ADDON_COLOR.g, ADDON_COLOR.b) .. " " ..
                ColorizeText(playerClass .. " - " .. profileType, PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b) .. " | " ..
                ColorizeText("Preferred tank set to:", STATUS_COLOR.r, STATUS_COLOR.g, STATUS_COLOR.b) .. " " ..
                ColorizeText(SARDB.preferredTankName, 1, 1, 0.8)
    print(msg)
    UpdateMacros(true)
  elseif cmd == "cleartank" then
    SARDB.preferredTankName = nil
    local msg = ColorizeText("[Dirty Tricks]", ADDON_COLOR.r, ADDON_COLOR.g, ADDON_COLOR.b) .. " " ..
                ColorizeText(playerClass .. " - " .. profileType, PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b) .. " | " ..
                ColorizeText("Using auto-detection", STATUS_COLOR.r, STATUS_COLOR.g, STATUS_COLOR.b)
    print(msg)
    UpdateMacros(true)
  elseif cmd == "help" then
    print(ColorizeText("[Dirty Tricks]", ADDON_COLOR.r, ADDON_COLOR.g, ADDON_COLOR.b) .. " Auto Redirect commands:")
    print(ColorizeText("  /sar", PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b) .. " - Open/close settings popup")
    print(ColorizeText("  /sar toggle", PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b) .. " - Toggle addon on/off")
    print(ColorizeText("  /sar settank <name>", PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b) .. " - Set preferred tank/player")
    print(ColorizeText("  /sar cleartank", PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b) .. " - Clear preferred tank")
    print(ColorizeText("  /sar help", PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b) .. " - Show this message")
  else
    print(ColorizeText("[Dirty Tricks]", ADDON_COLOR.r, ADDON_COLOR.g, ADDON_COLOR.b) .. " Use " .. ColorizeText("/sar help", PROFILE_COLOR.r, PROFILE_COLOR.g, PROFILE_COLOR.b) .. " for commands")
  end
end

-- Initialize on load
UpdateMacros()
