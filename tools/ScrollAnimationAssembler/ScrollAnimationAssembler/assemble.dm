
/proc/Assemble(background_dmi as file, foreground_dmi as file, mask_dmi as file, frames, duration)

	var/icon/source_icon = new(background_dmi, icon_state = "", frame = 1)

	var/icon/target_icon = new(foreground_dmi, icon_state = "", frame = 1)

	var/icon/mask_icon = new(mask_dmi, icon_state = "", frame = 1)

	var/icon/outputIcon = new /icon()

	var/filename = "output.dmi"
	fdel(filename)

	for(var/F in 1 to frames)
		outputIcon = icon(filename)

		var/icon/curr_frame = Apply(source_icon, mask_icon, target_icon, F)
		outputIcon.Insert(curr_frame, "", frame = F, delay = duration)

		fcopy(outputIcon, filename)

	world << "Finished!"