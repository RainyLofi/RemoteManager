# RemoteManager
## A module for managing how scripts create and interact with remote events. 

Benefits of using RemoteManager:
- No need to manually create new remote instances such as RemoteEvent/Functions.
- The instances created have encoded names that change every server.
- In order for an exploiter to find the remote event they want, they would have to either decrypt each event or also use the remote manager.
- Cleans up code substantionally.

![image](https://user-images.githubusercontent.com/71572372/147087358-03f36818-7ac2-4415-a9c6-c6fdda8bfa6f.png)

## Example of usage

### On the server:
```lua
local ReplicatedFirst = game:GetService('ReplicatedFirst')
local Modules = ReplicatedFirst:WaitForChild('Modules')
local RM = require(Modules:WaitForChild('RemoteManager'))

-- Client -> Server: Remote event for printing text to the server
RM:Get('RemoteEvent', 'PrintServer'):Connect(function(Player, Text)
  print(Player.Name .. ':', tostring(Text))
end)

-- Client -> Server -> Client: Remote function for returning number + 1
RM:Get('RemoteFunction', 'PlusOne'):Connect(function(Player, Number)
  return tonumber(Number) + 1
end)
```
### On the client:
```lua
local ReplicatedFirst = game:GetService('ReplicatedFirst')
local Modules = ReplicatedFirst:WaitForChild('Modules')
local RM = require(Modules:WaitForChild('RemoteManager'))

-- Get the server to print some text
RM:Get('RemoteEvent', 'PrintServer')('Hello, world!')

-- Get the result of the server adding one to number
local StartNumber = 0
local NewNumber = RM:Get('RemoteFunction', 'PlusOne')(StartNumber)
print(NewNumber == StartNumber + 1) -- should be true
```

## More details

To create (or get) a new remote instance, you just need to :Get the type (RemoteEvent, RemoteFunction, BindableEvent, BindableFunction) and then also provide a name to reference the instance by.

You can just call the remote instances directly instead of having to bother with :FireClient or :FireServer (and InvokeClient/InvokeServer, Fire & Invoke).
If you want to fire to all clients, you can do RemoteInstance:CallAll (equivalent to :FireAllClients).

The module also supports bindable events/functions. Bindable events/functions created on the server can only be accessed by the server and bindable events/functions created on the client can only be accessed by the client.
