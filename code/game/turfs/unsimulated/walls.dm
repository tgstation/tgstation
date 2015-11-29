/turf/unsimulated/wall
	name = "riveted wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1
	explosion_block = 2
	canSmoothWith = "/turf/unsimulated/wall=0"

	var/walltype = "riveted"

/turf/unsimulated/wall/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0
	canSmoothWith = null

/turf/unsimulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(istype(W,/obj/item/weapon/solder) && bullet_marks)
		var/obj/item/weapon/solder/S = W
		if(!S.remove_fuel(bullet_marks*2,user))
			return
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You remove the bullet marks with \the [W].</span>")
		bullet_marks = 0
		icon = initial(icon)

turf/unsimulated/wall/splashscreen
	name = "Space Station 13"
	icon = null
	icon_state = null
	layer = FLY_LAYER
	canSmoothWith = null

	New()
		var/path = "icons/splashworks/"
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) == "/")
				filenames -= filename
		icon = file("[path][pick(filenames)]")

/turf/unsimulated/wall/other
	icon_state = "r_wall"
	canSmoothWith = null

/turf/unsimulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon_state = "cult0"
	opacity = 1
	density = 1
	canSmoothWith = null

/turf/unsimulated/wall/cultify()
	ChangeTurf(/turf/unsimulated/wall/cult)
	turf_animation('icons/effects/effects.dmi',"cultwall",0,0,MOB_LAYER-1)
	return

/turf/unsimulated/wall/cult/cultify()
	return