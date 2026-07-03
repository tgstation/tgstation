/datum/personality/callous
	savefile_key = "callous"
	name = "Бессердечный"
	desc = "Меня не очень волнует, что происходит с другими людьми."
	pos_gameplay_desc = "Не прочь увидеть смерть"
	neg_gameplay_desc = "Предпочитает не помогать людям"
	groups = list(PERSONALITY_GROUP_DEATH)

/datum/personality/compassionate
	savefile_key = "compassionate"
	name = "Сострадательный"
	desc = "Я люблю помогать тем, кто нуждается в поддержке."
	pos_gameplay_desc = "Любит помогать людям"
	neg_gameplay_desc = "Вид смерти больше влияет на настроение"
	groups = list(PERSONALITY_GROUP_DEATH, PERSONALITY_GROUP_MISANTHROPY)

/datum/personality/empathetic
	savefile_key = "empathetic"
	name = "Эмпатичный" // according to google "empathic" means you understand other people, while "empathetic" means you feel what they feel
	desc = "Чувства других людей важны для меня."
	pos_gameplay_desc = "Любит видеть других людей счастливыми"
	neg_gameplay_desc = "Не любит видеть других людей грустными"
	groups = list(PERSONALITY_GROUP_OTHERS)

/datum/personality/misanthropic
	savefile_key = "misanthropic"
	name = "Мизантроп"
	desc = "Нам вообще не следовало отправляться к звёздам."
	pos_gameplay_desc = "Любит видеть других людей грустными"
	neg_gameplay_desc = "Не любит видеть других людей счастливыми"
	groups = list(PERSONALITY_GROUP_OTHERS, PERSONALITY_GROUP_MISANTHROPY)

/datum/personality/aloof
	savefile_key = "aloof"
	name = "Отчужденный"
	desc = "Почему все такие чувствительные? Я бы предпочёл остаться один."
	neg_gameplay_desc = "Не любит, когда его хватают, трогают или обнимают"
	personality_trait = TRAIT_BADTOUCH

/datum/personality/aloof/apply_to_mob(mob/living/who)
	. = ..()
	RegisterSignals(who, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HELP_ACT), PROC_REF(uncomfortable_touch))

/datum/personality/aloof/remove_from_mob(mob/living/who)
	. = ..()
	UnregisterSignal(who, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HELP_ACT))

/// Causes a negative moodlet to our quirk holder on signal
/datum/personality/aloof/proc/uncomfortable_touch(mob/living/source)
	SIGNAL_HANDLER

	if(source.stat == DEAD)
		return

	new /obj/effect/temp_visual/annoyed(source.loc)
	if(source.mob_mood.sanity <= SANITY_NEUTRAL)
		source.add_mood_event("bad_touch", /datum/mood_event/very_bad_touch)
	else
		source.add_mood_event("bad_touch", /datum/mood_event/bad_touch)
