local audio_manager = require("scripts/audio_manager")

local map = ...
local game = map:get_game()
local hero = map:get_hero()

local ledger_hook
local ledger_sprite

local small_fish_treasure
local big_fish_treasure_rupees
local big_fish_treasure_piece_of_heart
local piece_of_heart_savegame_variable = "piece_of_heart_2"

-- game state,
-- can be [rest, launching, falling, pulling, caught]
local state = "rest"

-- fish currently bitting the fishing ledger
local bitten_fish

-- spawn a fish of some size at position x, y, layer
-- size can be "small" or "big"
-- catch_callback will be called when the player gets this fish
local function make_fish(size, x, y, layer, catch_callback)

  local fish = map:create_custom_entity{
    x = x,
    y = y,
    layer = layer,
    direction = 0,
    width = 16,
    height = 16,
    sprite = string.format("entities/animals/fishing_%s_fish", size)
  }
  fish:set_origin(8, 13)
  fish.catch_callback = catch_callback

  local stroll_speed = 12
  local chase_speed = 24
  local turn_delay, turn_probability
  if size == "big" then
    turn_delay = 1500
    turn_probability = 1.0
  else
    turn_delay = 4000
    turn_probability = 0.5
  end

  local chasing = false

  local mov = sol.movement.create("straight")
  mov:set_speed(stroll_speed)
  mov:start(fish)
  local sprite = fish:get_sprite()

  -- activate the random walk of the fish
  function fish:start_stroll()
    local sprite = self:get_sprite()
    local mov = self:get_movement()
    sol.timer.start(self, math.random(1, 1000), function() -- phase timer
      local t1 = sol.timer.start(self, 200, function()
        -- check periodically if there is the hook in sight
        local fx, fy = self:get_position()
        local lx, ly = ledger_hook:get_position()
        if math.abs(ly - fy) < 16 and bitten_fish == nil and
            (state == "falling" or state == "pulling") then
          -- on the same line
          local close_enough = math.abs(fx-lx) < 50
          if (close_enough and fx < lx and sprite:get_direction() == 0) or
             (close_enough and fx > lx and sprite:get_direction() == 2) then
            -- ledger is in sight
            mov:set_speed(chase_speed)
            mov:set_angle(self:get_angle(ledger_hook))
            sprite:set_animation("chase")
            chasing = true
          end
        else
          mov:set_speed(stroll_speed)
          local ca = mov:get_angle()
          mov:set_angle(ca-math.fmod(ca, math.pi))
          sprite:set_animation("normal")
          chasing = false
        end

        self.chasing = chasing
        return true
      end)

      -- turn itself from time to time
      local t2 = sol.timer.start(self, turn_delay, function()
        if chasing then
          return true
        end
        if math.random() < turn_probability then
          mov:set_angle(math.pi - mov:get_angle())
        end
        return true
      end)

      -- disable auto move, called when fish is caught
      function self:cancel_timers()
        t1:stop()
        t2:stop()
      end
    end)
  end

  -- turn around when reaching obstacle
  function mov:on_obstacle_reached()
    mov:set_angle(mov:get_angle() + math.pi)
  end

  fish:add_collision_test("sprite", function(this, other)
    if other == ledger_hook and fish.chasing and bitten_fish == nil then
      -- was chasing and reached ledger, bite !
      fish:cancel_timers()
      mov:set_speed(0)
      sprite:set_frame(0)
      sprite:set_paused(true)

      -- fix fish position to ledger position
      function ledger_hook:on_position_changed()
        local x, y = ledger_hook:get_position()
        fish:set_position(x - 4, y + 4)
        sprite:set_direction(0)
      end
      bitten_fish = fish
    end
  end)

  function fish:on_movement_changed(mov)
    sprite:set_direction(mov:get_direction4())
  end

  function mov:on_position_changed()
    sprite:set_direction(mov:get_direction4())
  end

  fish:start_stroll()
  
  return fish
end

