----------------------------------
--
-- Buzz Blob.
--
-- Randomly goes over 8 directions and electrocute the hero when attacked by sword or thrust.
-- Transform into Cukeman on magic powder attack received.
--
----------------------------------

-- Global variables.
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)
local effect_model = require("scripts/gfx_effects/electric")
local audio_manager = require("scripts/audio_manager")

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local eighth = math.pi * 0.25

-- Configuration variables
local walking_angles = {0, eighth, 2.0 * eighth, 3.0 * eighth, 4.0 * eighth, 5.0 * eighth, 6.0 * eighth, 7.0 * eighth}
local walking_speed = 16
local walking_minimum_distance = 16
local walking_maximum_distance = 96
local walking_pause_duration = 1500
local cukeman_shaking_duration = 500

-- Start the enemy movement.
local function start_walking()

  enemy:start_straight_walking(walking_angles[math.random(8)], walking_speed, math.random(walking_minimum_distance, walking_maximum_distance), function()
    start_walking()
  end)
end

-- Electrocute the hero.
local function electrocute()

  local camera = map:get_camera()
  local surface = camera:get_surface()
  hero:get_sprite():set_ignore_suspend(true)
  game:set_suspended(true)
  sprite:set_animation("buzzing")
  audio_manager:play_sound("hero/shock")
  hero:set_animation("electrocute")
  effect_model.start_effect(surface, game, 'in', false)
  local shake_config = {
    count = 32,
    amplitude = 4,
    speed = 180,
  }
  camera:shake(shake_config, function()
    game:set_suspended(false)
    sprite:set_animation("walking")
    hero:unfreeze()
    hero:start_hurt(enemy:get_damage())
  end)
end

-- Transform into Cukeman.
local function transform_into_cukeman()

  local x, y, layer = enemy:get_position()
  local cukeman = enemy:create_enemy({
    name = (enemy:get_name() or enemy:get_breed()) .. "_cukeman",
    breed = "cukeman"
  })

  -- Make the Cukeman shake for some time and then restart.
  if cukeman and cukeman:exists() then -- If the Cukeman was not immediatly removed from the on_created() event.
    cukeman:set_invincible()
    cukeman:stop_movement()
    sol.timer.stop_all(cukeman)
    cukeman:set_treasure(enemy:get_treasure())
    cukeman:get_sprite():set_animation("shaking")
    sol.timer.start(cukeman, cukeman_shaking_duration, function()
      cukeman:restart()
    end)
  end

  enemy:set_treasure() -- The treasure will be dropped by the Cukeman.
  enemy:start_death()
end

-- The enemy appears: set its properties.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(4)
end)

-- The enemy appears: set its properties.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 4,
  	boomerang = 4,
  	explosion = 4,
  	sword = electrocute,
  	thrown_item = "protected",
  	fire = 4,
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "immobilized",
  	magic_powder = transform_into_cukeman,
  	shield = "protected",
  	thrust = electrocute
  })

  -- States.
  enemy:set_damage(4)
  start_walking()
end)
