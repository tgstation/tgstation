#define CARD_FILES list("set_one.json","set_two.json")
#define CARD_DIRECTORY "strings/tcg"
#define CARD_PACKS list(/obj/item/cardpack/series_one, /obj/item/cardpack/resin)
SUBSYSTEM_DEF(trading_card_game)
	name = "Trading Card Game"
	flags = SS_NO_FIRE

/datum/controller/subsystem/trading_card_game/Initialize()
	reloadAllCardFiles(CARD_FILES, CARD_DIRECTORY)
	. = ..()