-- Add the random fishes in the pool.
local function add_fishes()
  local line_count = 4

  local left, top, width, height = water_ent:get_bounding_box()

  for i = 0, line_count - 1 do
    local x = math.random(left + 20, left + width - 20)
    local y = top + height * (i / line_count) + math.random(8, 12)
    local layer = water_ent:get_layer()
    make_fish("small", x, y, layer, small_fish_treasure)
  end

  local x, y, layer = big_fish_placeholder_1:get_position()
  local has_piece_of_heart = game:get_value(piece_of_heart_savegame_variable)
  make_fish("big", x, y, layer,
      has_piece_of_heart and big_fish_treasure_rupees or big_fish_treasure_piece_of_heart)

  x, y, layer = big_fish_placeholder_2:get_position()
  make_fish("big", x, y, layer, big_fish_treasure_rupees)
end

function map:init_music()

  audio_manager:play_music("15_trendy_game")

end

-- utility function to set a movement from a vector
local function set_mov_vec(mov, x, y)
  local angle = math.atan2(-y, x)
  local speed = math.sqrt(x*x + y*y)
  mov:set_angle(angle)
  mov:set_speed(speed)
end

local function clamp(min, max, val)
  return math.max(min, math.min(max, val))
end

local falling_speed = 24
local pull_speed = 24

-- start states functions
local function start_rest()
  state = "rest"

  hero:freeze()
  game:set_pause_allowed(false)

  local x, y, l = hero:get_position()
  if ledger_hook ~= nil then
    ledger_hook:remove()
  end
  ledger_hook = map:create_custom_entity{
    x = x - 18,
    y = y + 8,
    layer = l,
    width = 8,
    height = 8,
    direction = 0,
    sprite = "entities/ledger_hook",
  }
  ledger_hook:set_origin(4, 5)
  ledger_sprite = ledger_hook:get_sprite()
  ledger_sprite:set_animation("move")
  hero:set_animation("fishing_stopped")
end

local function start_fall()
  state = "falling"
  local mov = sol.movement.create("straight")
  mov:set_angle(3 * math.pi / 2)
  mov:set_speed(falling_speed)
  mov:start(ledger_hook)
  ledger_sprite:set_animation("stopped")
  hero:set_animation("fishing_move")
end

local function start_pulling()
  state = "pulling"
  local mov = sol.movement.create("target")
  mov:set_target(hero)
  mov:set_speed(pull_speed)
  mov:set_ignore_obstacles(true)
  mov:start(ledger_hook)
  ledger_sprite:set_animation("move")
  hero:set_animation("fishing_pull")
end

local function start_in_water()
  local sp = ledger_hook:create_sprite("entities/ground_effects/water")
  sp:set_animation("default", function()
    ledger_hook:remove_sprite(sp)
  end)
  start_fall()
end

local function start_caught()
  state = "caught"
  hero:set_animation("fishing_caught_fish", function()
    local callback = bitten_fish.catch_callback
    bitten_fish:remove()
    bitten_fish = nil
    ledger_hook:remove()
    if callback ~= nil then
      callback()
    end
  end)
end

local function start_launching()
  map:start_coroutine(function()
    state = "launching"
    local options = {
      --entities_ignore_suspend = {ledger_hook}
    }
    map:set_cinematic_mode(true, options)
    hero:set_animation("fishing_stopped")

    wait(500)

    local x, y, l = hero:get_position()
    ledger_hook:set_position(x + 18, y, l)

    hero:set_animation("fishing_start", function()
      hero:set_animation("fishing_stopped")
    end)

    local acc = sol.movement.create("target")
    acc:set_target(x, y - 20)
    acc:set_speed(120)
    acc:set_ignore_obstacles(true)
    acc:set_ignore_suspend(true)

    movement(acc, ledger_hook)

    wait(80)

    local mov = sol.movement.create("straight")
    local t_start = sol.main.get_elapsed_time()

    local function current()
      return sol.main.get_elapsed_time() - t_start
    end

    local initial_x = -200
    local initial_y = -150
    local fall_factor = 0.3

    mov:set_ignore_obstacles(false)
    mov:set_ignore_suspend(true)
    set_mov_vec(mov, initial_x, initial_y)
    mov:start(ledger_hook)

    sol.timer.start(map, 20, function()
      if not game:is_command_pressed("action") then
        fall_factor = 0.8
      end
      set_mov_vec(mov,
        clamp(initial_x, 0, initial_x + current() * 0.00), 
        math.min(1000, initial_y + current() * fall_factor)
      )

      if ledger_hook:overlaps(water_ent) then
        mov:stop()
        map:set_cinematic_mode(false)
        game:set_pause_allowed(false)
        hero:freeze()
        hero:set_animation("fishing_stopped")
        start_in_water()
        return false
      end
      return true
    end)
  end)
