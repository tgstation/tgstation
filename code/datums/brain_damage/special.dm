//Brain traumas that are rare and/or somewhat beneficial;
//they are the easiest to cure, which means that if you want
//to keep them, you can't cure your other traumas
/datum/brain_trauma/special
	abstract_type = /datum/brain_trauma/special

/datum/brain_trauma/special/godwoken
	name = "Синдром пробужденного Бога"
	desc = "Время от времени пациент неконтролируемо транслирует речь древнего бога."
	scan_desc = "божественная иллюзия"
	symptoms = "Occasionally utters phrases or commands in a commanding tone, often accompanied by a sense of divine authority. \
		These utterances can influence the behavior of others, compelling them to act in accordance with the spoken words."
	gain_text = span_notice("Вы чувствуете высшую силу внутри своего разума...")
	lose_text = span_warning("Божественное присутствие покидает вашу голову, потеряв интерес.")

/datum/brain_trauma/special/godwoken/on_life(seconds_per_tick)
	..()
	if(SPT_PROB(2, seconds_per_tick))
		if(prob(33) && (owner.IsStun() || owner.IsParalyzed() || owner.IsUnconscious()))
			speak("unstun", TRUE)
		else if(prob(60) && owner.health <= owner.crit_threshold)
			speak("heal", TRUE)
		else if(prob(30) && owner.combat_mode)
			speak("aggressive")
		else
			speak("neutral", prob(25))

/datum/brain_trauma/special/godwoken/on_gain()
	ADD_TRAIT(owner, TRAIT_HOLY, TRAUMA_TRAIT)
	. = ..()

/datum/brain_trauma/special/godwoken/on_lose()
	REMOVE_TRAIT(owner, TRAIT_HOLY, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/special/godwoken/proc/speak(type, include_owner = FALSE)
	var/message
	switch(type)
		if("unstun")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_unstun")
		if("heal")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_heal")
		if("neutral")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_neutral")
		if("aggressive")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_aggressive")
		else
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_neutral")

	playsound(get_turf(owner), 'sound/effects/magic/clockwork/invoke_general.ogg', 200, TRUE, 5)
	voice_of_god(message, owner, list("colossus","yell"), 2.5, include_owner, name, TRUE)

/datum/brain_trauma/special/bluespace_prophet
	name = "Блюспейс пророчество"
	desc = "Пациент может ощущать колебания и переплетения блюспейса вокруг себя, показывающего проходы, которые никто другой не может увидеть."
	scan_desc = "bluespace attunement"
	symptoms = "Gains the ability to perceive hidden pathways through bluespace, allowing for spontaneous creation of temporary portals \
		that connect two distant locations. To the average eye, the patient appears to disappear into thin air, only to reappear elsewhere nearby."
	gain_text = span_notice("Вы чувствуете, как блюспейс пульсирует вокруг тебя...")
	lose_text = span_warning("Слабая пульсация блюспейса сменяется тишиной.")
	/// Cooldown so we can't teleport literally everywhere on a whim
	COOLDOWN_DECLARE(portal_cooldown)

/datum/brain_trauma/special/bluespace_prophet/on_life(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, portal_cooldown))
		return

	COOLDOWN_START(src, portal_cooldown, 10 SECONDS)
	var/list/turf/possible_turfs = list()
	for(var/turf/T as anything in RANGE_TURFS(8, owner))
		if(T.density)
			continue

		var/clear = TRUE
		for(var/obj/O in T)
			if(O.density)
				clear = FALSE
				break
		if(clear)
			possible_turfs += T

	if(!LAZYLEN(possible_turfs))
		return

	var/turf/first_turf = pick(possible_turfs)
	if(!first_turf)
		return

	possible_turfs -= (possible_turfs & range(first_turf, 3))

	var/turf/second_turf = pick(possible_turfs)
	if(!second_turf)
		return

	var/obj/effect/client_image_holder/bluespace_stream/first = new(first_turf, owner)
	var/obj/effect/client_image_holder/bluespace_stream/second = new(second_turf, owner)

	first.linked_to = second
	second.linked_to = first

/obj/effect/client_image_holder/bluespace_stream
	name = "bluespace stream"
	desc = "Вы видите скрытый проход через блюспейс..."
	image_icon = 'icons/effects/effects.dmi'
	image_state = "bluestream"
	image_layer = ABOVE_MOB_LAYER
	var/obj/effect/client_image_holder/bluespace_stream/linked_to

