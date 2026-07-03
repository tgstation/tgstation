/datum/lazy_template/virtual_domain/meta_central
	name = "ИСН Цереброн-централ"
	cost = BITRUNNER_COST_LOW
	desc = "Время от времени работники требуют соблюдения прав от Нанотрейзен. Это невыгодно."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	forced_outfit = /datum/outfit/job/security/mod
	help_text = "Отвечайте на требования работника санкционированным насилием. Соберите ценные материалы, которые могут быть разбросаны вокруг. Просто помните чему вас учили: все виновны по умолчанию, свою вину они признают в мед отделе... ну или что-то типо такого."
	is_modular = TRUE
	key = "meta_central"
	map_name = "meta_central"
	mob_modules = list(/datum/modular_mob_segment/revolutionary)
	reward_points = BITRUNNER_REWARD_LOW
	announce_to_ghosts = TRUE
