--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 14:01:02
--

local JContainer = class("JContainer", function ()
	return display.newNode()
end)

-- @param param {bg="背景图", size = cc.size() or nil, capInsets = cc.rect() or nil}
function JContainer:ctor(param)
	self._param = param or {width = display.width, height = display.height}
	makeUIComponent(self)
	
	if self._param.size then
		self:setSize(self._param.size.width, self._param.size.height)
	else
		self:setSize()
	end
	self._componentList = { }
end

function JContainer:createUI(uiConfig)
	local uiComponent = nil
	for _, ui in ipairs(uiConfig) do
		uiComponent = require(ui.ui).new(ui.param):addToContainer(self)
		if ui.id then
			self[ui.id] = uiComponent
			uiComponent:name(ui.id)
		end
		for k, v in pairs(ui) do
			if k ~= "id" and k ~= 'ui' and k ~= 'param' then
				if type(uiComponent[k]) == "function" then
					if type(v) == "table" then
						local l = #v
						if l == 1 then
							uiComponent[k](uiComponent, v[1])
						elseif l == 2 then
							uiComponent[k](uiComponent, v[1], v[2])
						elseif l == 3 then
							uiComponent[k](uiComponent, v[1], v[2], v[3])
						elseif l == 4 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4])
						elseif l == 5 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4], v[5])
						elseif l == 6 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4], v[5], v[6])
						elseif l == 7 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4], v[5], v[6], v[7])
						elseif l == 8 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
						elseif l == 9 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9])
						elseif l == 10 then
							uiComponent[k](uiComponent, v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10])
						end
					else
						uiComponent[k](uiComponent, v)
					end
				end
			end
		end
	end
end

function JContainer:setSize(width, height)
	width = width or display.width
	height = height or display.height
	self:actualWidth(width):actualHeight(height)
	if self._param and self._param.bg then
		if self._bg then
			if self._param.size then
				self._bg:setContentSize(size):pos(width / 2, height / 2)
			end
		else
			if self._param.size then
				self._bg = display.newScale9Sprite(self._param.bg, width / 2, height / 2, self._param.size, self._param.capInsets):addTo(self, -1):align(display.CENTER)
			else
				self._bg = display.newSprite(self._param.bg):addTo(self, -1):pos(display.cx, display.cy)
			end
		end
	end
	return self
end

function JContainer:getSize()
	return self._actualWidth, self._actualHeight
end

function JContainer:isContainer()
	return true
end

function JContainer:addUIComponent(component, zOrder)
	if not table.indexof(self._componentList, component) then
		self:addChild(component)
		if type(zOrder) == "number" then
			component:zorder(zOrder)
		end
		self._componentList[#self._componentList + 1] = component
	end
	return self
end

function JContainer:getComponent(name)
	if name and name ~= '' then
		for _, v in ipairs(self._componentList) do
			if v:name() == name then return v end
		end
	end
end

function JContainer:removeUIComponent(component)
	local index = table.indexof(self._componentList, component)
	if index then
		table.remove(self._componentList, index)
		component:removeFromParent(true)
	end
end

function JContainer:clearComponents()
	self:removeAllChildren()
	self._componentList = { }
end

return JContainer