/obj/effect/client_image_holder/bluespace_stream/Initialize(mapload, list/mobs_which_see_us)
	. = ..()
	QDEL_IN(src, 30 SECONDS)

/obj/effect/client_image_holder/bluespace_stream/generate_image()
	. = ..()
	apply_wibbly_filters(.)

/obj/effect/client_image_holder/bluespace_stream/Destroy()
	if(!QDELETED(linked_to))
		qdel(linked_to)
	linked_to = null
	return ..()

/obj/effect/client_image_holder/bluespace_stream/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!(user in who_sees_us) || !linked_to)
		return

	var/slip_in_message = pick("странным образом скользит в сторону и исчезает", "прыгает в невидимое измерение",\
		"вытягивает одну ногу прямо, шевелит своей ногой и внезапно исчезает", "останавливается, затем исчезает из реальности", \
		"затягивается в невидимый вихрь, исчезая из виду")
	var/slip_out_message = pick("бесшумно появляется из ниоткуда", "выпрыгивает из воздуха","появляется", "выходит из невидимого дверного проема",\
		"выскальзывает из складки пространства-времени")

	to_chat(user, span_notice("Вы пытаетесь приспособиться к потоку блюспейса..."))
	if(!do_after(user, 2 SECONDS, target = src))
		return

	var/turf/source_turf = get_turf(src)
	var/turf/destination_turf = get_turf(linked_to)

	new /obj/effect/temp_visual/bluespace_fissure(source_turf)
	new /obj/effect/temp_visual/bluespace_fissure(destination_turf)

	user.visible_message(span_warning("[user] [slip_in_message]."), ignored_mobs = user)

	if(do_teleport(user, destination_turf, no_effects = TRUE))
		user.visible_message(span_warning("[user] [slip_out_message]."), span_notice("...и найти дорогу на другую сторону."))
	else
		user.visible_message(span_warning("[user] [slip_out_message], оказавшись точно там же, откуда ушли."), span_notice("...и окажетесь там, где начали?"))


/obj/effect/client_image_holder/bluespace_stream/attack_tk(mob/user)
	to_chat(user, span_warning("\The [src] actively rejects your mind, and the bluespace energies surrounding it disrupt your telekinesis!"))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/brain_trauma/special/quantum_alignment
	name = "Квантовое выравнивание"
	desc = "Пациент склонен к частой спонтанной квантовой запутанности, вопреки всем обстоятельствам, что приводит к пространственным аномалиям."
	scan_desc = "квантовое выравнивание"
	symptoms = "Frequently experiences spontaneous quantum entanglement with nearby objects or beings, \
		resulting in sudden and unpredictable teleportation events that connect the patient to the entangled target."
	gain_text = span_notice("Вы чувствуете слабую связь со всем, что вас окружает...")
	lose_text = span_warning("Вы больше не чувствуете связи со своим окружением.")
	var/atom/linked_target = null
	var/linked = FALSE
	var/returning = FALSE
	/// Cooldown for snapbacks
	COOLDOWN_DECLARE(snapback_cooldown)

/datum/brain_trauma/special/quantum_alignment/on_life(seconds_per_tick)
	if(linked)
		if(QDELETED(linked_target))
			linked_target = null
			linked = FALSE
			return
		if(!returning && COOLDOWN_FINISHED(src, snapback_cooldown))
			start_snapback()
		return
	if(SPT_PROB(2, seconds_per_tick))
		try_entangle()

/datum/brain_trauma/special/quantum_alignment/proc/try_entangle()
	//Check for pulled mobs
	if(ismob(owner.pulling))
		entangle(owner.pulling)
		return
	//Check for adjacent mobs
	for(var/mob/living/L in oview(1, owner))
		if(owner.Adjacent(L))
			entangle(L)
			return
	//Check for pulled objects
	if(isobj(owner.pulling))
		entangle(owner.pulling)
		return

	//Check main hand
	var/obj/item/held_item = owner.get_active_held_item()
	if(held_item && !(HAS_TRAIT(held_item, TRAIT_NODROP)))
		entangle(held_item)
		return

	//Check off hand
	held_item = owner.get_inactive_held_item()
	if(held_item && !(HAS_TRAIT(held_item, TRAIT_NODROP)))
		entangle(held_item)
		return

	//Just entangle with the turf
	entangle(get_turf(owner))

