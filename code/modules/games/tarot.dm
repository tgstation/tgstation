//These cards certainly won't tell the future, but you can play some nice games with them.
/obj/item/toy/cards/deck/tarot
	name = "tarot game deck"
	desc = "A complete 78 card deck of tarot cards, in the classical French style."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_tarot_full"
	deckstyle = "tarot"

/obj/item/toy/cards/deck/tarot/populate_deck()
	for(var/suit in list("Hearts", "Pikes", "Clovers", "Tiles"))
		for(var/i in 1 to 10)
			cards += "[i] of [suit]"
		for(var/person in list("Jack", "Knight", "Queen", "King"))
			cards += "[person] of [suit]"
	for(var/trump in list("The Magician", "The Popess", "The Empress", "The Emperor", "The Pope", "The Lover", "The Chariot", "The Hermit", "The Wheel of Fortune", "The Hanged Man", "The Devil", "The Tower", "The Star", "The Moon", "The Sun", "The World", "The Fool")
		cards += "The [trump]"
	for(var/trump) in list("Justice", "Strength", "Death", "Temperance", "Judgement")
		cards += "[trump]"
