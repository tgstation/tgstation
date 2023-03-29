//Remember to comment
/datum/component/ctf_player
	var/team
	var/mob/living/player_mob
	var/can_respawn = TRUE
	var/datum/ctf_controller/ctf_game
	var/death_drop = /obj/effect/powerup/ammo/ctf

/datum/component/ctf_player/Initialize(team, ctf_game, death_drop)
	src.team = team
	src.ctf_game = ctf_game
	src.death_drop = death_drop
	var/datum/mind/true_parent = parent
	player_mob = true_parent.current
	if(!istype(parent, /datum/mind))
		return COMPONENT_INCOMPATIBLE
	setup_dusting()
	
/datum/component/ctf_player/PostTransfer()
	if(!istype(parent, /datum/mind))
		return COMPONENT_INCOMPATIBLE
	var/datum/mind/true_parent = parent
	player_mob = true_parent.current
	setup_dusting()

/datum/component/ctf_player/proc/setup_dusting()
	//Todo, check if the victim is actually a ctf participant just incase
	RegisterSignal(player_mob, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(ctf_dust))
	RegisterSignal(player_mob, COMSIG_MOB_GHOSTIZED, PROC_REF(ctf_dust))

/datum/component/ctf_player/proc/ctf_dust()
	SIGNAL_HANDLER

	//Todo, ignore oxy/stam damage as funny as it is for the shotgun class to die from exaustion
	if(HAS_TRAIT(player_mob, TRAIT_CRITICAL_CONDITION) || player_mob.stat == DEAD || !player_mob.client)
		UnregisterSignal(player_mob, list(COMSIG_MOB_AFTER_APPLY_DAMAGE, COMSIG_MOB_GHOSTIZED))
		var/turf/death_turf = get_turf(player_mob)
		player_mob.dust()
		player_mob = null
		can_respawn = FALSE
		addtimer(CALLBACK(src, PROC_REF(allow_respawns)), ctf_game.respawn_cooldown, TIMER_UNIQUE)
		if(death_drop)
			new death_drop(death_turf)

/datum/component/ctf_player/proc/allow_respawns()
	can_respawn = TRUE
	send_message(span_notice("You can now respawn in CTF!"))

/datum/component/ctf_player/proc/send_message(message)
	to_chat(parent, message)

/datum/component/ctf_player/proc/end_game()
	if(player_mob)
		for(var/obj/item/ctf_flag/flag in player_mob)
			player_mob.dropItemToGround(flag)
		player_mob.dust()
	qdel(src)

/datum/component/ctf_player/Destroy(force, silent)
	if(player_mob)
		UnregisterSignal(player_mob, list(COMSIG_MOB_AFTER_APPLY_DAMAGE, COMSIG_MOB_GHOSTIZED))
	return ..()
	