/datum/brain_trauma/special/quantum_alignment/proc/entangle(atom/target)
	to_chat(owner, span_notice("Вы начинаете испытывать сильное чувство связи с [target]."))
	linked_target = target
	linked = TRUE
	COOLDOWN_START(src, snapback_cooldown, rand(45 SECONDS, 10 MINUTES))

/datum/brain_trauma/special/quantum_alignment/proc/start_snapback()
	if(QDELETED(linked_target))
		linked_target = null
		linked = FALSE
		return
	to_chat(owner, span_warning("Ваша связь с [linked_target] внезапно становится невероятно сильной... вы можете почувствовать, как она притягивает вас!"))
	owner.playsound_local(owner, 'sound/effects/magic/lightning_chargeup.ogg', 75, FALSE)
	returning = TRUE
	addtimer(CALLBACK(src, PROC_REF(snapback)), 10 SECONDS)

/datum/brain_trauma/special/quantum_alignment/proc/snapback()
	returning = FALSE
	if(QDELETED(linked_target))
		to_chat(owner, span_notice("Связь резко обрывается, а вместе с ней и притяжение."))
		linked_target = null
		linked = FALSE
		return
	to_chat(owner, span_warning("Вас тянет сквозь пространство-время!"))
	do_teleport(owner, get_turf(linked_target), null, channel = TELEPORT_CHANNEL_QUANTUM)
	owner.playsound_local(owner, 'sound/effects/magic/repulse.ogg', 100, FALSE)
	linked_target = null
	linked = FALSE

/datum/brain_trauma/special/psychotic_brawling
	name = "Насильственный психоз"
	desc = "Пациент сражается непредсказуемыми способами, начиная от оказания помощи своей жертве и заканчивая нанесением ей жестоких ударов."
	scan_desc = "насильственный психоз"
	symptoms = "Exhibits erratic and potentially violent behavior when in physical contact with others, \
		often accidentally attacking those they intend to offer a hand, or hugging those who they mean to strike."
	gain_text = span_warning("Вы чувствуете себя расстроенными...")
	lose_text = span_notice("Вы чувствуете себя более уравновешенным.")
	/// The martial art we teach
	var/datum/martial_art/psychotic_brawling/psychotic_brawling

/datum/brain_trauma/special/psychotic_brawling/on_gain()
	. = ..()
	psychotic_brawling = new(src)
	psychotic_brawling.locked_to_use = TRUE
	psychotic_brawling.teach(owner)

/datum/brain_trauma/special/psychotic_brawling/on_lose()
	. = ..()
	QDEL_NULL(psychotic_brawling)

/datum/brain_trauma/special/psychotic_brawling/bath_salts
	name = "Химический насильственный психоз"

/datum/brain_trauma/special/tenacity
	name = "Упорство"
	desc = "Пациент психологически нечувствителен к боли и травмам и может оставаться на ногах гораздо дольше обычного человека."
	scan_desc = "травматическая невропатия"
	symptoms = "Exhibits a remarkable resistance to pain and physical trauma, \
		allowing them to sustain severe injuries that would incapacitate an otherwise normal individual."
	gain_text = span_warning("Вы внезапно перестаете чувствовать боль.")
	lose_text = span_warning("Вы понимаете, что снова можете чувствовать боль.")

/datum/brain_trauma/special/tenacity/on_gain()
	owner.add_traits(list(TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_ANALGESIA), TRAUMA_TRAIT)
	. = ..()

/datum/brain_trauma/special/tenacity/on_lose()
	owner.remove_traits(list(TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_ANALGESIA), TRAUMA_TRAIT)
	..()

/datum/brain_trauma/special/death_whispers
	name = "Функциональный церебральный некроз"
	desc = "Мозг пациента находится в функциональном предсмертном состоянии, что время от времени вызывает осознанные галлюцинации, которые часто интерпретируются как голоса умерших."
	scan_desc = "хронический функциональный некроз"
	symptoms = "Experiences intermittent auditory hallucinations characterized by whispering voices, \
		which are often perceived as communications from the deceased."
	gain_text = span_warning("Вы чувствуете себя мертвым внутри.")
	lose_text = span_notice("Вы снова чувствуете себя живым.")
	var/active = FALSE

