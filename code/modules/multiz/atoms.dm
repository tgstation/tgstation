
/atom
	var/atom/movable/zshadow/zshadow


//TODO: Simplify for base atoms? (their shadows would never move, so they don't need a zshadow movable atom)
/atom/proc/CreateZShadow()
	if(!zshadow) //if one exists, just sync it
		zshadow = new()
	zshadow.owner = src
	zshadow.Sync()
	return zshadow


//Can we fall through to the Z below? (regardless of open turfs, etc.)
//This is so mobs with jetpacks, thrown items, etc. can ignore falling
/atom/proc/CanFallThroughZ()
	if(!has_gravity())
		return FALSE
	return TRUE


/atom/movable/CanFallThroughZ()
	. = ..()
	if(.)
		if(throwing)
			return FALSE


/mob/CanFallThroughZ()
	. = ..()
	if(.)
		var/obj/item/weapon/tank/jetpack/J = get_jetpack()
		if(istype(J) && J.allow_thrust(0.01, src)) //working jetpack
			return FALSE



//Hooks:
//TODO: move to existing locations

/atom/proc/SetupZShadow(mapload = FALSE)
	if(mapload) //This is before SSz, so we can't rely on connections yet
		var/turf/U = get_step(src, UP)
		if(U && U.z_open)
			CreateZShadow()
	else if(GetAboveConnectedTurf(src))
		CreateZShadow()

/atom/Initialize(mapload)
	..()
	SetupZShadow(mapload)

/turf/Initialize(mapload)
	..()
	if(z_open)
		var/turf/D = get_step(src, DOWN)
		if(D)
			ConnectVerticalZs(z, D.z)
			D.SetupZShadow()
			for(var/a in D)
				var/atom/A = a
				A.SetupZShadow(mapload)

	SetupZShadow(mapload)

/atom/setDir(dir)
	..()
	if(zshadow)
		zshadow.setDir(dir) //dir is not an appearance var, so we can update it quickly

/atom/Destroy()
	. = ..()
	if(zshadow)
		qdel(zshadow)

/atom/movable/Moved()
	..()
	if(zshadow)
		zshadow.SyncLoc()
	else
		if(GetAboveConnectedTurf(src))
			CreateZShadow()


//Get this to cascade somehow...
/obj/update_icon()
	..()
	if(zshadow)
		zshadow.SyncAppearance()

//Cascade somehow.
/mob/update_icons()
	..()
	if(zshadow)
		zshadow.SyncAppearance()

/turf/AfterChange()
	..()
	if(zshadow)
		zshadow.SyncAppearance()


/turf/add_decal(decal,group)
	..()
	if(zshadow)
		zshadow.SyncAppearance()


/turf/remove_decal(group)
	..()
	if(zshadow)
		zshadow.SyncAppearance()


/turf/open/update_visuals()
	..()
	if(zshadow)
		zshadow.SyncAppearance()