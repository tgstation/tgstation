/datum/action/changeling/regenerate
	name = "Regenerate"
	desc = "Позволяет регенерировать и восстанавливать отсутствующие внешние конечности и жизненно важные внутренние органы, а также удалять осколки, заживлять серьезные раны и восстанавливать объем крови. Стоит 10 химикатов."
	helptext = "Оповестит ближайших членов экипажа о регенерации внешних конечностей. Можно использовать в бессознательном состоянии."
	button_icon_state = "regenerate"
	chemical_cost = 10
	dna_cost = CHANGELING_POWER_INNATE
	req_stat = HARD_CRIT

/datum/action/changeling/regenerate/sting_action(mob/living/user)
	if(!iscarbon(user))
		user.balloon_alert(user, "ничего не утеряно!")
		return FALSE

	..()
	to_chat(user, span_notice("Вы чувствуете зуд, как внутри, так и снаружи, когда ваши ткани плоти вяжутся и перевязываются."))
	var/mob/living/carbon/carbon_user = user
	var/got_limbs_back = length(carbon_user.get_missing_limbs()) >= 1
	carbon_user.fully_heal(HEAL_BODY)
	// Occurs after fully heal so the ling themselves can hear the sound effects (if deaf prior)
	if(got_limbs_back)
		playsound(user, 'sound/effects/magic/demon_consume.ogg', 50, TRUE)
		carbon_user.visible_message(
			span_warning("Отсутствующие конечности [user.declent_ru(GENITIVE)] срастаются, издавая громкий, жуткий звук!"),
			span_userdanger("Ваши конечности отрастают, издавая громкий хрустящий звук и причиняя вам сильную боль!"),
			span_hear("Вы слышите, как рвется и разрывается органическая масса!"),
		)
		carbon_user.emote("scream")

	return TRUE
