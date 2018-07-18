local E, L, V, P, G, _ =  unpack(ElvUI)
local EQXP = E:NewModule('QuestXP', 'AceEvent-3.0')

local addonName, addonTable = ...
local EP = LibStub("LibElvUIPlugin-1.0")

local questBar

--Default options
P["QuestXP"] = {
    ["IncludeComplete"] = false,
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
                name = "Include Completed Quests",
                get = function(info) return E.db.QuestXP.IncludeComplete end,
                set = function(info, val) E.db.QuestXP.IncludeComplete = val; EQXP:Refresh() end
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

function EQXP:Refresh()

end

function EQXP:Initialize()

    local bar = ElvUI_ExperienceBar
    questBar = CreateFrame('StatusBar', nil, bar)
    bar.questBar = questBar
    questBar:SetInside()
    questBar:SetStatusBarTexture(E.media.normTex)
    E:RegisterStatusBar(bar.questBar)

    local col = E.db.QuestXP.QuestXPColor
    questBar:SetStatusBarColor(col.r, col.g, col.b, col.a)
    questBar:SetMinMaxValues(0, UnitXPMax("player"))
    EQXP:Refresh()

    EP:RegisterPlugin(addonName, EQXP.InsertOptions)
end

E:RegisterModule(EQXP:GetName())