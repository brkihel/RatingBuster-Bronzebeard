local RBA = _G.RatingBusterAscension or {}
_G.RatingBusterAscension = RBA

RBA.Tooltip = RBA.Tooltip or {}
local Tooltip = RBA.Tooltip

local type = type

Tooltip.HookTargets = {
	"GameTooltip",
	"ItemRefTooltip",
	"ShoppingTooltip1",
	"ShoppingTooltip2",
}

function Tooltip:AddLineSafe(tooltip, text, r, g, b)
	if type(tooltip.AddLine) == "function" and text and text ~= "" then
		tooltip:AddLine(text, r, g, b)
	end
end

function Tooltip:AddDoubleLineSafe(tooltip, left, right, lr, lg, lb, rr, rg, rb)
	if type(tooltip.AddDoubleLine) == "function" then
		tooltip:AddDoubleLine(left, right, lr, lg, lb, rr, rg, rb)
	elseif type(tooltip.AddLine) == "function" then
		tooltip:AddLine(left .. ": " .. right, lr, lg, lb)
	end
end

function Tooltip:ProcessTooltip(tooltip)
	if not tooltip or tooltip.__RBAProcessing then
		return
	end

	local db = RBA:GetDB()
	if db.enabled == false or type(tooltip.GetItem) ~= "function" then
		return
	end

	local name, link = tooltip:GetItem()
	if not link then
		return
	end

	local key = link .. ":" .. RBA:BuildSettingsKey()
	if tooltip.__RBALastKey == key then
		return
	end

	tooltip.__RBAProcessing = true

	local scan = RBA.Scanner and RBA.Scanner:ScanItemLink(link, tooltip) or nil
	if scan then
		RBA.Stats:Enrich(scan)
		RBA.Ratings:Enrich(scan)
		RBA.Compare:Build(scan)
		scan.summaryText = RBA.Stats:BuildSummaryText(scan.summaryMetrics or {}, 6)
		scan.tooltipName = tooltip:GetName()

		local r, g, b = 1.0, 0.82, 0.30
		if not db.colorText then
			r, g, b = 1.0, 1.0, 1.0
		end

		self:AddLineSafe(tooltip, " ")
		self:AddLineSafe(tooltip, RBA.L.AddonHeader, r, g, b)

		if db.showItemID and scan.itemID then
			self:AddLineSafe(tooltip, "Item ID: " .. scan.itemID, 0.75, 0.75, 0.75)
		end
		if db.showItemLevel and scan.itemLevel and not (scan.tooltipMetadata and scan.tooltipMetadata.tooltipItemLevel) then
			self:AddLineSafe(tooltip, "Item Level: " .. scan.itemLevel, 0.75, 0.75, 0.75)
		end

		local index
		if db.showRatings then
			for index = 1, #(scan.ratingLines or {}) do
				local line = scan.ratingLines[index]
				self:AddDoubleLineSafe(tooltip, line.label, line.value, 0.90, 0.90, 0.90, r, g, b)
			end
		end

		if db.showStatBreakdown then
			for index = 1, #(scan.statBreakdownLines or {}) do
				local line = scan.statBreakdownLines[index]
				self:AddDoubleLineSafe(tooltip, line.label, line.value, 0.80, 0.95, 0.80, r, g, b)
			end
		end

		if db.showSummary and scan.summaryText and scan.summaryText ~= "" then
			self:AddLineSafe(tooltip, RBA.L.Summary .. ": " .. scan.summaryText, 0.85, 0.85, 0.85)
		end

		if db.showCompare and scan.compareTextPrimary then
			self:AddLineSafe(tooltip, RBA.L.Compare .. ": " .. scan.compareTextPrimary, 0.75, 0.85, 1.0)
		end
		if db.showCompare and scan.compareTextSecondary then
			self:AddLineSafe(tooltip, RBA.L.CompareAlt .. ": " .. scan.compareTextSecondary, 0.75, 0.85, 1.0)
		end

		if scan.gems and #scan.gems > 0 then
			local names = {}
			for index = 1, #scan.gems do
				names[#names + 1] = scan.gems[index].name or scan.gems[index].link or ("Gem " .. scan.gems[index].index)
			end
			self:AddLineSafe(tooltip, RBA.L.Gems .. ": " .. table.concat(names, ", "), 0.80, 0.80, 1.0)
		end

		if db.debug then
			self:AddLineSafe(tooltip, RBA.L.Debug .. ": " .. tooltip:GetName(), 1.0, 0.50, 0.50)
			if scan.apiItemLevel and scan.tooltipMetadata and scan.tooltipMetadata.tooltipItemLevel and scan.apiItemLevel ~= scan.tooltipMetadata.tooltipItemLevel then
				self:AddLineSafe(tooltip, "API Item Level: " .. scan.apiItemLevel, 1.0, 0.65, 0.35)
			end
			for index = 1, #(scan.researchNotes or {}) do
				self:AddLineSafe(tooltip, RBA.L.ResearchPending .. ": " .. scan.researchNotes[index], 1.0, 0.50, 0.50)
			end
		end

		if RBA.ItemCache then
			RBA.ItemCache:SetInspection(key, scan)
		end
		tooltip.__RBALastKey = key
		tooltip:Show()
	end

	tooltip.__RBAProcessing = false
end

function Tooltip:HookFrame(tooltip)
	if not tooltip or tooltip.__RBAHooked or type(tooltip.HookScript) ~= "function" then
		return
	end

	tooltip:HookScript("OnTooltipSetItem", function(frame)
		Tooltip:ProcessTooltip(frame)
	end)

	tooltip:HookScript("OnTooltipCleared", function(frame)
		frame.__RBALastKey = nil
		frame.__RBAProcessing = nil
	end)

	tooltip.__RBAHooked = true
end

function Tooltip:HookAll()
	local index
	for index = 1, #self.HookTargets do
		self:HookFrame(_G[self.HookTargets[index]])
	end
end

RBA:RegisterModule("Tooltip", Tooltip)
