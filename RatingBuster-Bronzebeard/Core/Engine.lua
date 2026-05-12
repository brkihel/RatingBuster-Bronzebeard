local ns = RatingBuster_BronzebeardNS
ns.Engine = ns.Engine or {}

local Engine = ns.Engine

local type = type
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local table_sort = table.sort
local table_concat = table.concat
local string_find = string.find
local string_match = string.match

local LibStub = _G.LibStub

local function copyTable(source)
	local destination = {}
	if type(source) ~= "table" then
		return destination
	end

	local key
	for key in pairs(source) do
		destination[key] = source[key]
	end

	return destination
end

local function sortedKeys(input)
	local keys = {}
	local key
	for key in pairs(input or {}) do
		keys[#keys + 1] = key
	end

	table_sort(keys)
	return keys
end

local RAW_TO_GENERIC = {
	ITEM_MOD_STRENGTH_SHORT = "STR",
	ITEM_MOD_AGILITY_SHORT = "AGI",
	ITEM_MOD_STAMINA_SHORT = "STA",
	ITEM_MOD_INTELLECT_SHORT = "INT",
	ITEM_MOD_SPIRIT_SHORT = "SPI",
	ITEM_MOD_HEALTH_SHORT = "HEALTH",
	ITEM_MOD_MANA_SHORT = "MANA",
	ITEM_MOD_ATTACK_POWER_SHORT = "AP",
	ITEM_MOD_RANGED_ATTACK_POWER_SHORT = "RANGED_AP",
	ITEM_MOD_MANA_REGENERATION_SHORT = "MP5",
	ITEM_MOD_BLOCK_VALUE_SHORT = "BLOCK_VALUE",
	ITEM_MOD_SPELL_POWER_SHORT = "SPELL_DMG",
	ITEM_MOD_SPELL_HEALING_DONE_SHORT = "HEAL",
	ITEM_MOD_SPELL_DAMAGE_DONE_SHORT = "SPELL_DMG",
	ITEM_MOD_HIT_RATING_SHORT = "HIT_RATING",
	ITEM_MOD_HIT_MELEE_RATING_SHORT = "MELEE_HIT_RATING",
	ITEM_MOD_HIT_RANGED_RATING_SHORT = "RANGED_HIT_RATING",
	ITEM_MOD_HIT_SPELL_RATING_SHORT = "SPELL_HIT_RATING",
	ITEM_MOD_CRIT_RATING_SHORT = "CRIT_RATING",
	ITEM_MOD_CRIT_MELEE_RATING_SHORT = "MELEE_CRIT_RATING",
	ITEM_MOD_CRIT_RANGED_RATING_SHORT = "RANGED_CRIT_RATING",
	ITEM_MOD_CRIT_SPELL_RATING_SHORT = "SPELL_CRIT_RATING",
	ITEM_MOD_HASTE_RATING_SHORT = "HASTE_RATING",
	ITEM_MOD_HASTE_MELEE_RATING_SHORT = "MELEE_HASTE_RATING",
	ITEM_MOD_HASTE_RANGED_RATING_SHORT = "RANGED_HASTE_RATING",
	ITEM_MOD_HASTE_SPELL_RATING_SHORT = "SPELL_HASTE_RATING",
	ITEM_MOD_EXPERTISE_RATING_SHORT = "EXPERTISE_RATING",
	ITEM_MOD_DEFENSE_SKILL_RATING_SHORT = "DEFENSE_RATING",
	ITEM_MOD_DODGE_RATING_SHORT = "DODGE_RATING",
	ITEM_MOD_PARRY_RATING_SHORT = "PARRY_RATING",
	ITEM_MOD_BLOCK_RATING_SHORT = "BLOCK_RATING",
	ITEM_MOD_RESILIENCE_RATING_SHORT = "RESILIENCE_RATING",
	ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT = "ARMOR_PENETRATION_RATING",
	ITEM_MOD_SPELL_PENETRATION_SHORT = "SPELL_PEN",
	RESISTANCE0_NAME = "ARMOR",
}

local SUM_TO_GENERIC = {
	STR = "STR",
	AGI = "AGI",
	STA = "STA",
	INT = "INT",
	SPI = "SPI",
	HEALTH = "HEALTH",
	MANA = "MANA",
	AP = "AP",
	RANGED_AP = "RANGED_AP",
	SPELL_DMG = "SPELL_DMG",
	HEAL = "HEAL",
	MP5 = "MP5",
	BLOCK_VALUE = "BLOCK_VALUE",
	ARMOR = "ARMOR",
	ARMOR_BONUS = "ARMOR_BONUS",
	HIT_RATING = "HIT_RATING",
	MELEE_HIT_RATING = "MELEE_HIT_RATING",
	RANGED_HIT_RATING = "RANGED_HIT_RATING",
	SPELL_HIT_RATING = "SPELL_HIT_RATING",
	CRIT_RATING = "CRIT_RATING",
	MELEE_CRIT_RATING = "MELEE_CRIT_RATING",
	RANGED_CRIT_RATING = "RANGED_CRIT_RATING",
	SPELL_CRIT_RATING = "SPELL_CRIT_RATING",
	HASTE_RATING = "HASTE_RATING",
	MELEE_HASTE_RATING = "MELEE_HASTE_RATING",
	RANGED_HASTE_RATING = "RANGED_HASTE_RATING",
	SPELL_HASTE_RATING = "SPELL_HASTE_RATING",
	EXPERTISE_RATING = "EXPERTISE_RATING",
	DEFENSE_RATING = "DEFENSE_RATING",
	DODGE_RATING = "DODGE_RATING",
	PARRY_RATING = "PARRY_RATING",
	BLOCK_RATING = "BLOCK_RATING",
	RESILIENCE_RATING = "RESILIENCE_RATING",
	ARMOR_PENETRATION_RATING = "ARMOR_PENETRATION_RATING",
	SPELL_PEN = "SPELL_PEN",
}

local function addValue(target, key, value)
	value = tonumber(value)
	if not key or not value or value == 0 then
		return
	end

	target[key] = (target[key] or 0) + value
end

function Engine:GetStatLogic()
	if self._statLogic ~= false then
		if self._statLogic then
			return self._statLogic
		end

		if LibStub and type(LibStub) == "function" then
			self._statLogic = LibStub("LibStatLogicBronzebeard", true)
		end

		if not self._statLogic then
			self._statLogic = false
		end
	end

	return self._statLogic or nil
end

function Engine:GetItemID(link)
	if type(link) ~= "string" then
		return nil
	end

	return tonumber(string_match(link, "item:(%d+)"))
end

function Engine:GetItemInfoTable(link)
	if type(GetItemInfo) ~= "function" or type(link) ~= "string" then
		return nil
	end

	local name, itemLink, quality, itemLevel, requiredLevel, itemClass, itemSubClass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(link)
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

function Engine:GetTooltipLines(tooltip)
	local lines = {}
	if not tooltip or type(tooltip.NumLines) ~= "function" then
		return lines
	end

	local tooltipName = tooltip.GetName and tooltip:GetName()
	local index
	for index = 1, tooltip:NumLines() do
		local region = tooltipName and _G[tooltipName .. "TextLeft" .. index]
		if region and type(region.GetText) == "function" then
			local text = ns.Trim(region:GetText())
			if text ~= "" then
				lines[#lines + 1] = text
			end
		end
	end

	return lines
end

function Engine:GetRawItemStats(link)
	if type(GetItemStats) ~= "function" or type(link) ~= "string" then
		return nil
	end

	local ok, stats = pcall(GetItemStats, link, {})
	if ok and type(stats) == "table" then
		return stats
	end

	return nil
end

function Engine:GetGemDetails(link)
	local gems = {}
	if type(GetItemGem) ~= "function" or type(link) ~= "string" then
		return gems
	end

	local index
	for index = 1, 4 do
		local name, gemLink = ns.SafeCall(GetItemGem, link, index)
		if gemLink or name then
			gems[#gems + 1] = {
				index = index,
				name = name,
				link = gemLink,
				itemID = self:GetItemID(gemLink),
			}
		end
	end

	return gems
end

function Engine:GetStatLogicSum(link)
	local statLogic = self:GetStatLogic()
	if not statLogic or type(statLogic.GetSum) ~= "function" then
		return nil
	end

	local sum = ns.SafeCall(statLogic.GetSum, statLogic, link, {})
	if type(sum) == "table" then
		return copyTable(sum)
	end

	return nil
end

function Engine:GetStatLogicDiff(link)
	local statLogic = self:GetStatLogic()
	if not statLogic then
		return nil, nil, nil, nil
	end

	local compareLink1
	local compareLink2
	if type(statLogic.GetDiffID) == "function" then
		local _, _, link1, link2 = ns.SafeCall(statLogic.GetDiffID, statLogic, link, false, false, nil, nil, nil, nil, false)
		compareLink1 = link1
		compareLink2 = link2
	end

	if type(statLogic.GetDiff) ~= "function" then
		return nil, nil, compareLink1, compareLink2
	end

	local diff1, diff2 = ns.SafeCall(statLogic.GetDiff, statLogic, link, {}, {}, false, false, nil, nil, nil, nil, false)
	if type(diff1) ~= "table" then
		diff1 = nil
	end
	if type(diff2) ~= "table" then
		diff2 = nil
	end

	return diff1, diff2, compareLink1, compareLink2
end

function Engine:NormalizeStats(rawStats, sumStats)
	local normalized = {}
	local unknown = {}

	local key
	if type(rawStats) == "table" then
		for key in pairs(rawStats) do
			local mapped = RAW_TO_GENERIC[key]
			if mapped then
				addValue(normalized, mapped, rawStats[key])
			elseif not string_find(key, "^EMPTY_SOCKET_") and key ~= "SOCKET_BONUS" then
				unknown[#unknown + 1] = key
			end
		end
	end

	if type(sumStats) == "table" then
		for key in pairs(sumStats) do
			local mapped = SUM_TO_GENERIC[key]
			if mapped and not ns.IsSignificant(normalized[mapped] or 0, 0.0001) then
				addValue(normalized, mapped, sumStats[key])
			end
		end
	end

	return normalized, unknown
end

function Engine:GetClassToken()
	if type(UnitClass) ~= "function" then
		return "WARRIOR"
	end

	return select(2, UnitClass("player")) or "WARRIOR"
end

function Engine:GetPlayerLevel()
	if type(UnitLevel) ~= "function" then
		return 80
	end

	return UnitLevel("player") or 80
end

function Engine:GetCurrentIntellect()
	if type(UnitStat) ~= "function" then
		return 0
	end

	local _, effective = UnitStat("player", 4)
	return effective or 0
end

function Engine:CallStatLogic(methodName, ...)
	local statLogic = self:GetStatLogic()
	local method = statLogic and statLogic[methodName]
	if not statLogic or type(method) ~= "function" then
		return nil
	end

	local value = ns.SafeCall(method, statLogic, ...)
	return tonumber(value)
end

function Engine:GetRatingEffect(value, ratingConstantName)
	local ratingConstant = _G[ratingConstantName]
	if not ratingConstant then
		return nil
	end

	return self:CallStatLogic("GetEffectFromRating", value, ratingConstant, self:GetPlayerLevel(), self:GetClassToken())
end

function Engine:BuildRatingBreakdown(stats)
	local lines = {}

	local function addRatingLine(label, valueParts)
		if #valueParts > 0 then
			lines[#lines + 1] = {
				label = label,
				value = table_concat(valueParts, ", "),
			}
		end
	end

	local function buildParts(amount, definitions)
		local parts = {}
		local seen = {}
		local index
		for index = 1, #definitions do
			local definition = definitions[index]
			local effect = self:GetRatingEffect(amount, definition.constant)
			if ns.IsSignificant(effect or 0, 0.005) then
				local text = ns.FormatSignedPercent(effect, 2) .. " " .. definition.label
				if not seen[text] then
					parts[#parts + 1] = text
					seen[text] = true
				end
			end
		end
		return parts
	end

	if stats.HIT_RATING then
		addRatingLine("Hit Rating", buildParts(stats.HIT_RATING, {
			{ constant = "CR_HIT_MELEE", label = "Hit" },
			{ constant = "CR_HIT_SPELL", label = "Spell Hit" },
			{ constant = "CR_HIT_RANGED", label = "Ranged Hit" },
		}))
	end
	if stats.MELEE_HIT_RATING then
		addRatingLine("Melee Hit Rating", buildParts(stats.MELEE_HIT_RATING, {
			{ constant = "CR_HIT_MELEE", label = "Hit" },
		}))
	end
	if stats.SPELL_HIT_RATING then
		addRatingLine("Spell Hit Rating", buildParts(stats.SPELL_HIT_RATING, {
			{ constant = "CR_HIT_SPELL", label = "Spell Hit" },
		}))
	end
	if stats.CRIT_RATING then
		addRatingLine("Crit Rating", buildParts(stats.CRIT_RATING, {
			{ constant = "CR_CRIT_MELEE", label = "Crit" },
			{ constant = "CR_CRIT_SPELL", label = "Spell Crit" },
			{ constant = "CR_CRIT_RANGED", label = "Ranged Crit" },
		}))
	end
	if stats.SPELL_CRIT_RATING then
		addRatingLine("Spell Crit Rating", buildParts(stats.SPELL_CRIT_RATING, {
			{ constant = "CR_CRIT_SPELL", label = "Spell Crit" },
		}))
	end
	if stats.HASTE_RATING then
		addRatingLine("Haste Rating", buildParts(stats.HASTE_RATING, {
			{ constant = "CR_HASTE_MELEE", label = "Haste" },
			{ constant = "CR_HASTE_SPELL", label = "Spell Haste" },
			{ constant = "CR_HASTE_RANGED", label = "Ranged Haste" },
		}))
	end
	if stats.EXPERTISE_RATING then
		local expertise = self:GetRatingEffect(stats.EXPERTISE_RATING, "CR_EXPERTISE")
		if ns.IsSignificant(expertise or 0, 0.005) then
			addRatingLine("Expertise Rating", {
				ns.FormatSignedNumber(expertise, 2) .. " Expertise",
				ns.FormatSignedPercent(expertise * 0.25, 2) .. " Dodge/Parry Reduction",
			})
		end
	end
	if stats.DEFENSE_RATING then
		local defense = self:GetRatingEffect(stats.DEFENSE_RATING, "CR_DEFENSE_SKILL")
		if ns.IsSignificant(defense or 0, 0.005) then
			addRatingLine("Defense Rating", {
				ns.FormatSignedNumber(defense, 2) .. " Defense Skill",
			})
		end
	end
	if stats.DODGE_RATING then
		addRatingLine("Dodge Rating", buildParts(stats.DODGE_RATING, {
			{ constant = "CR_DODGE", label = "Dodge" },
		}))
	end
	if stats.PARRY_RATING then
		addRatingLine("Parry Rating", buildParts(stats.PARRY_RATING, {
			{ constant = "CR_PARRY", label = "Parry" },
		}))
	end
	if stats.BLOCK_RATING then
		addRatingLine("Block Rating", buildParts(stats.BLOCK_RATING, {
			{ constant = "CR_BLOCK", label = "Block" },
		}))
	end
	if stats.RESILIENCE_RATING then
		local resilience = self:GetRatingEffect(stats.RESILIENCE_RATING, "CR_CRIT_TAKEN_MELEE")
		if ns.IsSignificant(resilience or 0, 0.005) then
			addRatingLine("Resilience Rating", {
				ns.FormatSignedPercent(resilience, 2) .. " Crit Taken Reduction",
			})
		end
	end
	if stats.ARMOR_PENETRATION_RATING then
		addRatingLine("Armor Pen. Rating", buildParts(stats.ARMOR_PENETRATION_RATING, {
			{ constant = "CR_ARMOR_PENETRATION", label = "Armor Penetration" },
		}))
	end

	return lines
end

function Engine:BuildPrimaryBreakdown(stats)
	local lines = {}

	local function append(label, entries)
		if #entries > 0 then
			lines[#lines + 1] = {
				label = label,
				value = table_concat(entries, ", "),
			}
		end
	end

	if stats.STR then
		local entries = {}
		local ap = self:CallStatLogic("GetAPFromStr", stats.STR, self:GetClassToken())
		local blockValue = self:CallStatLogic("GetBlockValueFromStr", stats.STR, self:GetClassToken())
		if ns.IsSignificant(ap or 0, 0.005) then
			entries[#entries + 1] = ns.FormatSignedNumber(ap, 0) .. " AP"
		end
		if ns.IsSignificant(blockValue or 0, 0.005) then
			entries[#entries + 1] = ns.FormatSignedNumber(blockValue, 0) .. " Block Value"
		end
		append("Strength", entries)
	end

	if stats.AGI then
		local entries = {}
		local crit = self:CallStatLogic("GetCritFromAgi", stats.AGI, self:GetClassToken(), self:GetPlayerLevel())
		local dodge = self:CallStatLogic("GetDodgeFromAgi", stats.AGI)
		local ap = self:CallStatLogic("GetAPFromAgi", stats.AGI, self:GetClassToken())
		local rap = self:CallStatLogic("GetRAPFromAgi", stats.AGI, self:GetClassToken())
		if ns.IsSignificant(crit or 0, 0.005) then
			entries[#entries + 1] = ns.FormatSignedPercent(crit, 2) .. " Crit"
		end
		if ns.IsSignificant(dodge or 0, 0.005) then
			entries[#entries + 1] = ns.FormatSignedPercent(dodge, 2) .. " Dodge"
		end
		if ns.IsSignificant(ap or 0, 0.005) then
			entries[#entries + 1] = ns.FormatSignedNumber(ap, 0) .. " AP"
		end
		if ns.IsSignificant(rap or 0, 0.005) then
			entries[#entries + 1] = ns.FormatSignedNumber(rap, 0) .. " Ranged AP"
		end
		append("Agility", entries)
	end

	if stats.STA then
		append("Stamina", {
			ns.FormatSignedNumber((stats.STA or 0) * 10, 0) .. " Health",
		})
	end

	if stats.INT then
		local entries = {
			ns.FormatSignedNumber((stats.INT or 0) * 15, 0) .. " Mana",
		}
		local spellCrit = self:CallStatLogic("GetSpellCritFromInt", stats.INT, self:GetClassToken(), self:GetPlayerLevel())
		if ns.IsSignificant(spellCrit or 0, 0.005) then
			entries[#entries + 1] = ns.FormatSignedPercent(spellCrit, 2) .. " Spell Crit"
		end
		append("Intellect", entries)
	end

	if stats.SPI then
		local entries = {}
		local spiritMp5 = self:CallStatLogic("GetNormalManaRegenFromSpi", stats.SPI, self:GetCurrentIntellect(), self:GetPlayerLevel())
		local spiritHp5 = self:CallStatLogic("GetHealthRegenFromSpi", stats.SPI, self:GetClassToken())
		if ns.IsSignificant(spiritMp5 or 0, 0.005) then
			entries[#entries + 1] = ns.FormatSignedNumber(spiritMp5, 2) .. " MP5"
		end
		if ns.IsSignificant(spiritHp5 or 0, 0.005) then
			entries[#entries + 1] = ns.FormatSignedNumber(spiritHp5, 2) .. " HP5"
		end
		append("Spirit", entries)
	end

	return lines
end

function Engine:BuildSummaryMetrics(stats)
	local metrics = {}

	local function addMetric(key, value)
		value = tonumber(value)
		if not value or value == 0 then
			return
		end

		metrics[key] = (metrics[key] or 0) + value
	end

	addMetric("Attack Power", stats.AP)
	addMetric("Ranged AP", stats.RANGED_AP)
	addMetric("Spell Power", stats.SPELL_DMG)
	addMetric("Healing", stats.HEAL)
	addMetric("Block Value", stats.BLOCK_VALUE)
	addMetric("Armor", (stats.ARMOR or 0) + (stats.ARMOR_BONUS or 0))
	addMetric("Mana", stats.MANA)
	addMetric("Health", stats.HEALTH)
	addMetric("MP5", stats.MP5)
	addMetric("Spell Pen.", stats.SPELL_PEN)

	if stats.STR then
		addMetric("Attack Power", self:CallStatLogic("GetAPFromStr", stats.STR, self:GetClassToken()))
		addMetric("Block Value", self:CallStatLogic("GetBlockValueFromStr", stats.STR, self:GetClassToken()))
	end
	if stats.AGI then
		addMetric("Attack Power", self:CallStatLogic("GetAPFromAgi", stats.AGI, self:GetClassToken()))
		addMetric("Ranged AP", self:CallStatLogic("GetRAPFromAgi", stats.AGI, self:GetClassToken()))
		addMetric("Crit", self:CallStatLogic("GetCritFromAgi", stats.AGI, self:GetClassToken(), self:GetPlayerLevel()))
		addMetric("Dodge", self:CallStatLogic("GetDodgeFromAgi", stats.AGI))
	end
	if stats.STA then
		addMetric("Health", stats.STA * 10)
	end
	if stats.INT then
		addMetric("Mana", stats.INT * 15)
		addMetric("Spell Crit", self:CallStatLogic("GetSpellCritFromInt", stats.INT, self:GetClassToken(), self:GetPlayerLevel()))
	end
	if stats.SPI then
		addMetric("MP5", self:CallStatLogic("GetNormalManaRegenFromSpi", stats.SPI, self:GetCurrentIntellect(), self:GetPlayerLevel()))
	end

	addMetric("Hit", self:GetRatingEffect(stats.HIT_RATING or stats.MELEE_HIT_RATING, "CR_HIT_MELEE"))
	addMetric("Spell Hit", self:GetRatingEffect(stats.HIT_RATING or stats.SPELL_HIT_RATING, "CR_HIT_SPELL"))
	addMetric("Crit", self:GetRatingEffect(stats.CRIT_RATING or stats.MELEE_CRIT_RATING, "CR_CRIT_MELEE"))
	addMetric("Spell Crit", self:GetRatingEffect(stats.CRIT_RATING or stats.SPELL_CRIT_RATING, "CR_CRIT_SPELL"))
	addMetric("Haste", self:GetRatingEffect(stats.HASTE_RATING or stats.MELEE_HASTE_RATING, "CR_HASTE_MELEE"))
	addMetric("Spell Haste", self:GetRatingEffect(stats.HASTE_RATING or stats.SPELL_HASTE_RATING, "CR_HASTE_SPELL"))
	addMetric("Expertise", self:GetRatingEffect(stats.EXPERTISE_RATING, "CR_EXPERTISE"))
	addMetric("Defense Skill", self:GetRatingEffect(stats.DEFENSE_RATING, "CR_DEFENSE_SKILL"))
	addMetric("Dodge", self:GetRatingEffect(stats.DODGE_RATING, "CR_DODGE"))
	addMetric("Parry", self:GetRatingEffect(stats.PARRY_RATING, "CR_PARRY"))
	addMetric("Block", self:GetRatingEffect(stats.BLOCK_RATING, "CR_BLOCK"))
	addMetric("Armor Pen.", self:GetRatingEffect(stats.ARMOR_PENETRATION_RATING, "CR_ARMOR_PENETRATION"))

	return metrics
end

function Engine:BuildSummaryText(metrics, maxEntries)
	local orderedKeys = {
		"Attack Power",
		"Ranged AP",
		"Spell Power",
		"Healing",
		"Hit",
		"Spell Hit",
		"Crit",
		"Spell Crit",
		"Haste",
		"Spell Haste",
		"Expertise",
		"Dodge",
		"Parry",
		"Block",
		"Defense Skill",
		"Armor Pen.",
		"Block Value",
		"Health",
		"Mana",
		"MP5",
		"Armor",
		"Spell Pen.",
	}

	local parts = {}
	local index
	for index = 1, #orderedKeys do
		local key = orderedKeys[index]
		local value = metrics[key]
		if ns.IsSignificant(value or 0, 0.005) then
			if key == "Hit" or key == "Spell Hit" or key == "Crit" or key == "Spell Crit" or key == "Haste" or key == "Spell Haste" or key == "Dodge" or key == "Parry" or key == "Block" or key == "Armor Pen." then
				parts[#parts + 1] = key .. " " .. ns.FormatSignedPercent(value, 2)
			elseif key == "Expertise" or key == "Defense Skill" or key == "MP5" then
				parts[#parts + 1] = key .. " " .. ns.FormatSignedNumber(value, 2)
			else
				parts[#parts + 1] = key .. " " .. ns.FormatSignedNumber(value, 0)
			end
		end
		if maxEntries and #parts >= maxEntries then
			break
		end
	end

	return table_concat(parts, ", ")
end

function Engine:InspectTooltip(tooltip, name, link)
	if type(link) ~= "string" then
		return nil
	end

	local info = self:GetItemInfoTable(link)
	local rawStats = self:GetRawItemStats(link)
	local tooltipLines = self:GetTooltipLines(tooltip)
	local sumStats = self:GetStatLogicSum(link)
	local diff1, diff2, compareLink1, compareLink2 = self:GetStatLogicDiff(link)
	local normalizedStats, unknownStatKeys = self:NormalizeStats(rawStats, sumStats)
	local compareStats1 = diff1 and select(1, self:NormalizeStats(nil, diff1)) or nil
	local compareStats2 = diff2 and select(1, self:NormalizeStats(nil, diff2)) or nil
	local summaryText = self:BuildSummaryText(self:BuildSummaryMetrics(normalizedStats), ns.GetProfile().maxSummaryEntries)
	local comparisonText1 = compareStats1 and self:BuildSummaryText(self:BuildSummaryMetrics(compareStats1), ns.GetProfile().maxComparisonEntries) or nil
	local comparisonText2 = compareStats2 and self:BuildSummaryText(self:BuildSummaryMetrics(compareStats2), ns.GetProfile().maxComparisonEntries) or nil

	return {
		name = name or (info and info.name) or link,
		link = link,
		itemID = self:GetItemID(link),
		info = info,
		rawStats = rawStats,
		sumStats = sumStats,
		normalizedStats = normalizedStats,
		unknownStatKeys = unknownStatKeys,
		tooltipLines = tooltipLines,
		gems = self:GetGemDetails(link),
		ratingBreakdown = self:BuildRatingBreakdown(normalizedStats),
		primaryBreakdown = self:BuildPrimaryBreakdown(normalizedStats),
		summaryText = summaryText,
		compareText1 = comparisonText1,
		compareText2 = comparisonText2,
		compareLink1 = compareLink1,
		compareLink2 = compareLink2,
		tooltipName = tooltip and tooltip.GetName and tooltip:GetName() or nil,
	}
end

function Engine:DumpInspection(inspection, printer)
	if not inspection then
		if printer and type(printer.Print) == "function" then
			printer:Print("No cached inspection yet. Hover an item first.")
		end
		return
	end

	local function printLine(text)
		if printer and type(printer.Print) == "function" then
			printer:Print(text)
		else
			ns.Debug(text)
		end
	end

	printLine("Item: " .. tostring(inspection.name))
	printLine("Link: " .. tostring(inspection.link))
	printLine("ItemID: " .. tostring(inspection.itemID or "n/a"))
	printLine("Tooltip: " .. tostring(inspection.tooltipName or "n/a"))
	if inspection.info then
		printLine("EquipSlot: " .. tostring(inspection.info.equipSlot or "n/a"))
		printLine("ItemLevel: " .. tostring(inspection.info.itemLevel or "n/a"))
	end
	printLine("GetItemStats available: " .. tostring(type(GetItemStats) == "function"))

	local key
	for _, key in ipairs(sortedKeys(inspection.rawStats or {})) do
		printLine("RawStat " .. key .. " = " .. tostring(inspection.rawStats[key]))
	end
	for _, key in ipairs(sortedKeys(inspection.normalizedStats or {})) do
		printLine("Normalized " .. key .. " = " .. tostring(inspection.normalizedStats[key]))
	end
	for _, key in ipairs(sortedKeys(inspection.sumStats or {})) do
		printLine("Sum " .. key .. " = " .. tostring(inspection.sumStats[key]))
	end

	local index
	for index = 1, #(inspection.tooltipLines or {}) do
		printLine("Tooltip[" .. index .. "]: " .. inspection.tooltipLines[index])
	end

	if inspection.compareLink1 and inspection.compareLink1 ~= "NOITEM" then
		printLine("CompareLink1: " .. inspection.compareLink1)
	end
	if inspection.compareLink2 and inspection.compareLink2 ~= "NOITEM" then
		printLine("CompareLink2: " .. inspection.compareLink2)
	end

	if inspection.summaryText and inspection.summaryText ~= "" then
		printLine("Summary: " .. inspection.summaryText)
	end
	if inspection.compareText1 and inspection.compareText1 ~= "" then
		printLine("Diff1: " .. inspection.compareText1)
	end
	if inspection.compareText2 and inspection.compareText2 ~= "" then
		printLine("Diff2: " .. inspection.compareText2)
	end

	if inspection.unknownStatKeys and #inspection.unknownStatKeys > 0 then
		printLine("Unknown GetItemStats keys: " .. table_concat(inspection.unknownStatKeys, ", "))
	end
end
