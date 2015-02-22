/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if (!contents.Find(internal))
			internal = null
		if (!wear_mask || !(wear_mask.flags & MASKINTERNALS) )
			internal = null
		if(internal)
			if (internals)
				internals.icon_state = "internal1"
			return internal.remove_air_volume(volume_needed)
		else
			if (internals)
				internals.icon_state = "internal0"
	return

/mob/living/carbon/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return
	if(!loc)
		return
	var/datum/gas_mixture/environment = loc.return_air()

	//Handle temperature/pressure differences between body and environment
	handle_environment(environment)

	handle_regular_status_updates() // Status updates, death etc.

	if(stat != DEAD)

		//Updates the number of stored chemicals for powers
		handle_changeling()

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Disabilities
		handle_disabilities()

		//Blud
		handle_blood()

		//Random events (vomiting etc)
		handle_random_events()

		. = 1

	handle_fire()

	//stuff in the stomach
	handle_stomach()

	update_canmove()

	update_gravity(mob_has_gravity())

	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(client)
		handle_regular_hud_updates()

	return .














//remember to remove the "proc" of the child procs of these.

/mob/living/carbon/proc/handle_changeling()
	return

/mob/living/carbon/proc/handle_mutations_and_radiation()
	return

/mob/living/carbon/proc/handle_chemicals_in_body()
	return

/mob/living/carbon/proc/handle_disabilities()
	return

/mob/living/carbon/proc/handle_blood()
	return

/mob/living/carbon/proc/handle_random_events()
	return

/mob/living/carbon/proc/handle_environment(var/datum/gas_mixture/environment)
	return

/mob/living/carbon/proc/handle_regular_status_updates()
	return

/mob/living/carbon/proc/handle_stomach()
	spawn(0)
		for(var/mob/living/M in stomach_contents)
			if(M.loc != src)
				stomach_contents.Remove(M)
				continue
			if(istype(M, /mob/living/carbon) && stat != 2)
				if(M.stat == 2)
					M.death(1)
					stomach_contents.Remove(M)
					qdel(M)
					continue
				if(SSmob.times_fired%3==1)
					if(!(M.status_flags & GODMODE))
						M.adjustBruteLoss(5)
					nutrition += 10

/mob/living/carbon/proc/handle_regular_hud_updates()
	return


