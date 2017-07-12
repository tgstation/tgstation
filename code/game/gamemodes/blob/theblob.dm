//I will need to recode parts of this but I am way too tired atm //I don't know who left this comment but they never did come back
/obj/structure/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	light_range = 2
	desc = "A thick wall of writhing tendrils."
	density = FALSE //this being false causes two bugs, being able to attack blob tiles behind other blobs and being unable to move on blob tiles in no gravity, but turning it to 1 causes the blob mobs to be unable to path through blobs, which is probably worse.
	opacity = 0
	anchored = TRUE
	layer = BELOW_MOB_LAYER
	var/point_return = 0 //How many points the blob gets back when it removes a blob of that type. If less than 0, blob cannot be removed.
	max_integrity = 30
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 80, acid = 70)
	var/health_regen = 2 //how much health this blob regens when pulsed
	var/pulse_timestamp = 0 //we got pulsed when?
	var/heal_timestamp = 0 //we got healed when?
	var/brute_resist = 0.5 //multiplies brute damage by this
	var/fire_resist = 1 //multiplies burn damage by this
	var/atmosblock = 0 //if the blob blocks atmos and heat spread
	var/mob/camera/blob/overmind

/obj/structure/blob/attack_hand(mob/M)
	. = ..()
	M.changeNext_move(CLICK_CD_MELEE)
	var/a = pick("gently stroke", "nuzzle", "affectionatly pet", "cuddle")
	M.visible_message("<span class='notice'>[M] [a]s [src]!</span>", "<span class='notice'>You [a] [src]!</span>")
	playsound(src, 'sound/effects/blobattack.ogg', 50, 1) //SQUISH SQUISH
	


/obj/structure/blob/Initialize()
	var/area/Ablob = get_area(loc)
	if(Ablob.blob_allowed) //Is this area allowed for winning as blob?
		GLOB.blobs_legit += src
	GLOB.blobs += src //Keep track of the blob in the normal list either way
	setDir(pick(GLOB.cardinals))
	update_icon()
	.= ..()
	ConsumeTile()
	if(atmosblock)
		CanAtmosPass = ATMOS_PASS_NO
		air_update_turf(1)

/obj/structure/blob/proc/creation_action() //When it's created by the overmind, do this.
	return

/obj/structure/blob/Destroy()
	if(atmosblock)
		atmosblock = 0
		air_update_turf(1)
	GLOB.blobs_legit -= src  //if it was in the legit blobs list, it isn't now
	GLOB.blobs -= src //it's no longer in the all blobs list either
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) //Expand() is no longer broken, no check necessary.
	return ..()

/obj/structure/blob/blob_act()
	return

/obj/structure/blob/Adjacent(var/atom/neighbour)
	. = ..()
	if(.)
		var/result = 0
		var/direction = get_dir(src, neighbour)
		var/list/dirs = list("[NORTHWEST]" = list(NORTH, WEST), "[NORTHEAST]" = list(NORTH, EAST), "[SOUTHEAST]" = list(SOUTH, EAST), "[SOUTHWEST]" = list(SOUTH, WEST))
		for(var/A in dirs)
			if(direction == text2num(A))
				for(var/B in dirs[A])
					var/C = locate(/obj/structure/blob) in get_step(src, B)
					if(C)
						result++
		. -= result - 1

/obj/structure/blob/BlockSuperconductivity()
	return atmosblock

/obj/structure/blob/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return 1
	if(istype(mover) && mover.checkpass(PASSBLOB))
		return 1
	return 0

/obj/structure/blob/CanAStarPass(ID, dir, caller)
	. = 0
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSBLOB)

/obj/structure/blob/update_icon() //Updates color based on overmind color if we have an overmind.
	if(overmind)
		add_atom_colour(overmind.blob_reagent_datum.color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)

/obj/structure/blob/process()
	Life()

/obj/structure/blob/proc/Life()
	return

