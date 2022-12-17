-- Initialize hero behavior specific to this quest.

-- Variables
local hero_meta = sol.main.get_metatable("hero")

-- Include scripts
local audio_manager = require("scripts/audio_manager")
local timer_sword_loading = nil
local timer_sword_tapping = nil
local timer_stairs = nil

function hero_meta:is_custom_state_started(state_name)
  local state, object=self:get_state()

  --Vige priority to custom state in cace the cstate has the same name as a biolt-in one
  return state=="custom" and object:get_description()==state_name
end

require("scripts/multi_events")
hero_meta:register_event("on_position_changed", function(hero)
    if not hero:get_map():is_sideview() and not hero.walking_sound_timer then
      hero.walking_sound_timer=sol.timer.start(hero, 300, function()
          hero.walking_sound_timer = nil
        end)
      if hero:get_ground_below()=="shallow_water" then
        audio_manager:play_sound("hero/wade"..(math.random(1, 2)))
      elseif hero:get_ground_below()=="grass" then
        audio_manager:play_sound("hero/walk_on_grass")
      end
    end

  end)

hero_meta:register_event("on_state_changed", function(hero, current_state)

    local game = hero:get_game()
    local state_object = hero:get_state_object()
    local state_desc = state_object and state_object:get_description() or ""
    -- Sounds
    if current_state == "lifting" then
      audio_manager:play_sound("hero/pickup") 
    elseif current_state == "sword loading" or state_desc=="sword_loading" then
      timer_sword_loading = sol.timer.start(hero, 1000, function()
          audio_manager:play_sound("items/sword_charge") 
        end)
    elseif current_state == "sword spin attack" or state_desc=="sword_spin_attack" then
      -- Sword spin attack
      audio_manager:play_sound("items/sword_spin") 
    elseif current_state == "sword swinging" or state_desc=="sword" then
      -- Sword swinging
      local index = math.random(1, 4)
      audio_manager:play_sound("items/sword_slash" .. index) 
    elseif current_state == "sword tapping" or state_desc == "sword_tapping" then
      if timer_sword_tapping == nil then
        timer_sword_tapping = sol.timer.start(hero, 250, function()
          local bombable = false
          local entity = hero:get_facing_entity()
          if entity ~= nil then
            bombable = entity:get_property("sound_sword") ~= nil or
              entity:get_property("is_weak")
          end
          if bombable then
            audio_manager:play_sound("items/sword_tap_bombable")
          else
            audio_manager:play_sound("items/sword_tap") 
          end
          return true
        end)
      end
    elseif current_state == "hurt" then
      -- Hurt
      audio_manager:play_sound("hero/hurt") 
    elseif current_state == "falling" then
      -- Falling
      hero:stop_movement()
      audio_manager:play_sound("hero/fall") 
    elseif current_state == "jumping" then
      audio_manager:play_sound("hero/cliff_jump")
    elseif current_state == "stairs" then
      if timer_stairs == nil then
        timer_stairs = sol.timer.start(hero, 0, function()
            --TODO audio_manager:play_sound("misc/stairs")
            return 400
          end)
        timer_stairs:set_suspended_with_map(false)
      end
    elseif current_state == "frozen" then
      -- Frozen
      local entity = hero:get_facing_entity()
      if entity ~= nil and entity:get_type() == "chest" and game:is_command_pressed("action") then
        audio_manager:play_sound("misc/chest_open")
      end

    end
    -- Reset timer sword loading
    if current_state ~= "sword loading" and timer_sword_loading ~= nil then
      timer_sword_loading:stop()
      timer_sword_loading = nil
    end
    -- Reset timer sword tapping
    if current_state ~= "sword tapping" and timer_sword_tapping ~= nil then
      timer_sword_tapping:stop()
      timer_sword_tapping = nil
    end  
    -- Reset timer stairs
    if current_state ~= "stairs" and timer_stairs ~= nil then
      timer_stairs:stop()
      timer_stairs = nil
    end  
    -- Previous states
    if hero.previous_state == "carrying" then
      hero:notify_object_thrown()
    end
    hero.previous_state = current_state

    --Recovering from drowning
    -- Avoid to lose any life when drowning.
    if current_state == "plunging" and game:get_item("flippers"):get_variant()==0 then
      --TODO play the drowning animation
      hero:stop_movement()
      if hero:get_ground_below()=="deep_water" then
        --print "drown"
        sol.timer.start(hero, 10, function()
            local s,c=hero:get_state()
            --print ("prepare to drown when in state"..s..(c and "("..c:get_description()..")" or ""))
            hero:drown()
          end)
      end
    end
    if current_state == "back to solid ground" then
      local ground = hero:get_ground_below()
      if ground == "deep_water" then -- Est-ce toujours utile du coup maintenant qu'on a une custom state de noyade ?
        game:add_life(1)
      end
    end
  end)

