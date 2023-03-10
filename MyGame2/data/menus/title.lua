-- Title screen of the game.

local title_screen = {}

function title_screen:on_started()

  -- black screen during 0.3 seconds
  self.phase = "black"

  self.surface = sol.surface.create(320, 240)
  sol.timer.start(self, 300, function()
    self:phase_zs_presents()
  end)

  -- use these 0.3 seconds to preload all sound effects
  sol.audio.preload_sounds()
end

function title_screen:phase_zs_presents()

  -- "Zelda Solarus presents" displayed for two seconds
  self.phase = "zs_presents"

  self.zs_presents_img =
      sol.surface.create("title_screen_initialization.png", true)

  local width, height = self.zs_presents_img:get_size()
  self.zs_presents_pos = { 160 - width / 2, 120 - height / 2 }
  sol.audio.play_sound("intro")

  sol.timer.start(self, 2000, function()
    self.surface:fade_out(10)
    sol.timer.start(self, 700, function()
      self:phase_title()
    end)
  end)
end

function title_screen:phase_title()

  -- actual title screen
  self.phase = "title"

  -- start music
  sol.audio.play_music("title_screen")

  -- create all images
  self.logo_img = sol.surface.create("menus/title_logo.png")
  self.borders_img = sol.surface.create("menus/title_borders.png")

  local dialog_font, dialog_font_size = sol.language.get_dialog_font()
  local menu_font, menu_font_size = sol.language.get_menu_font()

  self.website_img = sol.text_surface.create{
    font = menu_font,
    font_size = menu_font_size,
    color = {255, 255, 255},
    text_key = "title_screen.website",
    horizontal_alignment = "center"
  }

  self.press_space_img = sol.text_surface.create{
    font = dialog_font,
    font_size = dialog_font_size,
    color = {255, 255, 255},
    text_key = "title_screen.press_space",
    horizontal_alignment = "center"
  }

  -- set up the appearance of images and texts
  self.show_press_space = false
  function switch_press_space()
    self.show_press_space = not self.show_press_space
    sol.timer.start(self, 500, switch_press_space)
  end
  sol.timer.start(self, 6500, switch_press_space)

  -- show an opening transition
  self.surface:fade_in(30)

  self.allow_skip = false
  sol.timer.start(self, 2000, function()
    self.allow_skip = true
  end)
end

function title_screen:on_draw(dst_surface)

  if self.phase == "title" then
    self:draw_phase_title(dst_surface)
  elseif self.phase == "zs_presents" then
    self:draw_phase_present()
  end

  -- final blit (dst_surface may be larger)
  local width, height = dst_surface:get_size()
  self.surface:draw(dst_surface, width / 2 - 160, height / 2 - 120)
end

function title_screen:draw_phase_present()

  self.zs_presents_img:draw(self.surface, self.zs_presents_pos[1], self.zs_presents_pos[2])
end

function title_screen:draw_phase_title()

  -- background
  self.surface:fill_color({46, 49, 146})

  -- black bars
  self.borders_img:draw(self.surface, 0, 0)

  -- website name and logo
  self.website_img:draw(self.surface, 160, 220)
  self.logo_img:draw(self.surface)

  if self.show_press_space then
    self.press_space_img:draw(self.surface, 160, 200)
  end
end

function title_screen:on_key_pressed(key)

  local handled = false

  if key == "escape" then
    -- stop the program
    sol.main.exit()
    handled = true

  elseif key == "space" or key == "return" then
    handled = self:try_finish_title()

--  Debug.
  elseif sol.main.is_debug_enabled() then
    if key == "left shift" or key == "right shift" then
      self:finish_title()
      handled = true
    end
  end
end

function title_screen:on_joypad_button_pressed(button)

  return self:try_finish_title()
end

-- Ends the title screen (if possible)
-- and starts the savegame selection screen
function title_screen:try_finish_title()

  local handled = false

  if self.phase == "title"
      and self.allow_skip
      and not self.finished then
    self.finished = true

    self.surface:fade_out(30)
    sol.timer.start(self, 700, function()
      self:finish_title()
    end)

    handled = true
  end

  return handled
end

function title_screen:finish_title()

  sol.audio.stop_music()
  sol.menu.stop(self)
end

return title_screen

