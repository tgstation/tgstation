/datum/action/changeling/fleshmend
	name = "Fleshmend"
	desc = "Наша плоть быстро регенерирует, заживляя ожоги и ушибы, одышку, а также скрывая все шрамы. Стоит 20 химикатов."
	helptext = "Если мы находимся в огне, эффект лечения не действует. Не отращивает конечности и не восстанавливает потерянную кровь. Действует в бессознательном состоянии."
	button_icon_state = "fleshmend"
	category = "combat"
	chemical_cost = 20
	dna_cost = 2
	req_stat = HARD_CRIT

//Starts healing you every second for 10 seconds.
//Can be used whilst unconscious.
/datum/action/changeling/fleshmend/sting_action(mob/living/user)
	if(user.has_status_effect(/datum/status_effect/fleshmend))
		user.balloon_alert(user, "уже лечимся!")
		return
	..()
	to_chat(user, span_notice("Мы начинаем быстро выздоравливать."))
	user.apply_status_effect(/datum/status_effect/fleshmend)
	return TRUE

//Check buffs.dm for the fleshmend status effect code
