local RBA = _G.RatingBusterAscension or {}
_G.RatingBusterAscension = RBA

RBA.DebugModule = RBA.DebugModule or {}
local DebugModule = RBA.DebugModule

local pairs = pairs
local type = type
local tostring = tostring
local table_sort = table.sort

local function sortedKeys(input)
	local keys = {}
	local key
	for key in pairs(input or {}) do
		keys[#keys + 1] = key
	end
	table_sort(keys)
	return keys
end

function DebugModule:DumpTable(prefix, input)
	local key
	for _, key in ipairs(sortedKeys(input)) do
		RBA:Print(prefix .. key .. " = " .. tostring(input[key]))
	end
end

function DebugModule:DumpCapabilities()
	if not RBA.Compat then
		return
	end

	local keys = sortedKeys(RBA.Compat)
	local index
	for index = 1, #keys do
		local key = keys[index]
		if type(RBA.Compat[key]) ~= "function" and key ~= "ResearchNotes" then
			RBA:Print("Compat " .. key .. " = " .. tostring(RBA.Compat[key]))
		end
	end

	for _, key in ipairs(sortedKeys(RBA.Compat.ResearchNotes)) do
		RBA:Print("ResearchNote " .. key .. " = " .. tostring(RBA.Compat.ResearchNotes[key]))
	end
end

function DebugModule:DumpLivePlayerStats()
	if not RBA.Compat or type(RBA.Compat.GetLiveStatSnapshot) ~= "function" then
		return
	end

	RBA:Print("Live player stat snapshot:")
	self:DumpTable("Live ", RBA.Compat:GetLiveStatSnapshot("player"))
end

function DebugModule:DumpLastInspection()
	local inspection = RBA.state.lastInspection
	if not inspection then
		RBA:Print("No cached inspection yet. Hover an item first.")
		self:DumpCapabilities()
		self:DumpLivePlayerStats()
		return
	end

	RBA:Print("Item: " .. tostring(inspection.name))
	RBA:Print("Link: " .. tostring(inspection.link))
	RBA:Print("ItemID: " .. tostring(inspection.itemID or "n/a"))
	RBA:Print("Tooltip: " .. tostring(inspection.tooltipName or "n/a"))
	if inspection.itemLevel or inspection.info then
		RBA:Print("ItemLevel: " .. tostring(inspection.itemLevel or (inspection.info and inspection.info.itemLevel) or "n/a"))
	end
	if inspection.info then
		RBA:Print("EquipSlot: " .. tostring(inspection.info.equipSlot or "n/a"))
	end

	self:DumpCapabilities()
	self:DumpLivePlayerStats()
	self:DumpTable("Raw ", inspection.rawStats)
	self:DumpTable("Normalized ", inspection.normalizedStats)
	self:DumpTable("Summary ", inspection.summaryMetrics)

	local index
	for index = 1, #(inspection.tooltipLines or {}) do
		RBA:Print("Tooltip[" .. index .. "]: " .. inspection.tooltipLines[index])
	end

	for index = 1, #(inspection.researchNotes or {}) do
		RBA:Print("Research: " .. inspection.researchNotes[index])
	end

	if inspection.compareTextPrimary then
		RBA:Print("Compare: " .. inspection.compareTextPrimary)
	end
	if inspection.compareTextSecondary then
		RBA:Print("Compare Alt: " .. inspection.compareTextSecondary)
	end
end

RBA:RegisterModule("Debug", DebugModule)
