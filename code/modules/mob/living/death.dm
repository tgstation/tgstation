/**
 * Blow up the mob into giblets
 *
 * drop_bitflags: (see code/__DEFINES/blood.dm)
 * * DROP_BRAIN - Gibbed mob will drop a brain
 * * DROP_ORGANS - Gibbed mob will drop organs
 * * DROP_BODYPARTS - Gibbed mob will drop bodyparts (arms, legs, etc.)
 * * DROP_ITEMS - Gibbed mob will drop carried items (otherwise they get deleted)
 * * DROP_ALL_REMAINS - Gibbed mob will drop everything
**/
/mob/living/proc/gib(drop_bitflags=NONE)
	var/prev_lying = lying_angle
	spawn_gibs(drop_bitflags)

	if(!prev_lying)
		gib_animation()

	if(stat != DEAD)
		death(TRUE)

	ghostize()
	spill_organs(drop_bitflags)

	if(drop_bitflags & DROP_BODYPARTS)
		spread_bodyparts(drop_bitflags)

	SEND_SIGNAL(src, COMSIG_LIVING_GIBBED, drop_bitflags)
	qdel(src)

/mob/living/proc/gib_animation()
	return

/**
 * Spawn bloody gib mess on the floor
 *
 * drop_bitflags: (see code/__DEFINES/blood.dm)
 * * DROP_BODYPARTS - Gibs will spawn with bodypart limbs present
**/
/mob/living/proc/spawn_gibs(drop_bitflags=NONE)
	if(flags_1 & HOLOGRAM_1)
		return
	new /obj/effect/gibspawner/generic(drop_location(), src, get_static_viruses())

/**
 * Drops a mob's organs on the floor
 *
 * drop_bitflags: (see code/__DEFINES/blood.dm)
 * * DROP_BRAIN - Mob will drop a brain
 * * DROP_ORGANS - Mob will drop organs
 * * DROP_BODYPARTS - Mob will drop bodyparts (arms, legs, etc.)
 * * DROP_ALL_REMAINS - Mob will drop everything
**/
/mob/living/proc/spill_organs(drop_bitflags=NONE)
	return

/**
 * Launches all bodyparts away from the mob
 *
 * drop_bitflags: (see code/__DEFINES/blood.dm)
 * * DROP_BRAIN - Detaches the head from the mob and launches it away from the body
**/
/mob/living/proc/spread_bodyparts(drop_bitflags=NONE)
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
	if(body_position == STANDING_UP)
		// keep us upright so the animation fits.
		ADD_TRAIT(src, TRAIT_FORCED_STANDING, TRAIT_GENERIC)
	death(TRUE)

	if(drop_items)
		unequip_everything()

	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)

	dust_animation()
	spawn_dust(just_ash)
	ghostize()
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

	if(!gibbed && (death_sound || death_message))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "deathgasp")

	set_stat(DEAD)
	timeofdeath = world.time
	station_timestamp_timeofdeath = station_time_timestamp()
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
		client.player_details.time_of_death = timeofdeath

	return TRUE
