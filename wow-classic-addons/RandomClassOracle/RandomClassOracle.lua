local ADDON_NAME = ...

local ALLIANCE_CLASSES = {
    { token = "WARRIOR", name = "Warrior" },
    { token = "PALADIN", name = "Paladin" },
    { token = "HUNTER", name = "Hunter" },
    { token = "ROGUE", name = "Rogue" },
    { token = "PRIEST", name = "Priest" },
    { token = "MAGE", name = "Mage" },
    { token = "WARLOCK", name = "Warlock" },
    { token = "DRUID", name = "Druid" },
}

local HORDE_CLASSES = {
    { token = "WARRIOR", name = "Warrior" },
    { token = "SHAMAN", name = "Shaman" },
    { token = "HUNTER", name = "Hunter" },
    { token = "ROGUE", name = "Rogue" },
    { token = "PRIEST", name = "Priest" },
    { token = "MAGE", name = "Mage" },
    { token = "WARLOCK", name = "Warlock" },
    { token = "DRUID", name = "Druid" },
}

local POPUP_TEXT_LEVEL = "You leveled up and are now rested. Roll the dice and try another class for a level or two?"
local POPUP_TEXT_DEATH = "Oh noes! Anyway, roll the dice?"

local DEFAULT_DB = {
    pendingLevelUp = false,
    pendingReason = nil,
    pendingLevel = nil,
    recentPicks = {},
    soundEnabled = true,
}

local CLASS_NAME_TO_TOKEN = {
    Warrior = "WARRIOR",
    Paladin = "PALADIN",
    Hunter = "HUNTER",
    Rogue = "ROGUE",
    Priest = "PRIEST",
    Shaman = "SHAMAN",
    Mage = "MAGE",
    Warlock = "WARLOCK",
    Druid = "DRUID",
}

local diceFrame
local resultText
local ShowResult
local activePromptReason
local activePromptAllowOutsideRested
local activePromptExcludeCurrentClass
local activePromptIsPreview

local function CopyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = {}
                CopyDefaults(target[key], value)
            else
                target[key] = value
            end
        end
    end
end

local function NormalizeRecentPicks()
    for index, recentPick in ipairs(RandomClassOracleDB.recentPicks) do
        RandomClassOracleDB.recentPicks[index] = CLASS_NAME_TO_TOKEN[recentPick] or recentPick
    end
end

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100Class Dice:|r " .. message)
end

local function IsInRestArea()
    return IsResting() == true
end

local function GetRestStateText()
    if not GetRestState then
        return "unknown"
    end

    local restState = GetRestState()

    if restState == 1 then
        return "Rested"
    end

    if restState == 2 then
        return "Normal"
    end

    return "Unknown"
end

local function PrintStatus()
    Print("Pending level-up: " .. tostring(RandomClassOracleDB.pendingLevelUp))
    Print("Pending reason: " .. tostring(RandomClassOracleDB.pendingReason))
    Print("Pending level: " .. tostring(RandomClassOracleDB.pendingLevel))
    Print("Resting area: " .. tostring(IsInRestArea()))
    Print("Rest state: " .. GetRestStateText())
    Print("Location: " .. tostring(GetZoneText()) .. " / " .. tostring(GetSubZoneText()))
end

local function PlayDiceSound()
    if not RandomClassOracleDB.soundEnabled or not SOUNDKIT then
        return
    end

    local sound = SOUNDKIT.READY_CHECK or SOUNDKIT.IG_QUEST_LIST_OPEN or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON

    if sound then
        PlaySound(sound)
    end
end

