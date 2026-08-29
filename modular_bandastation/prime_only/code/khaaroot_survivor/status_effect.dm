#define REQUIRED_ACCUMULATION(wound) (1 + (wound.severity - 1) * 0.3)

/datum/singleton/sound_effect/khaaroot_voice_mutation
	suffix = "_khaaroot_voice_mutation"
	ffmpeg_arguments = "asetrate=21000,acrusher=0.4:1:15:0:log,volume=volume=5"

/datum/status_effect/khaaroot_survivor
	id = "khaaroot_survivor"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 3 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	remove_on_fullheal = FALSE

	var/wound_regen_rate = 0.15
	var/wound_regen_accumulation = 0

	var/datum/khaaroot_hivemind/hivemind

/datum/status_effect/khaaroot_survivor/on_apply()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/H = owner

	H.add_traits(list(TRAIT_VIRUSIMMUNE, TRAIT_ANALGESIA, TRAIT_HARDLY_WOUNDED, TRAIT_FEARLESS), TRAIT_STATUS_EFFECT(id))

	var/obj/item/organ/eyes/old_eyes = H.get_organ_slot(ORGAN_SLOT_EYES)
	if(old_eyes)
		old_eyes.Remove(H)
		QDEL_NULL(old_eyes)

	var/obj/item/organ/eyes/robotic/glow/new_eyes = new()
	new_eyes.light_color_string = "#ff5500"
	new_eyes.eye_color_mode = 1
	new_eyes.Insert(H, special = TRUE)
	new_eyes.activate()

	var/datum/disease/khaaroot_remnant/remnant = new()
	remnant.try_infect(H)
	remnant.carrier = TRUE

	RegisterSignal(H, COMSIG_LIVING_HEALTHSCAN, PROC_REF(on_health_scan))
	RegisterSignal(H, COMSIG_TTS_COMPONENT_PRE_CAST_TTS, PROC_REF(on_tts_pre_cast))

	if(H.mind)
		hivemind = new(H.mind)

	return TRUE

/datum/status_effect/khaaroot_survivor/on_remove()
	var/mob/living/carbon/human/H = owner
	if(!H)
		return

	H.remove_traits(list(TRAIT_VIRUSIMMUNE, TRAIT_ANALGESIA, TRAIT_HARDLY_WOUNDED, TRAIT_FEARLESS), TRAIT_STATUS_EFFECT(id))

	var/datum/disease/khaaroot_remnant/remnant = locate() in H.diseases
	if(remnant)
		remnant.cure(FALSE)

	UnregisterSignal(H, COMSIG_LIVING_HEALTHSCAN)
	UnregisterSignal(H, COMSIG_TTS_COMPONENT_PRE_CAST_TTS)

	QDEL_NULL(hivemind)

/datum/status_effect/khaaroot_survivor/proc/on_tts_pre_cast(mob/living/user, list/tts_args)
	SIGNAL_HANDLER
	if(tts_args[TTS_CHANNEL_OVERRIDE] == CHANNEL_TTS_TELEPATHY)
		return
	var/list/effects = tts_args[TTS_CAST_EFFECTS]
	effects.Insert(1, /datum/singleton/sound_effect/khaaroot_voice_mutation)

/datum/status_effect/khaaroot_survivor/tick(seconds_between_ticks)
	var/mob/living/carbon/human/H = owner
	if(!H)
		return

	if(length(H.all_wounds))
		wound_regen_accumulation += wound_regen_rate * seconds_between_ticks
	else
		wound_regen_accumulation = 0
		return

	while(wound_regen_accumulation >= 1 && length(H.all_wounds))
		var/list/candidates = list()
		for(var/datum/wound/wound in H.all_wounds)
			if(wound_regen_accumulation >= REQUIRED_ACCUMULATION(wound))
				candidates += wound

		if(!length(candidates))
			return

		var/datum/wound/wound_to_heal = pick(candidates)
		wound_regen_accumulation = max(0, wound_regen_accumulation - REQUIRED_ACCUMULATION(wound_to_heal))
		wound_to_heal.remove_wound()
		H.visible_message(span_warning("Раны [H.declent_ru(GENITIVE)] исчезают неестественно быстро..."), blind_message = span_hear("Вы слышите тихое шипение."), vision_distance = 2)

/datum/status_effect/khaaroot_survivor/proc/on_health_scan(datum/source, list/render_list, advanced, mob/user, mode, tochat)
	SIGNAL_HANDLER

	if(!advanced)
		return

	render_list += "<span class='alert ml-1'><b>⚠ ОБНАРУЖЕНА БИОЛОГИЧЕСКАЯ АНОМАЛИЯ КЛАССА БИОУГРОЗА.</b> Требуется изоляция.</span><br>"
	render_list += "<span class='notice ml-1'>Анализ антител... \[ДАННЫЕ УДАЛЕНЫ — УРОВЕНЬ ДОПУСКА: L3+ • ПОПЫТКА ОБХОДА БУДЕТ ЗАФИКСИРОВАНА И ПЕРЕДАНА В ОТДЕЛ КОНТРРАЗВЕДКИ\\]</span><br>"

#undef REQUIRED_ACCUMULATION
