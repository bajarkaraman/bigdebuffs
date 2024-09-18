---@diagnostic disable: undefined-global
local _, addon = ...

local function Update()
	BigDebuffs:Refresh()
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
	if C_AddOns.GetAddOnEnableState("Cell", nil) == 0 then
		return
	end

	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
	eventFrame:HookScript("OnEvent", function()
		RunNextFrame(Update)
	end)

	addon.CompactRaidFrameRedirectConfig.Cell = {
		GetRedirectFrame = GetRedirectFrame,
	}
end

addon.RedirectManager:RegisterRedirectAddon("Cell", {
	GetRedirectFrame = GetRedirectFrame,
	Init = Init,
})
