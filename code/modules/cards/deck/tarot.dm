//These cards certainly won't tell the future, but you can play some nice games with them.
/obj/item/toy/cards/deck/tarot
	name = "tarot game deck"
	desc = "A full 78 card game deck of tarot cards. Complete with 4 suites of 14 cards, and a full suite of trump cards."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_tarot_full"
	deckstyle = "tarot"

/obj/item/toy/cards/deck/tarot/populate_deck()
	for(var/suit in list("Hearts", "Pikes", "Clovers", "Tiles"))
		for(var/i in 1 to 10)
			cards += generate_card("[i] of [suit]")
		for(var/person in list("Valet", "Chevalier", "Dame", "Roi"))
			cards += generate_card("[person] of [suit]")
	for(var/trump in list("The Magician", "The High Priestess", "The Empress", "The Emperor", "The Hierophant", "The Lover", "The Chariot", "Justice", "The Hermit", "The Wheel of Fortune", "Strength", "The Hanged Man", "Death", "Temperance", "The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World", "The Fool"))
		cards += generate_card("[trump]")

/obj/item/toy/cards/deck/tarot/draw_card(mob/user, list/cards, obj/item/toy/cards/singlecard/forced_card = null)
	. = ..()
	var/obj/item/toy/cards/singlecard/C = .
	var/matrix/M = matrix()
	M.Turn(180)
	if(prob(50))
		C.transform = M
	return
