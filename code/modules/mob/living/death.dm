/mob/living/gib(no_brain, no_organs, no_bodyparts)
	var/prev_lying = lying
	if(stat != DEAD)
		death(1)

	if(!prev_lying)
		gib_animation()

	spill_organs(no_brain, no_organs, no_bodyparts)

	if(!no_bodyparts)
		spread_bodyparts(no_brain, no_organs)

	spawn_gibs(no_bodyparts)
	qdel(src)

/mob/living/proc/gib_animation()
	return

/mob/living/proc/spawn_gibs()
	new /obj/effect/gibspawner/generic(drop_location(), null, get_static_viruses())

/mob/living/proc/spill_organs()
	return

/mob/living/proc/spread_bodyparts()
	return

/mob/living/dust(just_ash = FALSE)
	death(1)

	if(buckled)
		buckled.unbuckle_mob(src,force=1)

	dust_animation()
	spawn_dust(just_ash)
	QDEL_IN(src,5) // since this is sometimes called in the middle of movement, allow half a second for movement to finish, ghosting to happen and animation to play. Looks much nicer and doesn't cause multiple runtimes.

/mob/living/proc/dust_animation()
	return

/mob/living/proc/spawn_dust(just_ash = FALSE)
	new /obj/effect/decal/cleanable/ash(loc)


/mob/living/death(gibbed)
	if(client)
		to_chat(src,"<font color='red' size='3'><B>You have died.</B></font>")
		if(GLOB && istype(GLOB.Player_Client_Cache,/list))
			var/datum/client_cache/cache = GLOB.Player_Client_Cache[client.ckey]
			var/cacheentry = "Informed_To_Adminhelp_Grief"
			if(istype(cache) && istype(cache.warnings_experienced,/list) && !(cacheentry in cache.warnings_experienced))
				cache.warnings_experienced += cacheentry
				client.inform_to_adminhelp_death()
	stat = DEAD
	var/alert_ssd = null
	if(!client)
		if(ckey)
			alert_ssd = ckey
		else if(mind)
			for(var/mob/dead/observer/O in GLOB.player_list)
				if(O.mind == mind && O.ckey)
					alert_ssd = O.ckey
					break
		if(alert_ssd)
			message_admins("An SSD player has died. [real_name]([alert_ssd])")
			log_game("An SSD player has died. [real_name]([alert_ssd])")
			log_attack("An SSD player has died. [real_name]([alert_ssd])")
	unset_machine()
	timeofdeath = world.time
	tod = station_time_timestamp()
	var/turf/T = get_turf(src)
	for(var/obj/item/I in contents)
		I.on_mob_death(src, gibbed)
	if(mind && mind.name && mind.active && (!(T.flags_1 & NO_DEATHRATTLE_1)))
		var/rendered = "<span class='deadsay'><b>[mind.name]</b> has died at <b>[get_area_name(T)]</b>.</span>"
		deadchat_broadcast(rendered, follow_target = src, turf_target = T, message_type=DEADCHAT_DEATHRATTLE)
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)
	GLOB.alive_mob_list -= src
	if(!gibbed)
		GLOB.dead_mob_list += src
	set_drugginess(0)
	set_disgust(0)
	SetSleeping(0, 0)
	blind_eyes(1)
	reset_perspective(null)
	reload_fullscreen()
	update_action_buttons_icon()
	update_damage_hud()
	update_health_hud()
	update_canmove()
	med_hud_set_health()
	med_hud_set_status()
	stop_pulling()

	if (client)
		client.move_delay = initial(client.move_delay)

	for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerDies(gibbed)
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerDies(gibbed)

	return TRUE
