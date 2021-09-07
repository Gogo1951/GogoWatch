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
            GameTooltip:AddLine(string.format("%s %s", GogoWatch.Strings.PreMsgNonChat, GogoWatch.Strings.TeamMeberToolTip))
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
    local _, subevent, _, sourceGUID, sourceName, _, _, _, destName, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_CAST_SUCCESS" then
        local curSpell = GogoWatch.SpellIDs[spellID]
        if curSpell ~= nil then
            if curSpell.MaxLevel ~= 0 then
                local Strings = GogoWatch.Strings
                local castLevel, castString = nil, nil
                if curSpell.LevelBase == "Self" then
                    castLevel = UnitLevel("Player")
                    castString = Strings.SelfCast
                elseif curSpell.LevelBase == "Target" then
                    castLevel = UnitLevel(destName)
                    castString = Strings.TargetCast
                end
                local spellLink = GetSpellLink(spellID)
                local castStringMsg = nil
                if curSpell.MaxLevel < castLevel then
                    castStringMsg = string.format(castString, spellLink, spellID, castLevel)
                    castStringMsg = string.format("%s%s %s", Strings.PreMsgStandard, castStringMsg, Strings.PostMessage)
                end

                if castStringMsg ~= nil then
                    if sourceGUID == UnitGUID("Player") then
                        castStringMsg = string.format("%s %s", Strings.PreMsgNonChat, castStringMsg)
                        print(castStringMsg)
                    else
                        castStringMsg = string.format("%s %s", Strings.PreMsgChat, castStringMsg)
                        for i = 1,  4 do if sourceGUID == UnitGUID("Party" .. i) then SendChatMessage(castStringMsg, "WHISPER", nil, sourceName) break end end
                        for i = 1, 40 do if sourceGUID == UnitGUID( "Raid" .. i) then SendChatMessage(castStringMsg, "WHISPER", nil, sourceName) break end end
                    end
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