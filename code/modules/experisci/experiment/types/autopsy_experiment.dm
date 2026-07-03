/datum/experiment/autopsy
	name = "Эксперимент по вскрытию"
	description = "Эксперимент, для продолжения которого требуется операция вскрытия."
	exp_tag = "Вскрытие"
	performance_hint = "Проведите операцию вскрытия, подключившись к операционному компьютеру."

/datum/experiment/autopsy/is_complete()
	return completed

/datum/experiment/autopsy/perform_experiment_actions(datum/component/experiment_handler/experiment_handler, mob/target)
	if (is_valid_autopsy(target))
		completed = TRUE
		return TRUE
	else
		return FALSE

/datum/experiment/autopsy/proc/is_valid_autopsy(mob/target)
	return TRUE

/datum/experiment/autopsy/human
	name = "Эксперимент по вскрытию человека"
	description = "Мы не хотим вкладывать деньги в станцию, которая не отличает копчик от улитки. Пришлите нам данные о препарировании человека, чтобы получить больше финансирования."

/datum/experiment/autopsy/human/is_valid_autopsy(mob/target)
	return ishumanbasic(target)

/datum/experiment/autopsy/nonhuman
	name = "Эксперимент по вскрытию нечеловека"
	description = "Когда мы просили хвостовую кость, мы не имели в виду... Слушайте, просто пришлите нам данные не человека, а чего-то ДРУГОГО. Это может быть и обезьяна, нам все равно, просто пришлите нам исследования."

/datum/experiment/autopsy/nonhuman/is_valid_autopsy(mob/target)
	return ishuman(target) && !ishumanbasic(target)

/datum/experiment/autopsy/xenomorph
	name = "Эксперимент по вскрытию ксеноморфа"
	description = "Наше представление о ксеноморфах лишь поверхностное. Пришлите нам исследования, полученные при препарировании ксеноморфа."

/datum/experiment/autopsy/xenomorph/is_valid_autopsy(mob/target)
	return isalien(target)
