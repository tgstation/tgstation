/obj/item/weapon/storage/backpack/deckgriffening
	name = "Deck of griffening cards"
	desc = "A deck for holding some griffening cards."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_nanotrasen_full"
	max_w_class = WEIGHT_CLASS_TINY
	w_class = WEIGHT_CLASS_TINY
	max_combined_w_class = 100
	storage_slots = 100
	var/isboosterpack = FALSE //Option to delete the bag + get to search through it without the input prompt

/obj/item/weapon/storage/backpack/deckgriffening/Initialize()
	. = ..()

/obj/item/weapon/storage/backpack/deckgriffening/examine(mob/user)
	to_chat(user, "<b>[src] has [contents.len] cards left in it.</b>")

/obj/item/weapon/storage/backpack/deckgriffening/handle_item_insertion(obj/item/W, FALSE, mob/user) //False is the prevent_warning var, which is for hidin stuff
	..() //I wanna call the parent proc or else this all breaks
	if(istype(W, /obj/item/griffening_single))
		user.visible_message("<span class='notice'>[user.name] puts the [W.name] into the [src.name].</span>")
		return
	if(istype(W, /obj/item/weapon/storage/backpack/deckgriffening/discardpile))
		..()
	if(istype(W, /obj/item/weapon/storage/backpack/deckgriffening/gibbedpile))
		..()
	if(istype(W, /obj/item/weapon/storage/backpack/deckgriffening/starterpack))
		..()
	if(!W) //Empty hand or non existing item
		return
	if(!istype(W, /obj/item/griffening_single))
		return

/obj/item/weapon/storage/backpack/deckgriffening/remove_from_storage(obj/item/W, atom/new_location) //I don't even know what im doing but I hope it works
	..()
	W.visible_message("<span class='notice'>.</span>")

/obj/item/weapon/storage/backpack/deckgriffening/attack_self(mob/user)
	if(!isboosterpack)
		var/safety = alert(user, "What do you wish to do?", "What do you wish to do?", "Draw", "Abort")
		if(safety == "Abort" && !in_range(src, user) && !user.incapacitated())
			src.close_all() //Just in case it's left open for some reason
			return
		if(safety == "Draw" && in_range(src, user) && !user.incapacitated())
			user.visible_message("<span class='notice'>[user.name] draws a card from their deck.</span>")
			var/obj/item/griffening_single/randomcard = pick(contents)
			user.put_in_hands(randomcard)
		else
			return //>Edge case
	else
		return

/obj/item/weapon/storage/backpack/deckgriffening/discardpile //Types paths so you can put cards in somewhere if it's discarded or gibbed
	name = "Griffening Discard Pile"
	desc = "A storage container for cards sent to the discard pile"

/obj/item/weapon/storage/backpack/deckgriffening/gibbedpile
	name = "Griffening Gibbed Pile"
	desc = "A storage container for cards sent to the gibbed pile"

/obj/item/weapon/storage/backpack/deckgriffening/starterpack //A storage container for holding the gibbed, discard and deck piles when walking around
	name = "Griffening game holder"
	desc = "A storage container for holding everything you need to play Griffening."

/obj/item/weapon/storage/backpack/deckgriffening/starterpack/PopulateContents()
	new /obj/item/griffening_boosterpack/deck40(src)
	new /obj/item/weapon/storage/backpack/griffeningholder(src)
	new /obj/item/weapon/storage/backpack/deckgriffening/discardpile(src)
	new /obj/item/weapon/storage/backpack/deckgriffening/gibbedpile(src)
