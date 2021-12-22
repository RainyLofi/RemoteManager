-- Author: RainyLofi#0001
-- Purpose: The actual instance scripts receive after getting the event.

-----------------------------------------------

local RunService = game:GetService('RunService')
local IsServer = RunService:IsServer()

-----------------------------------------------

local RemoteInstance = {}
RemoteInstance.__index = RemoteInstance
RemoteInstance.__call = function(self, ...) return self:Call(...) end

local ResolveRemote = function(Remote: Instance, All: boolean)
    if Remote:IsA('BindableEvent') then
        return Remote.Fire, Remote.Event
    elseif Remote:IsA('BindableFunction') then
        return Remote.Invoke, function(Callback) Remote.OnInvoke = Callback end
    elseif Remote:IsA('RemoteEvent') then
        if not IsServer then
            return Remote.FireServer, Remote.OnClientEvent
        else
            return All and Remote.FireAllClients or Remote.FireClient, Remote.OnServerEvent
        end
    elseif Remote:IsA('RemoteFunction') then
        if not IsServer then
            return Remote.InvokeServer, function(Callback) Remote.OnClientInvoke = Callback end
        else
            return Remote.InvokeClient, function(Callback) Remote.OnServerInvoke = Callback end
        end
    end
end

function RemoteInstance.new(Name: string, TypeData: table, ClassName: string, Parent: Instance)
    local IsRemote, IsEvent = table.unpack(TypeData)
    local NewInstance = {
        Name = Name,
        ClassName = ClassName,
        Parent = Parent,
        IsRemote = IsRemote,
        IsEvent = IsEvent,
    }

    local Remote = Parent:FindFirstChild(Name)
    if not Remote then
        Remote = Instance.new(ClassName, Parent)
		Remote.Name = Name
    end

    NewInstance.Remote = Remote

    setmetatable(NewInstance, RemoteInstance)
    return NewInstance
end

function RemoteInstance.Call(self, ...)
    local CallMethod = ResolveRemote(self.Remote, false)
    return CallMethod(self.Remote, ...)
end

function RemoteInstance.CallAll(self, ...)
    local CallMethod = ResolveRemote(self.Remote, true)
    return CallMethod(self.Remote, ...)
end

function RemoteInstance.Connect(self, Callback)
    local _, Event = ResolveRemote(self.Remote, false)

    if typeof(Event) == 'RBXScriptSignal' then
        Event:Connect(Callback)
    elseif typeof(Event) == 'function' then
        Event(Callback)
    end

    return self
end

return RemoteInstance