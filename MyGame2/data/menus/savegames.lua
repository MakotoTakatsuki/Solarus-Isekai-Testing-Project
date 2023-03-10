-- Savegame selection screen.

local savegame_menu = {}
local last_joy_axis_move = { 0, 0 }

function savegame_menu:on_started()

  -- Create all graphic objects.
  self.surface = sol.surface.create(320, 240)
  self.background_color = { 104, 144, 240 }
  self.background_img = sol.surface.create("menus/selection_menu_background.png")
  self.save_container_img = sol.surface.create("menus/selection_menu_save_container.png")
  self.option_container_img = sol.surface.create("menus/selection_menu_option_container.png")
  local dialog_font, dialog_font_size = sol.language.get_dialog_font()
  local menu_font, menu_font_size = sol.language.get_menu_font()
  self.option1_text = sol.text_surface.create{
    font = dialog_font,
    font_size = dialog_font_size,
  }
  self.option2_text = sol.text_surface.create{
    font = dialog_font,
    font_size = dialog_font_size,
  }
  self.title_text = sol.text_surface.create{
    horizontal_alignment = "center",
    font = menu_font,
    font_size = menu_font_size,
  }
  self.cursor_position = 1
  self.cursor_sprite = sol.sprite.create("menus/selection_menu_cursor")
  self.allow_cursor_move = true
  self.finished = false
  self.phase = nil

  -- Run the menu.
  self:read_savegames()
  sol.audio.play_music("game_over")
  self:init_phase_select_file()

  -- Show an opening transition.
  self.surface:fade_in()
end

function savegame_menu:on_key_pressed(key)

  local handled = false
  if key == "escape" then
    -- Stop the program.
    handled = true
    sol.main.exit()
  elseif key == "right" then
    handled = self:direction_pressed(0)
  elseif key == "up" then
    handled = self:direction_pressed(2)
  elseif key == "left" then
    handled = self:direction_pressed(4)
  elseif key == "down" then
    handled = self:direction_pressed(6)
  elseif not self.finished then

    -- Phase-specific direction_pressed method.
    local method_name = "key_pressed_phase_" .. self.phase
    handled = self[method_name](self, key)
  end

  return handled
end

function savegame_menu:on_joypad_button_pressed(button)

  local handled = true
  if not self.finished then
    -- Phase-specific joypad_button_pressed method.
    local method_name = "joypad_button_pressed_phase_" .. self.phase
    handled = self[method_name](self, button)
  else
    handled = false
  end

  return handled
end

function savegame_menu:on_joypad_axis_moved(axis, state)

  -- Avoid move repetition
  local handled = last_joy_axis_move[axis % 2] == state
  last_joy_axis_move[axis % 2] = state

  if not handled then
    if axis % 2 == 0 then  -- Horizontal axis.
      if state > 0 then
        self:direction_pressed(0)
      elseif state < 0 then
        self:direction_pressed(4)
      end
    else  -- Vertical axis.
      if state > 0 then
        self:direction_pressed(6)
      elseif state < 0 then
        self:direction_pressed(2)
      end
    end
  end

  return handled
end

function savegame_menu:on_joypad_hat_moved(hat, direction8)

  if direction8 ~= -1 then
    self:direction_pressed(direction8)
  end
end

function savegame_menu:direction_pressed(direction8)

  local handled = true
  if self.allow_cursor_move and not self.finished then

    -- The cursor moves too much when using a joypad axis.
    self.allow_cursor_move = false
    sol.timer.start(self, 100, function()
      self.allow_cursor_move = true
    end)

    -- Phase-specific direction_pressed method.
    local method_name = "direction_pressed_phase_" .. self.phase
    handled = self[method_name](self, direction8)
  else
    handled = false
  end
end

