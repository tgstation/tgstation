/datum/personality/gambler
	savefile_key = "gambler"
	name = "Азартный игрок"
	desc = "Игра в кости всегда того стоит!"
	pos_gameplay_desc = "Любит азартные игры и карточные развлечения, спокойно воспринимает проигрыши"

/datum/personality/slacking
	/// Areas which are considered "slacking off"
	var/list/slacker_areas = list(
		/area/station/commons/fitness,
		/area/station/commons/lounge,
		/area/station/service/bar,
		/area/station/service/cafeteria,
		/area/station/service/library,
		/area/station/service/minibar,
		/area/station/service/theater,
	)
	/// Mood event applied when in a slacking area
	var/mood_event_type

/datum/personality/slacking/apply_to_mob(mob/living/who)
	. = ..()
	who.apply_status_effect(/datum/status_effect/moodlet_in_area, mood_event_type, slacker_areas, CALLBACK(src, PROC_REF(is_slacking)))

/datum/personality/slacking/remove_from_mob(mob/living/who)
	. = ..()
	who.remove_status_effect(/datum/status_effect/moodlet_in_area, mood_event_type)

/// Callback for the moodlet_in_area status effect to determine if we're slacking off
/datum/personality/slacking/proc/is_slacking(mob/living/who, area/new_area)
	if(!istype(new_area, /area/station/service))
		return TRUE
	// Service workers don't slack in service
	if(who.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_SERVICE)
		return FALSE

	return TRUE

/datum/personality/slacking/lazy
	savefile_key = "lazy"
	name = "Ленивый"
	desc = "На самом деле мне сегодня не хочется работать."
	pos_gameplay_desc = "Приятно проводить время в баре или зонах отдыха"
	mood_event_type = /datum/mood_event/slacking_off_lazy
	groups = list(PERSONALITY_GROUP_RECREATION, PERSONALITY_GROUP_WORK, PERSONALITY_GROUP_ATHLETICS)

/datum/personality/slacking/diligent
	savefile_key = "diligent"
	name = "Старательный"
	desc = "Тут столько всего надо сделать!"
	pos_gameplay_desc = "Счастлив, находясь в своём отделе."
	neg_gameplay_desc = "Несчастен, когда отдыхает в баре или зонах отдыха, уклоняясь от обязанностей"
	mood_event_type = /datum/mood_event/slacking_off_diligent
	groups = list(PERSONALITY_GROUP_RECREATION)

/datum/personality/slacking/diligent/apply_to_mob(mob/living/who)
	. = ..()
	RegisterSignals(who, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_SET_ROLE), PROC_REF(update_effect))
	// Unfortunate side effect here in that IC job changes, IE HoP are missed
	who.apply_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/working_diligent, who.mind?.get_work_areas())

/datum/personality/slacking/diligent/remove_from_mob(mob/living/who)
	. = ..()
	UnregisterSignal(who, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_SET_ROLE))
	who.remove_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/working_diligent)

/// Signal handler to update our status effect when our job changes
/datum/personality/slacking/diligent/proc/update_effect(mob/living/source, ...)
	SIGNAL_HANDLER

	source.remove_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/working_diligent)
	source.apply_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/working_diligent, source.mind.get_work_areas())

/datum/personality/industrious
	savefile_key = "industrious"
	name = "Трудолюбивый"
	desc = "Каждый должен работать, иначе мы все напрасно тратим свое время."
	neg_gameplay_desc = "Не любит играть в игры"
	groups = list(PERSONALITY_GROUP_WORK)

/datum/personality/athletic
	savefile_key = "athletic"
	name = "Атлетичный"
	desc = "Нельзя же весь день сидеть сложа руки! Нужно двигаться."
	pos_gameplay_desc = "Любит заниматься спортом"
	neg_gameplay_desc = "Не любит лениться"
	groups = list(PERSONALITY_GROUP_ATHLETICS)

/datum/personality/erudite
	savefile_key = "erudite"
	name = "Эрудированный"
	desc = "Знание — сила. Особенно далеко в космосе."
	pos_gameplay_desc = "Любит читать книги"
	groups = list(PERSONALITY_GROUP_READING)

/datum/personality/uneducated
	savefile_key = "uneducated"
	name = "Необразованный"
	desc = "Меня не очень интересуют книги - я уже знаю все, что мне нужно знать."
	neg_gameplay_desc = "Не любит читать книги"
	groups = list(PERSONALITY_GROUP_READING)

/datum/personality/spiritual
	savefile_key = "spiritual"
	name = "Духовный"
	desc = "Я верю в высшие силы."
	pos_gameplay_desc = "Любит церковь и священника, имеет особые молитвы."
	neg_gameplay_desc = "Не любит нечестивые вещи"
	personality_trait = TRAIT_SPIRITUAL
