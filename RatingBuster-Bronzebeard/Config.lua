local RBA = _G.RatingBusterAscension or {}
_G.RatingBusterAscension = RBA

RBA.Config = RBA.Config or {}
local Config = RBA.Config

function Config:Open()
	RBA:Print("Config UI is not implemented yet. Use /rba reset or edit SavedVariables for now.")
	RBA:Print("Research note: a proper config panel can be added after we validate the BronzeBeard tooltip and item APIs we depend on.")
end

RBA:RegisterModule("Config", Config)
