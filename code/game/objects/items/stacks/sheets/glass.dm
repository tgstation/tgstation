/* Glass stack types
 * Contains:
 *		Glass sheets
 *		Reinforced glass sheets
 *		Plasma Glass Sheets
 *		Reinforced Plasma Glass Sheets (AKA Holy fuck strong windows)
 *		Glass shards - TODO: Move this into code/game/object/item/weapons
 */

/obj/item/stack/sheet/glass
	w_type = RECYK_GLASS
	melt_temperature = MELTPOINT_GLASS
	var/created_window = /obj/structure/window/basic
	var/full_window = /obj/structure/window/full/basic
	var/windoor = null
	var/reinforced = 0
	var/rglass = 0
	var/glass_quality = 0.5 //Quality of a solar made from this
	var/shealth = 5 //Health of a solar made from this
	var/sname = "glass"

/obj/item/stack/sheet/glass/attack_self(mob/user as mob)
	construct_window(user)

/obj/item/stack/sheet/glass/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/rods) && !reinforced)
		var/obj/item/stack/rods/V  = W
		var/obj/item/stack/sheet/glass/RG = new rglass(user.loc)
		RG.add_fingerprint(user)
		RG.add_to_stacks(user)
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
		user << "\red You don't have the dexterity to do this!"
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
						user << "\red There are too many windows in this location."
						return 1
					directions-=win.dir
					if(win.is_fulltile())
						user << "\red Can't let you do that."
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
				W.state = 0
				W.dir = dir_to_set
				W.ini_dir = W.dir
				W.anchored = 0
				src.use(1)
			if("Full Window")
				if(!src)	return 1
				if(src.loc != user)	return 1
				if(src.amount < 2)
					user << "\red You need more glass to do that."
					return 1
				if(locate(/obj/structure/window/full) in user.loc)
					user << "\red There is a window in the way."
					return 1
				var/obj/structure/window/W = new full_window( user.loc, 0 )
				W.state = 0
				W.dir = SOUTHWEST
				W.ini_dir = SOUTHWEST
				W.anchored = 0
				src.use(2)
			if("Windoor")
				if(!src || src.loc != user)
					return 1
				if(isturf(user.loc) && locate(/obj/structure/windoor_assembly/, user.loc))
					user << "\red There is already a windoor assembly in that location."
					return 1
				if(isturf(user.loc) && locate(/obj/machinery/door/window/, user.loc))
					user << "\red There is already a windoor in that location."
					return 1
				if(src.amount < 5)
					user << "\red You need more glass to do that."
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
						user << "\red There are too many windows in this location."
						return 1
					directions-=win.dir
					if(win.is_fulltile())
						user << "\red Can't let you do that."
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
				var/obj/structure/window/W
				W = new created_window( user.loc, 0 )
				W.dir = dir_to_set
				W.ini_dir = W.dir
				W.anchored = 0
				src.use(1)
			if("Full Window")
				if(!src)	return 1
				if(src.loc != user)	return 1
				if(src.amount < 2)
					user << "\red You need more glass to do that."
					return 1
				if(locate(/obj/structure/window/full) in user.loc)
					user << "\red There is a full window in the way."
					return 1
				var/obj/structure/window/W = new full_window( user.loc, 0 )
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
	g_amt = 3750
	origin_tech = "materials=1"
	rglass = /obj/item/stack/sheet/glass/rglass

/obj/item/stack/sheet/glass/glass/cyborg
	g_amt = 0

/obj/item/stack/sheet/glass/glass/recycle(var/datum/materials/rec)
	rec.addAmount("glass", 1*src.amount)
	return 1

/obj/item/stack/sheet/glass/glass/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/CC = W
		if(CC.amount < 5)
			user << "\b There is not enough wire in this coil. You need 5 lengths."
			return
		CC.use(5)
		user << "\blue You attach wire to the [name]."
		new /obj/item/stack/light_w(user.loc)
		src.use(1)
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
	g_amt = 3750
	m_amt = 1875
	created_window = /obj/structure/window/reinforced
	full_window = /obj/structure/window/full/reinforced
	windoor = /obj/structure/windoor_assembly/
	origin_tech = "materials=2"
	reinforced = 1
	glass_quality = 1
	shealth = 10

/obj/item/stack/sheet/glass/rglass/cyborg
	g_amt = 0
	m_amt = 0

