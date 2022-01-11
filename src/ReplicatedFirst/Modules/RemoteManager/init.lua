-- Author: RainyLofi#0001
-- Purpose: Manage remote functionality & events.

-----------------------------------------------

local RunService = game:GetService('RunService')
local IsServer = RunService:IsServer()

local ReplicatedStorage = game:GetService('ReplicatedStorage')

-----------------------------------------------

local Module = {}

Module.RemoteStorage = ReplicatedStorage:FindFirstChild('Remotes')
if IsServer and not Module.RemoteStorage then
	Module.RemoteStorage = Instance.new('Folder', ReplicatedStorage)
	Module.RemoteStorage.Name = 'Remotes'
elseif not IsServer then
	Module.RemoteStorage = ReplicatedStorage:WaitForChild('Remotes')
end

Module.BindParent = IsServer and game:GetService('ServerStorage') or ReplicatedStorage
Module.BindStorage = Module.BindParent:FindFirstChild('Bindables')
if not Module.BindStorage then
	Module.BindStorage = Instance.new('Folder', Module.BindParent)
	Module.BindStorage.Name = 'Bindables'
end

local RemoteInstance = require(script:WaitForChild('RemoteInstance'))

-----------------------------------------------

Module.Encode = function(data: string)
	local b = '␍␛␙␆␂␋␔␕␜␝␒␑␈␏␍␂␂␒␐␏␛␍␂␐␍␊␕␍␃␘␃␞␕␄␋␁␖␕␞␎␓␎␀␋␒␋␐␅␋␙␔␒␓␔␝␓␍␚␡␆␎␗␗␆'

	if not RunService:IsStudio() then data = game.JobId .. data end

	return ((data:gsub('.', function(x)
		local r,b='',x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end

-----------------------------------------------

local Types = { -- classname -> remote/not, event/function
	['RemoteEvent'] = {true, true},
	['RemoteFunction'] = {true, false},
	['BindableEvent'] = {false, true},
	['BindableFunction'] = {false, false}
}

Module.Get = function(self, Type: string, Name: string)
	
	-- check to see if the script getting the remote is valid
	-- can be bypassed using syn.secure_call however this is better than nothing
	local _, Source = pcall(function() return getfenv(2).script end)
	if not Source or not Source.Parent then return Module:Get(true, 'DONT_EXPLOIT!') end -- should crash
	
	local TypeData = Types[Type]
	if not TypeData then return end

	local IsRemote = table.unpack(TypeData)

	local EncodedName = Module.Encode(Name)
	local Parent = IsRemote and Module.RemoteStorage or Module.BindStorage

	local Remote = Parent:FindFirstChild(EncodedName)
	if not Remote then
		if not IsServer and IsRemote then -- client should wait for any events that are remote
			Remote = Parent:WaitForChild(EncodedName)
		end
	end

	return RemoteInstance.new(EncodedName, TypeData, Type, Parent)
end

return Module
