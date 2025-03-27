///A component added to the mind of anyone who is playing in an ongoing CTF match. Any player specific CTF functionality should be implemented here. (someone should implement score tracking here)
/datum/component/ctf_player
	///The team that this player is associated with.
	var/team
	///A reference to the players mob, cleared after they die, restored on respawn.
	var/mob/living/player_mob
	///Weather or not the player is currently able to respawn.
	var/can_respawn = TRUE
	///Reference to the game this player is participating in.
	var/datum/ctf_controller/ctf_game
	///Item dropped on death,
	var/death_drop = /obj/effect/powerup/ammo/ctf
	///Reference to players ckey, used for sending messages to them relating to CTF.
	var/ckey_reference

/datum/component/ctf_player/Initialize(team, ctf_game, death_drop)
	src.team = team
	src.ctf_game = ctf_game
	src.death_drop = death_drop
	if(!istype(parent, /datum/mind))
		return COMPONENT_INCOMPATIBLE
	var/datum/mind/true_parent = parent
	player_mob = true_parent.current
	ckey_reference = player_mob.ckey
	register_mob()

/datum/component/ctf_player/PostTransfer(datum/new_parent)
	if(!istype(new_parent, /datum/mind))
		return COMPONENT_INCOMPATIBLE
	var/datum/mind/true_parent = new_parent
	player_mob = true_parent.current
	register_mob()

/// Called when we get a new player mob, register signals and set up the mob.
/datum/component/ctf_player/proc/register_mob()
	RegisterSignal(player_mob, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(damage_type_check))
	RegisterSignal(player_mob, COMSIG_MOB_GHOSTIZED, PROC_REF(ctf_dust))
	ADD_TRAIT(player_mob, TRAIT_PERMANENTLY_MORTAL, CTF_TRAIT)

///Stamina and oxygen damage will not dust a player by themself.
/datum/component/ctf_player/proc/damage_type_check(datum/source, damage, damage_type)
	SIGNAL_HANDLER
	if(damage_type != STAMINA && damage_type != OXY)
		ctf_dust()

///Dusts the player and starts a respawn countdown.
/datum/component/ctf_player/proc/ctf_dust()
	SIGNAL_HANDLER
	if(!HAS_TRAIT(player_mob, TRAIT_CRITICAL_CONDITION) && !player_mob.stat == DEAD && player_mob.client)
		return
	UnregisterSignal(player_mob, list(COMSIG_MOB_AFTER_APPLY_DAMAGE, COMSIG_MOB_GHOSTIZED))
	var/turf/death_turf = get_turf(player_mob)
	player_mob.dust()
	player_mob = null
	can_respawn = FALSE
	addtimer(CALLBACK(src, PROC_REF(allow_respawns)), ctf_game.respawn_cooldown, TIMER_UNIQUE)
	if(death_drop)
		new death_drop(death_turf)

///Called after a period of time pulled from ctf_game, allows the player to respawn in CTF.
/datum/component/ctf_player/proc/allow_respawns()
	can_respawn = TRUE
	send_message(span_notice("You can now respawn in CTF!"))

///Sends a message to the player.
/datum/component/ctf_player/proc/send_message(message)
	to_chat(GLOB.directory[ckey_reference], message)

///Called when the associated CTF game ends or their associated team is deleted, dusts the player and deletes this component to ensure no data from it is carried over to future games.
/datum/component/ctf_player/proc/end_game()
	if(player_mob)
		for(var/obj/item/ctf_flag/flag in player_mob)
			player_mob.dropItemToGround(flag)
		player_mob.dust()
	qdel(src)

/datum/component/ctf_player/Destroy(force)
	if(player_mob)
		UnregisterSignal(player_mob, list(COMSIG_MOB_AFTER_APPLY_DAMAGE, COMSIG_MOB_GHOSTIZED))
	return ..()
