
/obj/effect/landmark/mining_center
	name = "Mining Epicenter"
	icon_state = "mining_epicenter"

/obj/effect/landmark/mining_center/Initialize(mapload)
	..()

	for(var/obj/mining_mark as anything in GLOB.mining_center)
		if(src.z == mining_mark.z)
			CRASH("\The [src] spawned on Z level [z] already exists! Maps should only have at most one mining epicenter for normal ore generation.")

	GLOB.mining_center += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/temp_visual/dust_cloud
	name = "dust"
	desc = "We're all like... dust... in the wind."
	icon_state = "light_dust_cloud"
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE
	pixel_x = -4
	pixel_z = -4
	base_pixel_z = -4
	base_pixel_x = -4
	duration = 1 SECONDS