function hero_meta.set_previous_state(hero, state, custom_state_name)
  hero.prev_state=state
  hero.prev_cstate_name=custom_state_name
end

function hero_meta.get_previous_state(hero)
  return hero.prev_state, hero.prev_cstate_name
end

function hero_meta.show_ground_effect(hero, id)

  local map = hero:get_map()
  local x,y, layer = hero:get_position()
  local ground_effect = map:create_custom_entity({
      name = "ground_effect",
      sprite = "entities/ground_effects/"..id,
      x = x,
      y = y ,
      width = 16,
      height = 16,
      layer = layer,
      direction = 0
    })
  local sprite = ground_effect:get_sprite()
  function sprite:on_animation_finished()
    ground_effect:remove()
  end

end

local function find_valid_ground(hero)

  local ground
  local x,y=hero:get_position()
  local map=hero:get_map()

  for layer=hero:get_layer(), map:get_min_layer(), -1 do
    ground=map:get_ground(x,y,layer)
    if ground~="empty" then
      return ground
    end
  end

  return "empty"
end

function hero_meta.play_ground_effect(hero)
  --print "About to play a ground effect"
  local map=hero:get_map()
  local ground=find_valid_ground(hero)
  --print ("ground: "..ground)
  local x,y=hero:get_position()

  if ground=="shallow_water" then
    --print "landed in water"
    hero:show_ground_effect("water")
    audio_manager:play_sound("hero/wade1")
  elseif ground=="grass" then
    --print "landed in grass"
    hero:show_ground_effect("grass")
    audio_manager:play_sound("hero/walk_on_grass")
  elseif ground=="deep_water" or ground=="lava" then
    --print "plundged in some fluid"
    audio_manager:play_sound("hero/diving")
  else --Not a standard ground
    --print "landed in some other ground"
    for entity in map:get_entities_in_rectangle(x,y,1,1) do
      if entity:get_property("custom_ground")=="sand" then
        --print "landed in sand"
        hero:show_ground_effect("sand") --TODO make proper sprite for sand landing effect
      end
      audio_manager:play_sound("hero/land")
    end
  end
end

hero_meta:register_event("on_state_changing", function(hero, old_state, new_state)
    -- print ("going from state "..old_state.." to state ".. new_state)
    if old_state~="custom" then
      hero:set_previous_state(old_state, "")
    end
    if old_state=="jumping" and new_state=="free" then
      hero:play_ground_effect()
    end
  end)

hero_meta:register_event("notify_object_thrown", function() end)

hero_meta:register_event("on_position_changed", function(hero)

    local game = hero:get_game()
    local map = game:get_map()
    local dungeon = game:get_dungeon()
    local x, y = hero:get_center_position()
    if dungeon == nil then
      local world = map:get_world()
      local square_x = 0
      local square_y = 0
      local square_min_x = 0
      local square_min_y = 0
      local square_total_x = 0
      local square_total_y = 0
      local map_max_x = 3840
      local map_max_y = 3072
      if world == "outside_world" then
        local map_x, map_y = map:get_location()
        local map_size_x, map_size_y = map:get_size()

        -- Mountain maps add 48 artificial pixels to the North as additional decorations.
        -- Don't take them into account in the map.
        if map_y > 0 then
          map_y = map_y - 48
        else
          map_size_y = map_size_y - 48
          y = y - 48
        end

        square_x = math.floor((map_x + map_size_x) / (map_size_x) - 1)
        square_y = math.floor((map_y + map_size_y) / (map_size_y) - 1)
        if x == 0 then
          square_min_x = 0
        else
          square_min_x = math.floor((x+240)/(240)-1)
        end
        if y == 0 then
          square_min_y = 0
        else
          square_min_y = math.floor((y+192)/(192)-1)
        end
        square_total_x = (4*square_x)+square_min_x
        square_total_y = (4*square_y)+square_min_y
        game:set_value("map_hero_position_x", square_total_x)
        game:set_value("map_hero_position_y", square_total_y)

        -- Save the map discovering.
        assert(square_total_x >= 0 and square_total_y >= 0, "Negative coordinates for map discovering: "..square_total_x.." "..square_total_y)
        if square_total_x >= 0 and square_total_y >= 0 then
          game:set_value("map_discovering_" .. square_total_x .. "_" .. square_total_y, true)
        end
      end
    else
      local map_width, map_height = map:get_size()
      local room_width, room_height = 320, 240  -- TODO don't hardcode these numbers
      local num_columns = math.floor(map_width / room_width)
      local column = math.floor(x / room_width)
      local row = math.floor(y / room_height)
      local room = row * num_columns + column + 1
      local room_old = game:get_value("room")
      if game:has_dungeon_compass() and room_old ~= room and game:is_secret_room(nil, nil, room) and game:is_secret_signal_room(nil, nil, room) then
        local timer = sol.timer.start(map, 500, function()
            audio_manager:play_sound("misc/dungeon_signal")
          end)
      end
      game:set_value("room", room)

    end

  end)


