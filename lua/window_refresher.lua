function r_w(window_title)
	me = dm.usr
	current_uis = list.to_table(me.tgui_open_uis)
	current_windows = {}
	desired_window_handle = nil
	for _, ui in pairs(current_uis) do
		current_windows[ui.title] = ui.window
		if(ui.title == window_title) then
			desired_window_handle = ui.window
		end
	end
	if(desired_window_handle) then
		function refresh_window()
			desired_window_handle:reinitialize()
		end
	end
end

