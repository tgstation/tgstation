/datum/personality/brave
	savefile_key = "brave"
	name = "Храбрый"
	desc = "Потребуется гораздо больше, чем просто капля крови, чтобы напугать меня."
	pos_gameplay_desc = "Страх накапливается медленнее, а модификаторы настроения, связанные со страхом, влияют слабее"
	groups = list(PERSONALITY_GROUP_GENERAL_FEAR, PERSONALITY_GROUP_PEOPLE_FEAR)

/datum/personality/cowardly
	savefile_key = "cowardly"
	name = "Трусливый"
	desc = "Здесь всё представляет опасность! Даже воздух!"
	neg_gameplay_desc = "Страх накапливается быстрее, а модификаторы настроения, связанные со страхом, влияют сильнее"
	groups = list(PERSONALITY_GROUP_GENERAL_FEAR)
