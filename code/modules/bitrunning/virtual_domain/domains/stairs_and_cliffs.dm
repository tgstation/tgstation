/datum/lazy_template/virtual_domain/stairs_and_cliffs
	name = "Ледниковый откос"
	cost = BITRUNNER_COST_LOW
	desc = "Коварный подъем, который осилят немногие. Зато это отличное кардио."
	help_text = "Слышали когда-нибудь о \"Змеях и Лестницах\"? Так вот, это тоже самое, но \
	вместо лестниц - подъемы, а вместо змей - крутой спуск \
	с обрыва на жесткие камни или в жидкую плазму."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	completion_loot = list(/obj/item/clothing/suit/costume/snowman = 2)
	secondary_loot = list(/obj/item/clothing/shoes/wheelys/skishoes = 2, /obj/item/clothing/head/costume/ushanka/polar = 1)
	forced_outfit = /datum/outfit/job/virtual_domain_iceclimber
	key = "stairs_and_cliffs"
	map_name = "stairs_and_cliffs"
	reward_points = BITRUNNER_REWARD_MEDIUM
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/turf/open/cliff/snowrock/virtual_domain
	name = "icy cliff"
	initial_gas_mix = FROZEN_ATMOS

/turf/open/lava/plasma/virtual_domain
	name = "plasma lake"
	initial_gas_mix = FROZEN_ATMOS

/datum/outfit/job/virtual_domain_iceclimber
	name = "Ice Climber"

	uniform = /obj/item/clothing/under/color/grey
	backpack = /obj/item/storage/backpack/duffelbag
	shoes = /obj/item/clothing/shoes/winterboots
