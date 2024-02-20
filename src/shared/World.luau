local RunService = game:GetService("RunService")

local DEBUG = false

local World = {}

function World.new()
	local world = {
		_nextEntityId = 0,
		_entities = {},
	}

	function world.entity()
		world._nextEntityId += 1

		local entity = {
			_id = world._nextEntityId,
			_components = {},
		}

		world._entities[entity._id] = entity

		function entity.insert(component)
			entity._components[component._name] = component
			if DEBUG then
				print("entity.insert", entity._id, component)
			end
		end

		function entity.remove(component)
			entity._components[component._name] = nil
			if DEBUG then
				print("entity.remove", entity._id, component)
			end
		end

		return entity
	end

	function world.component(name, ...)
		local component = {
			_name = name,
			_value = ...,
		}

		function component:set(newValue)
			component._value = newValue
		end

		setmetatable(component, {
			__call = function()
				return component._value
			end,
		})

		return component
	end

	function world.system(name, step)
		local system = {
			_name = name,
			_step = step,

			update = function(...)
				return ...
			end,
		}

		function system:start(worldData)
			if system.init then
				system.init(worldData)
			end

			system._stepped = RunService[step]:Connect(function()
				system:update(worldData)
			end)
		end

		function system.stop()
			system._stepped:Disconnect()
		end

		return system
	end

	function world:query(...)
		local componentsToQuery = { ... }
		local collection = {}
		local nextCollected = 0

		for _, entity in world._entities do
			for _, component in componentsToQuery do
				if not entity._components[component._NAME] then
					break
				end
			end

			table.insert(collection, entity)
		end

		local function nextValues()
			nextCollected += 1

			local collectedEntity = collection[nextCollected]
			if collectedEntity then
				return collectedEntity, table.unpack(componentsToQuery)
			end

			return
		end

		if DEBUG then
			print("world.query", componentsToQuery, collection, nextValues())
		end

		return nextValues
	end

	return world
end

return World
