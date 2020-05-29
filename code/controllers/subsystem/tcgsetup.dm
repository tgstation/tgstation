GLOBAL_LIST_INIT(card_files, list("set_one.json","set_two.json"))
GLOBAL_VAR_INIT(card_directory, "strings/tcg")
GLOBAL_LIST_INIT(card_packs, list(/obj/item/cardpack/series_one, /obj/item/cardpack/resin))
SUBSYSTEM_DEF(trading_card_game)
	name = "Trading Card Game"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TCG

//Let's load the cards before the map fires, so we can load cards on the map safely
/datum/controller/subsystem/trading_card_game/Initialize()
	reloadAllCardFiles(GLOB.card_files, GLOB.card_directory)
	return ..()
