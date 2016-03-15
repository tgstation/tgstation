/* Glass stack types
 * Contains:
 *		Glass sheets
 *		Reinforced glass sheets
 *		Plasma Glass Sheets
 *		Reinforced Plasma Glass Sheets (AKA Holy fuck strong windows)
 */

/obj/item/stack/sheet/glass
	w_type = RECYK_GLASS
	melt_temperature = MELTPOINT_GLASS
	var/created_window = /obj/structure/window
	var/full_window = /obj/structure/window/full
	var/windoor = null
	var/reinforced = 0
	var/rglass = 0
	//For solars created from this glass type
	var/glass_quality = 0.5 //Quality of a solar made from this
	var/shealth = 5 //Health of a solar made from this
	var/sname = "glass"
	var/shard_type = /obj/item/weapon/shard

	siemens_coefficient = 0 //does not conduct

/obj/item/stack/sheet/glass/attack_self(mob/user as mob)
	construct_window(user)

/obj/item/stack/sheet/glass/attackby(obj/item/W, mob/user)
	if(issolder(W))
		src.use(1)
		new /obj/item/weapon/circuitboard/blank(user.loc)
		to_chat(user, "<span class='notice'>You fashion a blank circuitboard out of the glass.</span>")
		playsound(src.loc, 'sound/items/Welder.ogg', 35, 1)
	if(istype(W, /obj/item/stack/rods) && !reinforced)
		var/obj/item/stack/rods/V  = W
		var/obj/item/stack/sheet/glass/RG = new rglass()
		RG.forceMove(user.loc) //This is because new() doesn't call forceMove, so we're forcemoving the new sheet to make it stack with other sheets on the ground.
		RG.add_fingerprint(user)
		V.use(1)
		var/obj/item/stack/sheet/glass/G = src
		src = null
		var/replace = (user.get_inactive_hand()==G)
		G.use(1)
		if (!G && !RG && replace)
			if(isMoMMI(user))
				RG.loc=get_turf(user)
			else
				user.put_in_hands(RG)
	else
		return ..()

/obj/item/stack/sheet/glass/proc/construct_window(mob/user as mob)
	if(!user || !src)	return 0
	if(!istype(user.loc,/turf)) return 0
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 0
	var/title = "[src.name] Sheets"
	title += " ([src.amount] sheet\s left)"
	if(windoor) //TODO: Find way to merge this if-else clause and lower duplication
		switch(input(title, "Would you like full tile glass a one direction glass pane or a windoor?") in list("One Direction", "Full Window", "Windoor", "Cancel"))
			if("One Direction")
				if(!src)	return 1
				if(src.loc != user)	return 1
				var/list/directions = new/list(cardinal)
				var/i = 0
				for (var/obj/structure/window/win in user.loc)
					i++
					if(i >= 4)
						to_chat(user, "<span class='warning'>There are too many windows in this location.</span>")
						return 1
					directions-=win.dir
					if(win.is_fulltile())
						to_chat(user, "<span class='warning'>Can't let you do that.</span>")
						return 1
				//Determine the direction. It will first check in the direction the person making the window is facing, if it finds an already made window it will try looking at the next cardinal direction, etc.
				var/dir_to_set = 2
				for(var/direction in list( user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270) ))
					var/found = 0
					for(var/obj/structure/window/WT in user.loc)
						if(WT.dir == direction)
							found = 1
					if(!found)
						dir_to_set = direction
						break
				var/obj/structure/window/W = new created_window(user.loc, 0)
				W.d_state = 0
				W.dir = dir_to_set
				W.ini_dir = W.dir
				W.anchored = 0
				src.use(1)
			if("Full Window")
				if(!src)	return 1
				if(src.loc != user)	return 1
				if(src.amount < 2)
					to_chat(user, "<span class='warning'>You need more glass to do that.</span>")
					return 1
				if(locate(/obj/structure/window/full) in user.loc)
					to_chat(user, "<span class='warning'>There is a window in the way.</span>")
					return 1
				var/obj/structure/window/W = new full_window( user.loc, 0 )
				W.d_state = 0
				W.dir = SOUTHWEST
				W.ini_dir = SOUTHWEST
				W.anchored = 0
				src.use(2)
			if("Windoor")
				if(!src || src.loc != user)
					return 1
				if(isturf(user.loc) && locate(/obj/structure/windoor_assembly/, user.loc))
					to_chat(user, "<span class='warning'>There is already a windoor assembly in that location.</span>")
					return 1
				if(isturf(user.loc) && locate(/obj/machinery/door/window/, user.loc))
					to_chat(user, "<span class='warning'>There is already a windoor in that location.</span>")
					return 1
				if(src.amount < 5)
					to_chat(user, "<span class='warning'>You need more glass to do that.</span>")
					return 1
				var/obj/structure/windoor_assembly/WD = new windoor(user.loc, 0 )
				WD.state = "01"
				WD.anchored = 0
				WD.dir = user.dir
				WD.ini_dir = WD.dir
				src.use(5)
				switch(user.dir)
					if(SOUTH)
						WD.dir = SOUTH
						WD.ini_dir = SOUTH
					if(EAST)
						WD.dir = EAST
						WD.ini_dir = EAST
					if(WEST)
						WD.dir = WEST
						WD.ini_dir = WEST
					else//If the user is facing northeast. northwest, southeast, southwest or north, default to north
						WD.dir = NORTH
						WD.ini_dir = NORTH
			else
				return 1
	else
		switch(alert(title, "Would you like full tile glass or one direction?", "One Direction", "Full Window", "Cancel", null))
			if("One Direction")
				if(!src)	return 1
				if(src.loc != user)	return 1
				var/list/directions = new/list(cardinal)
				var/i = 0
				for (var/obj/structure/window/win in user.loc)
					i++
					if(i >= 4)
						to_chat(user, "<span class='warning'>There are too many windows in this location.</span>")
						return 1
					directions-=win.dir
					if(win.is_fulltile())
						to_chat(user, "<span class='warning'>Can't let you do that.</span>")
						return 1
				//Determine the direction. It will first check in the direction the person making the window is facing, if it finds an already made window it will try looking at the next cardinal direction, etc.
				var/dir_to_set = 2
				for(var/direction in list( user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270) ))
					var/found = 0
					for(var/obj/structure/window/WT in user.loc)
						if(WT.dir == direction)
							found = 1
					if(!found)
						dir_to_set = direction
						break
				var/obj/structure/window/W = new created_window( user.loc, 0 )
				W.d_state = 0
				W.dir = dir_to_set
				W.ini_dir = W.dir
				W.anchored = 0
				src.use(1)
			if("Full Window")
				if(!src)	return 1
				if(src.loc != user)	return 1
				if(src.amount < 2)
					to_chat(user, "<span class='warning'>You need more glass to do that.</span>")
					return 1
				if(locate(/obj/structure/window/full) in user.loc)
					to_chat(user, "<span class='warning'>There is a window in the way.</span>")
					return 1
				var/obj/structure/window/W = new full_window( user.loc, 0 )
				W.d_state = 0
				W.dir = SOUTHWEST
				W.ini_dir = SOUTHWEST
				W.anchored = 0
				src.use(2)
	return 0


