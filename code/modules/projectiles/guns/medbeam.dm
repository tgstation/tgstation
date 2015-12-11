/obj/item/weapon/gun/medbeam
	name = "Medical Beamgun"
	desc = "Delivers medical nanites in a focused beam."
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronogun"
	item_state = "chronogun"
	w_class = 3.0

	var/mob/living/current_target
	var/last_check = 0
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	var/max_range = 8
	var/active = 0
	var/datum/beam/current_beam = null

	heavy_weapon = 1

/obj/item/weapon/gun/medbeam/New()
	..()
	SSobj.processing |= src

/obj/item/weapon/gun/medbeam/dropped(mob/user)
	..()
	LoseTarget()

/obj/item/weapon/gun/medbeam/proc/LoseTarget()
	if(active)
		qdel(current_beam)
		active = 0
		on_beam_relase(current_target)
	current_target = null

/obj/item/weapon/gun/medbeam/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override)
	add_fingerprint(user)

	if(!isliving(target))
		return
	if(current_target)
		LoseTarget()

	current_target = target
	active = 1
	current_beam = new(user,current_target,time=6000)
	spawn(0)
		current_beam.Start()

	feedback_add_details("gun_fired","[src.type]")

/obj/item/weapon/gun/medbeam/afterattack(obj/target, mob/user, proximity)
	if(target.loc == loc || target == user)	
		return

	if(!current_target && isliving(target))
		current_target = target
		active = 1
		current_beam = new(user,current_target,time=6000)
		spawn(0)
			current_beam.Start()

/obj/item/weapon/gun/medbeam/process()
	var/mob/living/carbon/human/H = loc
	if(!istype(H))
		LoseTarget()
		return

	if(!current_target)
		LoseTarget()
		return

	if(world.time <= last_check+check_delay)
		return
	
	last_check = world.time

	if(get_dist(H,current_target)>max_range || !los_check(H,current_target))
		LoseTarget()
		H << "<span class='warning'>You lose control of the beam!</span>"
		return

	if(current_target)
		on_beam_tick(current_target)

/obj/item/weapon/gun/medbeam/proc/los_check(mob/user,mob/target)
	var/turf/user_turf = user.loc
	if(!istype(user_turf))
		return 0
	var/obj/dummy = new(user_turf)
	dummy.pass_flags |= PASSTABLE & PASSGLASS & PASSGRILLE //Grille/Glass so it can be used through common windows
	for(var/turf/turf in getline(user_turf,target))
		if(turf.density)
			qdel(dummy)
			return 0
		for(var/atom/movable/AM in turf)
			if(!AM.CanPass(dummy,turf,1))
				qdel(dummy)
				return 0
		for(var/obj/effect/overlay/beam/O in turf)// Don't cross the str-beams!
			if(O.BeamSource!=user)
				explosion(O.loc,0,3,5,8)
				qdel(dummy)
				return 0
	qdel(dummy)
	return 1

/obj/item/weapon/gun/medbeam/proc/on_beam_hit(var/mob/living/target)
	return

/obj/item/weapon/gun/medbeam/proc/on_beam_tick(var/mob/living/target)
	target.adjustBruteLoss(-4)
	target.adjustFireLoss(-4)
	return 

/obj/item/weapon/gun/medbeam/proc/on_beam_relase(var/mob/living/target)
	return