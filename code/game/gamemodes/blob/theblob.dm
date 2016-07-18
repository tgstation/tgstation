//I will need to recode parts of this but I am way too tired atm //I don't know who left this comment but they never did come back
/obj/effect/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	luminosity = 1
	desc = "A thick wall of writhing tendrils."
	density = 0 //this being 0 causes two bugs, being able to attack blob tiles behind other blobs and being unable to move on blob tiles in no gravity, but turning it to 1 causes the blob mobs to be unable to path through blobs, which is probably worse.
	opacity = 0
	anchored = 1
	explosion_block = 1
	var/point_return = 0 //How many points the blob gets back when it removes a blob of that type. If less than 0, blob cannot be removed.
	var/health = 30
	var/maxhealth = 30
	var/health_regen = 2 //how much health this blob regens when pulsed
	var/pulse_timestamp = 0 //we got pulsed/healed when?
	var/brute_resist = 0.5 //multiplies brute damage by this
	var/fire_resist = 1 //multiplies burn damage by this
	var/atmosblock = 0 //if the blob blocks atmos and heat spread
	var/mob/camera/blob/overmind


/obj/effect/blob/New(loc)
	var/area/Ablob = get_area(loc)
	if(Ablob.blob_allowed) //Is this area allowed for winning as blob?
		blobs_legit += src
	blobs += src //Keep track of the blob in the normal list either way
	src.setDir(pick(1, 2, 4, 8))
	src.update_icon()
	..(loc)
	ConsumeTile()
	if(atmosblock)
		air_update_turf(1)
	return

/obj/effect/blob/proc/creation_action() //When it's created by the overmind, do this.
	return

/obj/effect/blob/Destroy()
	if(atmosblock)
		atmosblock = 0
		air_update_turf(1)
	blobs_legit -= src  //if it was in the legit blobs list, it isn't now
	blobs -= src //it's no longer in the all blobs list either
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) //Expand() is no longer broken, no check necessary.
	return ..()


/obj/effect/blob/Adjacent(var/atom/neighbour)
	. = ..()
	if(.)
		var/result = 0
		var/direction = get_dir(src, neighbour)
		var/list/dirs = list("[NORTHWEST]" = list(NORTH, WEST), "[NORTHEAST]" = list(NORTH, EAST), "[SOUTHEAST]" = list(SOUTH, EAST), "[SOUTHWEST]" = list(SOUTH, WEST))
		for(var/A in dirs)
			if(direction == text2num(A))
				for(var/B in dirs[A])
					var/C = locate(/obj/effect/blob) in get_step(src, B)
					if(C)
						result++
		. -= result - 1

/obj/effect/blob/CanAtmosPass(turf/T)
	return !atmosblock

/obj/effect/blob/BlockSuperconductivity()
	return atmosblock

/obj/effect/blob/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return 1
	if(istype(mover) && mover.checkpass(PASSBLOB))
		return 1
	return 0

/obj/effect/blob/CanAStarPass(ID, dir, caller)
	. = 0
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSBLOB)

/obj/effect/blob/proc/check_health(cause)
	health = Clamp(health, 0, maxhealth)
	if(health <= 0)
		if(overmind)
			overmind.blob_reagent_datum.death_reaction(src, cause)
		qdel(src) //we dead now
		return
	return

/obj/effect/blob/update_icon() //Updates color based on overmind color if we have an overmind.
	if(overmind)
		color = overmind.blob_reagent_datum.color
	else
		color = null
	return


/obj/effect/blob/process()
	Life()
	return

/obj/effect/blob/proc/Life()
	return

/obj/effect/blob/proc/Pulse_Area(pulsing_overmind = overmind, claim_range = 10, pulse_range = 3, expand_range = 2)
	src.Be_Pulsed()
	if(claim_range)
		for(var/obj/effect/blob/B in urange(claim_range, src, 1))
			if(!B.overmind && !istype(B, /obj/effect/blob/core) && prob(30))
				B.overmind = pulsing_overmind //reclaim unclaimed, non-core blobs.
				B.update_icon()
	if(pulse_range)
		for(var/obj/effect/blob/B in orange(pulse_range, src))
			B.Be_Pulsed()
	if(expand_range)
		if(prob(85))
			src.expand()
		for(var/obj/effect/blob/B in orange(expand_range, src))
			if(prob(max(13 - get_dist(get_turf(src), get_turf(B)) * 4, 1))) //expand falls off with range but is faster near the blob causing the expansion
				B.expand()
	return