function savegame_menu:on_draw(dst_surface)

  -- Background color.
  self.surface:fill_color(self.background_color)

  -- Savegames container.
  self.background_img:draw(self.surface, 0, 0)
  self.title_text:draw(self.surface, 160, 40)

  -- Phase-specific draw method.
  local method_name = "draw_phase_" .. self.phase
  self[method_name](self)

  -- The menu makes 320*240 pixels, but dst_surface may be larger.
  local width, height = dst_surface:get_size()
  self.surface:draw(dst_surface, width / 2 - 160, height / 2 - 120)
end

function savegame_menu:draw_savegame(slot_index)

  local slot = self.slots[slot_index]
  self.save_container_img:draw(self.surface, 57, 48 + slot_index * 27)
  slot.player_name_text:draw(self.surface, 137, 61 + slot_index * 27)

  if slot.hearts_view ~= nil then
    slot.hearts_view:set_dst_position(208, 51 + slot_index * 27)
    slot.hearts_view:on_draw(self.surface)
  end
end

function savegame_menu:draw_savegame_cursor()

  local x, y
  if self.cursor_position == 5 then
    x = 166
  else
    x = 72
  end
  if self.cursor_position < 4 then
    y = 49 + self.cursor_position * 27
  else
    y = 159
  end
  self.cursor_sprite:draw(self.surface, x, y)
end

function savegame_menu:draw_savegame_number(slot_index)

  local slot = self.slots[slot_index]
  slot.number_img:draw(self.surface, 76, 53 + slot_index * 27)
end

function savegame_menu:draw_bottom_buttons()

  local x
  local y = 158
  if self.option1_text:get_text():len() > 0 then
    x = 57
    self.option_container_img:draw(self.surface, x, y)
    self.option1_text:draw(self.surface, 110, 172)
  end
  if self.option2_text:get_text():len() > 0 then
    x = 165
    self.option_container_img:draw(self.surface, x, y)
    self.option2_text:draw(self.surface, 198, 172)
  end
end

function savegame_menu:read_savegames()

  self.slots = {}
  local font, font_size = sol.language.get_dialog_font()
  for i = 1, 3 do
    local slot = {}
    slot.file_name = "save" .. i .. ".dat"
    slot.savegame = sol.game.load(slot.file_name)
    slot.number_img = sol.surface.create("menus/selection_menu_save" .. i .. ".png")

    slot.player_name_text = sol.text_surface.create{
      font = font,
      font_size = font_size,
    }
    if sol.game.exists(slot.file_name) then
      -- Existing file.
      if slot.savegame:get_ability("tunic") == 0 then
        -- Savegame not fully initialized (created with Solarus 0.9).
        slot.savegame:set_ability("tunic", 1)
        slot.savegame:get_item("rupee_bag"):set_variant(1)
      end

      slot.player_name_text:set_text(slot.savegame:get_value("player_name"))

      -- Hearts.
      local hearts_class = require("hud/hearts")
      slot.hearts_view = hearts_class:new(slot.savegame)
    else
      -- New file.
      local name = "- " .. sol.language.get_string("selection_menu.empty") .. " -"
      slot.player_name_text:set_text(name)
    end

    self.slots[i] = slot
  end
end

function savegame_menu:set_bottom_buttons(key1, key2)

  if key1 ~= nil then
    self.option1_text:set_text_key(key1)
  else
    self.option1_text:set_text("")
  end

  if key2 ~= nil then
    self.option2_text:set_text_key(key2)
  else
    self.option2_text:set_text("")
  end
end

function savegame_menu:move_cursor_up()

  sol.audio.play_sound("cursor")
  local cursor_position = self.cursor_position - 1
  if cursor_position == 0 then
    cursor_position = 4
  elseif cursor_position == 4 then
    cursor_position = 3
  end
  self:set_cursor_position(cursor_position)
end

function savegame_menu:move_cursor_down()

  sol.audio.play_sound("cursor")
  local cursor_position = self.cursor_position + 1
  if cursor_position >= 5 then
    cursor_position = 1
  end
  self:set_cursor_position(cursor_position)
