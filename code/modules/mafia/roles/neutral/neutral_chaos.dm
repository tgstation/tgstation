/datum/mafia_role/obsessed
	name = "Obsessed"
	desc = "Lynch your obsession before you get killed at all costs!"
	win_condition = "lynch their obsession."
	revealed_outfit = /datum/outfit/mafia/obsessed
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_DISRUPT
	special_ui_theme = "neutral"
	hud_icon = "hudobsessed"
	revealed_icon = "obsessed"

	winner_award = /datum/award/achievement/mafia/obsessed
	///The person the obsessed has to get lynched in order to win.
	var/datum/mafia_role/obsession

/datum/mafia_role/obsessed/New(datum/mafia_controller/game) //note: obsession is always a townie
	. = ..()
	desc = initial(desc) + " Obsessions are assigned on the first night."
	RegisterSignal(game, COMSIG_MAFIA_SUNDOWN, PROC_REF(find_obsession))

/datum/mafia_role/obsessed/proc/find_obsession(datum/mafia_controller/game)
	SIGNAL_HANDLER

	var/list/all_roles_shuffle = shuffle(game.living_roles) - src
	for(var/datum/mafia_role/possible as anything in all_roles_shuffle)
		if(possible.team & MAFIA_TEAM_TOWN)
			obsession = possible
			break
	if(!obsession)
		obsession = pick(all_roles_shuffle) //okay no town just pick anyone here
	desc = initial(desc) + " Target: [obsession.body.real_name]"
	var/obj/item/modular_computer/modpc = player_pda
	if(modpc)
		modpc.update_static_data_for_all_viewers()
	else
		game.update_static_data(body)
	send_message_to_player(span_userdanger("Your obsession is [obsession.body.real_name]! Get them lynched to win!"))
	RegisterSignal(obsession, COMSIG_MAFIA_ON_KILL, PROC_REF(check_victory))
	UnregisterSignal(game, COMSIG_MAFIA_SUNDOWN)

/datum/mafia_role/obsessed/proc/check_victory(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MAFIA_ON_KILL)
	if(game_status == MAFIA_DEAD)
		return
	if(lynch)
		game.send_message("<span class='big comradio'>!! OBSESSED VICTORY !!</span>")
		game.award_role(winner_award, src)
		reveal_role(game, FALSE)
	else
		to_chat(body, span_userdanger("You have failed your objective to lynch [obsession.body.real_name]!"))

/datum/mafia_role/clown
	name = "Clown"
	desc = "If you are lynched you take down one of your voters (guilty or abstain) with you and win. HONK!"
	win_condition = "get themselves lynched!"
	revealed_outfit = /datum/outfit/mafia/clown
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_DISRUPT
	special_ui_theme = "neutral"
	hud_icon = SECHUD_CLOWN
	revealed_icon = "clown"
	winner_award = /datum/award/achievement/mafia/clown

/datum/mafia_role/clown/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(src, COMSIG_MAFIA_ON_KILL, PROC_REF(prank))

/datum/mafia_role/clown/proc/prank(datum/source,datum/mafia_controller/game, datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	if(lynch)
		var/datum/mafia_role/victim = pick(game.judgement_guilty_votes + game.judgement_abstain_votes)
		game.send_message("<span class='big clown'>[body.real_name] WAS A CLOWN! HONK! They take down [victim.body.real_name] with their last prank.</span>")
		game.send_message("<span class='big clown'>!! CLOWN VICTORY !!</span>")
		game.award_role(winner_award, src)
		victim.kill(game, FALSE)
