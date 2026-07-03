/datum/personality/apathetic
	savefile_key = "apathetic"
	name = "Апатичный"
	desc = "Меня практически ничего не волнует. Ни хорошее, ни плохое, и уж точно не уродливое."
	neut_gameplay_desc = "Все модификаторы настроения влияют на вас слабее"
	groups = list(PERSONALITY_GROUP_MOOD_POWER)

/datum/personality/apathetic/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.mood_modifier -= 0.2

/datum/personality/apathetic/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.mood_modifier += 0.2

/datum/personality/sensitive
	savefile_key = "sensitive"
	name = "Чувствительный"
	desc = "Я легко поддаюсь влиянию окружающего мира."
	neut_gameplay_desc = "Все модификаторы настроения влияют на вас сильнее"
	groups = list(PERSONALITY_GROUP_MOOD_POWER)

/datum/personality/sensitive/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.mood_modifier += 0.2

/datum/personality/sensitive/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.mood_modifier -= 0.2

/datum/personality/resilient
	savefile_key = "resilient"
	name = "Стойкий"
	desc = "Неважно. Я могу это вынести!"
	pos_gameplay_desc = "Негативные модификаторы настроения заканчиваются быстрее"
	groups = list(PERSONALITY_GROUP_MOOD_LENGTH)

/datum/personality/resilient/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.negative_moodlet_length_modifier -= 0.2

/datum/personality/resilient/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.negative_moodlet_length_modifier += 0.2

/datum/personality/brooding
	savefile_key = "brooding"
	name = "Задумчивый"
	desc = "Все это задевает меня, и я не могу не думать об этом."
	neg_gameplay_desc = "Негативные модификаторы настроения сохраняются дольше"
	groups = list(PERSONALITY_GROUP_MOOD_LENGTH)

/datum/personality/brooding/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.negative_moodlet_length_modifier += 0.2

/datum/personality/brooding/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.negative_moodlet_length_modifier -= 0.2

/datum/personality/hopeful
	savefile_key = "hopeful"
	name = "Оптимистичный"
	desc = "Я верю, что все всегда будет становиться лучше."
	pos_gameplay_desc = "Позитивные модификаторы настроения сохраняются дольше"
	groups = list(PERSONALITY_GROUP_HOPE)

/datum/personality/hopeful/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.positive_moodlet_length_modifier += 0.2

/datum/personality/hopeful/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.positive_moodlet_length_modifier -= 0.2

/datum/personality/pessimistic
	savefile_key = "pessimistic"
	name = "Пессимистичный"
	desc = "Я верю, что наши лучшие дни остались позади."
	neg_gameplay_desc = "Позитивные модификаторы настроения длятся меньше"
	groups = list(PERSONALITY_GROUP_HOPE)

/datum/personality/pessimistic/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.positive_moodlet_length_modifier -= 0.2

/datum/personality/pessimistic/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.positive_moodlet_length_modifier += 0.2

/datum/personality/whimsical
	savefile_key = "whimsical"
	name = "Эксцентричный"
	desc = "Эта станция иногда бывает слишком серьезной. Расслабься!"
	pos_gameplay_desc = "Любит якобы бессмысленные, но глупые вещи и не возражает против клоунских выходок"

/datum/personality/snob
	savefile_key = "snob"
	name = "Сноб"
	desc = "Я ожидаю от этой станции только самого лучшего - меньшее неприемлемо!"
	neut_gameplay_desc = "Качество комнаты влияет на ваше настроение"
	personality_trait = TRAIT_SNOB
