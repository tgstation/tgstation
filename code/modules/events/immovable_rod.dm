/*
Immovable rod random event.
The rod will spawn at some location outside the station, and travel in a straight line to the opposite side of the station
Everything solid in the way will be ex_act()'d
In my current plan for it, 'solid' will be defined as anything with density == 1

--NEOFite
*/

/datum/round_event_control/immovable_rod
	name = "Immovable Rod"
	typepath = /datum/round_event/immovable_rod
	min_players = 15
	max_occurrences = 5
	var/atom/special_target


/datum/round_event_control/immovable_rod/admin_setup()
	if(!check_rights(R_FUN))
		return

	var/aimed = alert("Aimed at current location?","Sniperod", "Yes", "No")
	if(aimed == "Yes")
		special_target = get_turf(usr)
	message_admins("[key_name_admin(usr)] has aimed an immovable rod at [AREACOORD(special_target)].")
	log_admin("[key_name_admin(usr)] has aimed an immovable rod at [AREACOORD(special_target)].")

/datum/round_event/immovable_rod
	announceWhen = 5

/datum/round_event/immovable_rod/announce(fake)
	priority_announce("What the fuck was that?!", "General Alert")

/datum/round_event/immovable_rod/start()
	var/datum/round_event_control/immovable_rod/C = control
	var/startside = pick(GLOB.cardinals)
	var/turf/endT = get_edge_target_turf(get_random_station_turf(), turn(startside, 180))
	var/turf/startT = spaceDebrisStartLoc(startside, endT.z)
	var/atom/rod = new /obj/effect/immovablerod(startT, endT, C.special_target)
	C.special_target = null //Cleanup for future event rolls.
	announce_to_ghosts(rod)

/obj/effect/immovablerod
	name = "immovable rod"
	desc = "What the fuck is that?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	move_force = INFINITY
	move_resist = INFINITY
	pull_force = INFINITY
	density = TRUE
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	generic_canpass = FALSE
	movement_type = PHASING | FLYING
	var/mob/living/wizard
	var/z_original = 0
	var/destination
	var/notify = TRUE
	///We can designate a specific target to aim for, in which case we'll try to snipe them rather than just flying in a random direction
	var/atom/special_target
	///How many mobs we've penetrated one way or another
	var/num_mobs_hit = 0
	///How many mobs we've hit with clients
	var/num_sentient_mobs_hit = 0
	///How many people we've hit with clients
	var/num_sentient_people_hit = 0
	/// The rod levels up with each kill, increasing in size and auto-renaming itself.
	var/dnd_style_level_up = TRUE

/obj/effect/immovablerod/New(atom/start, atom/end, aimed_at)
	. = ..()
	SSaugury.register_doom(src, 2000)

	destination = end
	special_target = aimed_at

	AddElement(/datum/element/point_of_interest)

	if(special_target)
		walk_towards(src, special_target, 1)
		return

	walk_towards(src, destination, 1)

/obj/effect/immovablerod/examine(mob/user)
	. = ..()
	if(!isobserver(user))
		return

	if(!num_mobs_hit)
		. += "<span class='notice'>So far, this rod has not hit any mobs.</span>"
		return

	. += "\t<span class='notice'>So far, this rod has hit: \n\
		\t\t[num_mobs_hit] mobs total, \n\
		\t\t[num_sentient_mobs_hit] of which were sentient, and \n\
		\t\t[num_sentient_people_hit] of which were sentient people</span>"

/obj/effect/immovablerod/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/effect/immovablerod/Moved()
	// If our loc is dense, noogie it.
	if(loc.density)
		Bump(loc)

	// So, we're phasing as will harmlessly glide through things. Let's noogie everything in our loc's contents.
	for(var/clong in loc.contents)
		if(clong == src)
			continue

		var/atom/clong_atom = clong
		if(clong_atom.density || isliving(clong_atom) && !QDELETED(clong_atom))
			Bump(clong_atom)

	// If we have a special target, we should definitely make an effort to go find them.
	if(special_target)
		var/turf/target_turf = get_turf(special_target)

		// Did they escape the z-level? Let's see if we can chase them down!
		var/z_diff = target_turf.z - z

		if(z_diff)
			var/direction = z_diff > 0 ? UP : DOWN
			var/turf/target_z_turf = get_step_multiz(src, direction)

			visible_message("<span class='danger'>[src] phases out of reality.</span>")

			if(!do_teleport(src, target_z_turf))
				// We failed to teleport. Might as well admit defeat.
				qdel(src)
				return

			visible_message("<span class='danger'>[src] phases into reality.</span>")
			walk_towards(src, special_target, 1)

		if(loc == target_turf)
			complete_trajectory()

		return ..()

	// If we have a destination turf, let's make sure it's also still valid.
	if(destination)
		var/turf/target_turf = get_turf(destination)

		// Note: There is no way to detect if this is because it spawned off the primary station
		// z-level with a destination on the primary station z-level. As a result, maps with
		// multiple station z-levels may find their immovable rods immediately deleting themselves.
		if(target_turf.z != z)
			qdel(src)
			return

		// Did we reach our destination? We're probably on Icebox. Let's get rid of ourselves.
		// Ordinarily this won't happen as the average destination is the edge of the map and
		// the rod will auto transition to a new z-level.
		if(loc == get_turf(destination))
			qdel(src)
			return

	return ..()

