#define WINDOWLOOSE 0
#define WINDOWLOOSEFRAME 1
#define WINDOWUNSECUREFRAME 2
#define WINDOWSECURE 3

/obj/structure/window/full

	name = "window"
	icon_state = "window"
	sheetamount = 2
	mouse_opacity = 2 // Complete opacity //What in the name of everything is this variable ?
	layer = 3.21 // Windows are at 3.2.

	cracked_base = "fcrack"

/obj/structure/window/full/New(loc)

	..(loc)
	flags &= ~ON_BORDER

/obj/structure/window/full/CheckExit(atom/movable/O as mob|obj, target as turf)

	return 1

/obj/structure/window/full/CanPass(atom/movable/mover, turf/target, height = 1.5, air_group = 0)

	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	return 0

/obj/structure/window/full/can_be_reached(mob/user)

	return 1 //That about it Captain

/obj/structure/window/full/is_fulltile()

	return 1

//Merges adjacent full-tile windows into one (blatant ripoff from game/smoothwall.dm)
/obj/structure/window/full/update_icon()

	//A little cludge here, since I don't know how it will work with slim windows. Most likely VERY wrong.
	//This way it will only update full-tile ones
	//This spawn is here so windows get properly updated when one gets deleted.
	spawn()
		if(!src)
			return
		var/junction = 0 //Will be used to determine from which side the window is connected to other windows
		if(anchored)
			for(var/obj/structure/window/full/W in orange(src, 1))
				if(W.anchored && W.density) //Only counts anchored, not-destroyed full-tile windows.
					if(abs(x-W.x)-abs(y-W.y)) 	//Doesn't count windows, placed diagonally to src
						junction |= get_dir(src,W)
		icon_state = "[initial(icon_state)][junction]"
		return

/obj/structure/window/full/reinforced
	name = "reinforced window"
	desc = "A window with a rod matrice. It looks more solid than the average window."
	icon_state = "rwindow"
	sheettype = /obj/item/stack/sheet/glass/rglass
	health = 40
	d_state = WINDOWSECURE
	reinforced = 1

/obj/structure/window/full/plasma

	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	shardtype = /obj/item/weapon/shard/plasma
	sheettype = /obj/item/stack/sheet/glass/plasmaglass
	health = 120

	fire_temp_threshold = 32000
	fire_volume_mod = 1000

/obj/structure/window/full/reinforced/plasma
	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and a rod matrice. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon_state = "plasmarwindow"
	shardtype = /obj/item/weapon/shard/plasma
	sheettype = /obj/item/stack/sheet/glass/plasmarglass
	health = 160

/obj/structure/window/full/reinforced/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/full/reinforced/tinted

	name = "tinted window"
	desc = "A window with a rod matrice. Its surface is completely tinted, making it opaque. Why not a wall ?"
	icon_state = "twindow"
	opacity = 1
	sheettype = /obj/item/stack/sheet/glass/rglass //A glass type for this window doesn't seem to exist, so here's to you

/obj/structure/window/full/reinforced/tinted/frosted

	name = "frosted window"
	desc = "A window with a rod matrice. Its surface is completely tinted, making it opaque, and it's frosty. Why not an ice wall ?"
	icon_state = "fwindow"
	health = 30
	sheettype = /obj/item/stack/sheet/glass/rglass //Ditto above

#undef WINDOWLOOSE
#undef WINDOWLOOSEFRAME
#undef WINDOWUNSECUREFRAME
#undef WINDOWSECURE
