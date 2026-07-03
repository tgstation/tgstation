/obj/effect/landmark/mafia_game_area //locations where mafia will be loaded by the datum
	name = "Mafia Area Spawn"

/obj/effect/landmark/mafia
	name = "Mafia Player Spawn"

/obj/effect/landmark/mafia/town_center
	name = "Mafia Town Center"

//for ghosts/admins
/obj/mafia_game_board
	name = "Mafia Game Board"
	icon = 'icons/obj/mafia.dmi'
	icon_state = "board"
	anchored = TRUE
	var/datum/mafia_controller/MF

/obj/mafia_game_board/attack_ghost(mob/user)
	. = ..()
	if(!MF)
		MF = GLOB.mafia_game
	if(!MF)
		MF = create_mafia_game()
	MF.ui_interact(user)

/datum/map_template/mafia
	should_place_on_top = FALSE
	///The map suffix to put onto the mappath.
	var/map_suffix
	///A brief background tidbit
	var/description = ""
	///What costume will this map force players to start with?
	var/custom_outfit

/datum/map_template/mafia/New(path = null, rename = null, cache = FALSE)
	path = "_maps/minigame/mafia/" + map_suffix
	return ..()

//we only have one map in unit tests for consistency.
#ifdef UNIT_TESTS
/datum/map_template/mafia/unit_test
	name = "Mafia Unit Test"
	description = "A map designed specifically for Unit Testing to ensure the game runs properly."
	map_suffix = "mafia_unit_test.dmm"

#else

/datum/map_template/mafia/summerball
	name = "Summerball 2020"
	description = "Оригинал, OG. Summer ball 2020 - это место, где появилась мафия с этой картой."
	map_suffix = "mafia_ball.dmm"

/datum/map_template/mafia/ufo
	name = "Корабль пришельцев"
	description = "Тур с призраками и НЛО сорвался, теперь нашим прекрасным горожанам и любителям страшилок предстоит убить настоящих инопланетных генокрадов..."
	map_suffix = "mafia_ayylmao.dmm"
	custom_outfit = /datum/outfit/mafia/abductee

/datum/map_template/mafia/spider_clan
	name = "Похищение клана Пауков"
	description = "Новые и улучшенные похищения клана Паука менее скучны и содержат гораздо больше линчеваний."
	map_suffix = "mafia_spiderclan.dmm"
	custom_outfit = /datum/outfit/mafia/ninja

/datum/map_template/mafia/gothic
	name = "Замок вампиров"
	description = "Вампиры и генокрады вступают в схватку, чтобы выяснить, кто из кровососущих монстров лучше на этой карте жуткого замка."
	map_suffix = "mafia_gothic.dmm"
	custom_outfit = /datum/outfit/mafia/gothic

/datum/map_template/mafia/syndicate
	name = "Мегастанция синдиката"
	description = "Да, сегодня очень запутанный день на Мегастанции. Удастся ли оперативникам Синдиката разрешить конфликт?"
	map_suffix = "mafia_syndie.dmm"
	custom_outfit = /datum/outfit/mafia/syndie

/datum/map_template/mafia/snowy
	name = "Snowdin"
	description = "Основанная на одноименной карте Ice Moon. Парень, который переделал её, очень постарался. Круто!"
	map_suffix = "mafia_snow.dmm"
	custom_outfit = /datum/outfit/mafia/snowy

/datum/map_template/mafia/lavaland
	name = "Экскурсия по Лаваланду"
	description = "Станция понятия не имеет, что сейчас происходит на Лаваланде. У нас есть генокрады... предатели, и хуже всего... адвокаты, которые мешают вам каждую ночь."
	map_suffix = "mafia_lavaland.dmm"
	custom_outfit = /datum/outfit/mafia/lavaland

#endif
