if RequiredScript == "lib/managers/hud/hudpresenter" and VoidUI.options.enable_presenter then
	function HUDPresenter:init(hud)
		self._hud_panel = hud.panel
		self._id = 0
		self._active = 0
		self._scale = VoidUI.options.presenter_scale
	end
	function HUDPresenter:present(params)
		self._present_queue = self._present_queue or {}
		if self._active > (VoidUI.options.presenter_buffer-1) then
			table.insert(self._present_queue, params)
			return
		end
		
		if self._active > 0 then
			for i = self._id - 1, self._id - self._active, -1 
			do
				local present_panel = self._hud_panel:child("present_panel_"..i)
				local slot = present_panel:child("slot")
				slot:set_text(slot:text()+1)
				present_panel:animate(callback(self, self, "_animate_move_queue"), tonumber(slot:text()))
			end
		end
		if params.present_mid_text then
			self:_present_information(params)
		end
	end

	function HUDPresenter:_present_information(params)
		local id = self._id
		self._active = self._active + 1
		self._id = self._id + 1
		local h = 40 * self._scale
		local w = 100 * self._scale
		local x = self._hud_panel:w() - 200 * self._scale
		local y = self._hud_panel:h() / 2 - (h / 2)
		local color = params.color or Color.white
		local present_panel = self._hud_panel:panel({
			visible = false,
			name = "present_panel_"..id,
			layer = 10,
			x = x,
			y = y
		})
		local slot = present_panel:text({
			name = "slot",
			visible = false,
			text = "0",
			vertical = "top",
			valign = "center",
			layer = 0,
			font = tweak_data.hud_present.title_font,
			font_size = 10
		})
		local weapons_texture = "guis/textures/VoidUI/hud_weapons"
		local present_bg_left = present_panel:bitmap({
			name = "present_bg_left",
			texture = weapons_texture,
			texture_rect = {26,0,43,150},
			layer = 1,
			y = 0,
			w = 35 * self._scale,
			h = h,
			rotation = 360,
		})
		local present_border_left = present_panel:bitmap({
			name = "present_border_left",
			texture = "guis/textures/VoidUI/hud_highlights",
			texture_rect = {0,0,23,157},
			layer = 2,
			y = 0,
			w = 15 * self._scale,
			h = h,
			rotation = 360,
			color = color,
			visible = params.border and true or false,
		})
		local present_bg = present_panel:bitmap({
			name = "present_bg",
			texture = weapons_texture,
			texture_rect = {69,0,416,150},
			layer = 1,
			w = w,
			h = h,
			x = 35 * self._scale,
			y = 0,
			rotation = 360,
		})	
		local present_border = present_panel:bitmap({
			name = "present_border",
			texture = "guis/textures/VoidUI/hud_highlights",
			texture_rect = {23,0,480,157},
			layer = 2,
			w = w,
			h = h,
			x = 15 * self._scale,
			y = 0,
			rotation = 360,
			color = color,
			visible = params.border and true or false,
		})	
		local present_bg_right = present_panel:bitmap({
			name = "present_bg_right",
			texture = weapons_texture,
			texture_rect = {485,0,43,150},
			layer = 1,
			y = 0,
			w = 35 * self._scale,
			h = h,
			rotation = 360,
		})
		present_bg_right:set_left(present_bg:right())
		local title = present_panel:text({
			name = "title",
			text = params.title or "ERROR",
			vertical = "top",
			valign = "left",
			layer = 2,
			x = 15 * self._scale,
			color = color,
			rotation = 360,
			font = tweak_data.hud_present.title_font,
			font_size = tweak_data.hud_present.title_size / 1.5 * self._scale
		})
		local _, _, title_w, title_h = title:text_rect()
		title:set_h(title_h)
		local text = present_panel:text({
			name = "text",
			text = params.text,
			vertical = "top",
			valign = "top",
			layer = 2,
			x = 9 * self._scale,
			color = color,
			rotation = 360,
			font = tweak_data.hud_present.text_font,
			font_size = tweak_data.hud_present.text_size / 1.5 * self._scale
		})
		local _, _, text_w, text_h = text:text_rect()
		text:set_top(title:bottom())
		text:set_h(text_h)
		w = math.max(title_w, text_w)
		present_bg:set_w(w - 35 * self._scale)
		present_bg_right:set_left(present_bg:right())
		present_panel:set_w(present_bg_left:w() + present_bg:w() + present_bg_right:w())
		present_panel:set_right(self._hud_panel:right())
		

		present_panel:animate(callback(self, self, "_animate_present_information"))
		
		if params.event and not VoidUI.options.presenter_sound then
			managers.hud._sound_source:post_event(params.event)
		end
	end
	function HUDPresenter:_animate_present_information(present_panel)
		present_panel:set_visible(true)
		present_panel:animate(callback(self, self, "_animate_show_panel"))
		wait(4)
		present_panel:animate(callback(self, self, "_animate_hide_panel"))
		wait(0.5)
		self._hud_panel:remove(present_panel)
		self._active = self._active - 1
		self:_present_done()
	end

	function HUDPresenter:_present_done()
		local queued = table.remove(self._present_queue, 1)
		if queued then
			setup:add_end_frame_clbk(callback(self, self, "_do_it", queued))
		end
	end
	function HUDPresenter:_do_it(queued)
		self._present_queue = self._present_queue or {}
		if self._active > 5 then
			table.insert(self._present_queue, params)
			return
		end
		
		if self._active > 0 then
			for i = self._id - 1, self._id - self._active, -1 
			do
				local present_panel = self._hud_panel:child("present_panel_"..i)
				local slot = present_panel:child("slot")
				slot:set_text(slot:text()+1)
				present_panel:animate(callback(self, self, "_animate_move_queue"), tonumber(slot:text()))
			end
		end
		self:_present_information(queued)
	end
	function HUDPresenter:_animate_move_queue(present_panel, goal)
		local y = present_panel:y()
		local y2 = (self._hud_panel:h() / 2 - ((40 * self._scale ) / 2)) - (goal * (45 * self._scale))
		local TOTAL_T = 0.2
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			present_panel:set_y(math.lerp(y,y2, t / TOTAL_T))
		end
		present_panel:set_y(y2)
	end

	function HUDPresenter:_animate_show_panel(present_panel)
		local x = present_panel:x()
		local x2 = present_panel:x() + present_panel:w()
		local TOTAL_T = 0.5
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			present_panel:set_alpha(math.lerp(0,1, t / TOTAL_T))
			present_panel:set_x(math.lerp(x2,x, t / TOTAL_T))
		end
		present_panel:set_alpha(1)
		present_panel:set_x(x)
	end
	function HUDPresenter:_animate_hide_panel(present_panel)
		local x = present_panel:x()
		local x2 = present_panel:x() + present_panel:w()
		local TOTAL_T = 0.5
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			present_panel:set_alpha(math.lerp(1, 0, t / TOTAL_T))
			present_panel:set_x(math.lerp(x,x2, t / TOTAL_T))
			x2 = x2 + (dt > 0 and 0.1 or 0)
		end
		present_panel:set_alpha(0)
		present_panel:set_x(x2)
	end
