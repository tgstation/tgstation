/mob/living/blood_worm_host
	name = "Host"
	desc = "..как вообще это осматривать? У ЭТОЙ ТВАРИ ДАЖЕ НЕТ ТЕЛА!."

	var/datum/action/changeling_expel_worm/expel_worm_action

/mob/living/blood_worm_host/Login()
	. = ..()
	if (!.)
		return

	if (IS_CHANGELING(src))
		to_chat(src, span_good("Кровяной червь в вашем теле уязвим для ваших генетических особенностей!"))

		if (!expel_worm_action)
			expel_worm_action = new(src)
			expel_worm_action.Grant(src)