/*
 * Glass sheets
 */

/obj/item/stack/sheet/glass/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	starting_materials = list(MAT_GLASS = 3750)
	origin_tech = "materials=1"
	rglass = /obj/item/stack/sheet/glass/rglass

/obj/item/stack/sheet/glass/glass/cyborg
	starting_materials = null

/obj/item/stack/sheet/glass/glass/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(CC.amount < 2) //Cost changed from 5 to 2, so that you get 15 tiles from a cable coil instead of only 6 (!)
			to_chat(user, "<B>There is not enough wire in this coil. You need at least two lengths.</B>")
			return
		CC.use(2)
		src.use(1)

		to_chat(user, "<span class='notice'>You attach some wires to the [name].</span>")//the dreaded dubblespan

		drop_stack(/obj/item/stack/light_w, get_turf(user), 1, user)
	else
		return ..()


/*
 * Reinforced glass sheets
 */

/obj/item/stack/sheet/glass/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	sname = "glass_ref"
	icon_state = "sheet-rglass"
	starting_materials = list(MAT_IRON = 1875, MAT_GLASS = 3750)
	created_window = /obj/structure/window/reinforced
	full_window = /obj/structure/window/full/reinforced
	windoor = /obj/structure/windoor_assembly/
	origin_tech = "materials=2"
	reinforced = 1
	glass_quality = 1
	shealth = 10

/obj/item/stack/sheet/glass/rglass/cyborg
	starting_materials = null

/*
 * Plasma Glass sheets
 */

/obj/item/stack/sheet/glass/plasmaglass
	name = "plasma glass"
	desc = "A very strong and very resistant sheet of a plasma-glass alloy."
	singular_name = "glass sheet"
	icon_state = "sheet-plasmaglass"
	sname = "plasma"
	starting_materials = list(MAT_GLASS = CC_PER_SHEET_GLASS, MAT_PLASMA = CC_PER_SHEET_MISC)
	origin_tech = "materials=3;plasmatech=2"
	created_window = /obj/structure/window/plasma
	full_window = /obj/structure/window/full/plasma
	rglass = /obj/item/stack/sheet/glass/plasmarglass
	perunit = 2875 //average of plasma and glass
	melt_temperature = MELTPOINT_STEEL + 500
	glass_quality = 1.15 //Can you imagine a world in which plasmaglass is worse than rglass
	shealth = 20
	shard_type = /obj/item/weapon/shard/plasma

/*
 * Reinforced plasma glass sheets
 */
/obj/item/stack/sheet/glass/plasmarglass
	name = "reinforced plasma glass"
	desc = "Plasma glass which seems to have rods or something stuck in them."
	singular_name = "reinforced plasma glass sheet"
	icon_state = "sheet-plasmarglass"
	sname = "plasma_ref"
	starting_materials = list(MAT_IRON = 1875, MAT_GLASS = CC_PER_SHEET_GLASS, MAT_PLASMA = CC_PER_SHEET_MISC)
	melt_temperature = MELTPOINT_STEEL+500 // I guess...?
	origin_tech = "materials=4;plasmatech=2"
	created_window = /obj/structure/window/reinforced/plasma
	full_window = /obj/structure/window/full/reinforced/plasma
	windoor = /obj/structure/windoor_assembly/plasma
	perunit = 2875
	reinforced = 1
	glass_quality = 1.3
	shealth = 30
	shard_type = /obj/item/weapon/shard/plasma
