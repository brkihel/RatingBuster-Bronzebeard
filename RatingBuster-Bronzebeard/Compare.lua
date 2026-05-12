local RBA = _G.RatingBusterAscension or {}
_G.RatingBusterAscension = RBA

RBA.Compare = RBA.Compare or {}
local Compare = RBA.Compare

local type = type

Compare.SlotMap = {
	INVTYPE_HEAD = { 1 },
	INVTYPE_NECK = { 2 },
	INVTYPE_SHOULDER = { 3 },
	INVTYPE_BODY = { 4 },
	INVTYPE_CHEST = { 5 },
	INVTYPE_ROBE = { 5 },
	INVTYPE_WAIST = { 6 },
	INVTYPE_LEGS = { 7 },
	INVTYPE_FEET = { 8 },
	INVTYPE_WRIST = { 9 },
	INVTYPE_HAND = { 10 },
	INVTYPE_FINGER = { 11, 12 },
	INVTYPE_TRINKET = { 13, 14 },
	INVTYPE_CLOAK = { 15 },
	INVTYPE_WEAPON = { 16, 17 },
	INVTYPE_2HWEAPON = { 16, 17 },
	INVTYPE_WEAPONMAINHAND = { 16 },
	INVTYPE_WEAPONOFFHAND = { 17 },
	INVTYPE_SHIELD = { 17 },
	INVTYPE_HOLDABLE = { 17 },
	INVTYPE_RANGED = { 18 },
	INVTYPE_RANGEDRIGHT = { 18 },
	INVTYPE_THROWN = { 18 },
	INVTYPE_RELIC = { 18 },
	INVTYPE_TABARD = { 19 },
}

local function buildDiff(baseMetrics, compareMetrics)
	local diff = {}
	local key
	for key in pairs(baseMetrics or {}) do
		diff[key] = (baseMetrics[key] or 0) - (compareMetrics and compareMetrics[key] or 0)
	end
	for key in pairs(compareMetrics or {}) do
		if diff[key] == nil then
			diff[key] = 0 - (compareMetrics[key] or 0)
		end
	end
	return diff
end

function Compare:GetCandidateSlots(link)
	local info = RBA.Compat and RBA.Compat:GetItemInfo(link) or nil
	if not info then
		return nil
	end
	return self.SlotMap[info.equipSlot]
end

function Compare:Build(scan)
	scan.compareTextPrimary = nil
	scan.compareTextSecondary = nil

	local slots = self:GetCandidateSlots(scan.link)
	if not slots or not RBA.Compat then
		return
	end

	local index
	for index = 1, #slots do
		local equippedLink = RBA.Compat:GetInventoryItemLink("player", slots[index])
		if equippedLink then
			local equippedScan = RBA.Scanner:ScanItemLink(equippedLink)
			if equippedScan then
				equippedScan.summaryMetrics = equippedScan.summaryMetrics or {}
				if not equippedScan._summaryEnriched then
					RBA.Stats:Enrich(equippedScan)
					RBA.Ratings:Enrich(equippedScan)
					equippedScan._summaryEnriched = true
				end
				local diff = buildDiff(scan.summaryMetrics or {}, equippedScan.summaryMetrics or {})
				local text = RBA.Stats:BuildSummaryText(diff, 6)
				if text and text ~= "" then
					if not scan.compareTextPrimary then
						scan.compareTextPrimary = text
					else
						scan.compareTextSecondary = text
					end
				end
			end
		end
	end
end

RBA:RegisterModule("Compare", Compare)