-- Return true if the hero is walking.
function hero_meta:is_walking()

  local m = self:get_movement()
  return m and m.get_speed and m:get_speed() > 0

end

function hero_meta:on_taking_damage(damage)

  local hero = self
  local game = hero:get_game()
  -- Calculate defense. Check tunic and powerups.
  local defense_tunic = game:get_value("defense_tunic") or 1
  local defense_powerup = hero.get_defense_powerup and hero:get_defense_powerup() or 1
  local defense = defense_tunic * defense_powerup
  -- Calculate final damage.
  local final_damage = math.ceil(damage/defense)
  -- Remove life.
  game:remove_life(damage)
  -- Charm
  game.acorn_count = 0
  if game.hero_charm then
    game.hero_charm_hurt_counter = game.hero_charm_hurt_counter + 1
    if game.hero_charm_hurt_counter == 3 then
      hero:remove_charm()
    end
  end

end

-- Returns true when the hero is jumping, even if running, jumping or loading the sword at the same time.
function hero_meta.is_jumping(hero)
  return hero.jumping
end

-- Returns true when the hero is actually running, not during the run preparation.
function hero_meta.is_running(hero)
  return hero.running
end

function hero_meta.get_force_powerup(hero)

  local game = hero:get_game()
  return game.hero_charm=="power_fragment" and 2 or 1

end

function hero_meta.get_defense_powerup(hero)

  local game = hero:get_game()
  return game.hero_charm=="acorn" and 2 or 1

end

--Utility function : it loops through all the sprites of a given hero and shifts them by the given amount of pixels in the X and Y directions.
local function set_sprite_offset(hero, ox, oy)
  for set, sprite in hero:get_sprites() do
    sprite:set_xy(ox or 0, oy or 0)
  end
end

--[[
  Redeclaration of the "on map changed' event to take account of the sideview mode.
  This override shifts the hero's sprites down by 2 pixels when entering a side view map and also reduces the width of his hitbos to help with falling through 16px gaps.
  Note : it is supposed to add a shadow under it if we enter a non side view map but in the current state of the engine, the functions hero:bring_sprite_to_back and hero:being_sprite_to_front do not work as intended (so no shadow for now).
--]]
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_map_changed", function(game, map)

    local hero = map:get_hero()
    local x,y, layer=hero:get_position()
    hero.jumping = false
    if map:is_sideview() then
      hero:set_size(8,16)
      hero:set_origin(4,13)
      set_sprite_offset(hero, 0,2)
      --hero:get_sprite("shadow"):stop_animation()
      local s=hero:get_sprite("shadow_override")
      if s then
        hero:remove_sprite(s)
      end
    else
      hero:set_size(16,16)
      hero:set_origin(8,13)
      set_sprite_offset(hero, 0,0)
--      hero:get_sprite("shadow"):set_animation("big")
      if not hero:get_sprite("shadow_override") then
        local s=hero:create_sprite("entities/shadows/shadow", "shadow_override")
        hero:bring_sprite_to_back(s)
      end
    end
    -- Todo Add sprite if charm exist

  end)

-- Ugly workaround to make the fucking hero walking speed changes effective immediately even if he is on a tile that modify its speed, such as grass.
hero_meta:register_event("set_walking_speed", function(hero, speed)

  local map = hero:get_map()
  local x, y, layer = hero:get_position()
  local ground = map:create_destructible({
    x = x,
    y = y,
    layer = layer,
    sprite = "entities/destructibles/grass",
    ground = "traversable"
  })
  ground:set_visible(false)
  sol.timer.start(map, 100, function()
    ground:remove()
  end)
end)

-- Initialize hero behavior specific to this quest.
hero_meta:register_event("on_created", function(hero)
    hero:set_previous_state("NONE", "")
    hero:remove_sprite(hero:get_sprite("shadow"))
    hero:initialize_fixing_functions() -- Used to fix direction and animations.

    local variant=hero:get_game():get_item("sword"):get_variant()
    if  variant>0 then
      hero:create_sprite("hero/sword"..variant, "sword_override"):stop_animation()
      hero:create_sprite("hero/sword_stars"..variant, "sword_stars_override"):stop_animation()
    end

  end)


--------------------------------------------------
-- Functions to fix tunic animation and direction.
--------------------------------------------------
local fixed_direction, fixed_stopped_animation, fixed_walking_animation


-- Get fixed direction for the hero.
function hero_meta:get_fixed_direction()

  return fixed_direction

