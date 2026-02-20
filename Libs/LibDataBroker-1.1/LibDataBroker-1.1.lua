-- LibDataBroker-1.1
-- Simplified broker for minimap icons and clickable elements

assert(LibStub, "LibDataBroker-1.1 requires LibStub")
local LibDataBroker = LibStub:NewLibrary("LibDataBroker-1.1", 6)
if not LibDataBroker then return end

local brokers = {}
local mixin = {}

function mixin:Hide()
	if self.OnHide then self:OnHide() end
	self.hidden = true
end

function mixin:Show()
	if self.OnShow then self:OnShow() end
	self.hidden = nil
end

function mixin:IsShown()
	return not self.hidden
end

function LibDataBroker:NewDataObject(key, tbl)
	assert(key and type(key) == "string", "Usage: NewDataObject(key, tbl)")
	assert(not brokers[key], ("A data object with key %q already exists"):format(key))

	tbl = tbl or {}
	setmetatable(tbl, {__index = mixin})
	brokers[key] = tbl
	return tbl
end

function LibDataBroker:GetDataObjectByKey(key)
	return brokers[key]
end

function LibDataBroker:EnumerateDataObjects()
	return pairs(brokers)
end
