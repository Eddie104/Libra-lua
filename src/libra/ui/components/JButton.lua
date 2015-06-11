--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-12 21:01:09
--

local function createScale9Sprite(img, size, capInsets)
	local s = display.newScale9Sprite(img, 0, 0, size, capInsets):align(display.CENTER, -size.width / 2, -size.height / 2)
	s:ignoreAnchorPointForPosition(true)
	return s
end

local Label = require("libra.ui.components.JLabel")

local JButton = class("JButton", function (param)
	assert(param.normal, "JButton:class() - invalid param:param.normal is nil")
	if param.scale9 then
		return display.newNode()
	else
		return display.newSprite(param.normal)
	end
end)

--- 构造函数
-- @param param {normmal = "按钮正常状态时图片", down = "按钮按下状态图片", unabled = "按钮不可用状态图片",  label = {text = "按钮文字", size = 24}}
-- scale9 = ccsize 如果有值,说明是九宫图, capInsets = CCRect,
function JButton:ctor(param)
	self._param = param
	makeUIComponent(self)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	if param.scale9 then
		self._scale9 = createScale9Sprite(param.normal, param.scale9, param.capInsets):addTo(self)
		self:actualWidth(param.scale9.width)
		self:actualHeight(param.scale9.Height)
	end

	if self._param.label then
		if param.scale9 then
			self._label = Label.new(self._param.label):addTo(self):align(display.CENTER, 0, self._actualHeight / 2)
		else
			self._label = Label.new(self._param.label):addTo(self):align(display.CENTER, self._actualWidth / 2, self._actualHeight / 2)
		end
	end

	self:enabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch))
end

function JButton:enabled(bool)
	if type(bool) == "boolean" then
		if self._enabled ~= bool then
			self._enabled = bool
		end
		if self._param.unabled then
			if self._scale9 then
				self._scale9:removeSelf()
				self._scale9 = createScale9Sprite(self._param.normal, self._param.scale9, self._param.capInsets):addTo(self)
			else
				self:setTexture(self._enabled and self._param.normal or self._param.unabled)
			end
		end
		self:setTouchEnabled(self._enabled)
		return self
	end
	return self._enabled
end

--- 触发点击事件
function JButton:doClick()
	self:dispatchEvent({name = BUTTON_EVENT.CLICKED})
end

function JButton:alignLabel(align, x, y)
	if self._label then
		self._label:align(align, x, y)
	end
	return self
end

function JButton:isTouchMoved()
	return self._isTouchMoved
end

function JButton:onTouch(evt)
	if evt.name == "began" then
		self._isTouchMoved = false
		self._prevX, self._prevY = evt.x, evt.y
		if self._param.down then
			if self._scale9 then
				self._scale9:removeSelf()
				self._scale9 = createScale9Sprite(self._param.down, self._param.scale9, self._param.capInsets):addTo(self)
			else
				self:setTexture(self._param.down)
			end
		else
			self:scale(.9)
		end
		self:onTouchBegan(evt)
		return true
	elseif evt.name == "moved" then
		if math.abs(evt.x - self._prevX) > 10 or math.abs(evt.y - self._prevY) > 10 then
			self._isTouchMoved = true
		end
		self:onTouchMoved(evt)
	elseif evt.name == "ended" then
		if self._param.down then
			if self._scale9 then
				self._scale9:removeSelf()
				self._scale9 = createScale9Sprite(self._param.normal, self._param.scale9, self._param.capInsets):addTo(self)
			else
				self:setTexture(self._param.normal)
			end
		else
			self:scale(1)
		end
		if self:isPointIn(evt.x, evt.y) then
			self:onTouchEnded(evt)
			self:doClick()
		end
		self._isTouchMoved = false
	end
end

function JButton:onTouchBegan(evt)
	self:dispatchEvent({name = BUTTON_EVENT.TOUCH_BEGAN})
end

function JButton:onTouchMoved(evt)
	self:dispatchEvent({name = BUTTON_EVENT.TOUCH_MOVED})
end

function JButton:onTouchEnded(evt)
	self:dispatchEvent({name = BUTTON_EVENT.TOUCH_ENDED})
end

return JButton