/obj/effect/blob/proc/Be_Pulsed()
	if(pulse_timestamp <= world.time)
		ConsumeTile()
		health = min(maxhealth, health+health_regen)
		update_icon()
		pulse_timestamp = world.time + 10
		return 1 //we did it, we were pulsed!
	return 0 //oh no we failed

/obj/effect/blob/proc/ConsumeTile()
	for(var/atom/A in loc)
		A.blob_act(src)
	if(istype(loc, /turf/closed/wall))
		loc.blob_act(src) //don't ask how a wall got on top of the core, just eat it

/obj/effect/blob/proc/blob_attack_animation(atom/A = null, controller) //visually attacks an atom
	var/obj/effect/overlay/temp/blob/O = PoolOrNew(/obj/effect/overlay/temp/blob, src.loc)
	if(controller)
		var/mob/camera/blob/BO = controller
		O.color = BO.blob_reagent_datum.color
		O.alpha = 200
	else if(overmind)
		O.color = overmind.blob_reagent_datum.color
	if(A)
		O.do_attack_animation(A) //visually attack the whatever
	return O //just in case you want to do something to the animation.

/obj/effect/blob/proc/expand(turf/T = null, controller = null, expand_reaction = 1)
	if(!T)
		var/list/dirs = list(1,2,4,8)
		for(var/i = 1 to 4)
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			T = get_step(src, dirn)
			if(!(locate(/obj/effect/blob) in T))
				break
			else
				T = null
	if(!T)
		return 0
	var/make_blob = TRUE //can we make a blob?

	if(istype(T, /turf/open/space) && !(locate(/obj/structure/lattice) in T) && prob(80))
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
		var/obj/effect/blob/B = new /obj/effect/blob/normal(src.loc)
		if(controller)
			B.overmind = controller
		else
			B.overmind = overmind
		B.density = 1
		if(T.Enter(B,src)) //NOW we can attempt to move into the tile
			B.density = initial(B.density)
			B.loc = T
			B.update_icon()
			if(B.overmind && expand_reaction)
				B.overmind.blob_reagent_datum.expand_reaction(src, B, T)
			return B
		else
			blob_attack_animation(T, controller)
			T.blob_act(src) //if we can't move in hit the turf again
			qdel(B) //we should never get to this point, since we checked before moving in. destroy the blob so we don't have two blobs on one tile
			return null
	else
		blob_attack_animation(T, controller) //if we can't, animate that we attacked
	return null


/obj/effect/blob/ex_act(severity, target)
	..()
	var/damage = 150 - 20 * severity
	take_damage(damage, BRUTE)

/obj/effect/blob/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	var/damage = Clamp(0.01 * exposed_temperature, 0, 4)
	take_damage(damage, BURN)

/obj/effect/blob/emp_act(severity)
	if(severity > 0)
		if(overmind)
			overmind.blob_reagent_datum.emp_reaction(src, severity)
		if(prob(100 - severity * 30))
			PoolOrNew(/obj/effect/overlay/temp/emp, get_turf(src))

/obj/effect/blob/tesla_act(power)
	..()
	if(overmind)
		if(overmind.blob_reagent_datum.tesla_reaction(src, power))
			take_damage(power/400, BURN)
	else
		take_damage(power/400, BURN)

/obj/effect/blob/extinguish()
	..()
	if(overmind)
		overmind.blob_reagent_datum.extinguish_reaction(src)

/obj/effect/blob/bullet_act(var/obj/item/projectile/Proj)
	..()
	take_damage(Proj.damage, Proj.damage_type, Proj)
	return 0

/obj/effect/blob/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/analyzer))
		user.changeNext_move(CLICK_CD_MELEE)
		user << "<b>The analyzer beeps once, then reports:</b><br>"
		user << 'sound/machines/ping.ogg'
		chemeffectreport(user)
		typereport(user)
	else
		return ..()

