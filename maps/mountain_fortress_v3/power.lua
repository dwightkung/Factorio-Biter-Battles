local Event = require 'utils.event'
local WPT = require 'maps.mountain_fortress_v3.table'

local function balance(t)
    local g = 0
    local c = 0
    for k, v in pairs(t) do
        if (v.valid) then
            g = g + v.energy
            c = c + v.electric_buffer_size
        end
    end
    for k, v in pairs(t) do
        if (v.valid) then
            local r = (v.electric_buffer_size / c)
            v.energy = g * r
        end
    end
end

local function tick()
    local this = WPT.get_table()
    if not this.energy['mountain_fortress_v3'] then
        this.energy['mountain_fortress_v3'] = this.ow_energy
    end

    if not this.energy['loco'] then
        this.energy['loco'] = this.lo_energy
    end

    local mountain_fortress_v3 = this.energy['mountain_fortress_v3']
    local loco = this.energy['loco']
    if not mountain_fortress_v3 or not loco then
        return
    end
    if not mountain_fortress_v3.valid or not loco.valid then
        return
    end
    balance(this.energy)
end

local function built_entity(event)
    local entity = event.created_entity
    if not entity.valid then
        return
    end
    local player = game.players[event.player_index]
    local surface = entity.surface
    local map_name = 'mountain_fortress_v3'

    if surface.name ~= map_name then
        return
    end
    if
        entity.name == 'steam-engine' or entity.name == 'steam-turbine' or entity.name == 'lab' or
            entity.name == 'rocket-silo'
     then
        if not entity.valid then
            return
        end
        player.print('"' .. entity.name .. '" Does not seem to work down here, thats strange!', {r = 1, g = 0, b = 0})
        entity.active = false
    end
end

Event.add(defines.events.on_tick, tick)
--Event.add(defines.events.on_built_entity, built_entity)