/obj/structure/blob/proc/Pulse_Area(pulsing_overmind = overmind, claim_range = 10, pulse_range = 3, expand_range = 2)
	src.Be_Pulsed()
	var/expanded = FALSE
	if(prob(70) && expand())
		expanded = TRUE
	var/list/blobs_to_affect = list()
	for(var/obj/structure/blob/B in urange(claim_range, src, 1))
		blobs_to_affect += B
	shuffle_inplace(blobs_to_affect)
	for(var/L in blobs_to_affect)
		var/obj/structure/blob/B = L
		if(!B.overmind && !istype(B, /obj/structure/blob/core) && prob(30))
			B.overmind = pulsing_overmind //reclaim unclaimed, non-core blobs.
			B.update_icon()
		var/distance = get_dist(get_turf(src), get_turf(B))
		var/expand_probablity = max(20 - distance * 8, 1)
		if(B.Adjacent(src))
			expand_probablity = 20
		if(distance <= expand_range)
			var/can_expand = TRUE
			if(blobs_to_affect.len >= 120 && B.heal_timestamp > world.time)
				can_expand = FALSE
			if(can_expand && B.pulse_timestamp <= world.time && prob(expand_probablity))
				var/obj/structure/blob/newB = B.expand(null, null, !expanded) //expansion falls off with range but is faster near the blob causing the expansion
				if(newB)
					if(expanded)
						qdel(newB)
					expanded = TRUE
		if(distance <= pulse_range)
			B.Be_Pulsed()

/obj/structure/blob/proc/Be_Pulsed()
	if(pulse_timestamp <= world.time)
		ConsumeTile()
		if(heal_timestamp <= world.time)
			obj_integrity = min(max_integrity, obj_integrity+health_regen)
			heal_timestamp = world.time + 20
		update_icon()
		pulse_timestamp = world.time + 10
		return 1 //we did it, we were pulsed!
	return 0 //oh no we failed

/obj/structure/blob/proc/ConsumeTile()
	for(var/atom/A in loc)
		A.blob_act(src)
	if(iswallturf(loc))
		loc.blob_act(src) //don't ask how a wall got on top of the core, just eat it

/obj/structure/blob/proc/blob_attack_animation(atom/A = null, controller) //visually attacks an atom
	var/obj/effect/temp_visual/blob/O = new /obj/effect/temp_visual/blob(src.loc)
	O.setDir(dir)
	if(controller)
		var/mob/camera/blob/BO = controller
		O.color = BO.blob_reagent_datum.color
		O.alpha = 200
	else if(overmind)
		O.color = overmind.blob_reagent_datum.color
	if(A)
		O.do_attack_animation(A) //visually attack the whatever
	return O //just in case you want to do something to the animation.

/obj/structure/blob/proc/expand(turf/T = null, controller = null, expand_reaction = 1)
	if(!T)
		var/list/dirs = list(1,2,4,8)
		for(var/i = 1 to 4)
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			T = get_step(src, dirn)
			if(!(locate(/obj/structure/blob) in T))
				break
			else
				T = null
	if(!T)
		return 0
	var/make_blob = TRUE //can we make a blob?

	if(isspaceturf(T) && !(locate(/obj/structure/lattice) in T) && prob(80))
		make_blob = FALSE
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) //Let's give some feedback that we DID try to spawn in space, since players are used to it

	ConsumeTile() //hit the tile we're in, making sure there are no border objects blocking us
	if(!T.CanPass(src, T, 5)) //is the target turf impassable
		make_blob = FALSE
		T.blob_act(src) //hit the turf if it is
	for(var/atom/A in T)
		if(!A.CanPass(src, T, 5)) //is anything in the turf impassable
			make_blob = FALSE
		A.blob_act(src) //also hit everything in the turf

	if(make_blob) //well, can we?
		var/obj/structure/blob/B = new /obj/structure/blob/normal(src.loc)
		if(controller)
			B.overmind = controller
		else
			B.overmind = overmind
		B.density = TRUE
		if(T.Enter(B,src)) //NOW we can attempt to move into the tile
			B.density = initial(B.density)
			B.loc = T
			B.update_icon()
			if(B.overmind && expand_reaction)
				B.overmind.blob_reagent_datum.expand_reaction(src, B, T, controller)
			return B
		else
			blob_attack_animation(T, controller)
			T.blob_act(src) //if we can't move in hit the turf again
			qdel(B) //we should never get to this point, since we checked before moving in. destroy the blob so we don't have two blobs on one tile
			return null
	else
		blob_attack_animation(T, controller) //if we can't, animate that we attacked
	return null

/obj/structure/blob/emp_act(severity)
	if(severity > 0)
		if(overmind)
			overmind.blob_reagent_datum.emp_reaction(src, severity)
		if(prob(100 - severity * 30))
			new /obj/effect/temp_visual/emp(get_turf(src))

