
//==================================//
// !            Kindle            ! //
//==================================//
/datum/clockcult/scripture/slab/kindle
	name = "Разжечь"
	desc = "Оглушает и приглушает цель с близкого расстояния. Значительно менее эффективен на Риби."
	tip = "Оглушает и приглушает цель с близкого расстояния."
	button_icon_state = "Kindle"
	power_cost = 125
	invokation_time = 30
	invokation_text = list("Божественность, покажи им свой свет!")
	after_use_text = "Позвольте энергии течь сквозь вас!"
	slab_overlay = "volt"
	use_time = 150
	category = SPELLTYPE_SERVITUDE

/datum/clockcult/scripture/slab/kindle/apply_effects(atom/A)
	var/mob/living/M = A
	if(!istype(M))
		return FALSE
	if(!is_servant_of_ratvar(invoker))
		M = invoker
	if(is_servant_of_ratvar(M))
		return FALSE
	//Anti magic abilities
	if(M.can_block_magic(MAGIC_RESISTANCE))
		M.mob_light(_color = LIGHT_COLOR_HOLY_MAGIC, _range = 2, _duration = 100)
		var/mutable_appearance/forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
		M.add_overlay(forbearance)
		addtimer(CALLBACK(M, /atom/proc/cut_overlay, forbearance), 100)
		M.visible_message(span_warning("[M] просто смотрит, как поток энергии пролетает мимо него.") , \
									   span_userdanger("Ощущаю как вокруг меня пролетают обрывки энергии."))
		playsound(invoker, 'sound/magic/mm_hit.ogg', 50, TRUE)
		return TRUE
	//Blood Cultist Effect
	if(IS_CULTIST(M))
		M.mob_light(_color = LIGHT_COLOR_BLOOD_MAGIC, _range = 2, _duration = 300)
		M.adjust_stutter(15 SECONDS)
		M.adjust_jitter(15 SECONDS)
		var/mob_color = M.color
		M.color = LIGHT_COLOR_BLOOD_MAGIC
		animate(M, color = mob_color, time = 300)
		M.say("Fwebar uloft'gib mirlig yro'fara!")
		to_chat(invoker, span_brass("Не вышло остановить [M]!"))
		playsound(invoker, 'sound/magic/mm_hit.ogg', 50, TRUE)
		return TRUE
	//Successful Invokation
	invoker.mob_light(_color = LIGHT_COLOR_CLOCKWORK, _range = 2, _duration = 10)
	if(!is_reebe(invoker.z))
		if(!HAS_TRAIT(M, TRAIT_MINDSHIELD))
			M.Paralyze(150)
		else
			to_chat(invoker, span_brass("[M] кажется несколько устойчивым к моим силам!"))
			M.adjust_confusion(5 SECONDS)
			M.adjust_silence(5 SECONDS)
	if(issilicon(M))
		var/mob/living/silicon/S = M
		S.emp_act(EMP_HEAVY)
	else if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.adjust_silence(6 SECONDS)
		C.adjust_stutter(15 SECONDS)
		C.adjust_jitter(15 SECONDS)
	if(M.client)
		var/client_color = M.client.color
		M.client.color = "#BE8700"
		animate(M.client, color = client_color, time = 25)
	playsound(invoker, 'sound/magic/staff_animation.ogg', 50, TRUE)
	return TRUE