end

function savegame_menu:move_cursor_left_or_right()

  if self.cursor_position == 4 then
    sol.audio.play_sound("cursor")
    self:set_cursor_position(5)
  elseif self.cursor_position == 5 then
    sol.audio.play_sound("cursor")
    self:set_cursor_position(4)
  end
end

function savegame_menu:set_cursor_position(cursor_position)

  self.cursor_position = cursor_position
  self.cursor_sprite:set_frame(0)  -- Restart the animation.
end

---------------------------
-- Phase "select a file" --
---------------------------
function savegame_menu:init_phase_select_file()

  self.phase = "select_file"
  self.title_text:set_text_key("selection_menu.phase.select_file")
  self:set_bottom_buttons("selection_menu.erase")
  self.cursor_sprite:set_animation("blue")
end

function savegame_menu:key_pressed_phase_select_file(key)

  local handled = false
  if key == "space" or key == "return" then
    sol.audio.play_sound("ok")
    if self.cursor_position == 4 then
      -- The user chooses "Erase".
      self:init_phase_erase_file()
    else
      -- The user chooses a savegame.
      local slot = self.slots[self.cursor_position]
      if sol.game.exists(slot.file_name) then
        -- The file exists: run it after a fade-out effect.
        self.finished = true
        self.surface:fade_out()
        sol.timer.start(self, 700, function()
          sol.menu.stop(self)
	  sol.main:start_savegame(slot.savegame)
        end)
      else
        -- It's a new savegame: choose the player's name.
        self:init_phase_choose_name()
      end
    end
    handled = true
  end

  return handled
end

function savegame_menu:joypad_button_pressed_phase_select_file(button)

  return self:key_pressed_phase_select_file("space")
end

function savegame_menu:direction_pressed_phase_select_file(direction8)

  local handled = true
  if direction8 == 6 then  -- Down.
    self:move_cursor_down()
  elseif direction8 == 2 then  -- Up.
    self:move_cursor_up()
  elseif direction8 == 0 or direction8 == 4 then  -- Right or Left.
    self:move_cursor_left_or_right()
  else
    handled = false
  end
  return handled
end

function savegame_menu:draw_phase_select_file()

  -- Savegame slots.
  for i = 1, 3 do
    self:draw_savegame(i)
  end

  -- Bottom buttons.
  self:draw_bottom_buttons()

  -- Cursor.
  self:draw_savegame_cursor()

  -- Save numbers.
  for i = 1, 3 do
    self:draw_savegame_number(i)
  end
end

--------------------------
-- Phase "erase a file" --
--------------------------
function savegame_menu:init_phase_erase_file()

  self.phase = "erase_file"
  self.title_text:set_text_key("selection_menu.phase.erase_file")
  self:set_bottom_buttons("selection_menu.cancel", nil)
  self.cursor_sprite:set_animation("red")
end

function savegame_menu:key_pressed_phase_erase_file(key)

  local handled = true
  if key == "space" or key == "return" then
    if self.cursor_position == 4 then
      -- The user chooses "Cancel".
      sol.audio.play_sound("ok")
      self:init_phase_select_file()
    elseif self.cursor_position > 0 and self.cursor_position <= 3 then
      -- The user chooses a savegame to delete.
      local slot = self.slots[self.cursor_position]
      if not sol.game.exists(slot.file_name) then
        -- The savegame doesn't exist: error sound.
        sol.audio.play_sound("wrong")
      else
        -- The savegame exists: confirm deletion.
        sol.audio.play_sound("ok")
        self:init_phase_confirm_erase()
      end
    end
  else
    handled = false
  end
  return handled
end

function savegame_menu:joypad_button_pressed_phase_erase_file(button)

  return self:key_pressed_phase_erase_file("space")
end

