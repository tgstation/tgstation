/obj/structure/window
	name = "window"
	desc = "A window."
	icon_state = "window"
	density = 1
	layer = ABOVE_OBJ_LAYER //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1 //initially is 0 for tile smoothing
	flags = ON_BORDER
	max_integrity = 25
	obj_integrity = 25
	var/ini_dir = null
	var/state = 0
	var/reinf = 0
	var/wtype = "glass"
	var/fulltile = 0
	var/glass_type = /obj/item/stack/sheet/glass
	var/glass_amount = 1
	var/image/crack_overlay
	var/list/debris = list()
	can_be_unanchored = 1
	resistance_flags = ACID_PROOF
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 80, acid = 100)
	CanAtmosPass = ATMOS_PASS_PROC

/obj/structure/window/examine(mob/user)
	..()
	user << "<span class='notice'>Alt-click to rotate it clockwise.</span>"

/obj/structure/window/New(Loc,re=0)
	..()
	obj_integrity = max_integrity
	if(re)
		reinf = re
	if(reinf)
		state = 2*anchored

	ini_dir = dir
	air_update_turf(1)

	// Precreate our own debris

	var/shards = 1
	if(fulltile)
		shards++
		setDir()
	var/rods = 0
	if(reinf)
		rods++
		if(fulltile)
			rods++

	for(var/i in 1 to shards)
		debris += new /obj/item/weapon/shard(src)
	if(rods)
		debris += new /obj/item/stack/rods(src, rods)


/obj/structure/window/narsie_act()
	add_atom_colour(NARSIE_WINDOW_COLOUR, FIXED_COLOUR_PRIORITY)
	for(var/obj/item/weapon/shard/shard in debris)
		shard.add_atom_colour(NARSIE_WINDOW_COLOUR, FIXED_COLOUR_PRIORITY)

/obj/structure/window/ratvar_act()
	if(!fulltile)
		new/obj/structure/window/reinforced/clockwork(get_turf(src), dir)
	else
		new/obj/structure/window/reinforced/clockwork/fulltile(get_turf(src))
	qdel(src)

/obj/structure/window/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/window/setDir(direct)
	if(!fulltile)
		..()
	else
		..(FULLTILE_WINDOW_DIR)

/obj/structure/window/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(dir == FULLTILE_WINDOW_DIR)
		return 0	//full tile window, you can't move into it!
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1


/obj/structure/window/CheckExit(atom/movable/O as mob|obj, target)
	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1