local function CreateDiceFrame()
    if diceFrame then
        return diceFrame
    end

    diceFrame = CreateFrame("Frame", "RandomClassDiceFrame", UIParent, "BasicFrameTemplateWithInset")
    diceFrame:SetSize(320, 170)
    diceFrame:SetPoint("CENTER")
    diceFrame:SetMovable(true)
    diceFrame:EnableMouse(true)
    diceFrame:RegisterForDrag("LeftButton")
    diceFrame:SetScript("OnDragStart", diceFrame.StartMoving)
    diceFrame:SetScript("OnDragStop", diceFrame.StopMovingOrSizing)
    diceFrame:Hide()

    diceFrame.title = diceFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    diceFrame.title:SetPoint("TOPLEFT", 14, -8)
    diceFrame.title:SetText("Random Class Dice")

    local intro = diceFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    intro:SetPoint("TOP", 0, -48)
    intro:SetText("The dice say:")

    resultText = diceFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    resultText:SetPoint("TOP", intro, "BOTTOM", 0, -14)
    resultText:SetText("-")

    local closeButton = CreateFrame("Button", nil, diceFrame, "UIPanelButtonTemplate")
    closeButton:SetSize(96, 24)
    closeButton:SetPoint("BOTTOM", 0, 16)
    closeButton:SetText("Close")
    closeButton:SetScript("OnClick", function()
        diceFrame:Hide()
    end)

    return diceFrame
end

local function GetClassPool()
    local faction = UnitFactionGroup("player")

    if faction == "Alliance" then
        return ALLIANCE_CLASSES
    end

    if faction == "Horde" then
        return HORDE_CLASSES
    end

    return {}
end

local function HasRecentPick(classToken)
    for _, recentPick in ipairs(RandomClassOracleDB.recentPicks) do
        if recentPick == classToken then
            return true
        end
    end

    return false
end