function savegame_menu:direction_pressed_phase_erase_file(direction8)

  local handled = true
  if direction8 == 6 then  -- Down.
    self:move_cursor_down()
  elseif direction8 == 2 then  -- Up.
    self:move_cursor_up()
  else
    handled = false
  end
  return handled
end

function savegame_menu:draw_phase_erase_file()

  -- Savegame slots.
  for i = 1, 3 do
    self:draw_savegame(i)
  end

  -- Bottom buttons.
  self:draw_bottom_buttons()

  -- Cursor.
  self:draw_savegame_cursor()

  -- Save numbers.
  for i = 1, 3 do
    self:draw_savegame_number(i)
  end
end

---------------------------
-- Phase "Are you sure?" --
---------------------------
function savegame_menu:init_phase_confirm_erase()

  self.phase = "confirm_erase"
  self.title_text:set_text_key("selection_menu.phase.confirm_erase")
  self:set_bottom_buttons("selection_menu.big_no", "selection_menu.big_yes")
  self.save_number_to_erase = self.cursor_position
  self.cursor_position = 4  -- Select "no" by default.
end

function savegame_menu:key_pressed_phase_confirm_erase(key)

  local handled = true
  if key == "space" or key == "return" then
   if self.cursor_position == 5 then
      -- The user chooses "yes".
      sol.audio.play_sound("boss_killed")
      local slot = self.slots[self.save_number_to_erase]
      sol.game.delete(slot.file_name)
      self.cursor_position = self.save_number_to_erase
      self:read_savegames()
      self:init_phase_select_file()
    elseif self.cursor_position == 4 then
      -- The user chooses "no".
      sol.audio.play_sound("ok")
      self:init_phase_select_file()
    end
  else
    handled = false
  end
  return handled
end

function savegame_menu:joypad_button_pressed_phase_confirm_erase(button)

  return self:key_pressed_phase_confirm_erase("space")
end

function savegame_menu:direction_pressed_phase_confirm_erase(direction8)

  local handled = false
  if direction8 == 0 or direction8 == 4 then  -- Right or Left.
    self:move_cursor_left_or_right()
    handled = true
  end
  return handled
end

function savegame_menu:draw_phase_confirm_erase()

  -- Current savegame slot.
  self:draw_savegame(self.save_number_to_erase)
  self:draw_savegame_number(self.save_number_to_erase)

  -- Bottom buttons.
  self:draw_bottom_buttons()

  -- Cursor.
  self:draw_savegame_cursor()
end
------------------------------
-- Phase "choose your name" --
------------------------------
function savegame_menu:init_phase_choose_name()

  self.phase = "choose_name"
  self.title_text:set_text_key("selection_menu.phase.choose_name")
  self.cursor_sprite:set_animation("letters")
  self.player_name = ""
  local font, font_size = sol.language.get_menu_font()
  self.player_name_text = sol.text_surface.create{
    font = font,
    font_size = font_size,
  }
  self.letter_cursor = { x = 0, y = 0 }
  self.letters_img = sol.surface.create("menus/selection_menu_letters.png")
  self.name_arrow_sprite = sol.sprite.create("menus/arrow")
  self.name_arrow_sprite:set_direction(0)
  self.can_add_letter_player_name = true
end

function savegame_menu:key_pressed_phase_choose_name(key)

  local handled = false
  local finished = false
  if key == "return" then
    -- Directly validate the name.
    finished = self:validate_player_name()
    handled = true

  elseif key == "space" or key == "c" then

    if self.can_add_letter_player_name then
      -- Choose a letter
      finished = self:add_letter_player_name()
      self.player_name_text:set_text(self.player_name)
      self.can_add_letter_player_name = false
      sol.timer.start(self, 300, function()
        self.can_add_letter_player_name = true
      end)
      handled = true
    end
  end

  if finished then
    self:init_phase_select_file()
  end

  return handled
end

function savegame_menu:joypad_button_pressed_phase_choose_name(button)

  return self:key_pressed_phase_choose_name("space")
end

