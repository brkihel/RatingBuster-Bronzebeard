local RBA = _G.RatingBusterAscension or {}
_G.RatingBusterAscension = RBA

RBA.Ratings = RBA.Ratings or {}
local Ratings = RBA.Ratings

local function appendUnique(target, value)
	local index
	for index = 1, #(target or {}) do
		if target[index] == value then
			return
		end
	end
	target[#target + 1] = value
end

Ratings.Conversions = {
	[80] = {
		HIT_RATING = 32.78998947,
		SPELL_HIT_RATING = 26.23199272,
		CRIT_RATING = 45.90598679,
		SPELL_CRIT_RATING = 45.90598679,
		HASTE_RATING = 32.78998947,
		SPELL_HASTE_RATING = 32.78998947,
		EXPERTISE_RATING = 8.197497367,
		EXPERTISE_PERCENT_RATING = 32.78998947,
		DEFENSE_RATING = 4.918498039,
		DODGE_RATING = 39.34798813,
		PARRY_RATING = 49.18498611,
		BLOCK_RATING = 16.39499474,
		RESILIENCE_RATING = 94.2712249,
		ARMOR_PENETRATION_RATING = 13.9957272,
	},
}

Ratings.SummaryMetricTypes = {
	Hit = "percent",
	["Spell Hit"] = "percent",
	Crit = "percent",
	["Spell Crit"] = "percent",
	Haste = "percent",
	["Spell Haste"] = "percent",
	Dodge = "percent",
	Parry = "percent",
	Block = "percent",
	["Armor Pen."] = "percent",
	Expertise = "rating",
	["Defense Skill"] = "rating",
	Resilience = "percent",
}

function Ratings:RatingToPercent(ratingKey, value, level)
	local levelTable = self.Conversions[level] or self.Conversions[80]
	local ratingPerPercent = levelTable and levelTable[ratingKey]
	if not ratingPerPercent or ratingPerPercent == 0 or not value then
		return nil
	end
	return value / ratingPerPercent
end

function Ratings:Enrich(scan)
	if scan._ratingsEnriched then
		return
	end

	scan.ratingLines = scan.ratingLines or {}
	scan.summaryMetrics = scan.summaryMetrics or {}
	scan.researchNotes = scan.researchNotes or {}

	local stats = scan.normalizedStats or {}
	local level = scan.playerLevel or 80
	local levelTable = self.Conversions[level] or self.Conversions[80]

	local function addLine(label, text)
		scan.ratingLines[#scan.ratingLines + 1] = {
			label = label,
			value = text,
		}
	end

	local function addSummary(name, value)
		if value then
			scan.summaryMetrics[name] = (scan.summaryMetrics[name] or 0) + value
		end
	end

	local hit = self:RatingToPercent("HIT_RATING", stats.HIT_RATING or stats.MELEE_HIT_RATING, level)
	if hit then
		addLine("Hit Rating", RBA:FormatSigned(hit, 2, "%") .. " Hit")
		addSummary("Hit", hit)
	end

	local spellHit = self:RatingToPercent("SPELL_HIT_RATING", stats.SPELL_HIT_RATING, level)
	if spellHit then
		addLine("Spell Hit Rating", RBA:FormatSigned(spellHit, 2, "%") .. " Spell Hit")
		addSummary("Spell Hit", spellHit)
	end

	local crit = self:RatingToPercent("CRIT_RATING", stats.CRIT_RATING, level)
	if crit then
		addLine("Crit Rating", RBA:FormatSigned(crit, 2, "%") .. " Crit")
		addSummary("Crit", crit)
	end

	local spellCrit = self:RatingToPercent("SPELL_CRIT_RATING", stats.SPELL_CRIT_RATING, level)
	if spellCrit then
		addLine("Spell Crit Rating", RBA:FormatSigned(spellCrit, 2, "%") .. " Spell Crit")
		addSummary("Spell Crit", spellCrit)
	end

	local haste = self:RatingToPercent("HASTE_RATING", stats.HASTE_RATING, level)
	if haste then
		addLine("Haste Rating", RBA:FormatSigned(haste, 2, "%") .. " Haste")
		addSummary("Haste", haste)
	end

	local spellHaste = self:RatingToPercent("SPELL_HASTE_RATING", stats.SPELL_HASTE_RATING, level)
	if spellHaste then
		addLine("Spell Haste Rating", RBA:FormatSigned(spellHaste, 2, "%") .. " Spell Haste")
		addSummary("Spell Haste", spellHaste)
	end

	local expertise = stats.EXPERTISE_RATING and levelTable and (stats.EXPERTISE_RATING / levelTable.EXPERTISE_RATING) or nil
	if expertise then
		local expertisePercent = stats.EXPERTISE_RATING / levelTable.EXPERTISE_PERCENT_RATING
		addLine("Expertise Rating", RBA:FormatSigned(expertise, 2) .. " Expertise, " .. RBA:FormatSigned(-expertisePercent, 2, "%") .. " Dodge/Parry")
		addSummary("Expertise", expertise)
	end

	local defense = self:RatingToPercent("DEFENSE_RATING", stats.DEFENSE_RATING, level)
	if defense then
		addLine("Defense Rating", RBA:FormatSigned(defense, 2) .. " Defense Skill")
		addSummary("Defense Skill", defense)
		appendUnique(scan.researchNotes, "Defense conversion uses WotLK level 80 baseline from the current design notes; BronzeBeard validation is still pending.")
	end

	local dodge = self:RatingToPercent("DODGE_RATING", stats.DODGE_RATING, level)
	if dodge then
		addLine("Dodge Rating", RBA:FormatSigned(dodge, 2, "%") .. " Dodge (pre-DR)")
		addSummary("Dodge", dodge)
	end

	local parry = self:RatingToPercent("PARRY_RATING", stats.PARRY_RATING, level)
	if parry then
		addLine("Parry Rating", RBA:FormatSigned(parry, 2, "%") .. " Parry (pre-DR)")
		addSummary("Parry", parry)
	end

	local block = self:RatingToPercent("BLOCK_RATING", stats.BLOCK_RATING, level)
	if block then
		addLine("Block Rating", RBA:FormatSigned(block, 2, "%") .. " Block")
		addSummary("Block", block)
	end

	local resilience = self:RatingToPercent("RESILIENCE_RATING", stats.RESILIENCE_RATING, level)
	if resilience then
		addLine("Resilience Rating", RBA:FormatSigned(resilience, 2, "%") .. " Resilience (approx.)")
		addSummary("Resilience", resilience)
		appendUnique(scan.researchNotes, "Resilience is still using an approximate WotLK baseline; BronzeBeard-specific effects still need confirmation.")
	end

	local armorPen = self:RatingToPercent("ARMOR_PENETRATION_RATING", stats.ARMOR_PENETRATION_RATING, level)
	if armorPen then
		addLine("Armor Pen. Rating", RBA:FormatSigned(armorPen, 2, "%") .. " Armor Penetration")
		addSummary("Armor Pen.", armorPen)
	end

	if (stats.HIT_RATING or stats.SPELL_HIT_RATING or stats.CRIT_RATING or stats.SPELL_CRIT_RATING or stats.HASTE_RATING or stats.SPELL_HASTE_RATING or stats.EXPERTISE_RATING)
		and RBA.Compat and RBA.Compat.HasGetCombatRatingBonus then
		appendUnique(scan.researchNotes, RBA.Compat.ResearchNotes.liveStatApis)
	end

	scan._ratingsEnriched = true
end

RBA:RegisterModule("Ratings", Ratings)
