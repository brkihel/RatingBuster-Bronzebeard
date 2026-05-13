local addonName, RBA = ...

if type(RBA) ~= "table" then
	RBA = _G.RatingBusterAscension or {}
end

_G.RatingBusterAscension = RBA

RBA.addonName = type(addonName) == "string" and addonName or "RatingBuster-Bronzebeard"
RBA.title = "RatingBuster-Bronzebeard"
RBA.version = (type(GetAddOnMetadata) == "function" and GetAddOnMetadata(RBA.addonName, "Version")) or "0.1.3"
RBA.frame = RBA.frame or CreateFrame("Frame")
RBA.modules = RBA.modules or {}
RBA.state = RBA.state or {}
RBA.defaults = {
	enabled = true,
	debug = false,
	showItemID = true,
	showItemLevel = true,
	showRatings = true,
	showStatBreakdown = true,
	showSummary = true,
	showCompare = true,
	ignoreEnchants = false,
	ignoreGems = false,
	ignoreSocketBonus = false,
	colorText = true,
}

local pairs = pairs
local type = type
local tostring = tostring
local tonumber = tonumber
local table_concat = table.concat
local string_format = string.format
local math_floor = math.floor
local math_abs = math.abs

local function copyDefaults(target, defaults)
	local key
	for key in pairs(defaults) do
		if target[key] == nil then
			target[key] = defaults[key]
		end
	end
end

function RBA:GetDB()
	RatingBusterAscensionDB = RatingBusterAscensionDB or {}
	copyDefaults(RatingBusterAscensionDB, self.defaults)
	return RatingBusterAscensionDB
end

function RBA:IsEnabled()
	return self:GetDB().enabled ~= false
end

function RBA:Print(message)
	if DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffd866[RBA]|r " .. tostring(message))
	end
end

function RBA:Debug(message)
	if self:GetDB().debug then
		self:Print(message)
	end
end

function RBA:Trim(text)
	if type(text) ~= "string" then
		return ""
	end
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

function RBA:Round(value, places)
	value = tonumber(value)
	if not value then
		return 0
	end

	local multiplier = 10 ^ (places or 0)
	return math_floor(value * multiplier + 0.5) / multiplier
end

function RBA:FormatNumber(value, places)
	value = tonumber(value)
	if not value then
		return "0"
	end

	return string_format("%." .. (places or 0) .. "f", value)
end

function RBA:FormatSigned(value, places, suffix)
	value = tonumber(value) or 0
	local text = self:FormatNumber(value, places)
	if value > 0 then
		text = "+" .. text
	end
	if suffix then
		text = text .. suffix
	end
	return text
end

function RBA:FormatMetric(name, value)
	if value == nil then
		return nil
	end

	local metricType = self.Stats and self.Stats.SummaryMetricTypes and self.Stats.SummaryMetricTypes[name] or "flat"
	if metricType == "percent" or metricType == "rating" then
		if math_abs(tonumber(value) or 0) < 0.005 then
			return nil
		end
	elseif math_abs(tonumber(value) or 0) < 0.5 then
		return nil
	end

	if metricType == "percent" then
		return name .. " " .. self:FormatSigned(value, 2, "%")
	end
	if metricType == "rating" then
		return name .. " " .. self:FormatSigned(value, 2)
	end
	return name .. " " .. self:FormatSigned(value, 0)
end

function RBA:BuildSettingsKey()
	local db = self:GetDB()
	return table_concat({
		db.enabled and "1" or "0",
		db.debug and "1" or "0",
		db.showItemID and "1" or "0",
		db.showItemLevel and "1" or "0",
		db.showRatings and "1" or "0",
		db.showStatBreakdown and "1" or "0",
		db.showSummary and "1" or "0",
		db.showCompare and "1" or "0",
		db.ignoreEnchants and "1" or "0",
		db.ignoreGems and "1" or "0",
		db.ignoreSocketBonus and "1" or "0",
		db.colorText and "1" or "0",
	}, ":")
end

function RBA:SafeCall(func, ...)
	if type(func) ~= "function" then
		return nil
	end

	local ok, a, b, c, d, e = pcall(func, ...)
	if ok then
		return a, b, c, d, e
	end

	self:Debug("Call failed: " .. tostring(a))
	return nil
end

function RBA:RegisterModule(name, module)
	self.modules[name] = module
end

function RBA:InitializeModules()
	local name
	for name in pairs(self.modules) do
		local module = self.modules[name]
		if type(module.Initialize) == "function" then
			self:SafeCall(module.Initialize, module)
		end
	end
end

function RBA:ResetConfig()
	RatingBusterAscensionDB = {}
	self:GetDB()
	if self.ItemCache then
		self.ItemCache:Reset()
	end
end

function RBA:HandleSlashCommand(input)
	input = self:Trim(input or "")
	local command, argument = string.match(input, "^(%S+)%s*(.-)$")
	command = string.lower(command or "")
	argument = string.lower(argument or "")

	if command == "" or command == "help" then
		self:Print("/rba help, debug, scan, dump, config, reset, version")
		return
	end

	if command == "debug" then
		if argument == "on" then
			self:GetDB().debug = true
		elseif argument == "off" then
			self:GetDB().debug = false
		else
			self:GetDB().debug = not self:GetDB().debug
		end
		self:Print("Debug " .. (self:GetDB().debug and "enabled." or "disabled."))
		return
	end

	if command == "scan" or command == "dump" then
		if self.DebugModule then
			self.DebugModule:DumpLastInspection()
		end
		return
	end

	if command == "config" then
		if self.Config then
			self.Config:Open()
		end
		return
	end

	if command == "reset" then
		self:ResetConfig()
		self:Print("Configuration reset to defaults.")
		return
	end

	if command == "version" then
		self:Print(self.title .. " " .. self.version)
		return
	end

	self:Print("Unknown command. Use /rba help.")
end

SlashCmdList.RATINGBUSTERASCENSION = function(msg)
	RBA:HandleSlashCommand(msg)
end
SLASH_RATINGBUSTERASCENSION1 = "/rba"
SLASH_RATINGBUSTERASCENSION2 = "/ratingbusterascension"
SLASH_RATINGBUSTERASCENSION3 = "/ratingbuster-bronzebeard"

RBA.frame:SetScript("OnEvent", function(_, event, ...)
	if event == "ADDON_LOADED" then
		local loadedName = ...
		if loadedName == RBA.addonName then
			RBA:GetDB()
			if RBA.Compat then
				RBA.Compat:DetectCapabilities()
			end
			RBA:InitializeModules()
			RBA:Print(RBA.title .. " " .. RBA.version .. " loaded.")
		end
	elseif event == "PLAYER_LOGIN" then
		if RBA.Tooltip then
			RBA.Tooltip:HookAll()
		end
	elseif event == "PLAYER_LEVEL_UP" or event == "MODIFIER_STATE_CHANGED" then
		if RBA.ItemCache then
			RBA.ItemCache:Reset()
		end
	end
end)

RBA.frame:RegisterEvent("ADDON_LOADED")
RBA.frame:RegisterEvent("PLAYER_LOGIN")
RBA.frame:RegisterEvent("PLAYER_LEVEL_UP")
RBA.frame:RegisterEvent("MODIFIER_STATE_CHANGED")
