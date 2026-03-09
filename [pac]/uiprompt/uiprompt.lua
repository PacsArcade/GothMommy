--- UI prompts and prompt groups

-- Treat 0 return value of some natives as falsey
local function toboolean(value)
	if not value or value == 0 then
		return false
	else
		return true
	end
end

-- Base class from which other classes are derived

local Class = {}

setmetatable(Class, {
	__call = function(self)
		self.__call = getmetatable(self).__call
		self.__index = self
		return setmetatable({}, self)
	end
})

function Class:new()
	return self()
end

--- System for automatically handling and cleaning up prompts and groups.
-- @type UipromptManager
UipromptManager = Class()
UipromptManager.prompts = {}
UipromptManager.groups = {}

function UipromptManager:addPrompt(prompt)
	self.prompts[prompt] = true
end

function UipromptManager:removePrompt(object)
	if self.prompts[prompt] then
		self.prompts[prompt] = nil
	end
end

function UipromptManager:addGroup(group)
	self.groups[group] = true
end

function UipromptManager:removeGroup(group)
	if self.groups[group] then
		self.groups[group] = nil
	end
end

function UipromptManager:startEventThread()
	Citizen.CreateThread(function()
		while true do
			for group, _ in pairs(self.groups) do
				group:handleEvents()
			end
			for prompt, _ in pairs(self.prompts) do
				prompt:handleEvents()
			end
			Citizen.Wait(0)
		end
	end)
end

function UipromptManager:delete()
	for group, _ in pairs(UipromptManager.groups) do
		group:delete()
	end
	for prompt, _ in pairs(UipromptManager.prompts) do
		prompt:delete()
	end
end

AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() == resourceName then
		UipromptManager:delete()
	end
end)

Uiprompt = Class()

function Uiprompt:new(controls, text, group, enabled)
	local self = Class.new(self)
	self.handle = PromptRegisterBegin()
	if type(controls) ~= "table" then
		self.controls = {controls}
	else
		self.controls = controls
	end
	for _, control in ipairs(self.controls) do
		if type(control) == "string" then
			PromptSetControlAction(self.handle, GetHashKey(control))
		else
			PromptSetControlAction(self.handle, control)
		end
	end
	self:setText(text)
	if enabled == false then
		self:setEnabledAndVisible(false)
	end
	if group then
		self:setGroup(group)
	else
		UipromptManager:addPrompt(self)
	end
	PromptRegisterEnd(self.handle)
	return self
end

function Uiprompt:getHandle() return self.handle end
function Uiprompt:isActive() return PromptIsActive(self.handle) end
function Uiprompt:isEnabled() return toboolean(PromptIsEnabled(self.handle)) end
function Uiprompt:setEnabled(toggle) PromptSetEnabled(self.handle, toggle); return self end
function Uiprompt:setVisible(toggle) PromptSetVisible(self.handle, toggle); return self end
function Uiprompt:setEnabledAndVisible(toggle) self:setEnabled(toggle); self:setVisible(toggle); return self end
function Uiprompt:isJustPressed() return PromptIsJustPressed(self.handle) end
function Uiprompt:isJustReleased() return PromptIsJustReleased(self.handle) end
function Uiprompt:isPressed() return PromptIsPressed(self.handle) end
function Uiprompt:isReleased() return PromptIsReleased(self.handle) end
function Uiprompt:isValid() return PromptIsValid(self.handle) end
function Uiprompt:setStandardMode(toggle) PromptSetStandardMode(self.handle, toggle); return self end
function Uiprompt:hasStandardModeCompleted() return PromptHasStandardModeCompleted(self.handle) end
function Uiprompt:hasStandardModeJustCompleted()
	if self.awaitingStandardModeEnd then
		if not self:hasStandardModeCompleted() then self.awaitingStandardModeEnd = false end
		return false
	else
		if self:hasStandardModeCompleted() then self.awaitingStandardModeEnd = true; return true
		else return false end
	end
end
function Uiprompt:hasHoldMode() return PromptHasHoldMode(self.handle) end
function Uiprompt:setHoldMode(toggle) PromptSetHoldMode(self.handle, toggle); return self end
function Uiprompt:isHoldModeRunning() return PromptIsHoldModeRunning(self.handle) end
function Uiprompt:hasHoldModeCompleted() return PromptHasHoldModeCompleted(self.handle) end
function Uiprompt:hasHoldModeJustCompleted()
	if self.awaitingHoldModeEnd then
		if not self:isHoldModeRunning() then self.awaitingHoldModeEnd = false end
		return false
	else
		if self:hasHoldModeCompleted() then self.awaitingHoldModeEnd = true; return true
		else return false end
	end
end
function Uiprompt:setText(text)
	local str = CreateVarString(10, "LITERAL_STRING", text)
	PromptSetText(self.handle, str)
	self.text = text
	return self
end
function Uiprompt:setGroup(group)
	if type(group) == "table" then group:addPrompt(self)
	else PromptSetGroup(self.handle, group); UipromptManager:addPrompt(self) end
	return self
end
function Uiprompt:doForEachControl(func, padIndex)
	for _, control in ipairs(self.controls) do
		if func(padIndex, control) then return true end
	end
	return false
