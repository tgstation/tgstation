//Coded by Nexendia~

/obj/item/dragon
	name = "Bad Dragon"
	desc = "You really shouldn't see this.. but if you do... Huzzah.. you found a bug.. please scream at Nexendia!"
	icon = 'icons/obj/dicks.dmi'
	icon_state = null
	force = 5
	w_class = 1
	throwforce = 5
	hitsound = 'sound/items/squishy.ogg'
	attack_verb = list("slapped")

/obj/item/dragon/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is shoving [src.name] down \his throat! It looks like they're trying to commit suicide.</span>"))
	return(BRUTELOSS)

/obj/item/dragon/sea
	name = "Sea Dragon Dildo"
	desc = "A Sea Dragon Dildo, Why this is on a SpaceStation we will never know..."
	icon_state = "seadragon"
	force = 5
	w_class = 2
	throwforce = 5

/obj/item/dragon/canine
	name = "Canine Dildo"
	desc = "A Canine Dildo, Why this is on a SpaceStation we will never know..."
	icon_state = "canine"
	force = 5
	w_class = 2
	throwforce = 7

/obj/item/dragon/equine
	name = "Equine Dildo"
	desc = "A fucking Horse Cock!?  WHY!  Why do we have this shit on a Space Station..."
	icon_state = "equine"
	force = 11
	w_class = 3
	throwforce = 9

/obj/structure/statue/dragon/shelf
	name = "Dragon Dildo Shelf"
	desc = "A shelf for all your fucking oversized Dildos.."
	icon = 'icons/obj/dicks.dmi'
	icon_state = "shelf1"

/obj/structure/statue/dragon/shelf/alt
	name = "Dragon Dildo Shelf"
	desc = "A shelf for all your fucking oversized Dildos.."
	icon_state = "shelf2"