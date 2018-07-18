local E, L, V, P, G, _ =  unpack(ElvUI)
local EQXP = E:NewModule('QuestXP', 'AceEvent-3.0')

local addonName, addonTable = ...
local EP = LibStub("LibElvUIPlugin-1.0")

local questBar

--Default options
P["QuestXP"] = {
    ["IncludeIncomplete"] = false,
    ["CurrentZoneOnly"] = false,
    ["QuestXPColor"] = {r = 217/255,g = 217/255,b = 0}
}

function EQXP:InsertOptions()
    E.Options.args.databars.args.experience.args.questXP = {
        order = 100,
        type = "group",
        name = "Quest XP",
        guiInline = true,
        args = {
            QuestXPColor = {
                order = 1,
                type = "color",
                name = "Quest XP Color",
                get = function(info)
                    local t = E.db.QuestXP.QuestXPColor
                    return t.r, t.g, t.b, t.a, 102/255, 136/255, 255/255, 1
                end,
                set = function(info, r, g, b, a)
                     local t = E.db.QuestXP.QuestXPColor
                     t.r, t.g, t.b, t.a = r, g, b, a
                     EQXP:Refresh()
                end
            },
            IncludeComplete = {
                order = 2,
                type = "toggle",
                name = "Include Incomplete Quests",
                get = function(info) return E.db.QuestXP.IncludeIncomplete end,
                set = function(info, val) E.db.QuestXP.IncludeIncomplete = val; EQXP:Refresh() end
            },
            CurrentZoneOnly = {
                order = 3,
                type = "toggle",
                name = "Current Zone Quests Only",
                get = function(info) return E.db.QuestXP.CurrentZoneOnly end,
                set = function(info, val) E.db.QuestXP.CurrentZoneOnly = val; EQXP:Refresh() end
            },
        }
    }
end

function EQXP:Refresh(event)

    local col = E.db.QuestXP.QuestXPColor
    questBar:SetStatusBarColor(col.r, col.g, col.b, col.a)
    questBar:SetMinMaxValues(0, UnitXPMax("player"))

    local mapID = C_Map.GetBestMapForUnit("player")
    local zoneName = C_Map.GetMapInfo(mapID).name

    local currentXP = UnitXP("player")

    local i = 1
	local lastHeader
    local currentQuestXPTotal = 0
    while GetQuestLogTitle(i) do
      local questLogTitleText, level, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(i)
        if (not isHeader) then
            local incompleteCheck = true
            local zoneCheck = true

            if (not E.db.QuestXP.IncludeIncomplete) then
                if not isComplete then
                    incompleteCheck = false                    
                end
            else

            end

            if E.db.QuestXP.CurrentZoneOnly then
                if lastHeader ~= zoneName then
                    zoneCheck = false
                end
            end

            if incompleteCheck and zoneCheck then
                currentQuestXPTotal = currentQuestXPTotal + GetQuestLogRewardXP(questID)
            end
        else
            lastHeader = questLogTitleText
      end
      i = i + 1
    end

    questBar:SetValue(min(currentXP + currentQuestXPTotal, UnitXPMax("player")))
end

function EQXP:Initialize()

    local bar = ElvUI_ExperienceBar
    questBar = CreateFrame('StatusBar', nil, bar)
    bar.questBar = questBar
    questBar:SetInside()
    questBar:SetStatusBarTexture(E.media.normTex)
    E:RegisterStatusBar(bar.questBar)

    questBar:SetOrientation(E.db.databars.experience.orientation)
    questBar:SetReverseFill(E.db.databars.experience.reverseFill)

    questBar.eventFrame = CreateFrame("Frame")
    questBar.eventFrame:Hide()
    
    questBar.eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
    questBar.eventFrame:RegisterEvent("PLAYER_XP_UPDATE")
    questBar.eventFrame:RegisterEvent("ZONE_CHANGED")
    questBar.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    questBar.eventFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    questBar.eventFrame:SetScript("OnEvent", function(self, event) EQXP:Refresh(event) end)

    EQXP:Refresh()

    EP:RegisterPlugin(addonName, EQXP.InsertOptions)
end

E:RegisterModule(EQXP:GetName())