end
function Uiprompt:isControlPressed(padIndex) return self:doForEachControl(IsControlPressed, padIndex) end
function Uiprompt:isControlReleased(padIndex) return self:doForEachControl(IsControlReleased, padIndex) end
function Uiprompt:isControlJustPressed(padIndex) return self:doForEachControl(IsControlJustPressed, padIndex) end
function Uiprompt:isControlJustReleased(padIndex) return self:doForEachControl(IsControlJustReleased, padIndex) end
function Uiprompt:setOnJustPressed(h) self.onJustPressed=h; return self end
function Uiprompt:setOnJustReleased(h) self.onJustReleased=h; return self end
function Uiprompt:setOnPressed(h) self.onPressed=h; return self end
function Uiprompt:setOnReleased(h) self.onReleased=h; return self end
function Uiprompt:setOnStandardModeCompleted(h) self.onStandardModeCompleted=h; return self end
function Uiprompt:setOnStandardModeJustCompleted(h) self.onStandardModeJustCompleted=h; return self end
function Uiprompt:setOnHoldModeRunning(h) self.onHoldModeRunning=h; return self end
function Uiprompt:setOnHoldModeCompleted(h) self.onHoldModeCompleted=h; return self end
function Uiprompt:setOnHoldModeJustCompleted(h) self.onHoldModeJustCompleted=h; return self end
function Uiprompt:handleEvents(...)
	if self:isEnabled() then
		if self.onJustPressed and self:isJustPressed() then self:onJustPressed(...) end
		if self.onJustReleased and self:isJustReleased() then self:onJustReleased(...) end
		if self.onPressed and self:isPressed() then self:onPressed(...) end
		if self.onReleased and self:isReleased() then self:onReleased(...) end
		if self.onStandardModeCompleted and self:hasStandardModeCompleted() then self:onStandardModeCompleted() end
		if self.onStandardModeJustCompleted and self:hasStandardModeJustCompleted() then self:onStandardModeJustCompleted() end
		if self.onHoldModeRunning and self:isHoldModeRunning() then self:onHoldModeRunning(...) end
		if self.onHoldModeCompleted and self:hasHoldModeCompleted() then self:onHoldModeCompleted(...) end
		if self.onHoldModeJustCompleted and self:hasHoldModeJustCompleted() then self:onHoldModeJustCompleted(...) end
	end
end
function Uiprompt:delete() UipromptManager:removePrompt(self); PromptDelete(self.handle) end

UipromptGroup = Class()

function UipromptGroup:new(text, active)
	local self = Class.new(self)
	self.groupId = GetRandomIntInRange(0, 0xFFFFFF)
	self.text = text
	self.prompts = {}
	self.active = active ~= false
	UipromptManager:addGroup(self)
	return self
end

function UipromptGroup:getGroupId() return self.groupId end
function UipromptGroup:setActiveThisFrame()
	local str = CreateVarString(10, "LITERAL_STRING", self.text)
	PromptSetActiveGroupThisFrame(self.groupId, str)
	return self
end
function UipromptGroup:getText() return self.text end
function UipromptGroup:setText(text) self.text=text; return self end
function UipromptGroup:getPrompts() return self.prompts end
function UipromptGroup:addPrompt(prompt)
	if type(prompt) == "table" then
		UipromptManager:removePrompt(prompt)
		PromptSetGroup(prompt:getHandle(), self.groupId)
		table.insert(self.prompts, prompt)
	else PromptSetGroup(prompt, self.groupId) end
	return prompt
end
function UipromptGroup:doForEachPrompt(methodName, callback, ...)
	local result = false
	for _, prompt in ipairs(self.prompts) do
		if prompt[methodName](prompt, ...) then
			result = true
			if callback then callback(prompt) else break end
		end
	end
	return result
end
function UipromptGroup:hasStandardModeCompleted(cb) return self:doForEachPrompt("hasStandardModeCompleted",cb) end
function UipromptGroup:hasStandardModeJustCompleted(cb) return self:doForEachPrompt("hasStandardModeJustCompleted",cb) end
function UipromptGroup:isHoldModeRunning(cb) return self:doForEachPrompt("isHoldModeRunning",cb) end
function UipromptGroup:hasHoldModeCompleted(cb) return self:doForEachPrompt("hasHoldModeCompleted",cb) end
function UipromptGroup:hasHoldModeJustCompleted(cb) return self:doForEachPrompt("hasHoldModeJustCompleted",cb) end
function UipromptGroup:isActive() return self.active end
function UipromptGroup:setActive(toggle) self.active=toggle; return self end
function UipromptGroup:setEnabled(toggle)
	for _, prompt in ipairs(self.prompts) do prompt:setEnabled(toggle) end
	return self
end
function UipromptGroup:setOnHoldModeJustCompleted(h) self.onHoldModeJustCompleted=h; return self end
function UipromptGroup:setOnStandardModeJustCompleted(h) self.onStandardModeJustCompleted=h; return self end
function UipromptGroup:handleEvents(...)
	if not self:isActive() then return end
	self:setActiveThisFrame()
	for _, prompt in ipairs(self.prompts) do
		if prompt:isEnabled() then
			if self.onHoldModeJustCompleted and prompt:hasHoldModeJustCompleted() then self:onHoldModeJustCompleted(prompt,...) end
			if self.onStandardModeJustCompleted and prompt:hasStandardModeJustCompleted() then self:onStandardModeJustCompleted(prompt,...) end
			prompt:handleEvents(...)
		end
	end
end
function UipromptGroup:delete()
	UipromptManager:removeGroup(self)
	for _, prompt in ipairs(self.prompts) do prompt:delete() end
end
