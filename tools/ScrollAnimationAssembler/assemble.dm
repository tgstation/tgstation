/// Pull the icons from their files, iterate over frames, constructing each using Apply() and inserting into the output dmi
/proc/Assemble(background_dmi as file, foreground_dmi as file, mask_dmi as file, frames, duration)

	var/icon/source_icon = new(background_dmi, icon_state = "", frame = 1)

	var/icon/target_icon = new(foreground_dmi, icon_state = "", frame = 1)

	var/icon/mask_icon = new(mask_dmi, icon_state = "", frame = 1)

	var/icon/output_icon = new /icon()

	var/filename = "output.dmi"
	fdel(filename)

	for(var/framenum in 1 to frames)
		output_icon = icon(filename)

		var/icon/curr_frame = Apply(source_icon, mask_icon, target_icon, framenum)
		output_icon.Insert(curr_frame, "", frame = framenum, delay = duration)

		fcopy(output_icon, filename)

	world << "Finished!"
