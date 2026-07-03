/datum/lazy_template/virtual_domain/syndicate_assault
	name = "Нападение Синдиката"
	announce_to_ghosts = TRUE
	cost = BITRUNNER_COST_MEDIUM
	desc = "Возьмите на абордаж вражеский корабль и верните украденный груз."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	completion_loot = list(/obj/item/toy/plush/nukeplushie = 1)
	help_text = "Группа из оперативников Синдиката похитила со станции ценный груз. \
	Они поднялись на борт своего корабля и пытаются сбежать. Проникните на их корабль и \
	верните ящик. Будьте осторожны, они очень хорошо вооружены."
	is_modular = TRUE
	key = "syndicate_assault"
	map_name = "syndicate_assault"
	mob_modules = list(/datum/modular_mob_segment/syndicate_team)
	reward_points = BITRUNNER_REWARD_MEDIUM
