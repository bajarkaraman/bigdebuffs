-- Party Sorting Script
-- This script sorts the party frames to display the player at the bottom, followed by party members in reverse order.

---------------------------------------------------------------------------
-- SET YOUR OPTIONS HERE

-- Use fixed list
local useFixedList = false

---------------------------------------------------------------------------
-- END OF OPTIONS
---------------------------------------------------------------------------

-- MARK: Variables
---------------------------------------------------------------------------
-- Functions
local F = Cell.funcs
local shouldSort, handleQueuedUpdate, addUpdateToQueue, cancelQueuedUpdate
local PartyFrame_UpdateLayout, updateAttributes
local Print, DevAdd
-- Vars
local playerName = GetUnitName("player", true) -- Get player name with realm
local debug = false
local updateIsQueued, queuedUpdate
local init = true
local lastInstanceType, lastGroupType

-- MARK: Sorting functions
-------------------------------------------------------

---@return table<string>|false
local function indexSort()
    local units = {}
    for unit in F:IterateGroupMembers() do
        local name = GetUnitName(unit, true) -- Get unit name with realm

        if unit ~= "player" and name ~= playerName then
            tinsert(units, 1, unit) -- Insert at the beginning for reverse order
        end
    end

    -- Insert player at the end
    tinsert(units, "player")

    DevAdd(units, "indexSort units")
    if #units == 0 then return false end

    return units
end

local function sortPartyFrames()
    if not shouldSort() then return end

    if init then
        init = false
        addUpdateToQueue()
        return
    end

    local nameList = indexSort()
    if not nameList then
        Print("Found no players in party.", true)
        return
    end

    updateAttributes(nameList)
end

-- MARK: Helper functions
-------------------------------------------------------

---@return boolean
shouldSort = function()
    local groupType = Cell.vars.groupType

    if groupType == "raid" or groupType == "party" then
        if InCombatLockdown() then
            cancelQueuedUpdate()
            return false
        end
        return true
    end

    cancelQueuedUpdate(true)
    return false
end

handleQueuedUpdate = function()
    if not updateIsQueued or not shouldSort() then return end

    updateIsQueued = false
    sortPartyFrames()
end

addUpdateToQueue = function()
    if not shouldSort() then return end

    if updateIsQueued and queuedUpdate then
        queuedUpdate:Cancel()
    end

    updateIsQueued = true
    queuedUpdate = C_Timer.NewTimer(1, handleQueuedUpdate)
end

cancelQueuedUpdate = function(fullReset)
    if fullReset then updateIsQueued = false end
    if queuedUpdate then queuedUpdate:Cancel() end
end

---@param nameList table<string>
updateAttributes = function(nameList)
    if InCombatLockdown() then
        queuedUpdate = true
        return
    end

    local partyHeader = _G["CellPartyFrameHeader"]
    local raidHeader = _G["CellRaidFrameHeader1"]

    -- Determine which header to use based on visibility
    local header
    if partyHeader:IsVisible() then
        header = partyHeader
    elseif raidHeader:IsVisible() then
        header = raidHeader
    else
        return -- Neither header is visible, nothing to update
    end

    for i = 1, 5 do
        local unit = nameList[i] or ("party" .. i)
        header[i]:SetAttribute("unit", unit)
        -- update OmniCD namespace
        CellPartyFrameHeader:UpdateButtonUnit(header[i]:GetName(), unit)
    end
end

-- MARK: Events
-------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" then
        handleQueuedUpdate()
        return
    end

    addUpdateToQueue()
end)

-- MARK: Callback
-------------------------------------------------------

PartyFrame_UpdateLayout = function()
    addUpdateToQueue()
end
Cell:RegisterCallback("UpdateLayout", "PartySortOptions_UpdateLayout", PartyFrame_UpdateLayout)

-- MARK: Slash command
-------------------------------------------------------
SLASH_CELLPARTYSORT1 = "/psort"
function SlashCmdList.CELLPARTYSORT()
    Cell:Fire("UpdateLayout", Cell.vars.currentLayout, "sort")
    F:Print("PartySortOptions: Sorting")
end

-- MARK: Debug
-------------------------------------------------------
Print = function(msg, isErr)
    if isErr then
        F:Print("PartySortOptions: |cFFFF3030" .. msg .. "|r")
    elseif debug then
        F:Print("PartySortOptions: " .. msg)
    end
end
DevAdd = function(data, name) if debug and DevTool then DevTool:AddData(data, name) end end