/datum/brain_trauma/special/death_whispers/on_life()
	..()
	if(!active && prob(2))
		whispering()

/datum/brain_trauma/special/death_whispers/on_lose()
	if(active)
		cease_whispering()
	..()

/datum/brain_trauma/special/death_whispers/proc/whispering()
	ADD_TRAIT(owner, TRAIT_SIXTHSENSE, TRAUMA_TRAIT)
	active = TRUE
	addtimer(CALLBACK(src, PROC_REF(cease_whispering)), rand(5 SECONDS, 30 SECONDS))

/datum/brain_trauma/special/death_whispers/proc/cease_whispering()
	REMOVE_TRAIT(owner, TRAIT_SIXTHSENSE, TRAUMA_TRAIT)
	active = FALSE

/datum/brain_trauma/special/existential_crisis
	name = "Экзистенциальный кризис"
	desc = "Связь пациента с реальностью ослабевает, вызывая периодические эпизоды несуществования."
	scan_desc = "экзистенциальный кризис"
	symptoms = "Experiences sporadic episodes of \"non-existence\", during which the patient temporarily fades out of reality, \
		becoming intangible and invisible to others. Often accompanied by feelings of detachment, depression, and disorientation."
	gain_text = span_warning("Вы чувствуете себя менее реальным.")
	lose_text = span_notice("Вы снова чувствуете себя более значимым.")
	var/obj/effect/abstract/sync_holder/veil/veil
	/// A cooldown to prevent constantly erratic dolphining through the fabric of reality
	COOLDOWN_DECLARE(crisis_cooldown)

/datum/brain_trauma/special/existential_crisis/on_life(seconds_per_tick)
	..()
	if(!veil && COOLDOWN_FINISHED(src, crisis_cooldown) && SPT_PROB(1.5, seconds_per_tick))
		if(isturf(owner.loc))
			fade_out()

/datum/brain_trauma/special/existential_crisis/on_lose()
	if(veil)
		fade_in()
	..()

/datum/brain_trauma/special/existential_crisis/proc/fade_out()
	if(veil)
		return
	var/duration = rand(5 SECONDS, 45 SECONDS)
	veil = new(owner.drop_location())
	to_chat(owner, span_warning("[pick(list(
			"Вы вообще существуете?",
			"Быть или не быть...",
			"Зачем существовать?",
			"Вы просто исчезаете.",
			"Вы перестаете быть настоящим.",
			"Вы на мгновение перестаете думать. Следовательно, вас нет.",
		))]"))
	owner.forceMove(veil)
	COOLDOWN_START(src, crisis_cooldown, 1 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(fade_in)), duration)

/datum/brain_trauma/special/existential_crisis/proc/fade_in()
	QDEL_NULL(veil)
	to_chat(owner, span_notice("Вы возвращаетесь в реальность."))
	COOLDOWN_START(src, crisis_cooldown, 1 MINUTES)

//base sync holder is in desynchronizer.dm
/obj/effect/abstract/sync_holder/veil
	name = "небытие"
	desc = "Существование - это просто состояние ума."

/datum/brain_trauma/special/beepsky
	name = "Преступник"
	desc = "Пациент, похоже, преступник."
	scan_desc = "преступный склад ума"
	gain_text = span_warning("Правосудие придет за вами.")
	lose_text = span_notice("Вы были освобождены от ответственности за ваши преступления.")
	random_gain = FALSE
	known_trauma = FALSE
	/// A ref to our fake beepsky image that we chase the owner with
	var/obj/effect/client_image_holder/securitron/beepsky

/datum/brain_trauma/special/beepsky/Destroy()
	QDEL_NULL(beepsky)
	return ..()

/datum/brain_trauma/special/beepsky/on_gain()
	create_securitron()
	return ..()

/datum/brain_trauma/special/beepsky/proc/create_securitron()
	QDEL_NULL(beepsky)
	var/turf/where = locate(owner.x + pick(-12, 12), owner.y + pick(-12, 12), owner.z)
	beepsky = new(where, owner)

/datum/brain_trauma/special/beepsky/on_lose()
	QDEL_NULL(beepsky)
	return ..()

