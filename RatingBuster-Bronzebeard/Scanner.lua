local RBA = _G.RatingBusterAscension or {}
_G.RatingBusterAscension = RBA

RBA.Scanner = RBA.Scanner or {}
local Scanner = RBA.Scanner

local pairs = pairs
local type = type
local string_match = string.match
local string_lower = string.lower
local string_gsub = string.gsub
local math_abs = math.abs

local function appendUnique(target, value)
	local index
	for index = 1, #(target or {}) do
		if target[index] == value then
			return
		end
	end
	target[#target + 1] = value
end

Scanner.RawKeyMap = {
	ITEM_MOD_STRENGTH_SHORT = "STR",
	ITEM_MOD_STRENGTH = "STR",
	STR = "STR",
	ITEM_MOD_AGILITY_SHORT = "AGI",
	ITEM_MOD_AGILITY = "AGI",
	AGI = "AGI",
	ITEM_MOD_STAMINA_SHORT = "STA",
	ITEM_MOD_STAMINA = "STA",
	STA = "STA",
	ITEM_MOD_INTELLECT_SHORT = "INT",
	ITEM_MOD_INTELLECT = "INT",
	INT = "INT",
	ITEM_MOD_SPIRIT_SHORT = "SPI",
	ITEM_MOD_SPIRIT = "SPI",
	SPI = "SPI",
	ITEM_MOD_ATTACK_POWER_SHORT = "AP",
	ITEM_MOD_ATTACK_POWER = "AP",
	AP = "AP",
	ITEM_MOD_RANGED_ATTACK_POWER_SHORT = "RANGED_AP",
	RANGED_AP = "RANGED_AP",
	ITEM_MOD_FERAL_ATTACK_POWER_SHORT = "FERAL_AP",
	FERAL_AP = "FERAL_AP",
	ITEM_MOD_SPELL_POWER_SHORT = "SPELL_POWER",
	ITEM_MOD_SPELL_POWER = "SPELL_POWER",
	ITEM_MOD_SPELL_HEALING_DONE = "HEALING",
	ITEM_MOD_HEALING_DONE_SHORT = "HEALING",
	ITEM_MOD_MANA_REGENERATION_SHORT = "MP5",
	ITEM_MOD_MANA_REGENERATION = "MP5",
	ITEM_MOD_HEALTH_REGEN_SHORT = "HP5",
	ITEM_MOD_BLOCK_VALUE_SHORT = "BLOCK_VALUE",
	ITEM_MOD_BLOCK_VALUE = "BLOCK_VALUE",
	ITEM_MOD_HIT_RATING_SHORT = "HIT_RATING",
	ITEM_MOD_HIT_RATING = "HIT_RATING",
	ITEM_MOD_HIT_SPELL_RATING_SHORT = "SPELL_HIT_RATING",
	ITEM_MOD_HIT_SPELL_RATING = "SPELL_HIT_RATING",
	ITEM_MOD_CRIT_RATING_SHORT = "CRIT_RATING",
	ITEM_MOD_CRIT_RATING = "CRIT_RATING",
	ITEM_MOD_CRIT_SPELL_RATING_SHORT = "SPELL_CRIT_RATING",
	ITEM_MOD_CRIT_SPELL_RATING = "SPELL_CRIT_RATING",
	ITEM_MOD_HASTE_RATING_SHORT = "HASTE_RATING",
	ITEM_MOD_HASTE_RATING = "HASTE_RATING",
	ITEM_MOD_HASTE_SPELL_RATING_SHORT = "SPELL_HASTE_RATING",
	ITEM_MOD_HASTE_SPELL_RATING = "SPELL_HASTE_RATING",
	ITEM_MOD_EXPERTISE_RATING_SHORT = "EXPERTISE_RATING",
	ITEM_MOD_EXPERTISE_RATING = "EXPERTISE_RATING",
	ITEM_MOD_DEFENSE_SKILL_RATING_SHORT = "DEFENSE_RATING",
	ITEM_MOD_DEFENSE_SKILL_RATING = "DEFENSE_RATING",
	ITEM_MOD_DODGE_RATING_SHORT = "DODGE_RATING",
	ITEM_MOD_DODGE_RATING = "DODGE_RATING",
	ITEM_MOD_PARRY_RATING_SHORT = "PARRY_RATING",
	ITEM_MOD_PARRY_RATING = "PARRY_RATING",
	ITEM_MOD_BLOCK_RATING_SHORT = "BLOCK_RATING",
	ITEM_MOD_BLOCK_RATING = "BLOCK_RATING",
	ITEM_MOD_RESILIENCE_RATING_SHORT = "RESILIENCE_RATING",
	ITEM_MOD_RESILIENCE_RATING = "RESILIENCE_RATING",
	ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT = "ARMOR_PENETRATION_RATING",
	ITEM_MOD_ARMOR_PENETRATION_RATING = "ARMOR_PENETRATION_RATING",
	ITEM_MOD_SPELL_PENETRATION_SHORT = "SPELL_PENETRATION",
	ARMOR = "ARMOR",
	RESISTANCE0_NAME = "ARMOR",
	ITEM_MOD_HEALTH_SHORT = "HEALTH",
	ITEM_MOD_MANA_SHORT = "MANA",
	EMPTY_SOCKET_RED = "EMPTY_SOCKET_RED",
	EMPTY_SOCKET_YELLOW = "EMPTY_SOCKET_YELLOW",
	EMPTY_SOCKET_BLUE = "EMPTY_SOCKET_BLUE",
	EMPTY_SOCKET_META = "EMPTY_SOCKET_META",
}

Scanner.Patterns = {
	{ pattern = "^%+(%d+) strength$", stat = "STR" },
	{ pattern = "^%+(%d+) agility$", stat = "AGI" },
	{ pattern = "^%+(%d+) stamina$", stat = "STA" },
	{ pattern = "^%+(%d+) intellect$", stat = "INT" },
	{ pattern = "^%+(%d+) spirit$", stat = "SPI" },
	{ pattern = "^%+(%d+) attack power$", stat = "AP" },
	{ pattern = "^%+(%d+) ranged attack power$", stat = "RANGED_AP" },
	{ pattern = "^%+(%d+) feral attack power$", stat = "FERAL_AP" },
	{ pattern = "^%+(%d+) spell power$", stat = "SPELL_POWER" },
	{ pattern = "^%+(%d+) healing$", stat = "HEALING" },
	{ pattern = "^%+(%d+) armor$", stat = "BONUS_ARMOR" },
	{ pattern = "^%+(%d+) arcane resistance$", stat = "ARCANE_RESISTANCE" },
	{ pattern = "^%+(%d+) fire resistance$", stat = "FIRE_RESISTANCE" },
	{ pattern = "^%+(%d+) frost resistance$", stat = "FROST_RESISTANCE" },
	{ pattern = "^%+(%d+) nature resistance$", stat = "NATURE_RESISTANCE" },
	{ pattern = "^%+(%d+) shadow resistance$", stat = "SHADOW_RESISTANCE" },
	{ pattern = "^equip: improves critical strike rating by (%d+)%.?$", stat = "CRIT_RATING" },
	{ pattern = "^equip: improves spell critical strike rating by (%d+)%.?$", stat = "SPELL_CRIT_RATING" },
	{ pattern = "^equip: improves hit rating by (%d+)%.?$", stat = "HIT_RATING" },
	{ pattern = "^equip: improves spell hit rating by (%d+)%.?$", stat = "SPELL_HIT_RATING" },
	{ pattern = "^equip: improves haste rating by (%d+)%.?$", stat = "HASTE_RATING" },
	{ pattern = "^equip: improves spell haste rating by (%d+)%.?$", stat = "SPELL_HASTE_RATING" },
	{ pattern = "^equip: improves expertise rating by (%d+)%.?$", stat = "EXPERTISE_RATING" },
	{ pattern = "^equip: improves defense rating by (%d+)%.?$", stat = "DEFENSE_RATING" },
	{ pattern = "^equip: improves dodge rating by (%d+)%.?$", stat = "DODGE_RATING" },
	{ pattern = "^equip: improves parry rating by (%d+)%.?$", stat = "PARRY_RATING" },
	{ pattern = "^equip: improves block rating by (%d+)%.?$", stat = "BLOCK_RATING" },
	{ pattern = "^equip: improves resilience rating by (%d+)%.?$", stat = "RESILIENCE_RATING" },
	{ pattern = "^equip: increases armor penetration rating by (%d+)%.?$", stat = "ARMOR_PENETRATION_RATING" },
	{ pattern = "^equip: increases attack power by (%d+)%.?$", stat = "AP" },
	{ pattern = "^equip: increases ranged attack power by (%d+)%.?$", stat = "RANGED_AP" },
	{ pattern = "^equip: increases spell power by (%d+)%.?$", stat = "SPELL_POWER" },
	{ pattern = "^equip: increases healing by up to (%d+)%.?$", stat = "HEALING" },
	{ pattern = "^equip: restores (%d+) mana per 5 sec%.?$", stat = "MP5" },
	{ pattern = "^equip: restores (%d+) health per 5 sec%.?$", stat = "HP5" },
	{ pattern = "^equip: increases your armor by (%d+)%.?$", stat = "BONUS_ARMOR" },
}

Scanner.TooltipSlotMap = {
	["head"] = "INVTYPE_HEAD",
	["neck"] = "INVTYPE_NECK",
	["shoulder"] = "INVTYPE_SHOULDER",
	["shirt"] = "INVTYPE_BODY",
	["chest"] = "INVTYPE_CHEST",
	["robe"] = "INVTYPE_ROBE",
	["waist"] = "INVTYPE_WAIST",
	["legs"] = "INVTYPE_LEGS",
	["feet"] = "INVTYPE_FEET",
	["wrist"] = "INVTYPE_WRIST",
	["hands"] = "INVTYPE_HAND",
	["finger"] = "INVTYPE_FINGER",
	["trinket"] = "INVTYPE_TRINKET",
	["back"] = "INVTYPE_CLOAK",
	["one-hand"] = "INVTYPE_WEAPON",
	["main hand"] = "INVTYPE_WEAPONMAINHAND",
	["off hand"] = "INVTYPE_WEAPONOFFHAND",
	["held in off-hand"] = "INVTYPE_HOLDABLE",
	["two-hand"] = "INVTYPE_2HWEAPON",
	["shield"] = "INVTYPE_SHIELD",
	["ranged"] = "INVTYPE_RANGED",
	["thrown"] = "INVTYPE_THROWN",
	["relic"] = "INVTYPE_RELIC",
	["tabard"] = "INVTYPE_TABARD",
}

local function addStat(target, key, value)
	value = tonumber(value)
	if not key or not value or value == 0 then
		return
	end
	target[key] = (target[key] or 0) + value
end

function Scanner:Initialize()
	if self.tooltip or type(CreateFrame) ~= "function" then
		return
	end

	self.tooltip = CreateFrame("GameTooltip", "RBAScannerTooltip", UIParent, "GameTooltipTemplate")
	self.tooltip:SetOwner(UIParent, "ANCHOR_NONE")
end

function Scanner:GetTooltipLinesForLink(link, sourceTooltip)
	local lines = {}
	local tooltip = sourceTooltip

	if not tooltip and self.tooltip and type(self.tooltip.SetHyperlink) == "function" then
		self.tooltip:ClearLines()
		self.tooltip:SetHyperlink(link)
		tooltip = self.tooltip
	end

	if not tooltip or type(tooltip.NumLines) ~= "function" then
		return lines
	end

	local tooltipName = tooltip:GetName()
	local index
	for index = 1, tooltip:NumLines() do
		local region = tooltipName and _G[tooltipName .. "TextLeft" .. index]
		local text = region and region:GetText()
		if text and text ~= "" then
			lines[#lines + 1] = RBA:Trim(text)
		end
	end

	return lines
end

function Scanner:NormalizeRawStats(rawStats, normalizedStats, unmappedRawStats)
	local key
	for key in pairs(rawStats or {}) do
		local mapped = self.RawKeyMap[key]
		if mapped and not string_match(mapped, "^EMPTY_SOCKET_") then
			addStat(normalizedStats, mapped, rawStats[key])
		elseif unmappedRawStats and not string_match(key, "^EMPTY_SOCKET_") then
			unmappedRawStats[key] = rawStats[key]
		end
	end
end

function Scanner:ParseTooltipLines(lines, parsedStats, metadata)
	local index
	for index = 1, #lines do
		local rawText = lines[index]
		local text = string_lower(string_gsub(string_gsub(rawText, "|c%x%x%x%x%x%x%x%x", ""), "|r", ""))
		local itemLevel = string_match(text, "^item level (%d+)$")
		if itemLevel then
			metadata.tooltipItemLevel = tonumber(itemLevel)
		end

		local requiredLevel = string_match(text, "^requires level (%d+)$")
		if requiredLevel then
			metadata.requiredLevel = tonumber(requiredLevel)
		end

		if self.TooltipSlotMap[text] then
			metadata.tooltipEquipSlot = self.TooltipSlotMap[text]
		end

		local patternIndex
		for patternIndex = 1, #self.Patterns do
			local pattern = self.Patterns[patternIndex]
			local value = string_match(text, pattern.pattern)
			if value then
				addStat(parsedStats, pattern.stat, value)
			end
		end
	end
end

function Scanner:ScanItemLink(link, sourceTooltip)
	if type(link) ~= "string" then
		return nil
	end

	local cacheKey = link .. ":" .. RBA:BuildSettingsKey()
	local cached = RBA.ItemCache and RBA.ItemCache:GetScan(cacheKey)
	if cached then
		return cached
	end

	local info = RBA.Compat and RBA.Compat:GetItemInfo(link) or nil
	if not info then
		return nil
	end

	local scan = {
		name = info.name,
		link = link,
		itemID = tonumber(string_match(link, "item:(%d+)")),
		info = info,
		itemLevel = RBA.Compat and RBA.Compat:GetItemLevel(link) or info.itemLevel,
		classToken = select(2, UnitClass("player")) or "WARRIOR",
		playerLevel = UnitLevel("player") or 80,
		rawStats = RBA.Compat and RBA.Compat:GetItemStats(link) or {},
		normalizedStats = {},
		parsedTooltipStats = {},
		unmappedRawStats = {},
		tooltipMetadata = {},
		tooltipStatConflicts = {},
		tooltipLines = self:GetTooltipLinesForLink(link, sourceTooltip),
		gems = RBA.Compat and RBA.Compat:GetItemGems(link) or {},
		researchNotes = {},
	}

	self:NormalizeRawStats(scan.rawStats, scan.normalizedStats, scan.unmappedRawStats)
	self:ParseTooltipLines(scan.tooltipLines, scan.parsedTooltipStats, scan.tooltipMetadata)

	local key
	for key in pairs(scan.parsedTooltipStats) do
		local parsedValue = scan.parsedTooltipStats[key]
		local rawValue = scan.normalizedStats[key]
		if rawValue == nil then
			scan.normalizedStats[key] = parsedValue
		elseif math_abs((rawValue or 0) - (parsedValue or 0)) > 0.001 then
			scan.tooltipStatConflicts[key] = {
				raw = rawValue,
				tooltip = parsedValue,
			}
		end
	end

	scan.equipSlot = info.equipSlot or scan.tooltipMetadata.tooltipEquipSlot
	if not scan.itemLevel and scan.tooltipMetadata.tooltipItemLevel then
		scan.itemLevel = scan.tooltipMetadata.tooltipItemLevel
	end

	if scan.itemLevel and scan.tooltipMetadata.tooltipItemLevel and scan.itemLevel ~= scan.tooltipMetadata.tooltipItemLevel then
		appendUnique(scan.researchNotes, "GetItemInfo item level differs from the visible tooltip item level for this item, which suggests BronzeBeard-specific scaling behavior still needs validation.")
	end

	if info.equipSlot == nil and scan.tooltipMetadata.tooltipEquipSlot then
		appendUnique(scan.researchNotes, "GetItemInfo did not provide an equip slot for this item, so compare fallback is using the visible tooltip slot.")
	end

	if RBA:GetDB().ignoreEnchants or RBA:GetDB().ignoreGems or RBA:GetDB().ignoreSocketBonus then
		appendUnique(scan.researchNotes, RBA.Compat.ResearchNotes.ignoreLinkMutators)
	end

	if next(scan.rawStats or {}) == nil then
		appendUnique(scan.researchNotes, "GetItemStats returned no documented payload for this item, so the current result depends on tooltip text parsing.")
	end

	if next(scan.unmappedRawStats or {}) ~= nil then
		appendUnique(scan.researchNotes, "GetItemStats exposed raw keys that are not mapped yet; inspect the dump before deciding whether they should affect tooltip output.")
	end

	if RBA.ItemCache then
		RBA.ItemCache:SetScan(cacheKey, scan)
	end

	return scan
end

RBA:RegisterModule("Scanner", Scanner)
