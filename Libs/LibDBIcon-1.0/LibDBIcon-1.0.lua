-- LibDBIcon-1.0
-- Minimap icon support using LibDataBroker

assert(LibStub, "LibDBIcon-1.0 requires LibStub")
local LibDataBroker = LibStub("LibDataBroker-1.1", true)
assert(LibDataBroker, "LibDBIcon-1.0 requires LibDataBroker-1.1")

local ICON_VERSION = 1
local LibDBIcon = LibStub:NewLibrary("LibDBIcon-1.0", 1)
if not LibDBIcon then return end

LibDBIcon.callbacks = LibDBIcon.callbacks or LibStub:GetLibrary("CallbackHandler-1.0", true)
if not LibDBIcon.callbacks then
	LibDBIcon.callbacks = { Register = function() end, Fire = function() end }
end

local icons = {}
local hdlr = {}

function hdlr:OnClick(button)
	if self.dbo.OnClick then
		local obj = self.dbo
		obj:OnClick(button)
	end
end

function hdlr:OnEnter()
	if self.dbo.OnEnter then
		self.dbo:OnEnter()
	end
	if self.dbo.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine(self.dbo.tooltip)
		GameTooltip:Show()
	end
end

function hdlr:OnLeave()
	if self.dbo.OnLeave then
		self.dbo:OnLeave()
	end
	GameTooltip:Hide()
end

function LibDBIcon:Register(key, dbo, db)
	if icons[key] then return icons[key] end

	db = db or {}
	db.hide = db.hide or false
	db.angle = db.angle or 225

	local button = CreateFrame("Button", "LibDBIcon_"..key, Minimap)
	button:SetSize(32, 32)
	button:SetFrameStrata("MEDIUM")
	button:SetMovable(true)
	button:EnableMouse(true)
	button:RegisterForDrag("LeftButton")
	button.dbo = dbo
	button.db = db

	-- Set icon texture
	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetSize(16, 16)
	icon:SetPoint("CENTER")
	if dbo.icon then
		icon:SetTexture(dbo.icon)
	end
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	button.icon = icon

	-- Add circular mask
	local iconMask = button:CreateMaskTexture()
	iconMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
	iconMask:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
	iconMask:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
	icon:AddMaskTexture(iconMask)

	-- Add border
	local border = button:CreateTexture(nil, "OVERLAY")
	border:SetAllPoints()
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

	-- Add highlight
	if button.SetHighlightTexture then
		button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
	end

	button:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)

	button:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local x, y = self:GetCenter()
		local mx, my = Minimap:GetCenter()
		db.angle = math.deg(math.atan2(y - my, x - mx))
	end)

	button:SetScript("OnClick", hdlr.OnClick)
	button:SetScript("OnEnter", hdlr.OnEnter)
	button:SetScript("OnLeave", hdlr.OnLeave)

	local function UpdatePosition()
		local radius = (Minimap:GetWidth() / 2) + 5
		local rad = math.rad(db.angle or 225)
		local x = math.cos(rad) * radius
		local y = math.sin(rad) * radius
		button:SetPoint("CENTER", Minimap, "CENTER", x, y)
	end

	UpdatePosition()

	if db.hide then
		button:Hide()
	else
		button:Show()
	end

	button.UpdatePosition = UpdatePosition

	icons[key] = button
	return button
end

function LibDBIcon:GetMinimapButton(key)
	return icons[key]
end

function LibDBIcon:Hide(key)
	local button = icons[key]
	if button then
		button.db.hide = true
		button:Hide()
	end
end

function LibDBIcon:Show(key)
	local button = icons[key]
	if button then
		button.db.hide = false
		button:Show()
		if button.UpdatePosition then
			button:UpdatePosition()
		end
	end
end

function LibDBIcon:IsHidden(key)
	local button = icons[key]
	return button and button.db.hide or false
end
