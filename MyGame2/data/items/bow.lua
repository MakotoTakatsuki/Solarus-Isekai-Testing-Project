local item = ...
local game = item:get_game()
local audio_manager=require("scripts/audio_manager")

function item:on_created()

  self:set_savegame_variable("i1102")
  self:set_amount_savegame_variable("i1025")
  self:set_assignable(true)
end

function item:on_using()

  if self:get_amount() == 0 then
    sol.audio.play_sound("wrong")
  else
    -- we remove the arrow from the equipment after a small delay because the hero
    -- does not shoot immediately
    sol.timer.start(300, function()
      self:remove_amount(1)
    end)
    self:get_map():get_entity("hero"):start_bow()
  end
  self:set_finished()
end

function item:on_amount_changed(amount)

  if self:get_variant() ~= 0 then
    -- update the icon (with or without arrow)
    if amount == 0 then
      self:set_variant(1)
    else
      self:set_variant(2)
    end
  end
end

function item:on_obtaining(variant, savegame_variable)

  local quiver = self:get_game():get_item("quiver")
  if not quiver:has_variant() then
    -- Give the first quiver automatically with the bow.
    quiver:set_variant(1)
  end
end

-- Initialize the metatable of appropriate entities to work with custom arrows.
local function initialize_meta()

  -- Add Lua arrow properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_arrow_reaction ~= nil then
    -- Already done.
    return
  end

  enemy_meta.arrow_reaction = "force"
  enemy_meta.arrow_reaction_sprite = {}
  function enemy_meta:get_arrow_reaction(sprite)

    if sprite ~= nil and self.arrow_reaction_sprite[sprite] ~= nil then
      return self.arrow_reaction_sprite[sprite]
    end

    if self.arrow_reaction == "force" then
      -- Replace by the current force value.
      local game = self:get_game()
      return game:get_item("bow"):get_force()
    end

    return self.arrow_reaction
  end

  function enemy_meta:set_arrow_reaction(reaction)

    self.arrow_reaction = reaction
  end

  function enemy_meta:set_arrow_reaction_sprite(sprite, reaction)

    self.arrow_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account arrows.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_arrow_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_arrow_reaction_sprite(sprite, "ignored")
  end
end

initialize_meta()