/obj/structure/window/attack_tk(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	add_fingerprint(user)
	playsound(loc, 'sound/effects/Glassknock.ogg', 50, 1)

/obj/structure/window/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(!can_be_reached(user))
		return 1
	. = ..()

/obj/structure/window/attack_hand(mob/user)
	if(!can_be_reached(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("[user] knocks on [src].")
	add_fingerprint(user)
	playsound(loc, 'sound/effects/Glassknock.ogg', 50, 1)

/obj/structure/window/attack_paw(mob/user)
	return attack_hand(user)


/obj/structure/window/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)	//used by attack_alien, attack_animal, and attack_slime
	if(!can_be_reached(user))
		return
	..()

/obj/structure/window/attackby(obj/item/I, mob/living/user, params)
	if(!can_be_reached(user))
		return 1 //skip the afterattack

	add_fingerprint(user)
	if(istype(I, /obj/item/weapon/weldingtool) && user.a_intent == INTENT_HELP)
		var/obj/item/weapon/weldingtool/WT = I
		if(obj_integrity < max_integrity)
			if(WT.remove_fuel(0,user))
				user << "<span class='notice'>You begin repairing [src]...</span>"
				playsound(loc, WT.usesound, 40, 1)
				if(do_after(user, 40*I.toolspeed, target = src))
					obj_integrity = max_integrity
					playsound(loc, 'sound/items/Welder2.ogg', 50, 1)
					update_nearby_icons()
					user << "<span class='notice'>You repair [src].</span>"
		else
			user << "<span class='warning'>[src] is already in good condition!</span>"
		return


	if(!(flags&NODECONSTRUCT))
		if(istype(I, /obj/item/weapon/screwdriver))
			playsound(loc, I.usesound, 75, 1)
			if(reinf && (state == 2 || state == 1))
				user << (state == 2 ? "<span class='notice'>You begin to unscrew the window from the frame...</span>" : "<span class='notice'>You begin to screw the window to the frame...</span>")
			else if(reinf && state == 0)
				user << (anchored ? "<span class='notice'>You begin to unscrew the frame from the floor...</span>" : "<span class='notice'>You begin to screw the frame to the floor...</span>")
			else if(!reinf)
				user << (anchored ? "<span class='notice'>You begin to unscrew the window from the floor...</span>" : "<span class='notice'>You begin to screw the window to the floor...</span>")

			if(do_after(user, 30*I.toolspeed, target = src))
				if(reinf && (state == 1 || state == 2))
					//If state was unfastened, fasten it, else do the reverse
					state = (state == 1 ? 2 : 1)
					user << (state == 1 ? "<span class='notice'>You unfasten the window from the frame.</span>" : "<span class='notice'>You fasten the window to the frame.</span>")
				else if(reinf && state == 0)
					anchored = !anchored
					update_nearby_icons()
					user << (anchored ? "<span class='notice'>You fasten the frame to the floor.</span>" : "<span class='notice'>You unfasten the frame from the floor.</span>")
				else if(!reinf)
					anchored = !anchored
					update_nearby_icons()
					user << (anchored ? "<span class='notice'>You fasten the window to the floor.</span>" : "<span class='notice'>You unfasten the window.</span>")
			return

		else if (istype(I, /obj/item/weapon/crowbar) && reinf && (state == 0 || state == 1))
			user << (state == 0 ? "<span class='notice'>You begin to lever the window into the frame...</span>" : "<span class='notice'>You begin to lever the window out of the frame...</span>")
			playsound(loc, I.usesound, 75, 1)
			if(do_after(user, 40*I.toolspeed, target = src))
				//If state was out of frame, put into frame, else do the reverse
				state = (state == 0 ? 1 : 0)
				user << (state == 1 ? "<span class='notice'>You pry the window into the frame.</span>" : "<span class='notice'>You pry the window out of the frame.</span>")
			return

		else if(istype(I, /obj/item/weapon/wrench) && !anchored)
			playsound(loc, I.usesound, 75, 1)
			user << "<span class='notice'> You begin to disassemble [src]...</span>"
			if(do_after(user, 40*I.toolspeed, target = src))
				if(qdeleted(src))
					return

				var/obj/item/stack/sheet/G = new glass_type(user.loc, glass_amount)
				G.add_fingerprint(user)

				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				user << "<span class='notice'>You successfully disassemble [src].</span>"
				qdel(src)
			return
	return ..()

/obj/structure/window/mech_melee_attack(obj/mecha/M)
	if(!can_be_reached())
		return
	..()


/obj/structure/window/proc/can_be_reached(mob/user)
	if(!fulltile)
		if(get_dir(user,src) & dir)
			for(var/obj/O in loc)
				if(!O.CanPass(user, user.loc, 1))
					return 0
	return 1

/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(.) //received damage
		update_nearby_icons()

/obj/structure/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)


/obj/structure/window/deconstruct(disassembled = TRUE)
	if(qdeleted(src))
		return
	if(!disassembled)
		playsound(src, "shatter", 70, 1)
		var/turf/T = loc

		if(!(flags & NODECONSTRUCT))
			for(var/i in debris)
				var/obj/item/I = i

				I.loc = T
				transfer_fingerprints_to(I)
	qdel(src)
	update_nearby_icons()

/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(anchored)
		usr << "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>"
		return 0

	setDir(turn(dir, 90))
	air_update_turf(1)
	ini_dir = dir
	add_fingerprint(usr)
	return


/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(anchored)
		usr << "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>"
		return 0

	setDir(turn(dir, 270))
	air_update_turf(1)
	ini_dir = dir
	add_fingerprint(usr)
	return

/obj/structure/window/AltClick(mob/user)
	..()
	if(user.incapacitated())
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(!in_range(src, user))
		return
	else
		revrotate()

/obj/structure/window/Destroy()
	density = 0
	air_update_turf(1)
	update_nearby_icons()
	return ..()


/obj/structure/window/Move()
	var/turf/T = loc
	..()
	setDir(ini_dir)
	move_update_air(T)

/obj/structure/window/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	if(dir == FULLTILE_WINDOW_DIR)
		return !density
	return 1

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_icon()
	if(smooth)
		queue_smooth_neighbors(src)

//merges adjacent full-tile windows into one
/obj/structure/window/update_icon()
	if(!qdeleted(src))
		if(!fulltile)
			return

		var/ratio = obj_integrity / max_integrity
		ratio = Ceiling(ratio*4) * 25

		if(smooth)
			queue_smooth(src)

		overlays -= crack_overlay
		if(ratio > 75)
			return
		crack_overlay = image('icons/obj/structures.dmi',"damage[ratio]",-(layer+0.1))
		add_overlay(crack_overlay)

/obj/structure/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + (reinf ? 1600 : 800))
		take_damage(round(exposed_volume / 100), BURN, 0, 0)
	..()

