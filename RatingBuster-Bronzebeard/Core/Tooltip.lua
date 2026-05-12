local ns = RatingBuster_BronzebeardNS
ns.Tooltip = ns.Tooltip or {}

local Tooltip = ns.Tooltip
local Engine = ns.Engine

local type = type
local tostring = tostring
local string_find = string.find
local table_concat = table.concat

local FALLBACK_TOOLTIPS = {
	"GameTooltip",
	"ItemRefTooltip",
	"ShoppingTooltip1",
	"ShoppingTooltip2",
	"ShoppingTooltip3",
}

function Tooltip:IsComparisonTooltip(tooltip)
	if not tooltip or type(tooltip.GetName) ~= "function" then
		return false
	end

	local name = tooltip:GetName() or ""
	return string_find(name, "ShoppingTooltip", 1, true) ~= nil or string_find(name, "ComparisonTooltip", 1, true) ~= nil
end

function Tooltip:BuildTooltipKey(link)
	local profile = ns.GetProfile()
	return table_concat({
		tostring(link or ""),
		profile.debug and "1" or "0",
		profile.showRatings and "1" or "0",
		profile.showPrimary and "1" or "0",
		profile.showSummary and "1" or "0",
		profile.showComparison and "1" or "0",
		profile.showGemInfo and "1" or "0",
		profile.showDebugTooltipLines and "1" or "0",
	}, ":")
end

function Tooltip:Render(tooltip, inspection)
	local profile = ns.GetProfile()
	local r, g, b = ns.GetTextColor()

	ns.SafeAddLine(tooltip, " ")
	ns.SafeAddLine(tooltip, ns.ADDON_TITLE, r, g, b)

	local index
	if profile.showRatings then
		for index = 1, #(inspection.ratingBreakdown or {}) do
			local entry = inspection.ratingBreakdown[index]
			ns.SafeAddDoubleLine(tooltip, entry.label, entry.value, 0.90, 0.90, 0.90, r, g, b)
		end
	end

	if profile.showPrimary then
		for index = 1, #(inspection.primaryBreakdown or {}) do
			local entry = inspection.primaryBreakdown[index]
			ns.SafeAddDoubleLine(tooltip, entry.label, entry.value, 0.80, 0.95, 0.80, r, g, b)
		end
	end

	if profile.showSummary and inspection.summaryText and inspection.summaryText ~= "" then
		ns.SafeAddLine(tooltip, "Summary: " .. inspection.summaryText, 0.85, 0.85, 0.85)
	end

	if profile.showComparison and not self:IsComparisonTooltip(tooltip) then
		if inspection.compareText1 and inspection.compareText1 ~= "" then
			ns.SafeAddLine(tooltip, "Vs Equipped: " .. inspection.compareText1, 0.75, 0.85, 1.0)
		end
		if inspection.compareText2 and inspection.compareText2 ~= "" then
			ns.SafeAddLine(tooltip, "Alt Slot: " .. inspection.compareText2, 0.75, 0.85, 1.0)
		end
	end

	if profile.showGemInfo and inspection.gems and #inspection.gems > 0 then
		local gemNames = {}
		for index = 1, #inspection.gems do
			local gem = inspection.gems[index]
			gemNames[#gemNames + 1] = gem.name or gem.link or ("Gem " .. gem.index)
		end
		ns.SafeAddLine(tooltip, "Gems: " .. table_concat(gemNames, ", "), 0.80, 0.80, 1.0)
	end

	if profile.debug then
		ns.SafeAddLine(tooltip, "Debug: itemID=" .. tostring(inspection.itemID or "n/a"), 1.0, 0.50, 0.50)
		if inspection.unknownStatKeys and #inspection.unknownStatKeys > 0 then
			ns.SafeAddLine(tooltip, "Unknown stats: " .. table_concat(inspection.unknownStatKeys, ", "), 1.0, 0.50, 0.50)
		end
		if profile.showDebugTooltipLines and inspection.tooltipLines then
			for index = 1, #inspection.tooltipLines do
				ns.SafeAddLine(tooltip, "TT[" .. index .. "]: " .. inspection.tooltipLines[index], 0.75, 0.75, 0.75)
			end
		end
	end

	if type(tooltip.Show) == "function" then
		tooltip:Show()
	end
end

function Tooltip:Process(tooltip, name, link)
	local profile = ns.GetProfile()
	if not profile.enabled or type(link) ~= "string" or type(tooltip) ~= "table" then
		return
	end

	local key = self:BuildTooltipKey(link)
	if tooltip.__RBABronzebeardKey == key then
		return
	end

	local inspection = Engine:InspectTooltip(tooltip, name, link)
	if not inspection then
		return
	end

	tooltip.__RBABronzebeardKey = key
	ns.state.lastInspection = inspection
	self:Render(tooltip, inspection)
end

function Tooltip:HookFallbackTooltip(frame)
	if not frame or frame.__RBABronzebeardHooked or type(frame.HookScript) ~= "function" then
		return
	end

	frame:HookScript("OnTooltipCleared", function(tooltip)
		tooltip.__RBABronzebeardKey = nil
	end)

	frame:HookScript("OnTooltipSetItem", function(tooltip)
		if type(tooltip.GetItem) ~= "function" then
			return
		end
		local name, link = tooltip:GetItem()
		if link then
			Tooltip:Process(tooltip, name, link)
		end
	end)

	frame.__RBABronzebeardHooked = true
end

function Tooltip:Hook()
	if self._hooked then
		return
	end

	local tipHooker = _G.LibStub and _G.LibStub("LibTipHooker-1.1", true)
	if tipHooker and type(tipHooker.Hook) == "function" then
		self._tipHookHandler = function(...)
			Tooltip:Process(...)
		end
		tipHooker:Hook(self._tipHookHandler, "item")
		self._tipHooker = tipHooker
	end

	local index
	for index = 1, #FALLBACK_TOOLTIPS do
		self:HookFallbackTooltip(_G[FALLBACK_TOOLTIPS[index]])
	end

	self._hooked = true
end

function Tooltip:Unhook()
	if self._tipHooker and self._tipHookHandler and type(self._tipHooker.Unhook) == "function" then
		self._tipHooker:Unhook(self._tipHookHandler, "item")
	end
	self._tipHooker = nil
	self._tipHookHandler = nil
	self._hooked = false
end
