/datum/mafia_role/fugitive
	name = "Беглец"
	desc = "Вы в бегах. Вы можете использовать жилет дважды, чтобы стать неуязвимым на одну ночь. Вы победите, если доживете до конца игры с кем угодно."
	win_condition = "доживет до конца игры с кем угодно."
	revealed_outfit = /datum/outfit/mafia/fugitive
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_DISRUPT
	special_ui_theme = "neutral"
	hud_icon = "hudfugitive"
	revealed_icon = "fugitive"
	winner_award = /datum/award/achievement/mafia/fugitive

	role_unique_actions = list(/datum/mafia_ability/vest)

/datum/mafia_role/fugitive/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game, COMSIG_MAFIA_GAME_END, PROC_REF(survived))

/datum/mafia_role/fugitive/proc/survived(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(game_status == MAFIA_ALIVE)
		game.award_role(winner_award, src)
		game.send_message("<span class='big comradio'>!! ПОБЕДА БЕГЛЕЦА !!</span>")
