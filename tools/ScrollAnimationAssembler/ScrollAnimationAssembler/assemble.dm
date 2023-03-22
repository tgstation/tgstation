
/proc/Assemble(background_dmi as file, foreground_dmi as file, mask_dmi as file, frames, duration)

	var/source_icon = icon(background_dmi)

	var/target_icon = icon(foreground_dmi)

	var/icon/mask_icon = new(mask_dmi, icon_state = "", dir = SOUTH, frame = 1)

	world << icon_states(mask_icon).len