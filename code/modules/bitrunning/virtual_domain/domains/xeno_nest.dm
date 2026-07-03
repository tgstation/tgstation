/datum/lazy_template/virtual_domain/xeno_nest
	name = "Заражение ксеноморфами"
	cost = BITRUNNER_COST_LOW
	desc = "Сканеры нашего корабля обнаружили формы жизни неизвестного происхождения. Дружественные попытки связаться с ними не увенчались успехом."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	completion_loot = list(/obj/item/toy/plush/rouny = 1)
	help_text = "Вы находитесь на бесплодной планете, наполненной враждебными существами. Где-то здесь ящик, \
	хоть он и не спрятан, но находится под охраной. Ожидайте сопротивления."
	is_modular = TRUE
	key = "xeno_nest"
	map_name = "xeno_nest"
	mob_modules = list(/datum/modular_mob_segment/xenos)
	reward_points = BITRUNNER_REWARD_LOW