/obj/item/stack/sheet/glass/rglass/recycle(var/datum/materials/rec)
	rec.addAmount("glass", 1*src.amount)
	rec.addAmount("iron",  0.5*src.amount)
	return 1

/*
 * Plasma Glass sheets
 */
/obj/item/stack/sheet/glass/plasmaglass
	name = "plasma glass"
	desc = "A very strong and very resistant sheet of a plasma-glass alloy."
	singular_name = "glass sheet"
	icon_state = "sheet-plasmaglass"
	sname = "plasma"
	g_amt=CC_PER_SHEET_GLASS
	origin_tech = "materials=3;plasmatech=2"
	created_window = /obj/structure/window/plasmabasic
	full_window = /obj/structure/window/full/plasmabasic
	rglass = /obj/item/stack/sheet/glass/plasmarglass
	perunit = 2875 //average of plasma and glass
	melt_temperature = MELTPOINT_STEEL+500
	glass_quality = 1.15 //Can you imagine a world in which plasmaglass is worse than rglass
	shealth = 20

/obj/item/stack/sheet/glass/plasmaglass/recycle(var/datum/materials/rec)
	rec.addAmount("plasma",1*src.amount)
	rec.addAmount("glass", 1*src.amount)
	return RECYK_GLASS

/*
 * Reinforced plasma glass sheets
 */
/obj/item/stack/sheet/glass/plasmarglass
	name = "reinforced plasma glass"
	desc = "Plasma glass which seems to have rods or something stuck in them."
	singular_name = "reinforced plasma glass sheet"
	icon_state = "sheet-plasmarglass"
	sname = "plasma_ref"
	g_amt=CC_PER_SHEET_GLASS
	m_amt = 1875
	melt_temperature = MELTPOINT_STEEL+500 // I guess...?
	origin_tech = "materials=4;plasmatech=2"
	created_window = /obj/structure/window/plasmareinforced
	full_window = /obj/structure/window/full/plasmareinforced
	perunit = 2875
	reinforced = 1
	glass_quality = 1.3
	shealth = 30

/obj/item/stack/sheet/glass/plasmarglass/recycle(var/datum/materials/rec)
	rec.addAmount("plasma",1*src.amount)
	rec.addAmount("glass", 1*src.amount)
	rec.addAmount("iron",  0.5*src.amount)
	return 1

/*
 * Glass shards - TODO: Move this into code/game/object/item/weapons
 */
/obj/item/weapon/shard/resetVariables()
	..("icon_state", "pixel_y", "pixel_x")

/obj/item/weapon/shard/Bump()

	spawn( 0 )
		if (prob(20))
			src.force = 15
		else
			src.force = 4
		..()
		return
	return

/obj/item/weapon/shard/New()

	src.icon_state = pick("large", "medium", "small")
	switch(src.icon_state)
		if("small")
			src.pixel_x = rand(-12, 12)
			src.pixel_y = rand(-12, 12)
		if("medium")
			src.pixel_x = rand(-8, 8)
			src.pixel_y = rand(-8, 8)
		if("large")
			src.pixel_x = rand(-5, 5)
			src.pixel_y = rand(-5, 5)
		else
	return

/obj/item/weapon/shard/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if ( istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			var/obj/item/stack/sheet/glass/glass/NG = new (user.loc)
			for (var/obj/item/stack/sheet/glass/glass/G in user.loc)
				if(G==NG)
					continue
				if(G.amount>=G.max_amount)
					continue
				G.attackby(NG, user)
				usr << "You add the newly-formed glass to the stack. It now contains [NG.amount] sheets."
			//SN src = null
			returnToPool(src)
			return
	return ..()

/obj/item/weapon/shard/Crossed(AM as mob|obj)
	if(ismob(AM))
		var/mob/M = AM
		M << "\red <B>You step in the broken glass!</B>"
		playsound(get_turf(src), 'sound/effects/glass_step.ogg', 50, 1)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if( !H.shoes && ( !H.wear_suit || !(H.wear_suit.body_parts_covered & FEET) ) )
				var/datum/organ/external/affecting = H.get_organ(pick("l_foot", "r_foot"))
				if(affecting.status & (ORGAN_ROBOT|ORGAN_PEG))
					return

				H.Weaken(3)
				if(affecting.take_damage(5, 0))
					H.QueueUpdateDamageIcon()
				H.updatehealth()
	..()


