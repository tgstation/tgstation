<<<<<<< HEAD
/* Glass stack types
 * Contains:
 *		Glass sheets
 *		Reinforced glass sheets
 *		Glass shards - TODO: Move this into code/game/object/item/weapons
 */

/*
 * Glass sheets
 */
/obj/item/stack/sheet/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	origin_tech = "materials=1"

/obj/item/stack/sheet/glass/cyborg
	materials = list()
	is_cyborg = 1
	cost = 500

/obj/item/stack/sheet/glass/fifty
	amount = 50

/obj/item/stack/sheet/glass/attack_self(mob/user)
	construct_window(user)

/obj/item/stack/sheet/glass/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if (get_amount() < 1 || CC.get_amount() < 5)
			user << "<span class='warning>You need five lengths of coil and one sheet of glass to make wired glass!</span>"
			return
		CC.use(5)
		use(1)
		user << "<span class='notice'>You attach wire to the [name].</span>"
		var/obj/item/stack/light_w/new_tile = new(user.loc)
		new_tile.add_fingerprint(user)
	else if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/V = W
		if (V.get_amount() >= 1 && src.get_amount() >= 1)
			var/obj/item/stack/sheet/rglass/RG = new (user.loc)
			RG.add_fingerprint(user)
			var/obj/item/stack/sheet/glass/G = src
			src = null
			var/replace = (user.get_inactive_hand()==G)
			V.use(1)
			G.use(1)
			if (!G && replace)
				user.put_in_hands(RG)
		else
			user << "<span class='warning'>You need one rod and one sheet of glass to make reinforced glass!</span>"
			return
	else
		return ..()

