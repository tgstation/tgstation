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

/datum/lazy_template/virtual_domain/water_grot
	name = "Водный сплав"
	cost = BITRUNNER_COST_LOW
	desc = "Доплыть до конца."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	help_text = "Награда ждет тебя в самом конце."
	key = "water_grot"
	map_name = "water_grot"
	reward_points = BITRUNNER_REWARD_LOW

/turf/open/water/groundwater
	name = "глубокие грунтовые воды"
	desc = "Холодная и чистая вода, просачивающаяся сквозь породы."
	immerse_overlay = "immerse_deep"
	icon = 'modular_bandastation/turfs/icons/water.dmi'
	icon_state = "water"
	base_icon_state = "water"
	baseturfs = /turf/open/water/groundwater
	is_swimming_tile = TRUE

/obj/effect/abstract/whirlpool
	name = "водоворот"
	desc = "Воронка на поверхности воды, затягивающая в пучину всё, что приближается."
	icon = 'modular_bandastation/turfs/icons/water.dmi'
	icon_state = "whirlpool"
	layer = ABOVE_OPEN_TURF_LAYER

/obj/effect/abstract/whirlpool/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	if(T && !T.GetComponent(/datum/component/chasm))
		T.AddComponent(/datum/component/chasm, null, mapload)

/obj/effect/abstract/mist
	name = "туман"
	desc = "Густой туман над водой."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