/datum/brain_trauma/special/beepsky/on_life()
	if(QDELETED(beepsky) || !beepsky.loc || beepsky.z != owner.z)
		if(prob(30))
			create_securitron()
		else
			return

	if(get_dist(owner, beepsky) >= 10 && prob(20))
		create_securitron()

	if(owner.stat != CONSCIOUS)
		if(prob(20))
			owner.playsound_local(beepsky, 'sound/mobs/non-humanoids/beepsky/iamthelaw.ogg', 50)
		return

	if(get_dist(owner, beepsky) <= 1)
		owner.playsound_local(owner, 'sound/items/weapons/egloves.ogg', 50)
		owner.visible_message(span_warning("Тело [declent_ru(owner, GENITIVE)] дергается, как будто его ударили током."), span_userdanger("Вы чувствуете силу ЗАКОНА."))
		owner.adjust_stamina_loss(rand(40, 70))
		QDEL_NULL(beepsky)

	if(prob(20) && get_dist(owner, beepsky) <= 8)
		owner.playsound_local(beepsky, 'sound/mobs/non-humanoids/beepsky/criminal.ogg', 40)

/obj/effect/client_image_holder/securitron
	name = "Securitron"
	desc = "Приближается ЗАКОН."
	image_icon = 'icons/mob/silicon/aibots.dmi'
	image_state = "secbot-c"

/obj/effect/client_image_holder/securitron/Initialize(mapload)
	. = ..()
	name = pick("Officer Beepsky", "Officer Johnson", "Officer Pingsky")
	START_PROCESSING(SSfastprocess, src)

/obj/effect/client_image_holder/securitron/Destroy()
	STOP_PROCESSING(SSfastprocess,src)
	return ..()

/obj/effect/client_image_holder/securitron/process()
	if(prob(40))
		return

	var/mob/victim = pick(who_sees_us)
	forceMove(get_step_towards(src, victim))
	if(prob(5))
		var/beepskys_cry = "Level 10 infraction alert!"
		to_chat(victim, "[span_name("[name]")] exclaims, \"[span_robot("[beepskys_cry]")]")
		if(victim.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat))
			victim.create_chat_message(src, raw_message = beepskys_cry, spans = list(SPAN_ROBOT))

// Used by Veteran Security Advisor job.
/datum/brain_trauma/special/ptsd
	name = "Боевое ПТСР"
	desc = "Пациент испытывает посттравматическое стрессовое расстройство, вызванное пережитыми боевыми действиями, что приводит к отсутствию эмоций. Кроме того, у него наблюдаются лёгкие галлюцинации."
	scan_desc = "ПТСР"
	symptoms = "Witnessed or experienced a traumatic, horrific, or potentially life threatening event, \
		resulting in avoidance, intrusive thoughts, flashbacks, auditory hallucinations, \
		emotional numbness, detachment from others, and heightened reactivity to stimuli - \
		particularly in situations reminiscent of the traumatic event."
	gain_text = span_warning("Вы возвращаетесь в хаос прошлого! Взрывы! Стрельба! Эмоции покинули строй!")
	lose_text = span_notice("Вы чувствуете, как исчезают воспоминания о прошлом, как возвращаются ваши эмоции и проясняется разум.")
	resilience = TRAUMA_RESILIENCE_ABSOLUTE
	can_gain = TRUE
	random_gain = FALSE
	/// Our cooldown declare for causing hallucinations
	COOLDOWN_DECLARE(ptsd_hallucinations)
	var/list/ptsd_hallucinations_list = list(
		/datum/hallucination/fake_sound/normal/boom,
		/datum/hallucination/fake_sound/normal/distant_boom,
		/datum/hallucination/stray_bullet,
		/datum/hallucination/battle/gun/disabler,
		/datum/hallucination/battle/gun/laser,
		/datum/hallucination/battle/bomb,
		/datum/hallucination/battle/e_sword,
		/datum/hallucination/battle/harm_baton,
		/datum/hallucination/battle/stun_prod,
	)

/datum/brain_trauma/special/ptsd/on_life(seconds_per_tick)
	if(owner.stat != CONSCIOUS)
		return

	if(!COOLDOWN_FINISHED(src, ptsd_hallucinations))
		return

	owner.cause_hallucination(pick(ptsd_hallucinations_list), "Caused by The Combat PTSD brain trauma")
	COOLDOWN_START(src, ptsd_hallucinations, rand(10 SECONDS, 10 MINUTES))