/obj/item/stack/sheet/glass/proc/construct_window(mob/user)
	if(!user || !src)
		return 0
	if(!istype(user.loc,/turf))
		return 0
	if(!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return 0
	if(zero_amount())
		return 0
	var/title = "Sheet-Glass"
	title += " ([src.get_amount()] sheet\s left)"
	switch(alert(title, "Would you like full tile glass or one direction?", "One Direction", "Full Window", "Cancel", null))
		if("One Direction")
			if(!src)
				return 1
			if(src.loc != user)
				return 1

			var/list/directions = new/list(cardinal)
			var/i = 0
			for (var/obj/structure/window/win in user.loc)
				i++
				if(i >= 4)
					user << "<span class='warning'>There are too many windows in this location.</span>"
					return 1
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					user << "<span class='danger'>Can't let you do that.</span>"
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
			W = new /obj/structure/window( user.loc, 0 )
			W.setDir(dir_to_set)
			W.ini_dir = W.dir
			W.anchored = 0
			W.air_update_turf(1)
			src.use(1)
			W.add_fingerprint(user)
		if("Full Window")
			if(!src)
				return 1
			if(src.loc != user)
				return 1
			if(src.get_amount() < 2)
				user << "<span class='warning'>You need more glass to do that!</span>"
				return 1
			if(locate(/obj/structure/window) in user.loc)
				user << "<span class='warning'>There is a window in the way!</span>"
				return 1
			var/obj/structure/window/W
			W = new /obj/structure/window/fulltile( user.loc, 0 )
			W.anchored = 0
			W.air_update_turf(1)
			W.add_fingerprint(user)
			src.use(2)
	return 0


/*
 * Reinforced glass sheets
 */
/obj/item/stack/sheet/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT/2, MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	origin_tech = "materials=2"

/obj/item/stack/sheet/rglass/cyborg
	materials = list()
	var/datum/robot_energy_storage/metsource
	var/datum/robot_energy_storage/glasource
	var/metcost = 250
	var/glacost = 500

/obj/item/stack/sheet/rglass/cyborg/get_amount()
	return min(round(metsource.energy / metcost), round(glasource.energy / glacost))

/obj/item/stack/sheet/rglass/cyborg/use(amount) // Requires special checks, because it uses two storages
	metsource.use_charge(amount * metcost)
	glasource.use_charge(amount * glacost)
	return

/obj/item/stack/sheet/rglass/cyborg/add(amount)
	metsource.add_charge(amount * metcost)
	glasource.add_charge(amount * glacost)
	return

/obj/item/stack/sheet/rglass/attack_self(mob/user)
	construct_window(user)

/obj/item/stack/sheet/rglass/proc/construct_window(mob/user)
	if(!user || !src)
		return 0
	if(!istype(user.loc,/turf))
		return 0
	if(!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return 0
	var/title = "Sheet Reinf. Glass"
	title += " ([src.get_amount()] sheet\s left)"
	switch(input(title, "Would you like full tile glass a one direction glass pane or a windoor?") in list("One Direction", "Full Window", "Windoor", "Cancel"))
		if("One Direction")
			if(!src)
				return 1
			if(src.loc != user)
				return 1
			var/list/directions = new/list(cardinal)
			var/i = 0
			for (var/obj/structure/window/win in user.loc)
				i++
				if(i >= 4)
					user << "<span class='danger'>There are too many windows in this location.</span>"
					return 1
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					user << "<span class='danger'>Can't let you do that.</span>"
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
			W = new /obj/structure/window/reinforced( user.loc, 1 )
			W.state = 0
			W.setDir(dir_to_set)
			W.ini_dir = W.dir
			W.anchored = 0
			W.add_fingerprint(user)
			src.use(1)

		if("Full Window")
			if(!src)
				return 1
			if(src.loc != user)
				return 1
			if(src.get_amount() < 2)
				user << "<span class='warning'>You need more glass to do that!</span>"
				return 1
			if(locate(/obj/structure/window) in user.loc)
				user << "<span class='warning'>There is a window in the way!</span>"
				return 1
			var/obj/structure/window/W
			W = new /obj/structure/window/reinforced/fulltile(user.loc, 1)
			W.state = 0
			W.anchored = 0
			W.add_fingerprint(user)
			src.use(2)

		if("Windoor")
			if(!src || src.loc != user || !isturf(user.loc))
				return 1

			for(var/obj/structure/windoor_assembly/WA in user.loc)
				if(WA.dir == user.dir)
					user << "<span class='warning'>There is already a windoor assembly in that location!</span>"
					return 1

			for(var/obj/machinery/door/window/W in user.loc)
				if(W.dir == user.dir)
					user << "<span class='warning'>There is already a windoor in that location!</span>"
					return 1

			if(src.get_amount() < 5)
				user << "<span class='warning'>You need more glass to do that!</span>"
				return 1

			var/obj/structure/windoor_assembly/WD = new(user.loc)
			WD.state = "01"
			WD.anchored = 0
			WD.add_fingerprint(user)
			src.use(5)
			switch(user.dir)
				if(SOUTH)
					WD.setDir(SOUTH)
					WD.ini_dir = SOUTH
				if(EAST)
					WD.setDir(EAST)
					WD.ini_dir = EAST
				if(WEST)
					WD.setDir(WEST)
					WD.ini_dir = WEST
				else //If the user is facing northeast. northwest, southeast, southwest or north, default to north
					WD.setDir(NORTH)
					WD.ini_dir = NORTH
		else
			return 1


	return 0


/obj/item/weapon/shard
	name = "shard"
	desc = "A nasty looking shard of glass."
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	w_class = 1
	force = 5
	throwforce = 10
	item_state = "shard-glass"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/cooldown = 0
	sharpness = IS_SHARP

/obj/item/weapon/shard/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting \his wrists with the shard of glass! It looks like \he's trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting \his throat with the shard of glass! It looks like \he's trying to commit suicide.</span>"))
	return (BRUTELOSS)


/obj/item/weapon/shard/New()
	icon_state = pick("large", "medium", "small")
	switch(icon_state)
		if("small")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("medium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("large")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)

/obj/item/weapon/shard/afterattack(atom/A as mob|obj, mob/user, proximity)
	if(!proximity || !(src in user))
		return
	if(isturf(A))
		return
	if(istype(A, /obj/item/weapon/storage))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves && !(PIERCEIMMUNE in H.dna.species.specflags)) // golems, etc
			H << "<span class='warning'>[src] cuts into your hand!</span>"
			var/organ = (H.hand ? "l_" : "r_") + "arm"
			var/obj/item/bodypart/affecting = H.get_bodypart(organ)
			if(affecting && affecting.take_damage(force / 2))
				H.update_damage_overlays(0)
	else if(ismonkey(user))
		var/mob/living/carbon/monkey/M = user
		M << "<span class='warning'>[src] cuts into your hand!</span>"
		M.adjustBruteLoss(force / 2)


/obj/item/weapon/shard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			var/obj/item/stack/sheet/glass/NG = new (user.loc)
			for(var/obj/item/stack/sheet/glass/G in user.loc)
				if(G == NG)
					continue
				if(G.amount >= G.max_amount)
					continue
				G.attackby(NG, user)
			user << "<span class='notice'>You add the newly-formed glass to the stack. It now contains [NG.amount] sheet\s.</span>"
			qdel(src)
	else
		return ..()

/obj/item/weapon/shard/Crossed(mob/AM)
	if(istype(AM) && has_gravity(loc))
		playsound(loc, 'sound/effects/glass_step.ogg', 50, 1)
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(PIERCEIMMUNE in H.dna.species.specflags)
				return
			var/picked_def_zone = pick("l_leg", "r_leg")
			var/obj/item/bodypart/O = H.get_bodypart(picked_def_zone)
			if(!istype(O))
				return
			if(!H.shoes)
				H.apply_damage(5, BRUTE, picked_def_zone)
				H.Weaken(3)
				if(cooldown < world.time - 10) //cooldown to avoid message spam.
					H.visible_message("<span class='danger'>[H] steps in the broken glass!</span>", \
							"<span class='userdanger'>You step in the broken glass!</span>")
					cooldown = world.time
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