/obj/effect/blob/proc/chemeffectreport(mob/user)
	if(overmind)
		user << "<b>Material: <font color=\"[overmind.blob_reagent_datum.color]\">[overmind.blob_reagent_datum.name]</font><span class='notice'>.</span></b>"
		user << "<b>Material Effects:</b> <span class='notice'>[overmind.blob_reagent_datum.analyzerdescdamage]</span>"
		user << "<b>Material Properties:</b> <span class='notice'>[overmind.blob_reagent_datum.analyzerdesceffect]</span><br>"
	else
		user << "<b>No Material Detected!</b><br>"

/obj/effect/blob/proc/typereport(mob/user)
	user << "<b>Blob Type:</b> <span class='notice'>[uppertext(initial(name))]</span>"
	user << "<b>Health:</b> <span class='notice'>[health]/[maxhealth]</span>"
	user << "<b>Effects:</b> <span class='notice'>[scannerreport()]</span>"

/obj/effect/blob/attacked_by(obj/item/I, mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
	visible_message("<span class='danger'>[user] has attacked the [src.name] with \the [I]!</span>")
	if(I.damtype == BURN)
		playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
	take_damage(I.force, I.damtype, user)

/obj/effect/blob/attack_animal(mob/living/simple_animal/M)
	if("blob" in M.faction) //sorry, but you can't kill the blob as a blobbernaut
		return
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
	visible_message("<span class='danger'>\The [M] has attacked the [src.name]!</span>")
	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
	take_damage(damage, M.melee_damage_type, M)
	return

/obj/effect/blob/attack_alien(mob/living/carbon/alien/humanoid/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
	visible_message("<span class='danger'>[M] has slashed the [src.name]!</span>")
	var/damage = rand(15, 30)
	take_damage(damage, BRUTE, M)
	return

/obj/effect/blob/proc/take_damage(damage, damage_type, cause = null, overmind_reagent_trigger = 1)
	switch(damage_type) //blobs only take brute and burn damage
		if(BRUTE)
			damage = max(damage * brute_resist, 0)
		if(BURN)
			damage = max(damage * fire_resist, 0)
		if(CLONE) //this is basically a marker for 'don't modify the damage'

		else
			damage = 0
	if(overmind && overmind_reagent_trigger)
		damage = overmind.blob_reagent_datum.damage_reaction(src, health, damage, damage_type, cause) //pass the blob, its health before damage, the damage being done, the type of damage being done, and the cause.
	health -= damage
	update_icon()
	check_health(cause)

/obj/effect/blob/proc/change_to(type, controller)
	if(!ispath(type))
		throw EXCEPTION("change_to(): invalid type for blob")
		return
	var/obj/effect/blob/B = new type(src.loc)
	if(controller)
		B.overmind = controller
	B.creation_action()
	B.update_icon()
	qdel(src)
	return B

/obj/effect/blob/examine(mob/user)
	..()
	var/datum/atom_hud/hud_to_check = huds[DATA_HUD_MEDICAL_ADVANCED]
	if(user.research_scanner || (user in hud_to_check.hudusers))
		user << "<b>Your HUD displays an extensive report...</b><br>"
		chemeffectreport(user)
		typereport(user)
	else
		user << "It seems to be made of [get_chem_name()]."

/obj/effect/blob/proc/scannerreport()
	return "A generic blob. Looks like someone forgot to override this proc, adminhelp this."

/obj/effect/blob/proc/get_chem_name()
	if(overmind)
		return overmind.blob_reagent_datum.name
	return "an unknown variant"

/obj/effect/blob/normal
	name = "normal blob"
	icon_state = "blob"
	luminosity = 0
	health = 21
	maxhealth = 25
	health_regen = 1
	brute_resist = 0.25

/obj/effect/blob/normal/scannerreport()
	if(health <= 10)
		return "Currently weak to brute damage."
	return "N/A"

/obj/effect/blob/normal/update_icon()
	..()
	if(health <= 10)
		icon_state = "blob_damaged"
		name = "fragile blob"
		desc = "A thin lattice of slightly twitching tendrils."
		brute_resist = 0.5
	else
		icon_state = "blob"
		name = "blob"
		desc = "A thick wall of writhing tendrils."
		brute_resist = 0.25