/datum/brain_trauma/special/ptsd/on_gain()
	owner.add_mood_event("combat_ptsd", /datum/mood_event/desentized)
	owner.mob_mood?.mood_modifier -= 1 //Basically nothing can change your mood
	owner.mob_mood?.set_sanity(SANITY_DISTURBED, override = TRUE) //Makes sanity on a unstable level unless cured
	owner.apply_status_effect(/datum/status_effect/desensitized, REF(src), DESENSITIZED_THRESHOLD)
	. = ..()

/datum/brain_trauma/special/ptsd/on_lose()
	owner.clear_mood_event("combat_ptsd")
	owner.mob_mood?.mood_modifier += 1
	owner.mob_mood?.set_sanity(SANITY_GREAT, override = TRUE)
	owner.remove_status_effect(/datum/status_effect/desensitized, REF(src))
	return ..()

/datum/brain_trauma/special/primal_instincts
	name = "Дикие инстинкты"
	desc = "Разум пациента застревает в первобытном состоянии, заставляя его действовать скорее инстинктивно, чем разумно."
	scan_desc = "одичание"
	symptoms = "Rarely experiences episodes where higher cognitive functions are suppressed, \
		resulting in behavior driven primarily by primal instincts. During these episodes, \
		the patient may exhibit increased aggression, territoriality, and a focus on basic survival needs."
	gain_text = span_warning("Ваши зрачки расширяются, и вам становится все труднее мыслить здраво.")
	lose_text = span_notice("Ваш разум проясняется, и вы чувствуете, что лучше контролируете ситуацию.")
	resilience = TRAUMA_RESILIENCE_SURGERY
	/// Tracks any existing AI controller, so we can restore it when we're cured
	var/old_ai_controller_type

/datum/brain_trauma/special/primal_instincts/on_gain()
	. = ..()
	if(!isnull(owner.ai_controller))
		old_ai_controller_type = owner.ai_controller.type
		QDEL_NULL(owner.ai_controller)

	owner.ai_controller = new /datum/ai_controller/monkey(owner)
	owner.ai_controller.continue_processing_when_client = TRUE
	owner.ai_controller.can_idle = FALSE
	owner.ai_controller.set_ai_status(AI_STATUS_OFF)

/datum/brain_trauma/special/primal_instincts/on_lose(silent)
	. = ..()
	if(QDELING(owner))
		return

	QDEL_NULL(owner.ai_controller)
	if(old_ai_controller_type)
		owner.ai_controller = new old_ai_controller_type(owner)
	owner.remove_language(/datum/language/monkey, UNDERSTOOD_LANGUAGE, TRAUMA_TRAIT)

/datum/brain_trauma/special/primal_instincts/on_life(seconds_per_tick)
	if(isnull(owner.ai_controller))
		qdel(src)
		return

	if(!SPT_PROB(3, seconds_per_tick))
		return

	owner.grant_language(/datum/language/monkey, UNDERSTOOD_LANGUAGE, TRAUMA_TRAIT)
	owner.ai_controller.set_blackboard_key(BB_MONKEY_AGGRESSIVE, prob(75))
	if(owner.ai_controller.ai_status == AI_STATUS_OFF)
		owner.ai_controller.set_ai_status(AI_STATUS_ON)
		owner.log_message("became controlled by monkey instincts ([owner.ai_controller.blackboard[BB_MONKEY_AGGRESSIVE] ? "aggressive" : "docile"])", LOG_ATTACK, color = "orange")
		to_chat(owner, span_warning("Вы чувствуете непреодолимое желание действовать в соответствии со своими первобытными инстинктами..."))
	// extend original timer if we roll the effect while it's already ongoing
	addtimer(CALLBACK(src, PROC_REF(primal_instincts_off)), rand(20 SECONDS, 40 SECONDS), TIMER_UNIQUE|TIMER_NO_HASH_WAIT|TIMER_OVERRIDE|TIMER_DELETE_ME)

/datum/brain_trauma/special/primal_instincts/proc/primal_instincts_off()
	owner.ai_controller.set_ai_status(AI_STATUS_OFF)
	owner.remove_language(/datum/language/monkey, UNDERSTOOD_LANGUAGE, TRAUMA_TRAIT)
	to_chat(owner, span_green("Желание утихает."))