/obj/effect/immovablerod/proc/complete_trajectory()
	// We hit what we wanted to hit, time to go.
	special_target = null
	destination = get_edge_target_turf(src, dir)
	walk_towards(src, destination, 1)

/obj/effect/immovablerod/singularity_act()
	return

/obj/effect/immovablerod/singularity_pull()
	return

/obj/effect/immovablerod/Bump(atom/clong)
	if(prob(10))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		audible_message("<span class='danger'>You hear a CLANG!</span>")

	if(special_target && clong == special_target)
		complete_trajectory()

	// If rod meets rod, they collapse into a singularity. Yes, this means that if two wizard rods collide,
	// they ALSO collapse into a singulo.
	if(istype(clong, /obj/effect/immovablerod))
		visible_message("<span class='danger'>[src] collides with [clong]! This cannot end well.</span>")
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(2, get_turf(src))
		smoke.start()
		var/obj/singularity/bad_luck = new(get_turf(src))
		bad_luck.energy = 800
		qdel(clong)
		qdel(src)
		return

	// If we Bump into a turf, turf go boom.
	if(isturf(clong))
		SSexplosions.highturf += clong
		return ..()

	if(isobj(clong))
		var/obj/clong_obj = clong
		clong_obj.take_damage(INFINITY, BRUTE, NONE, TRUE, dir, INFINITY)
		return ..()

	// If we Bump into a living thing, living thing goes splat.
	if(isliving(clong))
		penetrate(clong)
		return ..()

	// If we Bump into anything else, anything goes boom.
	if(isatom(clong))
		SSexplosions.high_mov_atom += clong
		return ..()

	CRASH("[src] Bump()ed into non-atom thing [clong] ([clong.type])")

/obj/effect/immovablerod/proc/penetrate(mob/living/smeared_mob)
	smeared_mob.visible_message("<span class='danger'>[smeared_mob] is penetrated by an immovable rod!</span>" , "<span class='userdanger'>The rod penetrates you!</span>" , "<span class='danger'>You hear a CLANG!</span>")

	if(smeared_mob.stat != DEAD)
		num_mobs_hit++
		if(smeared_mob.client)
			num_sentient_mobs_hit++
			if(iscarbon(smeared_mob))
				num_sentient_people_hit++
			if(dnd_style_level_up)
				transform = transform.Scale(1.005, 1.005)
				name = "[initial(name)] of sentient slaying +[num_sentient_mobs_hit]"

	if(iscarbon(smeared_mob))
		var/mob/living/carbon/smeared_carbon = smeared_mob
		smeared_carbon.adjustBruteLoss(100)
		var/obj/item/bodypart/penetrated_chest = smeared_carbon.get_bodypart(BODY_ZONE_CHEST)
		penetrated_chest?.receive_damage(60, wound_bonus = 20, sharpness=SHARP_POINTY)

	if(smeared_mob.density || prob(10))
		smeared_mob.ex_act(EXPLODE_HEAVY)

/obj/effect/immovablerod/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!(HAS_TRAIT(user, TRAIT_ROD_SUPLEX) || (user.mind && HAS_TRAIT(user.mind, TRAIT_ROD_SUPLEX))))
		return

	playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	for(var/mob/M in urange(8, src))
		if(M.stat != CONSCIOUS)
			continue
		shake_camera(M, 2, 3)

	if(wizard)
		user.visible_message("<span class='boldwarning'>[src] transforms into [wizard] as [user] suplexes them!</span>", "<span class='warning'>As you grab [src], it suddenly turns into [wizard] as you suplex them!</span>")
		to_chat(wizard, "<span class='boldwarning'>You're suddenly jolted out of rod-form as [user] somehow manages to grab you, slamming you into the ground!</span>")
		wizard.Stun(60)
		wizard.apply_damage(25, BRUTE)
		qdel(src)
	else
		user.client.give_award(/datum/award/achievement/misc/feat_of_strength, user) //rod-form wizards would probably make this a lot easier to get so keep it to regular rods only
		user.visible_message("<span class='boldwarning'>[user] suplexes [src] into the ground!</span>", "<span class='warning'>You suplex [src] into the ground!</span>")
		new /obj/structure/festivus/anchored(drop_location())
		new /obj/effect/anomaly/flux(drop_location())
		qdel(src)

	return TRUE
