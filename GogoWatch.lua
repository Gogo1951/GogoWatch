if GGWTest == nil then GGWTest = {} end
GGWTest.Events = {}

local EventFrame = nil

local addonLoaded, variablesLoaded = false, false

function GGWTest:OnLoad()
    EventFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    EventFrame:RegisterEvent("VARIABLES_LOADED")
    EventFrame:RegisterEvent("ADDON_LOADED")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:SetScript("OnEvent", function(...) GGWTest:OnEvent(...) end)
end

function GGWTest:OnEvent(self, event, ...)
    if event == "VARIABLES_LOADED" then
        GGWTest.Events:VariablesLoaded(...)
    elseif event == "ADDON_LOADED" then
        GGWTest.Events:AddonLoaded(...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        GGWTest.Events:CombatLogEventUnfiltered(...)
    end
end

function GGWTest.Events:CombatLogEventUnfiltered(...)
    local _, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool = CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_CAST_SUCCESS" and sourceGUID == UnitGUID("Player") then
        local curSpell = GGWTest.SpellIDs[spellID]
        local Strings = GGWTest.Strings
        if curSpell == nil then
            print(string.format(Strings.tempDevCastString, spellName, spellID))
        else
            local curRank = curSpell.Rank
            local sourceLevel = UnitLevel("Player")
            if curSpell.LevelBase == "Self" then
                if curSpell.MaxLevel < sourceLevel and curSpell.MaxLevel ~= 0 then
                    print(string.format(Strings.YouCastedSelf, Strings.UseHigher, curRank, spellName, spellID, sourceLevel))
                end
            elseif curSpell.LevelBase == "Target" then
                local destLevel = UnitLevel(destName)
                if destLevel ~= 0 and curSpell.MaxLevel < destLevel and curSpell.MaxLevel ~= 0 then
                    print(string.format(Strings.YouCastedSelf, Strings.YouCastedTarget, curRank, spellName, spellID, destLevel))
                end
            end
        end
    end
end

function GGWTest.Events:VarsAndAddonLoaded()

end

function GGWTest.Events:AddonLoaded(...)
    local addonName = ...
    if addonName == "GogoWatch" then
        if variablesLoaded == true then GGWTest.Events:VarsAndAddonLoaded() else addonLoaded = true end
    end
end

function GGWTest.Events:VariablesLoaded(...)
    if addonLoaded == true then GGWTest.Events:VarsAndAddonLoaded() else variablesLoaded = true end
end

GGWTest:OnLoad()