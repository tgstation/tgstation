/obj/item/weapon/storage/backpack/griffeningholder
	name = "Griffening Card Holder"
	desc = "A bag that's meant to hold cards, use this as a hand for playing the game."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nanotrasen_hand2"
	var/deckstyle = "nanotrasen"
	var/list/currenthand = list()
	max_w_class = WEIGHT_CLASS_TINY
	w_class = WEIGHT_CLASS_TINY
	max_combined_w_class = 100 //This can't possibly go wrong

/obj/item/weapon/storage/backpack/griffeningholder/Initialize()
	. = ..()

/obj/item/weapon/storage/backpack/griffeningholder/handle_item_insertion(obj/item/W, mob/user)
	. = ..() //Apparently prevents overriding parent procs, go figure
	if(.)
		if(!istype(W, /obj/item/griffening_single))
			to_chat(user, "You can't put that in here.")
			return
		if(istype(W, /obj/item/weapon/storage/backpack/griffeningholder))
			to_chat(user, "You can't comprehend on how you can put two objects that are the same into each other.")
			return
		if(istype(W, /obj/item/weapon/storage/backpack/deckgriffening))
			to_chat(user, "You feel like that putting the entire deck into a object meant to be your hand would be breaking some universal law.")
			return
		if(istype(W, /obj/item/griffening_single))
			..()
