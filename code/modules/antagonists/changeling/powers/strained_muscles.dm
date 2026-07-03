//Strained Muscles: Temporary speed boost at the cost of rapid damage
//Limited because of space suits and such; ideally, used for a quick getaway

/datum/action/changeling/strained_muscles
	name = "Strained Muscles"
	desc = "Мы развиваем способность уменьшать накопление кислоты в наших мышцах, что позволяет нам двигаться гораздо быстрее."
	helptext = "Нагрузка вызовет у нас усталость, и мы быстро выдохнемся. Обычные ограничения по весу, как у космических скафандров, все еще действуют. Не может быть использовано в меньшей форме."
	button_icon_state = "strained_muscles"
	category = "utility"
	chemical_cost = 0
	dna_cost = 1
	req_human = TRUE
	var/stacks = 0 //Increments every 5 seconds; damage increases over time
	active = FALSE //Whether or not you are a hedgehog
	disabled_by_fire = FALSE

/datum/action/changeling/strained_muscles/sting_action(mob/living/carbon/user)
	..()
	active = !active
	if(active)
		to_chat(user, span_notice("Наши мышцы напрягаются и укрепляются."))
	else
		user.remove_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
		to_chat(user, span_notice("Наши мышцы расслабляются."))
		if(stacks >= 10)
			to_chat(user, span_danger("Мы падаем в изнеможении."))
			user.Paralyze(60)
			user.emote("gasp")

	INVOKE_ASYNC(src, PROC_REF(muscle_loop), user)

	return TRUE

/datum/action/changeling/strained_muscles/Remove(mob/user)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
	return ..()

/datum/action/changeling/strained_muscles/proc/muscle_loop(mob/living/carbon/user)
	while(active)
		if(QDELETED(src) || QDELETED(user))
			return

		user.add_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
		if(user.stat != CONSCIOUS || user.staminaloss >= 90)
			active = !active
			to_chat(user, span_notice("Наши мышцы расслабляются, не получая энергии для их укрепления."))
			user.Paralyze(40)
			user.remove_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
			break

		stacks++

		user.adjust_stamina_loss(stacks * 1.3) //At first the changeling may regenerate stamina fast enough to nullify fatigue, but it will stack

		if(stacks == 11) //Warning message that the stacks are getting too high
			to_chat(user, span_warning("Наши ноги начинают болеть..."))

		sleep(4 SECONDS)

	while(!active && stacks) //Damage stacks decrease fairly rapidly while not in sanic mode
		if(QDELETED(src) || QDELETED(user))
			return

		stacks--
		sleep(2 SECONDS)
