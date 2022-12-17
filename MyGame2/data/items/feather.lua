local item = ...

local hero_meta = sol.main.get_metatable("hero")
local game = item:get_game()

local audio_manager = require("scripts/audio_manager")
local jump_manager = require("scripts/maps/jump_manager")
require("scripts/multi_events")

function item:on_created()
  self:set_savegame_variable("i1100")
  self:set_assignable(true)
end

local game_meta = sol.main.get_metatable("game")

function item:start_using()
  local map = game:get_map()
  local hero = map:get_hero()

  if not hero:is_jumping() then
    if not map:is_sideview() then

      jump_manager.start(hero) -- Running jump

    else
      local state=hero:get_state()
      -- Simply apply a vertical impulsion to the hero in sideview maps.
      if state~="carrying" and state~="lifting" and state~="falling" and state~="plunging" then
        local vspeed = hero.vspeed or 0
        if vspeed == 0 or hero.has_grabbed_ladder or map:get_ground(hero:get_position()) == "deep_water" then
          audio_manager:play_sound("hero/jump")
          sol.timer.start(10, function()
--              hero.has_grabbed_ladder = false
              hero.vspeed = -4 --TODO don"t make underwater jumps so powerful
              if hero.has_grabbed_ladder then
                hero.vspeed=-2
              end
              if map:get_ground(hero:get_position()) == "deep_water" then
                hero.vspeed= -2
              end
            end)
        end 
      end
    end
  end

end

function item:on_using()
  item:start_using()
  item:set_finished()
end

-- Initialize the metatable of appropriate entities to be able to set a reaction on jumped on.
local function initialize_meta()

  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_jump_on_reaction then
    return
  end

  enemy_meta.jump_on_reaction = "ignored"  -- Nothing happens by default.
  enemy_meta.jump_on_reaction_sprite = {}

  function enemy_meta:get_jump_on_reaction(sprite)
    if sprite and self.jump_on_reaction_sprite[sprite] then
      return self.jump_on_reaction_sprite[sprite]
    end
    return self.jump_on_reaction
  end

  function enemy_meta:set_jump_on_reaction(reaction, sprite)
    self.jump_on_reaction = reaction
  end

  function enemy_meta:set_jump_on_reaction_sprite(sprite, reaction)
    self.jump_on_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the feather.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_jump_on_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_jump_on_reaction_sprite(sprite, "ignored")
  end
end
initialize_meta()

