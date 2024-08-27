local _, addon = ...

local lastUpdate = 0
local debounceTime = 2

local function UpdateGroupHeader(header)
    if header ~= CellPartyFrameHeader and header ~= CellRaidFrameHeader0 then
        return
    end

    local currentTime = GetTime()

    if currentTime - lastUpdate < debounceTime then
        return
    end

    for frame, _ in pairs(BigDebuffs.frames) do
        if frame then CompactUnitFrame_UpdateAuras(frame) end
        if frame and frame.BigDebuffs then BigDebuffs:AddBigDebuffs(frame) end
    end

    lastUpdate = currentTime
end

local function GetRedirectFrame(targetFrame)
    local partyHeader = _G["CellPartyFrameHeader"]
    local raidHeader = _G["CellRaidFrameHeader0"]
    local soloFrame = _G["CellSoloFramePlayer"]
    local groupCount = GetNumGroupMembers()

    if soloFrame and soloFrame:IsVisible() then
        -- We're solo
        return _G["CellSoloFramePlayer"]
    end

    if raidHeader and raidHeader:IsVisible() then
        -- We're in a raid
        for i = 1, groupCount do
            local frame = _G["CellRaidFrameHeader0UnitButton" .. i]
            if frame and frame:IsVisible() and UnitIsUnit(frame.unit, targetFrame.unit) then
                return frame
            end
        end
    end

    if partyHeader and partyHeader:IsVisible() then
        -- We're in a party
        for i = 1, groupCount do
            local frame = _G["CellPartyFrameHeaderUnitButton" .. i]
            if frame and frame:IsVisible() and UnitIsUnit(frame.unit, targetFrame.unit) then
                return frame
            end
        end
    end

    return nil
end

local function Init()
    if not Cell then return end

    hooksecurefunc("SecureGroupHeader_Update", function(header)
        UpdateGroupHeader(header)
    end)

    if BigDebuffs and BigDebuffs.CompactRaidFrameRedirectConfig then
        BigDebuffs.CompactRaidFrameRedirectConfig.Cell = {
            GetRedirectFrame = GetRedirectFrame
        }
    end
end

addon.Init = Init
addon.RedirectManager:RegisterRedirectAddon("Cell", {
    GetRedirectFrame = GetRedirectFrame,
    Init = Init
})