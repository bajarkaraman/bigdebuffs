---@diagnostic disable: undefined-global
local _, addon = ...

local function Update()
	BigDebuffs:Refresh()
end

local function GetRedirectFrame(targetFrame)
	for i = 1, MEMBERS_PER_RAID_GROUP do
		local frame = _G["CellPartyFrameHeaderUnitButton" .. i]

		if frame and frame:IsVisible() and UnitIsUnit(frame.unit, targetFrame.unit) then
			return frame
		end
	end

	for group = 1, MAX_RAID_MEMBERS / MEMBERS_PER_RAID_GROUP do
		for member = 1, MEMBERS_PER_RAID_GROUP do
			local frame = _G["CellRaidFrameHeader" .. group .. "UnitButton" .. member]

			if frame and frame:IsVisible() and UnitIsUnit(frame.unit, targetFrame.unit) then
				return frame
			end
		end
	end

	if not UnitIsUnit("player", targetFrame.unit) then
		return nil
	end

	return CellSoloFramePlayer
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
