//Coded by Nexendia~ :)

/obj/item/dragon
	name = "Bad Dragon"
	desc = "You really shouldn't see this.. but if you do... Huzzah.. you found a bug.. please scream at Nexendia!" //Suck a dick Spacedong my shit not yours
	icon = 'hippiestation/icons/obj/dicks.dmi'
	icon_state = null
	force = 5
	w_class = 6
	throwforce = 5
	hitsound = 'hippiestation/sound/misc/squishy.ogg'
	attack_verb = list("slapped")

/obj/item/dragon/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is shoving [src.name] down \his throat! It looks like they're trying to commit suicide.</span>"))
	return(BRUTELOSS)

/obj/item/dragon/sea
	name = "Sea Dragon Dildo"
	desc = "It's damp."
	icon_state = "seadragon"
	force = 5
	throwforce = 5

/obj/item/dragon/canine
	name = "Canine Dildo"
	desc = "Taking the phrase \"dogging your mates\" to a whole new level."
	icon_state = "canine"
	force = 5
	throwforce = 7

/obj/item/dragon/equine
	name = "Equine Dildo"
	desc = "Yes, it's the whole horse."
	icon_state = "equine"
	force = 11
	throwforce = 9

/obj/structure/statue/dragon/shelf
	name = "Dragon Dildo Shelf"
	desc =  "Built to withstand your collection and your sins."
	icon = 'hippiestation/icons/obj/dicks.dmi'
	icon_state = "shelf1"

/obj/structure/statue/dragon/shelf/alt
	desc =  "Built to withstand your collection and your sins."
	icon_state = "shelf2"

