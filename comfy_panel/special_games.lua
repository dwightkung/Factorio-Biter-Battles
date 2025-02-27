local Event = require 'utils.event'
local Color = require 'utils.color_presets'
local Public = {}
global.active_special_games = {}
global.special_games_variables = {}
local valid_special_games = {
	--[[ 
	Add your special game here.
	Syntax:
	<game_name> = {
		name = {type = "label", caption = "<Name displayed in gui>", tooltip = "<Short description of the mode"
		config = {
			list of all knobs, leavers and dials used to config your game
			[1] = {name = "<name of this element>" called in on_gui_click to set variables, type = "<type of this element>", any other parameters needed to define this element},
			[2] = {name = "example_1", type = "textfield", text = "200", numeric = true, width = 40},
			[3] = {name = "example_2", type = "checkbox", caption = "Some checkbox", state = false}
			NOTE all names should be unique in the scope of the game mode
		},
		button = {name = "<name of this button>" called in on_gui_clicked , type = "button", caption = "Apply"}
	}
	]]
	turtle = {
		name = {type = "label", caption = "Turtle", tooltip = "Generate moat with given dimensions around the spawn"},
		config = {
			[1] = {name = "label1", type = "label", caption = "moat width"},
			[2] = {name = 'moat_width', type = "textfield", text = "5", numeric = true, width = 40},
			[3] = {name = "label2", type = "label", caption = "entrance width"},
			[4] = {name = 'entrance_width', type = "textfield", text = "20", numeric = true, width = 40},
			[5] = {name = "label3", type = "label", caption = "size x"},
			[6] = {name = 'size_x', type = "textfield", text = "200", numeric = true, width = 40},
			[7] = {name = "label4", type = "label", caption = "size y"},
			[8] = {name = 'size_y', type = "textfield", text = "200", numeric = true, width = 40},
			[9] = {name = "chart_turtle", type = "button", caption = "Chart", width = 60}
		},
		button = {name = "turtle_apply", type = "button", caption = "Apply"}
	},

	infinity_chest = {
		name = {type = "label", caption = "Infinity chest", tooltip = "Spawn infinity chests with given filters"},
		config = {
			[1] = {name = "eq1", type = "choose-elem-button", elem_type = "item"},
			[2] = {name = "eq2", type = "choose-elem-button", elem_type = "item"},
			[3] = {name = "eq3", type = "choose-elem-button", elem_type = "item"},
			[4] = {name = "eq4", type = "choose-elem-button", elem_type = "item"},
			[5] = {name = "eq5", type = "choose-elem-button", elem_type = "item"},
			[6] = {name = "eq6", type = "choose-elem-button", elem_type = "item"},
			[7] = {name = "eq7", type = "choose-elem-button", elem_type = "item"},
			[8] = {name = "separate_chests", type = "switch", switch_state = "left", tooltip = "Single chest / Multiple chests"},
			[9] = {name = "operable", type = "switch", switch_state = "right", tooltip = "Operable? Y / N"},
			[10] = {name = "label1", type = "label", caption = "Gap size"},
			[11] = {name = "gap", type = "textfield", text = "3", numeric = true, width = 40},
		},
		button = {name = "infinity_chest_apply", type = "button", caption = "Apply"}
	},
  
	disabled_research = {
		name = {type = "label", caption = "Disabled research", tooltip = "Disables choosen technologies from being researched"},
		config = {
			[1] = {name = "eq1", type = "choose-elem-button", elem_type = "technology"},
			[2] = {name = "eq2", type = "choose-elem-button", elem_type = "technology"},
			[3] = {name = "eq3", type = "choose-elem-button", elem_type = "technology"},
			[4] = {name = "eq4", type = "choose-elem-button", elem_type = "technology"},
			[5] = {name = "eq5", type = "choose-elem-button", elem_type = "technology"},
			[6] = {name = "eq6", type = "choose-elem-button", elem_type = "technology"},
			[7] = {name = "eq7", type = "choose-elem-button", elem_type = "technology"}, 
			[8] = {name = "team", type = "switch", switch_state = "none", allow_none_state = true, tooltip = "North / Both / South"},
			[9] = {name = "reset_disabled_research", type = "button", caption = "Reset", tooltip = "Enable all the disabled research again"}
		},
		button = {name = "disabled_research_apply", type = "button", caption = "Apply"}
	},

	disabled_entities = {
		name = {type = "label", caption = "Disabled entities", tooltip = "Disables choosen entities from being placed"},
		config = {
			[1] = {name = "eq1", type = "choose-elem-button", elem_type = "item"},
			[2] = {name = "eq2", type = "choose-elem-button", elem_type = "item"},
			[3] = {name = "eq3", type = "choose-elem-button", elem_type = "item"},
			[4] = {name = "eq4", type = "choose-elem-button", elem_type = "item"},
			[5] = {name = "eq5", type = "choose-elem-button", elem_type = "item"},
			[6] = {name = "eq6", type = "choose-elem-button", elem_type = "item"},
			[7] = {name = "eq7", type = "choose-elem-button", elem_type = "item"},
			[8] = {name = "team", type = "switch", switch_state = "none", allow_none_state = true, tooltip = "North / Both / South"},
		},
		button = {name = "disabled_entities_apply", type = "button", caption = "Apply"}
	}

}

function Public.reset_active_special_games() for _, i in ipairs(global.active_special_games) do i = false end end
function Public.reset_special_games_variables() global.special_games_variables = {} end

local function generate_turtle(moat_width, entrance_width, size_x, size_y)
	game.print("Special game turtle is being generated!", Color.warning)
	local surface = game.surfaces[global.bb_surface_name]
	local water_positions = {}
	local concrete_positions = {}
	local landfill_positions = {}

	for i = 0, size_y + moat_width do -- veritcal canals
		for a = 1, moat_width do
			table.insert(water_positions, {name = "deepwater", position = {x = (size_x / 2) + a, y = i}})
			table.insert(water_positions, {name = "deepwater", position = {x = (size_x / 2) - size_x - a, y = i}})
			table.insert(water_positions, {name = "deepwater", position = {x = (size_x / 2) + a, y = -i - 1}})
			table.insert(water_positions, {name = "deepwater", position = {x = (size_x / 2) - size_x - a, y = -i - 1}})
		end
	end
	for i = 0, size_x do -- horizontal canals
		for a = 1, moat_width do
			table.insert(water_positions, {name = "deepwater", position = {x = i - (size_x / 2), y = size_y + a}})
			table.insert(water_positions, {name = "deepwater", position = {x = i - (size_x / 2), y = -size_y - 1 - a}})
		end
	end

	for i = 0, entrance_width - 1 do
		for a = 1, moat_width + 6 do
			table.insert(concrete_positions,
			             {name = "refined-concrete", position = {x = -entrance_width / 2 + i, y = size_y - 3 + a}})
			table.insert(concrete_positions,
			             {name = "refined-concrete", position = {x = -entrance_width / 2 + i, y = -size_y + 2 - a}})
			table.insert(landfill_positions, {name = "landfill", position = {x = -entrance_width / 2 + i, y = size_y - 3 + a}})
			table.insert(landfill_positions, {name = "landfill", position = {x = -entrance_width / 2 + i, y = -size_y + 2 - a}})
		end
	end

	surface.set_tiles(water_positions)
	surface.set_tiles(landfill_positions)
	surface.set_tiles(concrete_positions)
	global.active_special_games["turtle"] = true
end

local function generate_infinity_chest(separate_chests, operable, gap, eq)
	local surface = game.surfaces[global.bb_surface_name]
	local position_0 = {x = 0, y = -42}

	local objects = surface.find_entities_filtered {name = 'infinity-chest'}
	for _, object in pairs(objects) do object.destroy() end

	game.print("Special game Infinity chest is being generated!", Color.warning)
	if operable == "left" then
		operable = true
	else
		operable = false
	end

	if separate_chests == "left" then
		local chest = surface.create_entity {
			name = "infinity-chest",
			position = position_0,
			force = "neutral",
			fast_replace = true
		}
		chest.minable = false
		chest.operable = operable
		chest.destructible = false
		for i, v in ipairs(eq) do
			chest.set_infinity_container_filter(i, {name = v, index = i, count = game.item_prototypes[v].stack_size})
		end
		chest.clone {position = {position_0.x, -position_0.y}}

	elseif separate_chests == "right" then
		local k = gap + 1
		for i, v in ipairs(eq) do
			local chest = surface.create_entity {
				name = "infinity-chest",
				position = position_0,
				force = "neutral",
				fast_replace = true
			}
			chest.minable = false
			chest.operable = operable
			chest.destructible = false
			chest.set_infinity_container_filter(i, {name = v, index = i, count = game.item_prototypes[v].stack_size})
			chest.clone {position = {position_0.x, -position_0.y}}
			position_0.x = position_0.x + (i * k)
			k = k * -1
		end
	end
	global.active_special_games["infinity_chest"] = true
end

local function generate_disabled_research(team, eq)
	if not global.special_games_variables["disabled_research"] then
		global.special_games_variables["disabled_research"] = {["north"] = {}, ["south"] = {}}
	end
	global.active_special_games["disabled_research"] = true
	local tab = {
		["left"] = "north",
		["right"] = "south"
	}
	if tab[team] then
		for k, v in pairs(eq) do
			table.insert(global.special_games_variables["disabled_research"][tab[team]], v)
			game.forces[tab[team]].technologies[v].enabled = false
		end
		game.print("Special game Disabled research: ".. table.concat(eq, ", ") .. " for team " .. tab[team] .. " is being generated!", Color.warning)
		return
	end
	
	for k, v in pairs(eq) do
		table.insert(global.special_games_variables["disabled_research"]["south"], v)
		table.insert(global.special_games_variables["disabled_research"]["north"], v)
		game.forces["north"].technologies[v].enabled = false
		game.forces["south"].technologies[v].enabled = false
	end
	game.print("Special game Disabled research: ".. table.concat(eq, ", ") .. " for both teams is being generated!", Color.warning)
end

local function reset_disabled_research(team)
	if not global.active_special_games["disabled_research"] then return end
	local tab = {
		["left"] = "north",
		["right"] = "south"
	}
	if tab[team] then
		for k, v in pairs(global.special_games_variables["disabled_research"][tab[team]]) do
			game.forces[tab[team]].technologies[v].enabled = true
		end
		global.special_games_variables["disabled_research"][tab[team]] = {}
		game.print("All disabled research has been enabled again for team " .. tab[team], Color.warning)
		return
	else
		for k, v in pairs(global.special_games_variables["disabled_research"]["north"]) do
			game.forces["north"].technologies[v].enabled = true
		end
		for k, v in pairs(global.special_games_variables["disabled_research"]["south"]) do
			game.forces["south"].technologies[v].enabled = true
		end
		global.special_games_variables["disabled_research"]["north"] = {}
		global.special_games_variables["disabled_research"]["south"] = {}
		game.print("All disabled research has been enabled again for both teams", Color.warning)
  end
end

local function generate_disabled_entities(team, eq)
	if not global.special_games_variables["disabled_entities"] then
		global.special_games_variables["disabled_entities"] = {["north"] = {}, ["south"] = {}}
	end
	local tab = {}
	for k, v in pairs(eq) do
		if v then
			tab[v] = true
		end
	end
	if team == "left" then
		global.special_games_variables["disabled_entities"]["north"] = tab
		game.print("Special game Disabled entities: ".. table.concat(eq, ", ") .. " for team North is being generated!", Color.warning)
	elseif team == "right" then
		global.special_games_variables["disabled_entities"]["south"] = tab
		game.print("Special game Disabled entities: ".. table.concat(eq, ", ") .. " for team South is being generated!", Color.warning)
	else
		global.special_games_variables["disabled_entities"]["south"] = tab
		global.special_games_variables["disabled_entities"]["north"] = tab
		game.print("Special game Disabled entities: ".. table.concat(eq, ", ") .. " for both teams is being generated!", Color.warning)
	end
	global.active_special_games["disabled_entities"] = true
end

local function on_built_entity(event)
	if not global.active_special_games["disabled_entities"] then return end
	local player = game.get_player(event.player_index)
	local force = player.force
	local entity = event.created_entity
	if global.special_games_variables["disabled_entities"][force.name][entity.name] then
		player.create_local_flying_text({text = "Disabled by special game", position = entity.position})
		player.get_inventory(defines.inventory.character_main).insert({name = entity.name, count = 1})
		entity.destroy()
	end
end

local create_special_games_panel = (function(player, frame)
	frame.clear()
	frame.add{type = "label", caption = "Configure and apply special games here"}.style.single_line = false

	for k, v in pairs(valid_special_games) do
		local a = frame.add {type = "frame"}
		a.style.width = 750
		local table = a.add {name = k, type = "table", column_count = 3, draw_vertical_lines = true}
		table.add(v.name).style.width = 100
		local config = table.add {name = k .. "_config", type = "flow", direction = "horizontal"}
		config.style.width = 500
		for _, i in ipairs(v.config) do
			config.add(i)
			config[i.name].style.width = i.width
		end
		table.add {name = v.button.name, type = v.button.type, caption = v.button.caption}
		table[k .. "_config"].style.vertical_align = "center"
	end
end)

local function on_gui_click(event)
	local player = game.get_player(event.player_index)
	local element = event.element
	if not element.type == "button" then return end
	local config = element.parent.children[2]

	if string.find(element.name, "_apply") then
		local flow = element.parent.add {type = "flow", direction = "vertical"}
		flow.add {type = "button", name = string.gsub(element.name, "_apply", "_confirm"), caption = "Confirm"}
		flow.add {type = "button", name = "cancel", caption = "Cancel"}
		element.visible = false -- hides Apply button	
		player.print("[SPECIAL GAMES] Are you sure? This change will be reversed only on map restart!", Color.cyan)

	elseif string.find(element.name, "_confirm") then
		config = element.parent.parent.children[2]

	end
	-- Insert logic for apply button here

	if element.name == "turtle_confirm" then

		local moat_width = config["moat_width"].text
		local entrance_width = config["entrance_width"].text
		local size_x = config["size_x"].text
		local size_y = config["size_y"].text

		generate_turtle(moat_width, entrance_width, size_x, size_y)
	elseif element.name == "chart_turtle" then
		config = element.parent.parent.children[2]
		local moat_width = config["moat_width"].text
		local entrance_width = config["entrance_width"].text
		local size_x = config["size_x"].text
		local size_y = config["size_y"].text

		game.forces["spectator"].chart(game.surfaces[global.bb_surface_name], {
			{-size_x / 2 - moat_width, -size_y - moat_width}, {size_x / 2 + moat_width, size_y + moat_width}
		})

	elseif element.name == "infinity_chest_confirm" then

		local separate_chests = config["separate_chests"].switch_state
		local operable = config["operable"].switch_state
		local gap = config["gap"].text
		local eq = {
			config["eq1"].elem_value, 
			config["eq2"].elem_value, 
			config["eq3"].elem_value, 
			config["eq4"].elem_value,
			config["eq5"].elem_value,
			config["eq6"].elem_value,
			config["eq7"].elem_value
		}

		generate_infinity_chest(separate_chests, operable, gap, eq)
	
	elseif element.name == "disabled_research_confirm" then
		local team = config["team"].switch_state
		local eq = {
			config["eq1"].elem_value, 
			config["eq2"].elem_value, 
			config["eq3"].elem_value, 
			config["eq4"].elem_value,
			config["eq5"].elem_value,
			config["eq6"].elem_value,
			config["eq7"].elem_value
		}

		generate_disabled_research(team, eq)

	elseif element.name == "reset_disabled_research" then
		config = element.parent.parent.children[2]
		local team = config["team"].switch_state
		reset_disabled_research(team)

	elseif element.name == "disabled_entities_confirm" then
		local team = config["team"].switch_state
		local eq = {}
		for v = 1, 1, 7 do
			if config["eq"..v].elem_value then
				eq[config["eq"..v].elem_value] = true
			end
		end
		eq = {
			config["eq1"].elem_value, 
			config["eq2"].elem_value, 
			config["eq3"].elem_value, 
			config["eq4"].elem_value,
			config["eq5"].elem_value,
			config["eq6"].elem_value,
			config["eq7"].elem_value
		}
		generate_disabled_entities(team, eq)
	end
	if string.find(element.name, "_confirm") or element.name == "cancel" then
		element.parent.parent.children[3].visible = true -- shows back Apply button
		element.parent.destroy() -- removes confirm/Cancel buttons
	end
end
comfy_panel_tabs['Special games'] = {gui = create_special_games_panel, admin = true}

Event.add(defines.events.on_gui_click, on_gui_click)
Event.add(defines.events.on_built_entity, on_built_entity)
return Public

