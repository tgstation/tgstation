/**
 * Blow up the mob into giblets
 *
 * Arguments:
 * * no_brain - Should the mob NOT drop a brain?
 * * no_organs - Should the mob NOT drop organs?
 * * no_bodyparts - Should the mob NOT drop bodyparts?
*/
/mob/living/proc/gib(no_brain, no_organs, no_bodyparts)
	var/prev_lying = lying_angle
	if(stat != DEAD)
		death(TRUE)

	if(!prev_lying)
		gib_animation()

	spill_organs(no_brain, no_organs, no_bodyparts)

	if(!no_bodyparts)
		spread_bodyparts(no_brain, no_organs)

	spawn_gibs(no_bodyparts)
	SEND_SIGNAL(src, COMSIG_LIVING_GIBBED, no_brain, no_organs, no_bodyparts)
	qdel(src)

/mob/living/proc/gib_animation()
	return

/mob/living/proc/spawn_gibs()
	new /obj/effect/gibspawner/generic(drop_location(), src, get_static_viruses())

/mob/living/proc/spill_organs()
	return

/mob/living/proc/spread_bodyparts()
	return

/**
 * This is the proc for turning a mob into ash.
 * Dusting robots does not eject the MMI, so it's a bit more powerful than gib()
 *
 * Arguments:
 * * just_ash - If TRUE, ash will spawn where the mob was, as opposed to remains
 * * drop_items - Should the mob drop their items before dusting?
 * * force - Should this mob be FORCABLY dusted?
*/
/mob/living/proc/dust(just_ash, drop_items, force)
	death(TRUE)

	if(drop_items)
		unequip_everything()

	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)

	dust_animation()
	spawn_dust(just_ash)
	QDEL_IN(src,5) // since this is sometimes called in the middle of movement, allow half a second for movement to finish, ghosting to happen and animation to play. Looks much nicer and doesn't cause multiple runtimes.

/mob/living/proc/dust_animation()
	return

/mob/living/proc/spawn_dust(just_ash = FALSE)
	new /obj/effect/decal/cleanable/ash(loc)

/*
 * Called when the mob dies. Can also be called manually to kill a mob.
 *
 * Arguments:
 * * gibbed - Was the mob gibbed?
*/
/mob/living/proc/death(gibbed)
	if(stat == DEAD)
		return FALSE

	set_stat(DEAD)
	unset_machine()
	timeofdeath = world.time
	tod = station_time_timestamp()
	var/turf/death_turf = get_turf(src)
	var/area/death_area = get_area(src)
	// Display a death message if the mob is a player mob (has an active mind)
	var/player_mob_check = mind && mind.name && mind.active
	// and, display a death message if the area allows it (or if they're in nullspace)
	var/valid_area_check = !death_area || !(death_area.area_flags & NO_DEATH_MESSAGE)
	if(player_mob_check && valid_area_check)
		deadchat_broadcast(" has died at <b>[get_area_name(death_turf)]</b>.", "<b>[mind.name]</b>", follow_target = src, turf_target = death_turf, message_type=DEADCHAT_DEATHRATTLE)
		if(SSlag_switch.measures[DISABLE_DEAD_KEYLOOP] && !client?.holder)
			to_chat(src, span_deadsay(span_big("Observer freelook is disabled.\nPlease use Orbit, Teleport, and Jump to look around.")))
			ghostize(TRUE)
	set_disgust(0)
	SetSleeping(0, 0)
	reset_perspective(null)
	reload_fullscreen()
	update_mob_action_buttons()
	update_damage_hud()
	update_health_hud()
	med_hud_set_health()
	med_hud_set_status()
	stop_pulling()

	SEND_SIGNAL(src, COMSIG_LIVING_DEATH, gibbed)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_DEATH, src, gibbed)

	if (client)
		client.move_delay = initial(client.move_delay)

	if(!gibbed && (death_sound || death_message))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "deathgasp")

	return TRUE
