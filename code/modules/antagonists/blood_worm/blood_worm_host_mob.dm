/mob/living/blood_worm_host
	name = "Host"
	desc = "...how are you examining this? THIS THING ISN'T EVEN EMBODIED."

	var/datum/action/changeling_expel_worm/expel_worm_action

/mob/living/blood_worm_host/Login()
	. = ..()
	if (!.)
		return

	if (IS_CHANGELING(src))
		to_chat(src, span_good("The blood worm in your body is vulnerable to your genetic prowess!"))

		if (!expel_worm_action)
			expel_worm_action = new(src)
			expel_worm_action.Grant(src)
