/datum/experiment/scanning/cytology
	name = "Эксперимент по скану цитологии"
	exp_tag = "Скан цитологии"

/datum/experiment/scanning/cytology/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	return ..() && HAS_TRAIT(target, TRAIT_VATGROWN)

/datum/experiment/scanning/cytology/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Скан образцов [declent_ru_initial(target::name, GENITIVE, target::name)], выращенных в лаборатории", seen_instances.len, required_atoms[target])

/datum/experiment/scanning/cytology/slime
	name = "Сканирование слаймов выращенных в лаборатории"
	description = "Видели слаймов в ксенобиологическом загоне? Они появились, когда наши исследователи бросили в резервуар заплесневелый кусок хлеба. Вырастите еще одного и сообщите о результатах."
	performance_hint = "Соберите клеточные линии слаймов из заплесневелого хлеба или возьмите биопсийный образец существующих слаймов. И выращивайте их в загоне."
	required_atoms = list(/mob/living/basic/slime = 1)


