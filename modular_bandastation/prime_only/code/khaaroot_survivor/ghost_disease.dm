/datum/disease/khaaroot_remnant
	name = "Khaaroot Remnant Antigen"
	desc = "Остаточный антиген крайне опасного вирусного штамма, полностью интегрированный в генетический код носителя. Уникальный задокументированный случай выживания. Требует дальнейшего изучения."
	form = "Аномалия"
	agent = "\[ДАННЫЕ УДАЛЕНЫ — УРОВЕНЬ ДОПУСКА: L3+ • ПОПЫТКА ОБХОДА БУДЕТ ЗАФИКСИРОВАНА И ПЕРЕДАНА В ОТДЕЛ КОНТРРАЗВЕДКИ\]"
	spread_text = "Не заразен (интегрирован в носителя)"
	cure_text = "\[ДАННЫЕ УДАЛЕНЫ\] Носитель неизлечим. Антиген интегрирован в ДНК."
	max_stages = 1
	stage_prob = 0
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	spreading_modifier = 0
	severity = DISEASE_SEVERITY_BIOHAZARD
	disease_flags = CHRONIC
	bypasses_immunity = TRUE
	infectivity = 0
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 0

/datum/disease/khaaroot_remnant/stage_act(seconds_per_tick)
	. = ..()
