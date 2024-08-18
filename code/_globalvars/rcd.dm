GLOBAL_VAR_INIT(holographic_wall, init_holographic_wall())
GLOBAL_VAR_INIT(holographic_window, init_holographic_window())

/proc/init_holographic_wall()
	return generate_joined_wall('icons/turf/walls/metal_wall.dmi', NONE)

/proc/init_holographic_window()
	var/mutable_appearance/window_frame = mutable_appearance('icons/obj/structures/smooth/window_frames/window_frame_normal.dmi', "window_frame_normal-0")
	var/mutable_appearance/window = mutable_appearance('icons/obj/structures/smooth/windows/normal_window.dmi', "0-lower")
	var/mutable_appearance/window_frill = mutable_appearance('icons/obj/structures/smooth/windows/normal_window.dmi', "0-upper")
	window_frill.pixel_z = 32
	window_frame.add_overlay(list(window, window_frill))
	return window_frame
