local RBA = _G.RatingBusterAscension or {}
_G.RatingBusterAscension = RBA

RBA.Stats = RBA.Stats or {}
local Stats = RBA.Stats

local type = type

local function appendUnique(target, value)
	local index
	for index = 1, #(target or {}) do
		if target[index] == value then
			return
		end
	end
	target[#target + 1] = value
end

Stats.SummaryMetricTypes = {
	["Attack Power"] = "flat",
	["Ranged AP"] = "flat",
	["Feral AP"] = "flat",
	["Spell Power"] = "flat",
	Healing = "flat",
	Health = "flat",
	Mana = "flat",
	MP5 = "rating",
	HP5 = "rating",
	Armor = "flat",
	["Block Value"] = "flat",
}

Stats.StrengthAttackPower = {
	WARRIOR = 2,
	PALADIN = 2,
	DEATHKNIGHT = 2,
	SHAMAN = 2,
	HUNTER = 1,
	ROGUE = 1,
	DRUID = 2,
}

Stats.AgilityAttackPower = {
	ROGUE = 1,
	HUNTER = 1,
	SHAMAN = 1,
	DRUID = 1,
}

Stats.AgilityRangedAttackPower = {
	HUNTER = 1,
	ROGUE = 1,
}

Stats.BlockValueStrength = {
	WARRIOR = 0.5,
	PALADIN = 0.5,
}

local function getStatLogic()
	if type(LibStub) ~= "function" then
		return nil
	end
	return LibStub("LibStatLogicBronzebeard", true)
end

local function getPlayerClass()
	return select(2, UnitClass("player")) or "WARRIOR"
end

local function getPlayerLevel()
	return UnitLevel("player") or 80
end

local function addSummary(scan, name, value)
	if value then
		scan.summaryMetrics[name] = (scan.summaryMetrics[name] or 0) + value
	end
end

local function addLine(scan, label, text)
	scan.statBreakdownLines[#scan.statBreakdownLines + 1] = {
		label = label,
		value = text,
	}
end

function Stats:BuildSummaryText(metrics, limit)
	local order = {
		"Attack Power",
		"Ranged AP",
		"Feral AP",
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
		"Resilience",
		"Block Value",
		"Health",
		"Mana",
		"MP5",
		"HP5",
		"Armor",
	}

	local parts = {}
	local index
	for index = 1, #order do
		local name = order[index]
		local formatted = RBA:FormatMetric(name, metrics[name])
		if formatted then
			parts[#parts + 1] = formatted
		end
		if limit and #parts >= limit then
			break
		end
	end

	return table.concat(parts, ", ")
end

function Stats:Enrich(scan)
	if scan._statsEnriched then
		return
	end

	scan.statBreakdownLines = scan.statBreakdownLines or {}
	scan.summaryMetrics = scan.summaryMetrics or {}
	scan.researchNotes = scan.researchNotes or {}

	local stats = scan.normalizedStats or {}
	local class = scan.classToken or getPlayerClass()
	local level = scan.playerLevel or getPlayerLevel()
	local statLogic = getStatLogic()

	addSummary(scan, "Attack Power", stats.AP)
	addSummary(scan, "Ranged AP", stats.RANGED_AP)
	addSummary(scan, "Feral AP", stats.FERAL_AP)
	addSummary(scan, "Spell Power", stats.SPELL_POWER or stats.SPELL_DMG)
	addSummary(scan, "Healing", stats.HEALING or stats.HEAL)
	addSummary(scan, "MP5", stats.MP5)
	addSummary(scan, "HP5", stats.HP5)
	addSummary(scan, "Armor", (stats.ARMOR or 0) + (stats.BONUS_ARMOR or stats.ARMOR_BONUS or 0))
	addSummary(scan, "Block Value", stats.BLOCK_VALUE)
	addSummary(scan, "Health", stats.HEALTH)
	addSummary(scan, "Mana", stats.MANA)

	if stats.STR and stats.STR > 0 then
		local entries = {}
		local ap = stats.STR * (self.StrengthAttackPower[class] or 0)
		if ap > 0 then
			entries[#entries + 1] = RBA:FormatSigned(ap, 0) .. " AP"
			addSummary(scan, "Attack Power", ap)
		end
		local blockValue = stats.STR * (self.BlockValueStrength[class] or 0)
		if blockValue > 0 then
			entries[#entries + 1] = RBA:FormatSigned(blockValue, 0) .. " Block Value"
			addSummary(scan, "Block Value", blockValue)
		end
		if #entries > 0 then
			addLine(scan, "Strength", table.concat(entries, ", "))
		end
	end

	if stats.AGI and stats.AGI > 0 then
		local entries = {}
		local ap = stats.AGI * (self.AgilityAttackPower[class] or 0)
		local rap = stats.AGI * (self.AgilityRangedAttackPower[class] or 0)
		if ap > 0 then
			entries[#entries + 1] = RBA:FormatSigned(ap, 0) .. " AP"
			addSummary(scan, "Attack Power", ap)
		end
		if rap > 0 then
			entries[#entries + 1] = RBA:FormatSigned(rap, 0) .. " Ranged AP"
			addSummary(scan, "Ranged AP", rap)
		end
		if statLogic and type(statLogic.GetCritFromAgi) == "function" then
			local crit = RBA:SafeCall(statLogic.GetCritFromAgi, statLogic, stats.AGI, class, level)
			if crit then
				entries[#entries + 1] = RBA:FormatSigned(crit, 2, "%") .. " Crit"
				addSummary(scan, "Crit", crit)
			end
		else
			appendUnique(scan.researchNotes, "Agility to crit still needs more BronzeBeard-specific research if LibStatLogic is not trusted as a temporary backend.")
		end
		if statLogic and type(statLogic.GetDodgeFromAgi) == "function" then
			local dodge = RBA:SafeCall(statLogic.GetDodgeFromAgi, statLogic, stats.AGI)
			if dodge then
				entries[#entries + 1] = RBA:FormatSigned(dodge, 2, "%") .. " Dodge"
				addSummary(scan, "Dodge", dodge)
			end
		else
			appendUnique(scan.researchNotes, "Agility to dodge still needs more BronzeBeard-specific research if LibStatLogic is not trusted as a temporary backend.")
		end
		if #entries > 0 then
			addLine(scan, "Agility", table.concat(entries, ", "))
		end
	end

	if stats.STA and stats.STA > 0 then
		local health = stats.STA * 10
		addSummary(scan, "Health", health)
		addLine(scan, "Stamina", RBA:FormatSigned(health, 0) .. " Health")
		appendUnique(scan.researchNotes, "Stamina currently uses the standard 1 STA = 10 Health approximation; exact BronzeBeard behavior still needs validation.")
	end

	if stats.INT and stats.INT > 0 then
		local entries = {}
		local mana = stats.INT * 15
		addSummary(scan, "Mana", mana)
		entries[#entries + 1] = RBA:FormatSigned(mana, 0) .. " Mana"
		if statLogic and type(statLogic.GetSpellCritFromInt) == "function" then
			local spellCrit = RBA:SafeCall(statLogic.GetSpellCritFromInt, statLogic, stats.INT, class, level)
			if spellCrit then
				entries[#entries + 1] = RBA:FormatSigned(spellCrit, 2, "%") .. " Spell Crit"
				addSummary(scan, "Spell Crit", spellCrit)
			end
		else
			appendUnique(scan.researchNotes, "Intellect to spell crit still needs more BronzeBeard-specific research if LibStatLogic is not trusted as a temporary backend.")
		end
		addLine(scan, "Intellect", table.concat(entries, ", "))
	end

	if stats.SPI and stats.SPI > 0 then
		local entries = {}
		if statLogic and type(statLogic.GetNormalManaRegenFromSpi) == "function" and type(UnitStat) == "function" then
			local _, intellect = UnitStat("player", 4)
			local mp5 = RBA:SafeCall(statLogic.GetNormalManaRegenFromSpi, statLogic, stats.SPI, intellect or 0, level)
			if mp5 then
				entries[#entries + 1] = RBA:FormatSigned(mp5, 2) .. " MP5"
				addSummary(scan, "MP5", mp5)
			end
		else
			appendUnique(scan.researchNotes, "Spirit to mana regen still needs more BronzeBeard-specific research.")
		end

		if statLogic and type(statLogic.GetHealthRegenFromSpi) == "function" then
			local hp5 = RBA:SafeCall(statLogic.GetHealthRegenFromSpi, statLogic, stats.SPI, class)
			if hp5 then
				entries[#entries + 1] = RBA:FormatSigned(hp5, 2) .. " HP5"
				addSummary(scan, "HP5", hp5)
			end
		else
			appendUnique(scan.researchNotes, "Spirit to health regen still needs more BronzeBeard-specific research.")
		end

		if #entries > 0 then
			addLine(scan, "Spirit", table.concat(entries, ", "))
		end
	end

	if (stats.AGI or stats.INT or stats.SPI) and RBA.Compat and (RBA.Compat.HasGetCritChanceFromAgility or RBA.Compat.HasGetSpellCritChanceFromIntellect or RBA.Compat.HasGetManaRegen or RBA.Compat.HasGetPowerRegen) then
		appendUnique(scan.researchNotes, RBA.Compat.ResearchNotes.liveStatApis)
	end

	scan._statsEnriched = true
end

RBA:RegisterModule("Stats", Stats)
