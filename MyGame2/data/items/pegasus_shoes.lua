local item = ...
require("scripts/multi_events")
require("scripts/states/running")

function item:on_created()

  self:set_savegame_variable("i1107")
  self:set_assignable(true)

  -- Let the hero also run with the action key with old savegames.
  self:get_game():set_ability("run", self:get_variant())
end

function item:on_variant_changed(variant)

  self:get_game():set_ability("run", variant)
end

function item:on_using()

  self:get_map():get_entity("hero"):start_running()
  self:set_finished()
end

-- Initialize the metatable of appropriate entities to work with pegasus shoes.
local function initialize_meta()

  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_thrust_reaction ~= nil then
    return
  end

  enemy_meta.thrust_reaction = 2  -- 2 life points by default.
  enemy_meta.thrust_reaction_sprite = {}

  function enemy_meta:get_thrust_reaction(sprite)
    if sprite ~= nil and self.thrust_reaction_sprite[sprite] ~= nil then
      return self.thrust_reaction_sprite[sprite]
    end
    return self.thrust_reaction
  end

  function enemy_meta:set_thrust_reaction(reaction)
    self.thrust_reaction = reaction
  end

  function enemy_meta:set_thrust_reaction_sprite(sprite, reaction)
    self.thrust_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the thrust.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_thrust_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_thrust_reaction_sprite(sprite, "ignored")
  end
end

initialize_meta()

