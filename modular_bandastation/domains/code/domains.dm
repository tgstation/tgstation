#define SPAWN_ALWAYS 100
#define SPAWN_LIKELY 85
#define SPAWN_UNLIKELY 35
#define SPAWN_RARE 10

/datum/lazy_template/virtual_domain/inka_base
	name = "Зачистка Инки"
	announce_to_ghosts = TRUE
	cost = BITRUNNER_COST_HIGH
	desc = "Зачистите базу Нанотрейзен во время нападения синдиката и заберите секретные данные."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	completion_loot = list(/obj/item/toy/plush/hampter/ert = 1)
	help_text = "Группа из оперативников Синдиката нападает на секретную базу Нанотрейзен. \
	Они только заходят на объект. Проникните на защищённую базу и \
	заберите секретные документы. Будьте осторожны, защитники и нападающие \
	очень хорошо вооружены."
	is_modular = TRUE
	forced_outfit = /datum/outfit/tsf/bitrun
	key = "inka_base"
	map_name = "inka_base"
	mob_modules = list(/datum/modular_mob_segment/nanotrasen_team)
	reward_points = BITRUNNER_REWARD_HIGH

/datum/modular_mob_segment/nanotrasen_team
	max = 2
	/// The list of mobs to spawn
	mobs = list(
		/mob/living/basic/trooper/nanotrasen/ranged/assault,
		/mob/living/basic/trooper/nanotrasen/ranged/smg,
		/mob/living/basic/trooper/nanotrasen/ranged/elite
		)
	/// Chance this will spawn (1 - 100)
	probability = SPAWN_LIKELY

/datum/outfit/tsf/bitrun
	name = "TSF - Marine (Bitrun)"
	uniform = /obj/item/clothing/under/rank/tsf/marine
	id = /obj/item/card/id/advanced
	back = /obj/item/storage/backpack/tsf
	head = /obj/item/clothing/head/beret/tsf_marine
	shoes = /obj/item/clothing/shoes/jackboots

#undef SPAWN_ALWAYS
#undef SPAWN_LIKELY
#undef SPAWN_UNLIKELY
#undef SPAWN_RARE
