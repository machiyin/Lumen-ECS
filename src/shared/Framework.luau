local RunService = game:GetService("RunService")

local DEBUG = false

local Framework = { world = {} }

function Framework.world.new()
	local world = {
		_nextEntityId = 0,
		_entities = {},
	}

	function world.entity()
		world._nextEntityId += 1

		local entity = {
			id = world._nextEntityId,
			_components = {},
		}

		world._entities[entity.id] = entity

		function entity.insert(...)
			local componentsToInsert = { ... }
			for _, component in componentsToInsert do
				entity._components[component._name] = component
			end

			if DEBUG then
				print("entity.insert", entity.id, ...)
			end

			return ...
		end

		function entity.remove(...)
			local componentsToRemove = { ... }
			for _, component in componentsToRemove do
				entity._components[component._name] = nil
			end

			if DEBUG then
				print("entity.remove", entity.id, ...)
			end
		end

		function entity.get(name)
			return entity._components[name]
		end

		function entity:destroy()
			for _, component in entity._components do
				entity.remove(component)
			end

			entity = nil
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
			_step = step or "Heartbeat",

			update = function(...)
				return ...
			end,
		}

		function system:start(worldData)
			if system.init then
				system.init(worldData)
			end

			system._stepped = RunService[system._step]:Connect(function(...)
				if worldData then
					worldData._DELTATIME = ...
				else
					worldData = { _DELTATIME = ... }
				end

				system:update(worldData)
			end)

			return system
		end

		function system:stop()
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

return Framework
