SUBSYSTEM_DEF(trading_card_game)
	name = "Trading Card Game"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TCG
	var/card_directory = "strings/tcg"
	var/list/card_files = list("set_one.json","set_two.json")
	var/card_packs = list(/obj/item/cardpack/series_one, /obj/item/cardpack/resin)
	var/loaded = FALSE

//Let's load the cards before the map fires, so we can load cards on the map safely
/datum/controller/subsystem/trading_card_game/Initialize()
	reloadAllCardFiles(card_files, card_directory)
	return ..()