local function PickClass(excludeCurrentClass)
    local classes = GetClassPool()
    local available = {}
    local _, currentClassToken = UnitClass("player")

    for _, classInfo in ipairs(classes) do
        local isCurrentClass = excludeCurrentClass and classInfo.token == currentClassToken

        if not isCurrentClass and not HasRecentPick(classInfo.token) then
            table.insert(available, classInfo)
        end
    end

    if #available == 0 then
        wipe(RandomClassOracleDB.recentPicks)

        for _, classInfo in ipairs(classes) do
            if not (excludeCurrentClass and classInfo.token == currentClassToken) then
                table.insert(available, classInfo)
            end
        end
    end

    if #available == 0 then
        return nil
    end

    local choice = available[math.random(#available)]
    table.insert(RandomClassOracleDB.recentPicks, choice.token)
    return choice.name
end

ShowResult = function(allowOutsideRested, excludeCurrentClass)
    if not allowOutsideRested and not IsInRestArea() then
        Print("You need to be in a rested area to roll the dice.")
        return false
    end

    local className = PickClass(excludeCurrentClass)

    if not className then
        Print("I could not find a class pool for this character.")
        return false
    end

    CreateDiceFrame()
    resultText:SetText(className)
    diceFrame:Show()

    PlayDiceSound()
    Print("The dice say: |cffffffff" .. className .. "|r")
    return true
end

local function ClearPendingState()
    if activePromptIsPreview then
        return
    end

    RandomClassOracleDB.pendingLevelUp = false
    RandomClassOracleDB.pendingReason = nil
    RandomClassOracleDB.pendingLevel = nil
end

local function ClearActivePrompt()
    activePromptReason = nil
    activePromptAllowOutsideRested = nil
    activePromptExcludeCurrentClass = nil
    activePromptIsPreview = nil
end

StaticPopupDialogs["RANDOM_CLASS_DICE_ROLL"] = {
    text = "Roll the dice and try another class for a level or two?",
    button1 = "Roll",
    button2 = "Not now",
    OnAccept = function()
        local pickedClass = ShowResult(activePromptAllowOutsideRested, activePromptExcludeCurrentClass)

        if pickedClass then
            ClearPendingState()
            ClearActivePrompt()
        else
            ClearActivePrompt()
        end
    end,
    OnCancel = function()
        ClearPendingState()
        ClearActivePrompt()
        Print("Roll skipped.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function ShowRollPrompt(reason)
    activePromptReason = reason
    activePromptAllowOutsideRested = reason == "death"
    activePromptExcludeCurrentClass = reason == "death"
    activePromptIsPreview = false

    if reason == "death" then
        StaticPopupDialogs["RANDOM_CLASS_DICE_ROLL"].text = POPUP_TEXT_DEATH
    else
        StaticPopupDialogs["RANDOM_CLASS_DICE_ROLL"].text = POPUP_TEXT_LEVEL
    end

    StaticPopup_Show("RANDOM_CLASS_DICE_ROLL")
end

local function PreviewRollPrompt(reason)
    activePromptReason = reason
    activePromptAllowOutsideRested = true
    activePromptExcludeCurrentClass = reason == "death"
    activePromptIsPreview = true

    if reason == "death" then
        StaticPopupDialogs["RANDOM_CLASS_DICE_ROLL"].text = POPUP_TEXT_DEATH
    else
        StaticPopupDialogs["RANDOM_CLASS_DICE_ROLL"].text = POPUP_TEXT_LEVEL
    end

    StaticPopup_Show("RANDOM_CLASS_DICE_ROLL")
end

local function MaybeShowLevelRollPrompt()
    if RandomClassOracleDB.pendingReason ~= "level" then
        return
    end

    if StaticPopup_Visible and StaticPopup_Visible("RANDOM_CLASS_DICE_ROLL") then
        return
    end

    if not IsInRestArea() then
        return
    end

    ShowRollPrompt("level")
end

local function QueueRestedCheck()
    C_Timer.After(0.5, MaybeShowLevelRollPrompt)
end

local events = CreateFrame("Frame")

events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("PLAYER_DEAD")
events:RegisterEvent("PLAYER_UPDATE_RESTING")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("ZONE_CHANGED")
events:RegisterEvent("ZONE_CHANGED_INDOORS")

events:SetScript("OnEvent", function(_, event, loadedAddonName, newLevel)
    if event == "ADDON_LOADED" and loadedAddonName == ADDON_NAME then
        RandomClassOracleDB = RandomClassOracleDB or {}
        CopyDefaults(RandomClassOracleDB, DEFAULT_DB)

        if RandomClassOracleDB.pendingLevelUp and not RandomClassOracleDB.pendingReason then
            RandomClassOracleDB.pendingReason = "level"
        end

        NormalizeRecentPicks()
        return
    end

    if event == "PLAYER_LEVEL_UP" then
        RandomClassOracleDB.pendingLevelUp = true
        RandomClassOracleDB.pendingReason = "level"
        RandomClassOracleDB.pendingLevel = newLevel or UnitLevel("player")
        QueueRestedCheck()
        return
    end

    if event == "PLAYER_DEAD" then
        RandomClassOracleDB.pendingLevelUp = false
        RandomClassOracleDB.pendingReason = "death"
        RandomClassOracleDB.pendingLevel = nil
        ShowRollPrompt("death")
        return
    end

    if event == "PLAYER_ENTERING_WORLD" and RandomClassOracleDB.pendingReason == "death" then
        ShowRollPrompt("death")
        return
    end

    if event == "PLAYER_UPDATE_RESTING"
        or event == "PLAYER_ENTERING_WORLD"
        or event == "ZONE_CHANGED"
        or event == "ZONE_CHANGED_INDOORS"
    then
        QueueRestedCheck()
    end
end)

SLASH_RANDOMCLASSDICE1 = "/rcd"
SLASH_RANDOMCLASSDICE2 = "/randomclassdice"

SlashCmdList["RANDOMCLASSDICE"] = function(message)
    message = string.lower(strtrim(message or ""))

    if message == "roll" then
        ShowResult()
        return
    end

    if message == "show" then
        CreateDiceFrame()
        diceFrame:Show()
        return
    end

    if message == "status" then
        PrintStatus()
        return
    end

    if message == "testding" then
        PreviewRollPrompt("level")
        return
    end

    if message == "testdeath" then
        PreviewRollPrompt("death")
        return
    end

    if message == "sound" then
        RandomClassOracleDB.soundEnabled = not RandomClassOracleDB.soundEnabled
        Print("Sound enabled: " .. tostring(RandomClassOracleDB.soundEnabled))
        return
    end

    if message == "reset" then
        wipe(RandomClassOracleDB.recentPicks)
        RandomClassOracleDB.pendingLevelUp = false
        RandomClassOracleDB.pendingReason = nil
        RandomClassOracleDB.pendingLevel = nil
        Print("History and pending level-up state reset.")
        return
    end

    Print("Commands: /rcd roll, /rcd testding, /rcd testdeath, /rcd show, /rcd status, /rcd sound, /rcd reset")
end