/datum/brain_trauma/special/axedoration
	name = "Галлюцинации с топором"
	desc = "Пациент испытывает огромное чувство долга по отношению к защите топора и испытывает галлюцинации, связанные с ним."
	scan_desc = "привязанность к объекту"
	gain_text = span_notice("Вы чувствуете, что защита пожарного топора - одна из ваших главных обязанностей.")
	lose_text = span_warning("Вы чувствуете, что потеряли чувство долга.")
	resilience = TRAUMA_RESILIENCE_ABSOLUTE
	random_gain = FALSE
	known_trauma = FALSE
	var/static/list/talk_lines = list(
		"Я горжусь тобой.",
		"Я верю в тебя!",
		"Я тебе не мешаю?",
		"Восхваляй меня!",
		"Горят костры.",
		"Мы сделали это!",
		"Мама, моё тело мне отвратительно.",
		"Там, где мы встречаемся, есть пропасть, где заканчиваюсь я и начинаешься ты..",
		"Смири себя.",
	)
	var/static/list/hurt_lines = list(
		"Ой!",
		"Ай!",
		"Эй!",
		"Горит!",
		"Стой!",
		"Ааааа!",
		"Пожалуйста!",
		"Покончи с этим!",
		"Прекрати!",
		"Ах!",
	)

/datum/brain_trauma/special/axedoration/on_life(seconds_per_tick)
	if(owner.stat != CONSCIOUS)
		return

	if(!GLOB.bridge_axe)
		if(SPT_PROB(0.5, seconds_per_tick))
			to_chat(owner, span_warning("Мой долг не выполнен..."))
			owner.set_jitter_if_lower(5 SECONDS)
			owner.set_stutter_if_lower(5 SECONDS)
			if(SPT_PROB(20, seconds_per_tick))
				owner.vomit(VOMIT_CATEGORY_DEFAULT)
		return

	var/atom/axe_location = get_axe_location()
	if(!SPT_PROB(1.5, seconds_per_tick))
		return
	if(isliving(axe_location))
		var/mob/living/axe_holder = axe_location
		if(axe_holder == owner)
			talk_tuah(pick(talk_lines))
			return
		var/datum/job/holder_job = axe_holder.mind?.assigned_role
		if(holder_job && (/datum/job_department/command in holder_job.departments_list))
			to_chat(owner, span_notice("Я надеюсь, что топор находится в надежных руках..."))
			owner.add_mood_event("fireaxe", /datum/mood_event/axe_neutral)
			return
		to_chat(owner, span_warning("У вас появляется дурное предчувствие..."))
		owner.add_mood_event("fireaxe", /datum/mood_event/axe_missing)
		return

	if(!isarea(axe_location))
		owner.add_mood_event("fireaxe", /datum/mood_event/axe_gone)
		return

	if(istype(axe_location, /area/station/command))
		to_chat(owner, span_notice("Вы испытываете чувство облегчения..."))
		if(istype(GLOB.bridge_axe.loc, /obj/structure/fireaxecabinet))
			return
		owner.add_mood_event("fireaxe", /datum/mood_event/axe_neutral)
		return

	to_chat(owner, span_warning("У вас появляется дурное предчувствие..."))
	owner.add_mood_event("fireaxe", /datum/mood_event/axe_missing)

/datum/brain_trauma/special/axedoration/on_gain()
	RegisterSignal(owner, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equip))
	RegisterSignal(owner, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_unequip))
	RegisterSignal(owner, COMSIG_MOB_EXAMINING, PROC_REF(on_examine))
	if(!GLOB.bridge_axe)
		axe_gone()
		return ..()
	RegisterSignal(GLOB.bridge_axe, COMSIG_QDELETING, PROC_REF(axe_gone))
	if(istype(get_axe_location(), /area/station/command) && istype(GLOB.bridge_axe.loc, /obj/structure/fireaxecabinet))
		owner.add_mood_event("fireaxe", /datum/mood_event/axe_cabinet)
	else if(owner.is_holding(GLOB.bridge_axe))
		on_equip(owner, GLOB.bridge_axe)
	else
		owner.add_mood_event("fireaxe", /datum/mood_event/axe_neutral)
	RegisterSignal(GLOB.bridge_axe, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_axe_attack))
	return ..()


