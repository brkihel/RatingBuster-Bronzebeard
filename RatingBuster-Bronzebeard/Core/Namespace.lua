RatingBuster_BronzebeardNS = RatingBuster_BronzebeardNS or {}

local ns = RatingBuster_BronzebeardNS

ns.ADDON_NAME = "RatingBuster-Bronzebeard"
ns.ADDON_TITLE = "RatingBuster-Bronzebeard"
ns.DB_NAME = "RatingBuster_BronzebeardDB"
ns.VERSION = "0.1.0"
ns.state = ns.state or {}
ns.defaults = ns.defaults or {
	profile = {
		enabled = true,
		debug = false,
		showRatings = true,
		showPrimary = true,
		showSummary = true,
		showComparison = true,
		showGemInfo = true,
		showDebugTooltipLines = false,
		textColor = {
			r = 1.0,
			g = 0.85,
			b = 0.30,
		},
		maxSummaryEntries = 6,
		maxComparisonEntries = 6,
	},
}

local type = type
local tostring = tostring
local tonumber = tonumber
local string_format = string.format
local math_floor = math.floor

function ns.GetProfile()
	if ns.Addon and ns.Addon.db and ns.Addon.db.profile then
		return ns.Addon.db.profile
	end

	return ns.defaults.profile
end

function ns.SafeCall(func, ...)
	if type(func) ~= "function" then
		return nil
	end

	local ok, a, b, c, d, e, f = pcall(func, ...)
	if ok then
		return a, b, c, d, e, f
	end

	if ns.Addon and type(ns.Addon.Print) == "function" and ns.GetProfile().debug then
		ns.Addon:Print("Call failed: " .. tostring(a))
	end

	return nil
end

function ns.Trim(text)
	if type(text) ~= "string" then
		return ""
	end

	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

function ns.Round(value, places)
	value = tonumber(value)
	if not value then
		return 0
	end

	local multiplier = 10 ^ (places or 0)
	return math_floor(value * multiplier + 0.5) / multiplier
end

function ns.FormatNumber(value, places)
	value = tonumber(value)
	if not value then
		return "0"
	end

	places = places or 0
	return string_format("%." .. places .. "f", value)
end

function ns.FormatSignedNumber(value, places)
	value = tonumber(value) or 0
	local formatted = ns.FormatNumber(value, places)
	if value > 0 then
		return "+" .. formatted
	end
	return formatted
end

function ns.FormatSignedPercent(value, places)
	return ns.FormatSignedNumber(value, places or 2) .. "%"
end

function ns.SafeAddLine(tooltip, text, r, g, b)
	if tooltip and type(tooltip.AddLine) == "function" and text and text ~= "" then
		tooltip:AddLine(text, r, g, b)
	end
end

function ns.SafeAddDoubleLine(tooltip, left, right, lr, lg, lb, rr, rg, rb)
	if tooltip and type(tooltip.AddDoubleLine) == "function" and left and right then
		tooltip:AddDoubleLine(left, right, lr, lg, lb, rr, rg, rb)
	elseif tooltip and type(tooltip.AddLine) == "function" and left and right then
		tooltip:AddLine(left .. ": " .. right, lr, lg, lb)
	end
end

function ns.GetTextColor()
	local color = ns.GetProfile().textColor or ns.defaults.profile.textColor
	return color.r or 1, color.g or 1, color.b or 1
end

function ns.IsSignificant(value, threshold)
	value = tonumber(value) or 0
	return value <= -(threshold or 0.005) or value >= (threshold or 0.005)
end

function ns.Debug(message)
	if not ns.GetProfile().debug then
		return
	end

	if ns.Addon and type(ns.Addon.Print) == "function" then
		ns.Addon:Print(message)
	elseif DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffd866[RBA]|r " .. tostring(message))
	end
end
