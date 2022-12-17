-- Initialize Map behavior specific to this quest.

-- Variables
local map_meta = sol.main.get_metatable("map")

-- Include scripts
require ("scripts/multi_events")
local audio_manager = require("scripts/audio_manager")




--SYSTEME DE JOUR/NUIT
--Crépuscule (+ aube avec effet soleil levant)
local twilight_surface_yellow = sol.surface.create(320,240)
twilight_surface_yellow:set_blend_mode("add")
twilight_surface_yellow:fill_color({63, 42, 0})
local twilight_surface_red = sol.surface.create(320,240)
twilight_surface_red:set_blend_mode("multiply")
twilight_surface_red:fill_color({255, 173, 226})
--Nuit
local night_surface = sol.surface.create(320,240)
night_surface:set_blend_mode("multiply")
night_surface:fill_color({0, 33, 164})

local transition_finished_callback
function map_meta:wait_on_next_map_opening_transition_finished(callback)
  assert(type(callback) == 'function')
  transition_finished_callback = callback
end

function map_meta:on_draw(dst_surface)
  local game = self:get_game()
  local hero = self:get_hero()

  --SYSTEME JOUR/NUIT
  if game:get_map():get_world() == "outside_world" then
    if game:get_value("twilight") then twilight_surface_red:draw(dst_surface) twilight_surface_yellow:draw(dst_surface) end
  end

end

map_meta:register_event("on_opening_transition_finished", function(map, destination)
    --print ("End of built-in transition")

    local game = map:get_game()
    local hero = map:get_hero()

    local ground=game:get_value("tp_ground")

    if game:get_map():get_world() == "outside_world" then
      sol.timer.start(1, function() 
        daytime_increment = true 
      end)
    end    

    if ground=="hole" and not map:is_sideview() then
      hero:fall_from_ceiling(120, nil, function()
          hero:play_ground_effect()

        end)
    end

    --call pending callback if any
    if transition_finished_callback then
      transition_finished_callback(map, destination)
      transition_finished_callback = nil
    end

    if game.needs_running_restoration==true and game.prevent_running_restoration==nil then --Restore running state
      hero:run(true)
    end
    game.prevent_running_restoration=nil
  end)

map_meta:register_event("on_started", function(map)
  local game = map:get_game()
  local hero = map:get_hero()
  hero.respawn_point_saved=nil
  local ground = game:get_value("tp_ground")
  if ground=="hole" and not map:is_sideview() then
    hero:set_visible(false)
  else
    hero:set_visible()
  end
end)

function map_meta:on_finished()
  local game = self:get_game()
  --Système jour/nuit: Temps qui passe
    game:set_value("daytime",game:get_value("daytime") + 2)
    if game:get_value("daytime") > 6 then game:set_value("daytime", 1) end
    if game:get_value("daytime") == 3 then 
      game:set_value("day",false)
      game:set_value("twilight",true) 
      game:set_value("night",false)
      game:set_value("dawn",false)
    elseif game:get_value("daytime") == 4 or game:get_value("daytime") == 5 then
      game:set_value("day",false)
      game:set_value("twilight",false) 
      game:set_value("night",true)
      game:set_value("dawn",false)
    elseif game:get_value("daytime") == 6 then
      game:set_value("day",false)
      game:set_value("twilight",false) 
      game:set_value("night",false)
      game:set_value("dawn",true)
    else
      game:set_value("day",true)
      game:set_value("twilight",false) 
      game:set_value("night",false)
      game:set_value("dawn",false)
    end
end

map_meta:register_event("on_finished", function(map)
  if map:get_hero():is_running() then
    map:get_game().needs_running_restoration = true
  end
end)