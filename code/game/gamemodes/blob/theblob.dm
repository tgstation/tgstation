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
	var/health_timestamp = 0 //we got healed when?
	var/pulse_timestamp = 0 //we got pulsed when?
	var/brute_resist = 0.5 //multiplies brute damage by this
	var/fire_resist = 1 //multiplies burn damage by this
	var/atmosblock = 0 //if the blob blocks atmos and heat spread
	var/mob/camera/blob/overmind


/obj/effect/blob/New(loc)
	var/area/Ablob = get_area(loc)
	if(Ablob.blob_allowed) //Is this area allowed for winning as blob?
		blobs_legit += src
	blobs += src //Keep track of the blob in the normal list either way
	src.dir = pick(1, 2, 4, 8)
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
	var/area/Ablob = get_area(loc)
	if(Ablob.blob_allowed) //Only remove for blobs in areas that counted for the win
		blobs_legit -= src
	blobs -= src //It's still removed from the normal list
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) //Expand() is no longer broken, no check necessary.
	return ..()


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


/obj/effect/blob/proc/check_health(cause)
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
		for(var/obj/effect/blob/B in ultra_range(claim_range, src, 1))
			B.update_icon()
			if(!B.overmind && !istype(B, /obj/effect/blob/core) && prob(30))
				B.overmind = pulsing_overmind //reclaim unclaimed, non-core blobs.
				B.update_icon()
	if(pulse_range)
		for(var/obj/effect/blob/B in orange(pulse_range, src))
			B.Be_Pulsed()
	if(expand_range)
		src.expand()
		for(var/obj/effect/blob/B in orange(expand_range, src))
			if(prob(12))
				B.expand()
	return

/obj/effect/blob/proc/Be_Pulsed()
	if(pulse_timestamp <= world.time)
		PulseAnimation()
		ConsumeTile()
		RegenHealth()
		run_action()
		pulse_timestamp = world.time + 10
		return 1 //we did it, we were pulsed!
	return 0 //oh no we failed

/obj/effect/blob/proc/ConsumeTile()
	for(var/atom/A in loc)
		A.blob_act()

/obj/effect/blob/proc/PulseAnimation()
	flick("[icon_state]_glow", src)
	return

/obj/effect/blob/proc/RegenHealth() //when pulsed, heal!
	if(health_timestamp <= world.time)
		health = min(maxhealth, health+health_regen)
		update_icon()
		health_timestamp = world.time + 10 //1 second between heals
		return 1
	return 0

/obj/effect/blob/proc/run_action()
	return 0


/obj/effect/blob/proc/expand(turf/T = null, prob = 1, controller = null)
	if(prob && !prob(health))
		return
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
	var/make_blob = 1 //can we make a blob?
	if(istype(T, /turf/space) && prob(65))
		make_blob = 0
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) //Let's give some feedback that we DID try to spawn in space, since players are used to it
	for(var/atom/A in T)
		if(A.density)
			make_blob = 0
		A.blob_act() //Hit everything
	if(T.density) //Check for walls and such dense turfs
		make_blob = 0
		T.blob_act() //Hit the turf
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
			if(B.overmind)
				B.overmind.blob_reagent_datum.expand_reaction(B, T)
		else
			T.blob_act() //If we cant move in hit the turf
			qdel(B) //We should never get to this point, since we checked before moving in. Destroy blob anyway for cleanliness though
	return 1


/obj/effect/blob/ex_act(severity, target)
	..()
	var/damage = 150 - 20 * severity
	take_damage(damage, BRUTE)

/obj/effect/blob/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	var/damage = Clamp(0.01 * exposed_temperature, 0, 4)
	take_damage(damage, BURN)

/obj/effect/blob/bullet_act(var/obj/item/projectile/Proj)
	..()
	take_damage(Proj.damage, Proj.damage_type, Proj)
	return 0

/obj/effect/blob/attackby(obj/item/weapon/W, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
	visible_message("<span class='danger'>[user] has attacked the [src.name] with \the [W]!</span>")
	if(W.damtype == BURN)
		playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
	take_damage(W.force, W.damtype, user)

/obj/effect/blob/attack_animal(mob/living/simple_animal/M)
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

/obj/effect/blob/proc/take_damage(damage, damage_type, cause = null)
	switch(damage_type) //blobs only take brute and burn damage
		if(BRUTE)
			damage = max(damage * brute_resist, 0)
		if(BURN)
			damage = max(damage * fire_resist, 0)
		else
			damage = 0
	if(overmind)
		overmind.blob_reagent_datum.damage_reaction(src, health, damage, damage_type, cause) //pass the blob, its health before damage, the damage being done, the type of damage being done, and the cause.
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
	user << "It seems to be made of [get_chem_name()]."
	return

/obj/effect/blob/proc/get_chem_name()
	if(overmind)
		return overmind.blob_reagent_datum.name
	return "an unknown variant"

/obj/effect/blob/normal
	icon_state = "blob"
	luminosity = 0
	health = 21
	maxhealth = 25
	health_regen = 1
	brute_resist = 0.25

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
