/datum/action/changeling/resonant_shriek
	name = "Resonant Shriek"
	desc = "Наши легкие и голосовые связки смещаются, позволяя нам на короткое время издать звук, который оглушает и сбивает с толку не-генокрадов. \
		Идеально для остановки побега жертвы. Плохо работает в вакууме. Стоит 20 химикатов."
	helptext = "Излучает высокочастотный звук, который сбивает с толку и оглушает людей, выбивает свет и перегружает сенсоры киборгов."
	button_icon_state = "resonant_shriek"
	category = "combat"
	chemical_cost = 20
	dna_cost = 1
	req_human = TRUE
	disabled_by_fire = FALSE

//A flashy ability, good for crowd control and sowing chaos.
/datum/action/changeling/resonant_shriek/sting_action(mob/user)
	..()
	if(user.movement_type & VENTCRAWLING)
		user.balloon_alert(user, "не можем кричать в трубах!")
		return FALSE
	playsound(user, 'sound/effects/screech.ogg', 100)
	for(var/mob/living/living in get_hearers_in_view(4, user))
		if(IS_CHANGELING(living) || !living.soundbang_act(SOUNDBANG_MASSIVE, stun_pwr = 0, damage_pwr = 0, deafen_pwr = 1 MINUTES, ignore_deafness = TRUE, send_sound = FALSE))
			continue
		if(issilicon(living))
			living.Paralyze(rand(10 SECONDS, 20 SECONDS))
			continue
		living.adjust_confusion(25 SECONDS)
		living.set_jitter_if_lower(100 SECONDS)

	for(var/obj/machinery/light/light in range(4, user))
		light.on = TRUE
		light.break_light_tube()
		stoplag()
	return TRUE

/datum/action/changeling/dissonant_shriek
	name = "Technophagic Shriek"
	desc = "Мы смещаем голосовые связки, чтобы выпустить высокочастотный звук, который перегружает близлежащую электронику. Ломает наушники и камеры, а так же, иногда ломает лазерное оружие, двери и модсьюты. Стоит 20 химикатов."
	button_icon_state = "technophagic_shriek"
	category = "combat"
	chemical_cost = 20
	dna_cost = 1
	disabled_by_fire = FALSE

/datum/action/changeling/dissonant_shriek/sting_action(mob/user)
	..()
	if(user.movement_type & VENTCRAWLING)
		user.balloon_alert(user, "не можем кричать в трубах!")
		return FALSE
	empulse(get_turf(user), 2, 5, 1, emp_source = src)
	for(var/obj/machinery/light/L in range(5, usr))
		L.on = TRUE
		L.break_light_tube()
		stoplag()

	return TRUE
