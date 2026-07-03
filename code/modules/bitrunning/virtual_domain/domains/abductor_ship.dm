/datum/lazy_template/virtual_domain/abductor_ship
	name = "Корабль абдукторов"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Высадитесь на корабль абдукторов и заберите их ценности."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	completion_loot = list(/obj/item/toy/plush/abductor/agent = 1)
	help_text = "Материнский корабль абдукторов непреднамеренно вошел во враждебное окружение. \
	В настоящее время они готовятся покинуть зону, прихватив своё снаряжение и добычу, включая \
	ящик. Будьте осторожны, так как абдукторы известны своим продвинутым вооружением."
	is_modular = TRUE
	key = "abductor_ship"
	map_name = "abductor_ship"
	mob_modules = list(/datum/modular_mob_segment/abductor_agents)
	reward_points = BITRUNNER_REWARD_MEDIUM
	forced_outfit = /datum/outfit/bitductor
