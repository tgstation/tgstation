//It's Wiz-Off, the wizard themed card game! It's modular too, in case you might want to make it Syndie, Sec and Clown themed or something stupid like that.
/obj/item/toy/cards/deck/wizoff
	name = "\improper Wiz-Off deck"
	desc = "A Wiz-Off deck. Fight an arcane battle for the fate of the universe: Draw 5! Play 5! Best of 5! A rules card is attached."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_wizoff_full"
	deckstyle = "wizoff"
	var/theme = "wizard"

/obj/item/toy/cards/deck/wizoff/populate_deck()
	var/card_list = strings("wizoff.json", theme)
	for(var/card in card_list)
		cards += generate_card("[card]")

/obj/item/toy/cards/deck/wizoff/examine_more(mob/user)
	. = ..()
	. += span_notice("Remember the rules of Wiz-Off!")
	. += "\t[span_info("Each player draws 5 cards.")]"
	. += "\t[span_info("There are five rounds. Each round, a player selects a card to play, and the winner is selected based on the following rules:")]"
	. += "\t[span_info("Defensive beats Offensive!")]"
	. += "\t[span_info("Offensive beats Utility!")]"
	. += "\t[span_info("Utility beats Defensive!")]"
	. += "\t[span_info("If both players play the same type of spell, the higher number wins!")]"
	. += "\t[span_info("The player who wins the most of the 5 rounds wins the game!")]"
	. += "\t[span_notice("Now get ready to battle for the fate of the universe: Wiz-Off!")]"
	return .
