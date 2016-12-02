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
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 100)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/glass

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
			var/replace = (user.get_inactive_held_item()==G)
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
	if(!isturf(user.loc))
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
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 70, acid = 100)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/rglass

/obj/item/stack/sheet/rglass/cyborg
	materials = list()
	var/datum/robot_energy_storage/glasource
	var/metcost = 250
	var/glacost = 500

/obj/item/stack/sheet/rglass/cyborg/get_amount()
	return min(round(source.energy / metcost), round(glasource.energy / glacost))

/obj/item/stack/sheet/rglass/cyborg/use(amount) // Requires special checks, because it uses two storages
	source.use_charge(amount * metcost)
	glasource.use_charge(amount * glacost)

/obj/item/stack/sheet/rglass/cyborg/add(amount)
	source.add_charge(amount * metcost)
	glasource.add_charge(amount * glacost)

/obj/item/stack/sheet/rglass/attack_self(mob/user)
	construct_window(user)

/obj/item/stack/sheet/rglass/proc/construct_window(mob/user)
	if(!user || !src)
		return 0
	if(!isturf(user.loc))
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
	w_class = WEIGHT_CLASS_TINY
	force = 5
	throwforce = 10
	item_state = "shard-glass"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	resistance_flags = ACID_PROOF
	armor = list(melee = 100, bullet = 0, laser = 0, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 100)
	obj_integrity = 40
	max_integrity = 40
	var/cooldown = 0
	sharpness = IS_SHARP

/obj/item/weapon/shard/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is slitting [user.p_their()] [pick("wrists", "throat")] with the shard of glass! It looks like [user.p_theyre()] trying to commit suicide.</span>")
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
	var/hit_hand = ((user.active_hand_index % 2 == 0) ? "r_" : "l_") + "arm"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves && !(PIERCEIMMUNE in H.dna.species.species_traits)) // golems, etc
			H << "<span class='warning'>[src] cuts into your hand!</span>"
			H.apply_damage(force*0.5, BRUTE, hit_hand)
	else if(ismonkey(user))
		var/mob/living/carbon/monkey/M = user
		M << "<span class='warning'>[src] cuts into your hand!</span>"
		M.apply_damage(force*0.5, BRUTE, hit_hand)


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
			if(PIERCEIMMUNE in H.dna.species.species_traits)
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
