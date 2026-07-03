/datum/antagonist/rev/on_gain()
	objectives |= rev_team.objectives
	. = ..()

/datum/antagonist/rev/on_removal()
	. = ..()
	objectives -= rev_team.objectives

/datum/team/revolution/proc/check_size()
	if(rev_ascendent)
		return

#ifndef UNIT_TESTS
	var/alive = 0
	var/revplayers = 0
	for(var/I in GLOB.player_list)
		var/mob/M = I
		if(M.stat != DEAD)
			if(IS_REVOLUTIONARY(M))
				++revplayers
			else
				++alive

	ASSERT(revplayers) //we shouldn't be here.

	var/highpop_thresold_reached = alive >= REV_HIGHPOP_THRESHOLD
	var/rev_ascended_threshold = highpop_thresold_reached ? REV_ASCENDENT_HIGHPOP : REV_ASCENDENT_LOWPOP
	var/ratio = alive ? revplayers / alive : 1

	if(ratio >= rev_ascended_threshold && !rev_ascendent)
		for(var/datum/mind/mind as anything in members)
			if(mind.current)
				SEND_SOUND(mind.current, sound('sound/music/antag/traitor/final_objective.ogg'))
				to_chat(mind.current, span_userdanger(span_warning("Ваше революционное движение набирает силу. Сотрудникам службы безопасности и командованию станции известно о вашей активности. \
				Пора начинать действовать!")))
		rev_ascendent = TRUE
		priority_announce(
			text = "Мы фиксируем антикорпоративные настроения связанные с действиями мятежников на вашей станции. \
				Согласно нашим данным, [floor(ratio * 100)]% экипажа станции присоединились к мятежникам. \
				Сотрудники службы безопасности наделены полномочиями применять летальную силу против мятежников. \
				Остальному экипажу надлежит сотрудничать с сотрудниками службы безопасности для защиты себя и своих отделов, не ведя охоту на мятежников. \
				Члены экипажа примкнувшие в ряды мятежников, должны быть арестованы и перевоспитаны для восстановления лояльности к корпорации. \
				Пострадавшим членам экипажа должна быть оказана медицинская помощь, как только ситуация на станции будет стабилизирована.",
			title = "[command_name()]: Отдел мониторинга лояльности",
			sound = SSstation.announcer.get_rand_report_sound(),
			has_important_message = TRUE,
		)
		log_game("The revolution has reached its peak with [revplayers] players.")
#endif
