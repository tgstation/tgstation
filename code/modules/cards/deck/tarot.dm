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

/obj/item/toy/cards/deck/tarot/haunted
	name = "haunted tarot game deck"
	desc = "A spooky looking tarot deck. You can sense a supernatural presence linked to the cards..."
	var/mob/living/carbon/psychic // the person holding the cards

/obj/item/toy/cards/deck/tarot/haunted/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/// Triggered on wield of two handed item
/// Gives the user the SIXTH SENSE trait to communicate with the dead
/obj/item/toy/cards/deck/tarot/haunted/proc/on_wield(obj/item/source, mob/living/carbon/user)
	SIGNAL_HANDLER

	wielded = TRUE
	ADD_TRAIT(user, TRAIT_SIXTHSENSE, MAGIC_TRAIT)
	to_chat(user, span_notice("The veil to the underworld is opened. You can sense the dead souls calling out..."))

/// Triggered on unwield of two handed item
/// Removes the SIXTH SENSE trait from the user
/obj/item/toy/cards/deck/tarot/haunted/proc/on_unwield(obj/item/source, mob/living/carbon/user)
	SIGNAL_HANDLER

	wielded = FALSE
	REMOVE_TRAIT(user, TRAIT_SIXTHSENSE, MAGIC_TRAIT)
	to_chat(user, span_notice("The veil to the underworld closes shut. You feel your senses returning to normal."))