function savegame_menu:direction_pressed_phase_choose_name(direction8)

  local handled = true
  if direction8 == 0 then  -- Right.
    sol.audio.play_sound("cursor")
    self.letter_cursor.x = (self.letter_cursor.x + 1) % 13

  elseif direction8 == 2 then  -- Up.
    sol.audio.play_sound("cursor")
    self.letter_cursor.y = (self.letter_cursor.y + 4) % 5

  elseif direction8 == 4 then  -- Left.
    sol.audio.play_sound("cursor")
    self.letter_cursor.x = (self.letter_cursor.x + 12) % 13

  elseif direction8 == 6 then  -- Down.
    sol.audio.play_sound("cursor")
    self.letter_cursor.y = (self.letter_cursor.y + 1) % 5

  else
    handled = false
  end
  return handled
end

function savegame_menu:draw_phase_choose_name()

  -- Letter cursor.
  self.cursor_sprite:draw(self.surface,
      66 + 14 * self.letter_cursor.x,
      92 + 16 * self.letter_cursor.y)

  -- Name and letters.
  self.name_arrow_sprite:draw(self.surface, 72, 76)
  self.player_name_text:draw(self.surface, 82, 85)
  self.letters_img:draw(self.surface, 72, 98)
end

function savegame_menu:add_letter_player_name()

  local size = self.player_name:len()
  local letter_cursor = self.letter_cursor
  local letter_to_add = nil
  local finished = false

  if letter_cursor.y == 0 then  -- Uppercase letter from A to M.
    letter_to_add = string.char(string.byte("A") + letter_cursor.x)

  elseif letter_cursor.y == 1 then  -- Uppercase letter from N to Z.
    letter_to_add = string.char(string.byte("N") + letter_cursor.x)

  elseif letter_cursor.y == 2 then  -- Lowercase letter from a to m.
    letter_to_add = string.char(string.byte("a") + letter_cursor.x)

  elseif letter_cursor.y == 3 then  -- Lowercase letter from n to z.
    letter_to_add = string.char(string.byte("n") + letter_cursor.x)

  elseif letter_cursor.y == 4 then  -- Digit or special command.
    if letter_cursor.x <= 9 then
      -- Digit.
      letter_to_add = string.char(string.byte("0") + letter_cursor.x)
    else
      -- Special command.

      if letter_cursor.x == 10 then  -- Remove the last letter.
        if size == 0 then
          sol.audio.play_sound("wrong")
        else
          sol.audio.play_sound("danger")
          self.player_name = self.player_name:sub(1, size - 1)
        end

      elseif letter_cursor.x == 11 then  -- Validate the choice.
        finished = self:validate_player_name()

      elseif letter_cursor.x == 12 then  -- Cancel.
        sol.audio.play_sound("danger")
        finished = true
      end
    end
  end

  if letter_to_add ~= nil then
    -- A letter was selected.
    if size < 6 then
      sol.audio.play_sound("danger")
      self.player_name = self.player_name .. letter_to_add
    else
      sol.audio.play_sound("wrong")
    end
  end

  return finished
end

function savegame_menu:validate_player_name()

  if self.player_name:len() == 0 then
    sol.audio.play_sound("wrong")
    return false
  end

  sol.audio.play_sound("ok")

  local savegame = self.slots[self.cursor_position].savegame
  self:set_initial_values(savegame)
  savegame:save()
  self:read_savegames()
  return true
end

function savegame_menu:set_initial_values(savegame)

  savegame:set_starting_location("Out/plains_1", "start_position")
  savegame:set_value("player_name", self.player_name)

  -- Initially give 3 hearts, the first tunic and the first wallet.
  savegame:set_max_life(12)
  savegame:set_life(savegame:get_max_life())
  savegame:get_item("tunic"):set_variant(1)
  savegame:set_ability("tunic", 1)
  savegame:get_item("rupee_bag"):set_variant(1)
end

return savegame_menu