elseif RequiredScript == "lib/managers/customsafehousemanager" then
	
	local complete_trophy = CustomSafehouseManager.complete_trophy
	function CustomSafehouseManager:complete_trophy(trophy_or_id)
		complete_trophy(self, trophy_or_id)
		local trophy = type(trophy_or_id) == "table" and trophy_or_id or self:get_trophy(trophy_or_id)
		if VoidUI.options.trophies and managers.hud and trophy and trophy.completed then
			managers.hud:present({present_mid_text = true, title = managers.localization:to_upper_text("VoidUI_trophy"), text = managers.localization:text(trophy.name_id), border = true, color = tweak_data.screen_colors.challenge_completed_color})
		end
	end
	
	local complete_daily = CustomSafehouseManager.complete_daily
	function CustomSafehouseManager:complete_daily()
		complete_daily(self)
		if not self:unlocked() then
			return
		end
		
		if VoidUI.options.trophies and managers.hud and self._global.daily and self._global.daily.trophy.completed then
			managers.hud:present({present_mid_text = true, title = managers.localization:to_upper_text("VoidUI_daily"), text = managers.localization:text(self._global.daily.trophy.name_id), border = true, color = tweak_data.screen_colors.challenge_completed_color})
		end
	end
	
elseif RequiredScript == "lib/managers/challengemanager" then
	
	local check_challenge_completed = ChallengeManager._check_challenge_completed
	function ChallengeManager:_check_challenge_completed(id, key)
		check_challenge_completed(self, id, key)
		local active_challenge = self:get_active_challenge(id, key)
		if VoidUI.options.trophies and managers.hud and active_challenge and active_challenge.completed then
			managers.hud:present({present_mid_text = true, title = managers.localization:to_upper_text("VoidUI_challenge"), text = managers.localization:text(active_challenge.name_id), border = true, color = tweak_data.screen_colors.challenge_completed_color})
		end
	end
	
end