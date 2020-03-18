#define CARD_FILES list("templates", "set_one")
#define CARD_DIRECTORY "strings/tcg"
SUBSYSTEM_DEF(trading_card_game)
	name = "Trading Card Game"
	flags = SS_NO_FIRE

/datum/controller/subsystem/trading_card_game/Initialize()
	reloadAllCardFiles(CARD_FILES, CARD_DIRECTORY)
	. = ..()
