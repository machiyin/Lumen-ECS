local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.Shared.World).new()
local Entity = World.entity()
local Component = World.component("foo", 1)

Entity.insert(Component)

local System = World.system("bar", "Heartbeat")

function System:update(world)
	for entity, foo in world:query(Component) do
		foo:set(foo() + 1)
		print(entity, foo)
	end
end

System:start(World)