/datum/brain_trauma/special/axedoration/on_lose()
	owner.clear_mood_event("fireaxe")
	UnregisterSignal(owner, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_MOB_EXAMINING))
	if(GLOB.bridge_axe)
		UnregisterSignal(GLOB.bridge_axe, COMSIG_ITEM_AFTERATTACK)
	return ..()

/datum/brain_trauma/special/axedoration/proc/axe_gone(source)
	SIGNAL_HANDLER
	to_chat(owner, span_danger("Вы чувствуете сильное возмущение Силы."))
	owner.add_mood_event("fireaxe", /datum/mood_event/axe_gone)
	owner.set_jitter_if_lower(15 SECONDS)
	owner.set_stutter_if_lower(15 SECONDS)

/datum/brain_trauma/special/axedoration/proc/on_equip(source, obj/item/picked_up, slot)
	SIGNAL_HANDLER
	if(!istype(picked_up, /obj/item/fireaxe))
		return
	owner.set_jitter_if_lower(3 SECONDS)
	if(picked_up == GLOB.bridge_axe)
		to_chat(owner, span_hypnophrase("Он у меня. Пришло время положить его на место."))
		owner.add_mood_event("fireaxe", /datum/mood_event/axe_held)
		return
	ADD_TRAIT(picked_up, TRAIT_NODROP, type)
	to_chat(owner, span_warning("...Это не тот, за каким я присматриваю."))
	owner.Immobilize(2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(throw_faker), picked_up), 2 SECONDS)

/datum/brain_trauma/special/axedoration/proc/throw_faker(obj/item/faker)
	REMOVE_TRAIT(faker, TRAIT_NODROP, type)
	var/held_index = owner.get_held_index_of_item(faker)
	if(!held_index)
		return
	to_chat(owner, span_warning("Уйду с тобой."))
	owner.swap_hand(held_index, silent = TRUE)
	var/turf/target_turf = get_ranged_target_turf(owner, owner.dir, faker.throw_range)
	owner.throw_item(target_turf)

/datum/brain_trauma/special/axedoration/proc/on_unequip(datum/source, obj/item/dropped_item, force, new_location)
	SIGNAL_HANDLER
	if(dropped_item != GLOB.bridge_axe)
		return
	if(get_axe_location() == owner)
		return
	if(istype(new_location, /obj/structure/fireaxecabinet))
		if(istype(get_area(new_location), /area/station/command))
			to_chat(owner, span_nicegreen("Ах! Вернулся туда, где должен быть!"))
			owner.add_mood_event("fireaxe", /datum/mood_event/axe_cabinet)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "smile")
			return
		to_chat(owner, span_warning("Оставить его вне мостика? Я в этом уверен?"))
		owner.add_mood_event("fireaxe", /datum/mood_event/axe_neutral)
		return
	to_chat(owner, span_warning("Мне действительно стоит оставить его здесь?"))
	owner.add_mood_event("fireaxe", /datum/mood_event/axe_neutral)

/datum/brain_trauma/special/axedoration/proc/on_examine(mob/source, atom/target, list/examine_strings, list/examine_overrides)
	SIGNAL_HANDLER
	if(!istype(target, /obj/item/fireaxe))
		return
	if(target == GLOB.bridge_axe)
		examine_strings += span_notice("Это топор, который я поклялся защищать.")
	else
		examine_strings += span_warning("Это симулякр, фальшивый топор, созданный для того, чтобы одурачить массы.")

/datum/brain_trauma/special/axedoration/proc/on_axe_attack(obj/item/axe, atom/target, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(user != owner)
		return
	talk_tuah(pick(hurt_lines))

/datum/brain_trauma/special/axedoration/proc/talk_tuah(sent_message = "Hello World.")
	owner.Hear(GLOB.bridge_axe, owner.get_selected_language(), sent_message)

/datum/brain_trauma/special/axedoration/proc/get_axe_location()
	if(!GLOB.bridge_axe)
		return
	var/atom/axe_loc = GLOB.bridge_axe.loc
	while(!ismob(axe_loc) && !isarea(axe_loc) && !isnull(axe_loc))
		axe_loc = axe_loc.loc
	return axe_loc
