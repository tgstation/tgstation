///Called by the mob subsystem. ALWAYS call parent first.
/mob/living/proc/Process_Living(seconds, times_fired)
	set waitfor = FALSE
	set invisibility = 0
	. = NONE
	if(stat == DEAD)
		. |= MOBFLAG_DEAD
	if(client) //Just a bunch of Z level tracking stuff.
		var/turf/T = get_turf(src)
		if(!T)
			for(var/obj/effect/landmark/error/E in GLOB.landmarks_list)
				forceMove(E.loc)
				break
			var/msg = "[ADMIN_LOOKUPFLW(src)] was found to have no .loc with an attached client, if the cause is unknown it would be wise to ask how this was accomplished."
			message_admins(msg)
			send2irc_adminless_only("Mob", msg, R_ADMIN)
			log_game("[key_name(src)] was found to have no .loc with an attached client.")

		// This is a temporary error tracker to make sure we've caught everything
		else if (registered_z != T.z)
#ifdef TESTING
			message_admins("[ADMIN_LOOKUPFLW(src)] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z]. If you could ask them how that happened and notify coderbus, it would be appreciated.")
#endif
			log_game("Z-TRACKING: [src] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z].")
			update_z(T.z)
	else if (registered_z)
		log_game("Z-TRACKING: [src] of type [src.type] has a Z-registration despite not having a client.")
		update_z(null)
	if(notransform || !loc)
		. |= MOBFLAG_KILLALL
		return
	if(digitalinvis) //TO-DO: Get rid of this somehow.
		handle_diginvis()
	if((movement_type & FLYING) && !(movement_type & FLOATING))	//TODO: Better floating
		float(on = TRUE)
	//Here is where the fun begins
	if(!IS_IN_STASIS(src) && !(. & MOBFLAG_DEAD))
		. |= Life(seconds, times_fired)
	if(. & MOBFLAG_QDELETED)
		return
	var/datum/gas_mixture/environment = loc.return_air()
	if(environment)
		. |= handle_environment(environment)
	handle_fire(environment)
	handle_gravity()
	if(machine)
		machine.check_eye(src)

///Called if the mob isn't in stasis AND alive.
/mob/living/proc/Life(seconds, times_fired)
	. |= handle_mutations_and_radiation()
	if(. & MOBFLAG_DEAD)
		return
	. |= handle_status_effects() //all special effects, stun, knockdown, jitteryness, hallucination, sleeping, etc
	if(. & MOBFLAG_DEAD)
		return
	handle_random_events() //Only used by carbons right now, but there is value in this being on living.
	handle_traits() // eye, ear, brain damages

///Handles mutation and radiation and stuff like that.
/mob/living/proc/handle_mutations_and_radiation()
	radiation = 0 //so radiation don't accumulate in simple animals
	return

///Makes the user invisible to the AI.
/mob/living/proc/handle_diginvis()
	if(!digitaldisguise)
		src.digitaldisguise = image(loc = src)
	src.digitaldisguise.override = 1
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		AI.client.images |= src.digitaldisguise

///Used for stuff like vomiting.
/mob/living/proc/handle_random_events()
	return

///Handles how the mob should react to surrounding atmos.
/mob/living/proc/handle_environment(datum/gas_mixture/environment)
	return

///Handles fire and when it should get extinguished. Attention. Environment can be null.
/mob/living/proc/handle_fire(datum/gas_mixture/G)
	if(fire_stacks < 0) //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks + 1)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return TRUE //the mob is no longer on fire, no need to do the rest.
	if(fire_stacks > 0)
		adjust_fire_stacks(-0.1) //the fire is slowly consumed
	else
		ExtinguishMob()
		return TRUE //mob was put out, on_fire = FALSE via ExtinguishMob(), no need to update everything down the chain.
	if(!G || !G.gases[/datum/gas/oxygen] || G.gases[/datum/gas/oxygen][MOLES] < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return TRUE
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1)

//this updates all special effects: knockdown, druggy, stuttering, etc..
/mob/living/proc/handle_status_effects()
	if(confused)
		confused = max(0, confused - 1)

/mob/living/proc/handle_traits()
	//Eyes
	if(eye_blind)			//blindness, heals slowly over time
		if(!stat && !(HAS_TRAIT(src, TRAIT_BLIND)))
			eye_blind = max(eye_blind-1,0)
			if(client && !eye_blind)
				clear_alert("blind")
				clear_fullscreen("blind")
		else
			eye_blind = max(eye_blind-1,1)
	else if(eye_blurry)			//blurry eyes heal slowly
		eye_blurry = max(eye_blurry-1, 0)
		if(client)
			update_eye_blur()

/mob/living/proc/update_damage_hud()
	return

/mob/living/proc/handle_gravity()
	var/gravity = mob_has_gravity()
	update_gravity(gravity)

	if(gravity > STANDARD_GRAVITY)
		gravity_animate()
		handle_high_gravity(gravity)

/mob/living/proc/gravity_animate()
	if(!get_filter("gravity"))
		add_filter("gravity",1,list("type"="motion_blur", "x"=0, "y"=0))
	INVOKE_ASYNC(src, .proc/gravity_pulse_animation)

/mob/living/proc/gravity_pulse_animation()
	animate(get_filter("gravity"), y = 1, time = 10)
	sleep(10)
	animate(get_filter("gravity"), y = 0, time = 10)

/mob/living/proc/handle_high_gravity(gravity)
	if(gravity >= GRAVITY_DAMAGE_TRESHOLD) //Aka gravity values of 3 or more
		var/grav_stregth = gravity - GRAVITY_DAMAGE_TRESHOLD
		adjustBruteLoss(min(grav_stregth,3))