/obj/structure/window/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	return 0

/obj/structure/window/CanAStarPass(ID, to_dir)
	if(!density)
		return 1
	if((dir == FULLTILE_WINDOW_DIR) || (dir == to_dir))
		return 0

	return 1

/obj/structure/window/reinforced
	name = "reinforced window"
	icon_state = "rwindow"
	reinf = 1
	armor = list(melee = 50, bullet = 0, laser = 0, energy = 0, bomb = 25, bio = 100, rad = 100, fire = 80, acid = 100)
	max_integrity = 50
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/rglass

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	icon_state = "twindow"
	opacity = 1

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	icon_state = "fwindow"


/* Full Tile Windows (more obj_integrity) */

/obj/structure/window/fulltile
	icon = 'icons/obj/smooth_structures/window.dmi'
	icon_state = "window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 50
	fulltile = 1
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile)
	glass_amount = 2

/obj/structure/window/reinforced/fulltile
	icon = 'icons/obj/smooth_structures/reinforced_window.dmi'
	icon_state = "r_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 100
	fulltile = 1
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile)
	level = 3
	glass_amount = 2

/obj/structure/window/reinforced/tinted/fulltile
	icon = 'icons/obj/smooth_structures/tinted_window.dmi'
	icon_state = "tinted_window"
	dir = FULLTILE_WINDOW_DIR
	fulltile = 1
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile/)
	level = 3
	glass_amount = 2

/obj/structure/window/reinforced/fulltile/ice
	icon = 'icons/obj/smooth_structures/rice_window.dmi'
	icon_state = "ice_window"
	max_integrity = 150
	canSmoothWith = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/reinforced/fulltile/ice)
	level = 3
	glass_amount = 2

/obj/structure/window/shuttle
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "shuttle_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 100
	wtype = "shuttle"
	fulltile = 1
	reinf = 1
	armor = list(melee = 50, bullet = 0, laser = 0, energy = 0, bomb = 25, bio = 100, rad = 100, fire = 80, acid = 100)
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	explosion_block = 1
	level = 3
	glass_type = /obj/item/stack/sheet/rglass
	glass_amount = 2

/obj/structure/window/shuttle/narsie_act()
	add_atom_colour("#3C3434", FIXED_COLOUR_PRIORITY)

/obj/structure/window/shuttle/tinted
	opacity = TRUE

/obj/structure/window/reinforced/clockwork
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass."
	icon = 'icons/obj/smooth_structures/clockwork_window.dmi'
	icon_state = "clockwork_window_single"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 100
	armor = list(melee = 60, bullet = 25, laser = 0, energy = 0, bomb = 25, bio = 100, rad = 100, fire = 80, acid = 100)
	explosion_block = 2 //fancy AND hard to destroy. the most useful combination.
	glass_type = /obj/item/stack/tile/brass
	glass_amount = 1
	var/made_glow = FALSE

/obj/structure/window/reinforced/clockwork/New(loc, direct)
	..()
	for(var/obj/item/I in debris)
		debris -= I
		qdel(I)
	var/amount_of_gears = 2
	if(!fulltile)
		if(direct)
			var/obj/effect/E = PoolOrNew(/obj/effect/overlay/temp/ratvar/window/single, get_turf(src))
			setDir(direct)
			E.setDir(direct)
			made_glow = TRUE
	else
		PoolOrNew(/obj/effect/overlay/temp/ratvar/window, get_turf(src))
		made_glow = TRUE
		amount_of_gears = 4
	for(var/i in 1 to amount_of_gears)
		debris += new/obj/item/clockwork/alloy_shards/medium/gear_bit()
	change_construction_value(fulltile ? 2 : 1)

/obj/structure/window/reinforced/clockwork/setDir(direct)
	if(!made_glow)
		var/obj/effect/E = PoolOrNew(/obj/effect/overlay/temp/ratvar/window/single, get_turf(src))
		E.setDir(direct)
		made_glow = TRUE
	..()

/obj/structure/window/reinforced/clockwork/Destroy()
	change_construction_value(fulltile ? -2 : -1)
	return ..()

/obj/structure/window/reinforced/clockwork/ratvar_act()
	obj_integrity = max_integrity
	update_icon()

/obj/structure/window/reinforced/clockwork/narsie_act()
	take_damage(rand(25, 75), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/obj/structure/window/reinforced/clockwork/fulltile
	icon_state = "clockwork_window"
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	fulltile = 1
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 150
	level = 3
	glass_amount = 2
	made_glow = TRUE