end

function map:on_started()

  map:init_music()

  add_fishes()
  hero:set_animation("fishing_stopped")
  start_rest()
end

function map:on_opening_transition_finished()
  local state = hero:get_state()
  hero:freeze()
  hero:set_animation("fishing_stopped")
end

function map:on_command_pressed(cmd)
  if cmd == "action" then
    if state == "rest" then
      start_launching()
    elseif state == "falling" then
      start_pulling()
    end
  end
end

function map:on_command_released(cmd)
  if cmd == "action" then
    if state == "pulling" then
      start_fall()
    end
  end
end

catch_zone:add_collision_test("overlapping", function(this, other)
  if state == "pulling" and other == ledger_hook then
    if bitten_fish ~= nil then
      -- fish was caught !
      start_caught()
    else
      start_rest()
    end
  end
end)

-- Asks to play again.
local function play_again_or_leave(dialog_id)

  game:start_dialog(dialog_id, function(response)
    if response == 1 then
      if game:get_money() >= 10 then
        game:remove_money(10)
        return
      else
        game:start_dialog("maps.out.fishman_not_enough_money")
        hero:teleport("Out/plains_2", "from_fishing_game")
        return
      end
    end

    -- Leave the map
    game:set_pause_allowed(true)
    game:start_dialog("maps.sideviews.leaving", function()
      hero:teleport("Out/plains_2", "from_fishing_game")
    end)
  end)
end

function small_fish_treasure()
  map:start_coroutine(function()
    wait_for(hero.start_treasure, hero, "fish_small", 1, "")
    start_rest()  -- To restore the fishing animation
    dialog("maps.sideviews.got_small_fish")
    game:add_money(5)
    wait(200)
    if fish:exists() then
        play_again_or_leave("maps.sideviews.got_small_fish_2")
      else
        game:start_dialog("maps.sideviews.leaving", function()
          hero:teleport("Out/plains_2", "from_fishing_game")
        end)
      end
  end)
end

function big_fish_treasure_rupees()
  map:start_coroutine(function()
    wait_for(hero.start_treasure, hero, "fish_big", 1, "")
    start_rest()  -- To restore the fishing animation
    dialog("maps.sideviews.got_big_fish")
    game:add_money(20)
    wait(200)
    if fish:exists() then
        play_again_or_leave("maps.sideviews.got_big_fish_2")
      else
        game:start_dialog("maps.sideviews.leaving", function()
          hero:teleport("Out/plains_2", "from_fishing_game")
        end)
      end
  end)
end

function big_fish_treasure_piece_of_heart()

  hero:start_treasure("fish_big", 1, "", function()
    start_rest()  -- To restore the fishing animation
    game:start_dialog("maps.sideviews.got_big_fish_heart_piece", function()
      hero:start_treasure("piece_of_heart", 1, piece_of_heart_savegame_variable)
    end)
  end)
end

function map:on_obtained_treasure(item, variant, savegame_variable)

  if item:get_name() == "piece_of_heart" then
    start_rest()
    sol.timer.start(map, 10, function()
      -- Wait for the piece of heart dialogs to finish.
      if game:is_dialog_enabled() then
        return true
      end
      game:add_money(20)
      if fish:exists() then
        play_again_or_leave("maps.sideviews.got_big_fish_heart_piece_2")
      else
        game:start_dialog("maps.sideviews.leaving", function()
          hero:teleport("Out/plains_2", "from_fishing_game")
        end)
      end
    end)
  end
end
