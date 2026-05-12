local RBA = _G.RatingBusterAscension or {}
_G.RatingBusterAscension = RBA

RBA.Compat = RBA.Compat or {
	ResearchNotes = {
		modernTooltip = "TooltipDataProcessor, C_TooltipInfo and Enum.TooltipDataType were not found in the local ascension-docs snapshot. Runtime detection stays optional.",
		modernItemApi = "C_Item and GetDetailedItemLevelInfo were not found in the local ascension-docs snapshot. Fallbacks stay mandatory.",
		ignoreLinkMutators = "Ignoring enchants, gems and socket bonuses still needs BronzeBeard-specific validation before we mutate item links confidently.",
		liveStatApis = "The documented Ascension stat APIs expose live unit totals, but not direct marginal deltas for arbitrary item stats. Item-derived breakdowns still need runtime validation against BronzeBeard behavior.",
	},
}

local Compat = RBA.Compat
local type = type

function Compat:DetectCapabilities()
	self.HasGetItemStats = type(GetItemStats) == "function"
	self.HasGetItemInfo = type(GetItemInfo) == "function"
	self.HasGetItemGem = type(GetItemGem) == "function"
	self.HasGetInventoryItemLink = type(GetInventoryItemLink) == "function"
	self.HasGetDetailedItemLevelInfo = type(GetDetailedItemLevelInfo) == "function"
	self.HasGetCombatRating = type(GetCombatRating) == "function"
	self.HasGetCombatRatingBonus = type(GetCombatRatingBonus) == "function"
	self.HasGetExpertise = type(GetExpertise) == "function"
	self.HasGetExpertisePercent = type(GetExpertisePercent) == "function"
	self.HasGetCritChanceFromAgility = type(GetCritChanceFromAgility) == "function"
	self.HasGetSpellCritChanceFromIntellect = type(GetSpellCritChanceFromIntellect) == "function"
	self.HasGetManaRegen = type(GetManaRegen) == "function"
	self.HasGetPowerRegen = type(GetPowerRegen) == "function"
	self.HasCItem = type(C_Item) == "table"
	self.HasTooltipDataProcessor = type(TooltipDataProcessor) == "table"
	self.HasCTooltipInfo = type(C_TooltipInfo) == "table"
	self.HasEnumTooltipDataType = type(Enum) == "table" and type(Enum.TooltipDataType) == "table"
	self.HasGameTooltipSetHyperlinkCompareItem = type(GameTooltip) == "table" and type(GameTooltip.SetHyperlinkCompareItem) == "function"
	self.HasShoppingTooltipCompare = type(ShoppingTooltip1) == "table" and type(ShoppingTooltip1.SetHyperlinkCompareItem) == "function"
end

function Compat:GetItemInfo(link)
	if not self.HasGetItemInfo or type(link) ~= "string" then
		return nil
	end

	local name, itemLink, quality, itemLevel, requiredLevel, itemClass, itemSubClass, maxStack, equipSlot, texture, vendorPrice = RBA:SafeCall(GetItemInfo, link)
	if not name then
		return nil
	end

	return {
		name = name,
		link = itemLink,
		quality = quality,
		itemLevel = itemLevel,
		requiredLevel = requiredLevel,
		itemClass = itemClass,
		itemSubClass = itemSubClass,
		maxStack = maxStack,
		equipSlot = equipSlot,
		texture = texture,
		vendorPrice = vendorPrice,
	}
end

function Compat:GetItemLevel(link)
	if self.HasGetDetailedItemLevelInfo then
		local detailedLevel = RBA:SafeCall(GetDetailedItemLevelInfo, link)
		if detailedLevel then
			return detailedLevel
		end
	end

	local info = self:GetItemInfo(link)
	return info and info.itemLevel or nil
end

function Compat:GetInventoryItemLink(unit, slot)
	if not self.HasGetInventoryItemLink then
		return nil
	end

	return RBA:SafeCall(GetInventoryItemLink, unit or "player", slot)
end

function Compat:GetItemStats(link)
	if not self.HasGetItemStats then
		return nil
	end

	local stats = RBA:SafeCall(GetItemStats, link, {})
	if type(stats) == "table" then
		return stats
	end

	return nil
end

function Compat:GetItemGems(link)
	local gems = {}
	if not self.HasGetItemGem then
		return gems
	end

	local index
	for index = 1, 4 do
		local name, gemLink = RBA:SafeCall(GetItemGem, link, index)
		if gemLink or name then
			gems[#gems + 1] = {
				index = index,
				name = name,
				link = gemLink,
			}
		end
	end

	return gems
end

function Compat:GetLiveStatSnapshot(unit)
	unit = unit or "player"

	local snapshot = {}
	local combatRatings = {
		{ key = "meleeHitBonus", constant = "CR_HIT_MELEE" },
		{ key = "spellHitBonus", constant = "CR_HIT_SPELL" },
		{ key = "meleeCritBonus", constant = "CR_CRIT_MELEE" },
		{ key = "spellCritBonus", constant = "CR_CRIT_SPELL" },
		{ key = "meleeHasteBonus", constant = "CR_HASTE_MELEE" },
		{ key = "spellHasteBonus", constant = "CR_HASTE_SPELL" },
		{ key = "expertiseBonus", constant = "CR_EXPERTISE" },
		{ key = "defenseBonus", constant = "CR_DEFENSE_SKILL" },
		{ key = "dodgeBonus", constant = "CR_DODGE" },
		{ key = "parryBonus", constant = "CR_PARRY" },
		{ key = "blockBonus", constant = "CR_BLOCK" },
		{ key = "resilienceBonus", constant = "CR_RESILIENCE_PLAYER_DAMAGE_TAKEN" },
		{ key = "armorPenBonus", constant = "CR_ARMOR_PENETRATION" },
	}

	if self.HasGetCritChanceFromAgility then
		snapshot.critFromAgility = RBA:SafeCall(GetCritChanceFromAgility, unit)
	end

	if self.HasGetSpellCritChanceFromIntellect then
		snapshot.spellCritFromIntellect = RBA:SafeCall(GetSpellCritChanceFromIntellect, unit)
	end

	if self.HasGetManaRegen then
		local base, casting = RBA:SafeCall(GetManaRegen)
		snapshot.manaRegenBase = base
		snapshot.manaRegenCasting = casting
	end

	if self.HasGetPowerRegen then
		local inactive, active = RBA:SafeCall(GetPowerRegen)
		snapshot.powerRegenInactive = inactive
		snapshot.powerRegenActive = active
	end

	if self.HasGetExpertise then
		local main, offhand = RBA:SafeCall(GetExpertise)
		snapshot.expertiseMainHand = main
		snapshot.expertiseOffHand = offhand
	end

	if self.HasGetExpertisePercent then
		local main, offhand = RBA:SafeCall(GetExpertisePercent)
		snapshot.expertisePercentMainHand = main
		snapshot.expertisePercentOffHand = offhand
	end

	if self.HasGetCombatRatingBonus then
		local index
		for index = 1, #combatRatings do
			local entry = combatRatings[index]
			local ratingIndex = _G[entry.constant]
			if type(ratingIndex) == "number" then
				snapshot[entry.key] = RBA:SafeCall(GetCombatRatingBonus, ratingIndex)
			end
		end
	end

	return snapshot
end

RBA:RegisterModule("Compatibility", Compat)
