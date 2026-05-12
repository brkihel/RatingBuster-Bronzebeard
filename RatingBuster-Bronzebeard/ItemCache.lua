local RBA = _G.RatingBusterAscension or {}
_G.RatingBusterAscension = RBA

RBA.ItemCache = RBA.ItemCache or {
	inspections = {},
	scans = {},
}

local ItemCache = RBA.ItemCache

function ItemCache:Reset()
	self.inspections = {}
	self.scans = {}
	RBA.state.lastInspection = nil
end

function ItemCache:GetScan(key)
	return self.scans[key]
end

function ItemCache:SetScan(key, value)
	self.scans[key] = value
end

function ItemCache:GetInspection(key)
	return self.inspections[key]
end

function ItemCache:SetInspection(key, value)
	self.inspections[key] = value
	RBA.state.lastInspection = value
end

RBA:RegisterModule("ItemCache", ItemCache)
