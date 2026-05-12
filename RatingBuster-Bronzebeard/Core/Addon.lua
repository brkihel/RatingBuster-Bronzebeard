local ns = RatingBuster_BronzebeardNS

local LibStub = _G.LibStub
local AceAddon = LibStub and LibStub("AceAddon-3.0", true)
local AceDB = LibStub and LibStub("AceDB-3.0", true)

local addon
if AceAddon then
	addon = AceAddon:NewAddon(ns.ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
else
	addon = CreateFrame and CreateFrame("Frame") or {}
end

ns.Addon = addon
_G[ns.ADDON_NAME] = addon

local function printMessage(self, message)
	if type(self.Print) == "function" then
		self:Print(message)
	elseif DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffd866[RBA]|r " .. tostring(message))
	end
end

local function setDebug(enabled)
	ns.GetProfile().debug = enabled and true or false
	printMessage(addon, "Debug " .. (enabled and "enabled" or "disabled") .. ".")
end

local function printHelp()
	printMessage(addon, "/rba help - show commands")
	printMessage(addon, "/rba debug on|off|toggle - toggle debug mode")
	printMessage(addon, "/rba dump - print the last inspected item data")
	printMessage(addon, "/rba enable - enable tooltip output")
	printMessage(addon, "/rba disable - disable tooltip output")
	printMessage(addon, "/rba version - print the current addon version")
	printMessage(addon, "/rba reset - reset the profile")
end

function addon:HandleSlashCommand(input)
	input = ns.Trim(input or "")
	local command, argument = string.match(input, "^(%S+)%s*(.-)$")
	command = string.lower(command or "")
	argument = string.lower(argument or "")

	if command == "" or command == "help" then
		printHelp()
		return
	end

	if command == "debug" then
		if argument == "on" then
			setDebug(true)
		elseif argument == "off" then
			setDebug(false)
		else
			setDebug(not ns.GetProfile().debug)
		end
		return
	end

	if command == "dump" or command == "scan" then
		ns.Engine:DumpInspection(ns.state.lastInspection, self)
		return
	end

	if command == "version" then
		printMessage(self, ns.ADDON_TITLE .. " " .. ns.VERSION)
		return
	end

	if command == "enable" then
		ns.GetProfile().enabled = true
		printMessage(self, "Tooltip output enabled.")
		return
	end

	if command == "disable" then
		ns.GetProfile().enabled = false
		printMessage(self, "Tooltip output disabled.")
		return
	end

	if command == "reset" then
		if self.db and type(self.db.ResetProfile) == "function" then
			self.db:ResetProfile()
			printMessage(self, "Profile reset.")
		else
			printMessage(self, "Profile reset is unavailable.")
		end
		return
	end

	printHelp()
end

function addon:OnInitialize()
	if AceDB then
		self.db = AceDB:New(ns.DB_NAME, ns.defaults)
	end

	if not self.db or not self.db.profile then
		self.db = self.db or {}
		self.db.profile = self.db.profile or {}
		local key
		for key in pairs(ns.defaults.profile) do
			if self.db.profile[key] == nil then
				self.db.profile[key] = ns.defaults.profile[key]
			end
		end
	end

	if type(self.RegisterChatCommand) == "function" then
		self:RegisterChatCommand("rba", "HandleSlashCommand")
		self:RegisterChatCommand("ratingbusterascension", "HandleSlashCommand")
	elseif type(SlashCmdList) == "table" then
		SlashCmdList.RBABRONZEBEARD = function(msg)
			addon:HandleSlashCommand(msg)
		end
		SLASH_RBABRONZEBEARD1 = "/rba"
		SLASH_RBABRONZEBEARD2 = "/ratingbusterascension"
	end
end

function addon:OnEnable()
	ns.Tooltip:Hook()

	if type(self.RegisterEvent) == "function" then
		self:RegisterEvent("PLAYER_LEVEL_UP", function()
			ns.state.lastInspection = nil
		end)
		self:RegisterEvent("MODIFIER_STATE_CHANGED", function()
			ns.state.lastInspection = nil
		end)
	end
end

function addon:OnDisable()
	ns.Tooltip:Unhook()
end
