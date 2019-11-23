/obj/item/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = CAMERA_SEE_GHOSTS_BASIC

/obj/item/camera/spooky/badmin
	desc = "A polaroid camera, some say it can see ghosts! It seems to have an extra magnifier on the end."
	see_ghosts = CAMERA_SEE_GHOSTS_ORBIT

/obj/item/camera/detective
	name = "Detective's camera"
	desc = "A polaroid camera with extra capacity for crime investigations."
	pictures_max = 30
	pictures_left = 30

/obj/item/camera/brain
	name = "Brain camera"
	desc = "The real memories were the friends we made along the way..."
	see_ghosts = CAMERA_SEE_GHOSTS_BASIC
	silent = TRUE

/obj/item/camera/brain/captureimage(atom/target, mob/user, flag, size_x = 1, size_y = 1)
	var/mob/living/simple_animal/capone_flicker/our_boy = new /mob/living/simple_animal/capone_flicker(get_turf(src))

	if(flash_enabled)
		flash_lighting_fx(8, light_power, light_color)
	blending = TRUE
	var/turf/target_turf = get_turf(target)
	if(!isturf(target_turf))
		blending = FALSE
		return FALSE
	size_x = CLAMP(size_x, 0, CAMERA_PICTURE_SIZE_HARD_LIMIT)
	size_y = CLAMP(size_y, 0, CAMERA_PICTURE_SIZE_HARD_LIMIT)
	var/list/desc = list("This is a photo of an area of [size_x+1] meters by [size_y+1] meters.")
	var/list/mobs_spotted = list()
	var/list/dead_spotted = list()
	var/list/seen
	var/list/viewlist = (user && user.client)? getviewsize(user.client.view) : getviewsize(world.view)
	var/viewr = max(viewlist[1], viewlist[2]) + max(size_x, size_y)
	var/viewc = user.client? user.client.eye : target
	seen = get_hear(viewr, viewc)
	var/list/turfs = list()
	var/list/mobs = list()

	var/clone_area = SSmapping.RequestBlockReservation(size_x * 2 + 1, size_y * 2 + 1)

	for(var/turf/T in block(locate(target_turf.x - size_x, target_turf.y - size_y, target_turf.z), locate(target_turf.x + size_x, target_turf.y + size_y, target_turf.z)))
		if((T in seen))
			turfs += T
			for(var/mob/M in T)
				mobs += M

	mobs += our_boy
	our_boy.forceMove(pick(turfs))

	for(var/i in mobs)
		var/mob/M = i
		mobs_spotted += M
		if(M.stat == DEAD)
			dead_spotted += M
		desc += M.get_photo_description(src)

	var/psize_x = (size_x * 2 + 1) * world.icon_size
	var/psize_y = (size_y * 2 + 1) * world.icon_size
	var/get_icon = camera_get_icon(turfs, target_turf, psize_x, psize_y, clone_area, size_x, size_y, (size_x * 2 + 1), (size_y * 2 + 1))
	qdel(clone_area)
	var/icon/temp = icon('icons/effects/96x96.dmi',"")
	temp.Blend("#000", ICON_OVERLAY)
	temp.Scale(psize_x, psize_y)
	temp.Blend(get_icon, ICON_OVERLAY)

	QDEL_NULL(our_boy)

	var/datum/picture/P = new("picture", desc.Join(" "), mobs_spotted, dead_spotted, temp, null, psize_x, psize_y)
	return P
