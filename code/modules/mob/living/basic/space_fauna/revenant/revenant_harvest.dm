// This file contains the proc we use for revenant harvesting because it is a very long and bulky proc that takes up a lot of space elsewhere

/// Container proc for `harvest()`, handles the pre-checks as well as potential early-exits for any reason.
/// Will return FALSE if we can't execute `harvest()`, or will otherwise the result of `harvest()`: a boolean value.
/mob/living/basic/revenant/proc/attempt_harvest(mob/living/carbon/human/target)
	if(LAZYFIND(drained_mobs, REF(target)))
		to_chat(src, span_revenwarning("Душа [target] мертва и пуста."))
		return FALSE

	if(!cast_check(0))
		return FALSE

	if(draining)
		to_chat(src, span_revenwarning("Вы уже вытягиваете эссенцию из души!"))
		return FALSE

	if(target.flags_1 & HOLOGRAM_1)
		target.balloon_alert(src, "не обладает душой!") // it's a machine generated visual
		return

	draining = TRUE
	var/value_to_return = harvest_soul(target)
	if(!value_to_return)
		log_combat(src, target, "остановил поглощение души")
	draining = FALSE

	return value_to_return

/// Harvest; activated by clicking a target, will try to drain their essence. Handles all messages and handling of the target.
/// Returns FALSE if we exit out of the harvest, TRUE if it is fully done.
/mob/living/basic/revenant/proc/harvest_soul(mob/living/carbon/human/target) // this isn't in the main revenant code file because holyyyy shit it's long
	if(QDELETED(target)) // what
		return FALSE

	// cache pronouns in case they get deleted as well as be a nice micro-opt due to the multiple times we use them
	//var/target_their = target.ru_p_them() // BANDASTATION REMOVAL
	//var/target_Their = target.p_Their() // BANDASTATION REMOVAL
	//var/target_Theyre = target.p_Theyre() // BANDASTATION REMOVAL
	//var/target_They_have = "[target.p_They()] [target.p_have()]" // BANDASTATION REMOVAL

	if(target.stat == CONSCIOUS)
		to_chat(src, span_revennotice("[capitalize(target.ru_p_them())] душа слишком сильна для поглощения."))
		if(prob(10))
			to_chat(target, span_revennotice("Вам кажется, что за вами наблюдают."))
		return FALSE

	log_combat(src, target, "started to harvest")
	face_atom(target)
	var/essence_drained = rand(15, 20)

	to_chat(src, span_revennotice("Вы ищете душу [target]."))

	if(!do_after(src, (rand(10, 20) DECISECONDS), target, timed_action_flags = IGNORE_HELD_ITEM)) //did they get deleted in that second?
		return FALSE

	var/target_has_client = !isnull(target.client)
	if(target_has_client || target.ckey) // any target that has been occupied with a ckey is considered "intelligent"
		to_chat(src, span_revennotice("[capitalize(target.ru_p_them())] душа пылает разумом."))
		essence_drained += rand(20, 30)

	if(target.stat != DEAD && !HAS_TRAIT(target, TRAIT_WEAK_SOUL))
		to_chat(src, span_revennotice("[capitalize(target.ru_p_them())] душа пылает жизнью!"))
		essence_drained += rand(40, 50)

	if(!target_has_client && HAS_TRAIT(target, TRAIT_WEAK_SOUL))
		to_chat(src, span_revennotice("[capitalize(target.ru_p_them())] душа слаба и неразвита. Они не будут стоить многого."))
		essence_drained = 5

	to_chat(src, span_revennotice("[capitalize(target.ru_p_them())] душа слаба и колеблется. Пришло время поглощать."))

	if(!do_after(src, (rand(15, 20) DECISECONDS), target, timed_action_flags = IGNORE_HELD_ITEM))
		to_chat(src, span_revennotice("Поглощение прервано."))
		return FALSE

	switch(essence_drained)
		if(1 to 30)
			to_chat(src, span_revennotice("[target] не принесёт особой пользы. Тем не менее, важна каждая мелочь."))
		if(30 to 70)
			to_chat(src, span_revennotice("[target] получится среднее количество эссенции."))
		if(70 to 90)
			to_chat(src, span_revenboldnotice("Пир для гурманов! [target] принесет вам много пользы."))
		if(90 to INFINITY)
			to_chat(src, span_revenbignotice("Ах, совершенная душа. [target] даст вам огромное количество эссенции."))

	if(!do_after(src, (rand(15, 25) DECISECONDS), target, timed_action_flags = IGNORE_HELD_ITEM)) //how about now
		to_chat(src, span_revenwarning("Вы недостаточно близко, чтобы проникнуть в душу [target ? "[target]" : "[target.ru_p_them()]"]. Связь прервана."))
		return FALSE

	if(target.stat == CONSCIOUS)
		to_chat(src, span_revenwarning("[capitalize(target.ru_p_they())] теперь достаточно силён, чтобы противостоять вашему поглощению!"))
		to_chat(target, span_bolddanger("Вы чувствуете, как что-то тянется по вашему телу, прежде чем утихнуть.")) //hey, wait a minute...
		return FALSE

	to_chat(src, span_revenminor("Вы начинаете поглощать эссенцию из души [target]."))
	if(target.stat != DEAD)
		to_chat(target, span_warning("Вы испытываете ужасно неприятное ощущение опустошения по мере того, как ваша хватка за жизнь ослабевает..."))
	if(target.stat == SOFT_CRIT)
		target.Stun(46)

	apply_status_effect(/datum/status_effect/revenant/revealed, 5 SECONDS)
	apply_status_effect(/datum/status_effect/incapacitating/paralyzed/revenant, 5 SECONDS)

	target.visible_message(span_warning("[target] внезапно слегка приподнимается в воздух, [target.ru_p_them()] кожа становится пепельно-серой."))

	if(target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		to_chat(src, span_revenminor("Что-то не так! [target], похоже, сопротивляется поглощению, оставляя вас уязвимым!"))
		target.visible_message(
			span_warning("[target] падает на землю."),
			span_revenwarning("Фиолетовые огни, танцующие в вашем поле зрения отсту--"),
		)
		return FALSE

	var/datum/beam/draining_beam = Beam(target, icon_state = "drain_life")
	if(!do_after(src, 4.6 SECONDS, target, timed_action_flags = (IGNORE_HELD_ITEM | IGNORE_INCAPACITATED))) //As one cannot prove the existence of ghosts, ghosts cannot prove the existence of the target they were draining.
		to_chat(src, span_revenwarning("[target ? "Душа [target]" : "[target.ru_p_them()]"] была вырвана из ваших объятий. Связь разорвана."))
		if(target)
			target.visible_message(
				span_warning("[target] падает на землю."),
				span_revenwarning("Фиолетовые огни, танцующие в вашем поле зрения отсту--"),
			)
		qdel(draining_beam)
		return FALSE

	change_essence_amount(essence_drained, FALSE, target)

	if(essence_drained <= 90 && target.stat != DEAD && !HAS_TRAIT(target, TRAIT_WEAK_SOUL))
		max_essence += 5
		to_chat(src, span_revenboldnotice("Поглощение живой души [target] повысило ваш максимальный уровень эссенции. Ваша новая максимальная эссенция - [max_essence]."))

	if(essence_drained > 90)
		max_essence += 15
		perfectsouls++
		to_chat(src, span_revenboldnotice("Совершенство души [target] повысило ваш максимальный уровень эссенции. Ваша новая максимальная эссенции - [max_essence]."))

	to_chat(src, span_revennotice("Душа [target] значительно ослаблена и в настоящее время больше не будет давать эссенции."))
	target.visible_message(
		span_warning("[target] падает на землю."),
		span_revenwarning("Фиолетовый свет, танцующий перед глазами, приближа--"),
	)

	LAZYADD(drained_mobs, REF(target))
	if(target.stat != DEAD)
		target.investigate_log("has died from revenant harvest.", INVESTIGATE_DEATHS)
	target.death(FALSE)

	qdel(draining_beam)
	return TRUE