end

-- Get fixed stopped/walking animations for the hero.
function hero_meta:get_fixed_animations()

  return fixed_stopped_animation, fixed_walking_animation

end

-- Set a fixed direction for the hero (or nil to disable it).
function hero_meta:set_fixed_direction(new_direction)

  fixed_direction = new_direction
  if fixed_direction then
    self:get_sprite("tunic"):set_direction(fixed_direction)
  end

end

-- Set fixed stopped/walking animations for the hero (or nil to disable them).
function hero_meta:set_fixed_animations(new_stopped_animation, new_walking_animation)

  fixed_stopped_animation = new_stopped_animation
  fixed_walking_animation = new_walking_animation
  -- Initialize fixed animations if necessary.
  local state = self:get_state()
  if state == "free" then
    if self:is_walking() then self:set_animation(fixed_walking_animation or "walking")
    else self:set_animation(fixed_stopped_animation or "stopped") end
  end

end

-- Initialize events to fix direction and animation for the tunic sprite of the hero.
-- For this purpose, we redefine on_created and set_tunic_sprite_id events for the hero metatable.
function hero_meta:initialize_fixing_functions()

  local hero = self
  local sprite = hero:get_sprite("tunic")

  -- Define events for the tunic sprite.
  function sprite:on_animation_changed(animation)
    local tunic_animation = sprite:get_animation()
    if tunic_animation == "stopped" and fixed_stopped_animation ~= nil then 
      if fixed_stopped_animation ~= tunic_animation then
        sprite:set_animation(fixed_stopped_animation)
      end
    elseif tunic_animation == "walking" and fixed_walking_animation ~= nil then 
      if fixed_walking_animation ~= tunic_animation then
        sprite:set_animation(fixed_walking_animation)
      end
    end
    function sprite:on_direction_changed(animation, direction)
      local fixed_direction = fixed_direction
      local tunic_direction = sprite:get_direction()
      if fixed_direction ~= nil and fixed_direction ~= tunic_direction then
        sprite:set_direction(fixed_direction)
      end
    end
  end
  -- Initialize fixing functions for the new sprite when the tunic sprite is changed.
  local old_set_tunic = hero_meta.set_tunic_sprite_id -- We redefine this function.
  function hero_meta:set_tunic_sprite_id(sprite_id)
    old_set_tunic(self, sprite_id)
    self:initialize_fixing_functions()
  end

end

-- Create an exclamation symbol near hero
function hero_meta:create_symbol_exclamation(sound)

  local map = self:get_map()
  local x, y, layer = self:get_position()
  if sound then
    audio_manager:play_sound("menus/menu_select")
  end
  local symbol = map:create_custom_entity({
      sprite = "entities/symbols/exclamation",
      x = x - 16,
      y = y - 16,
      width = 16,
      height = 16,
      layer = layer,
      direction = 0
    })

  return symbol

end

-- Create an interrogation symbol near hero
function hero_meta:create_symbol_interrogation(sound)

  local map = self:get_map()
  local x, y, layer = self:get_position()
  if sound then
    audio_manager:play_sound("menus/menu_select")
  end
  local symbol = map:create_custom_entity({
      sprite = "entities/symbols/interrogation",
      x = x,
      y = y,
      width = 16,
      height = 16,
      layer = layer + 1,
      direction = 0
    })

  return symbol

end

-- Create a collapse symbol near hero
function hero_meta:create_symbol_collapse(sound)

  local map = self:get_map()
  local width, height = self:get_sprite():get_size()
  local x, y, layer = self:get_position()
  if sound then
    -- Todo create a custom sound
  end
  local symbol = map:create_custom_entity({
      sprite = "entities/symbols/collapse",
      x = x,
      y = y - height / 2,
      width = 16,
      height = 16,
      layer = layer + 1,
      direction = 0
    })

  return symbol

end

function hero_meta:add_charm(charm)

  if charm then
    local game = self:get_game()
    game.hero_charm = charm
    game.hero_charm_hurt_counter = 0
    -- Shader
    local shader=sol.shader.create("power_effect")
    self:get_sprite():set_shader(shader)
    if charm == "acorn" then
      shader:set_uniform("target_color", {0., 0., 1.0, 1.0})
    else --Power fragment
      shader:set_uniform("target_color", {1.0, 0.0, 0.0, 1.0})
    end

    -- Sound and music
    audio_manager:play_sound("items/get_power_up")
    audio_manager:refresh_music()
  end

end

function hero_meta:remove_charm()

  local game = self:get_game() 
  game.hero_charm = nil
  game.hero_charm_hurt_counter = 0
  game.acorn_count = 0
  game.power_fragment_count = 0
  self:get_sprite():set_shader(nil)
  -- Music
  audio_manager:refresh_music()

end

return true