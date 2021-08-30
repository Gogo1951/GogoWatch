if GogoWatch == nil then GogoWatch = {} end
GogoWatch.Events = {}

local EventFrame = nil

local addonLoaded, variablesLoaded = false, false

function GogoWatch:OnLoad()
    EventFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    EventFrame:RegisterEvent("VARIABLES_LOADED")
    EventFrame:RegisterEvent("ADDON_LOADED")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:SetScript("OnEvent", function(...) GogoWatch:OnEvent(...) end)

    GameTooltip:HookScript("OnTooltipSetUnit", function(...)
        local curMouseOver = UnitGUID("MouseOver")
        if GogoWatch.Devs[curMouseOver] == true then
            GameTooltip:AddLine(GogoWatch.Strings.TeamMeberToolTip)
        end
    end)
end

function GogoWatch:OnEvent(self, event, ...)
    if event == "VARIABLES_LOADED" then
        GogoWatch.Events:VariablesLoaded(...)
    elseif event == "ADDON_LOADED" then
        GogoWatch.Events:AddonLoaded(...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        GogoWatch.Events:CombatLogEventUnfiltered(...)
    end
end

function GogoWatch.Events:CombatLogEventUnfiltered(...)
    local _, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool = CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_CAST_SUCCESS" and sourceGUID == UnitGUID("Player") then
        local curSpell = GogoWatch.SpellIDs[spellID]
        local Strings = GogoWatch.Strings
        if curSpell == nil then
            print(string.format(Strings.tempDevCastString, spellName, spellID))
        else
            local curRank = curSpell.Rank
            local sourceLevel = UnitLevel("Player")
            if curSpell.LevelBase == "Self" then
                if curSpell.MaxLevel < sourceLevel and curSpell.MaxLevel ~= 0 then
                    print(string.format(Strings.YouCastedSelf, curRank, spellName, spellID, sourceLevel, Strings.UseHigher))
                end
            elseif curSpell.LevelBase == "Target" then
                local destLevel = UnitLevel(destName)
                if destLevel ~= 0 and curSpell.MaxLevel < destLevel and curSpell.MaxLevel ~= 0 then
                    print(string.format(Strings.YouCastedSelf, curRank, spellName, spellID, destLevel, Strings.YouCastedTarget))
                end
            end
        end
    end
end

function GogoWatch.Events:VarsAndAddonLoaded()

end

function GogoWatch.Events:AddonLoaded(...)
    local addonName = ...
    if addonName == "GogoWatch" then
        if variablesLoaded == true then GogoWatch.Events:VarsAndAddonLoaded() else addonLoaded = true end
    end
end

function GogoWatch.Events:VariablesLoaded(...)
    if addonLoaded == true then GogoWatch.Events:VarsAndAddonLoaded() else variablesLoaded = true end
end

GogoWatch:OnLoad()