/obj/structure/blob/tesla_act(power)
	..()
	if(overmind)
		if(overmind.blob_reagent_datum.tesla_reaction(src, power))
			take_damage(power/400, BURN, "energy")
	else
		take_damage(power/400, BURN, "energy")

/obj/structure/blob/extinguish()
	..()
	if(overmind)
		overmind.blob_reagent_datum.extinguish_reaction(src)

/obj/structure/blob/hulk_damage()
	return 15

/obj/structure/blob/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/analyzer))
		user.changeNext_move(CLICK_CD_MELEE)
		to_chat(user, "<b>The analyzer beeps once, then reports:</b><br>")
		user << 'sound/machines/ping.ogg'
		chemeffectreport(user)
		typereport(user)
	else
		return ..()

/obj/structure/blob/proc/chemeffectreport(mob/user)
	if(overmind)
		to_chat(user, "<b>Material: <font color=\"[overmind.blob_reagent_datum.color]\">[overmind.blob_reagent_datum.name]</font><span class='notice'>.</span></b>")
		to_chat(user, "<b>Material Effects:</b> <span class='notice'>[overmind.blob_reagent_datum.analyzerdescdamage]</span>")
		to_chat(user, "<b>Material Properties:</b> <span class='notice'>[overmind.blob_reagent_datum.analyzerdesceffect]</span><br>")
	else
		to_chat(user, "<b>No Material Detected!</b><br>")

/obj/structure/blob/proc/typereport(mob/user)
	to_chat(user, "<b>Blob Type:</b> <span class='notice'>[uppertext(initial(name))]</span>")
	to_chat(user, "<b>Health:</b> <span class='notice'>[obj_integrity]/[max_integrity]</span>")
	to_chat(user, "<b>Effects:</b> <span class='notice'>[scannerreport()]</span>")

/obj/structure/blob/attack_animal(mob/living/simple_animal/M)
	if("blob" in M.faction) //sorry, but you can't kill the blob as a blobbernaut
		return
	..()

/obj/structure/blob/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/blob/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	switch(damage_type)
		if(BRUTE)
			damage_amount *= brute_resist
		if(BURN)
			damage_amount *= fire_resist
		if(CLONE)
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor[damage_flag]
	damage_amount = round(damage_amount * (100 - armor_protection)*0.01, 0.1)
	if(overmind && damage_flag)
		damage_amount = overmind.blob_reagent_datum.damage_reaction(src, damage_amount, damage_type, damage_flag)
	return damage_amount

/obj/structure/blob/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		update_icon()

/obj/structure/blob/obj_destruction(damage_flag)
	if(overmind)
		overmind.blob_reagent_datum.death_reaction(src, damage_flag)
	..()

/obj/structure/blob/proc/change_to(type, controller)
	if(!ispath(type))
		throw EXCEPTION("change_to(): invalid type for blob")
		return
	var/obj/structure/blob/B = new type(src.loc)
	if(controller)
		B.overmind = controller
	B.creation_action()
	B.update_icon()
	B.setDir(dir)
	qdel(src)
	return B

/obj/structure/blob/examine(mob/user)
	..()
	var/datum/atom_hud/hud_to_check = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	if(user.research_scanner || hud_to_check.hudusers[user])
		to_chat(user, "<b>Your HUD displays an extensive report...</b><br>")
		chemeffectreport(user)
		typereport(user)
	else
		to_chat(user, "It seems to be made of [get_chem_name()].")

/obj/structure/blob/proc/scannerreport()
	return "A generic blob. Looks like someone forgot to override this proc, adminhelp this."

/obj/structure/blob/proc/get_chem_name()
	if(overmind)
		return overmind.blob_reagent_datum.name
	return "an unknown variant"

/obj/structure/blob/normal
	name = "normal blob"
	icon_state = "blob"
	light_range = 0
	obj_integrity = 21 //doesn't start at full health
	max_integrity = 25
	health_regen = 1
	brute_resist = 0.25

/obj/structure/blob/normal/scannerreport()
	if(obj_integrity <= 15)
		return "Currently weak to brute damage."
	return "N/A"

/obj/structure/blob/normal/update_icon()
	..()
	if(obj_integrity <= 15)
		icon_state = "blob_damaged"
		name = "fragile blob"
		desc = "A thin lattice of slightly twitching tendrils."
		brute_resist = 0.5
	else
		icon_state = "blob"
		name = "blob"
		desc = "A thick wall of writhing tendrils."
		brute_resist = 0.25
