/obj/item/reagent_containers/food/drinks/bottle/sarsaparilla
	name = "Sandblast Sarsaparilla"
	desc = "Sealed for a guaranteed fresh taste in every bottle."
	icon_state = "sandbottle"
	volume = 50
	list_reagents = list(/datum/reagent/medicine/molten_bubbles/sand = 50)
	reagent_flags = null //Cap's on
/*
/obj/item/reagent_containers/food/drinks/bottle/sarsaparilla/attack_self(mob/user)
	if(!is_drainable()) // Uses the reagents.flags cause reagent_flags is only the init value
		playsound(src, 'whitesands/sound/items/openbottle.ogg', 30, 1)
		user.visible_message("<span class='notice'>[user] takes the cap off \the [src].</span>", "<span class='notice'>You take the cap off [src].</span>")
		reagents.flags |= OPENCONTAINER //Cap's off
		if(prob(1)) //Lucky you
			var/S = new /obj/item/sandstar(src)
			user.put_in_hands(S)
			to_chat(user, "<span class='notice'>You found a Sandblast Star!</span>")
	else
		. = ..()
*/
/obj/item/reagent_containers/food/drinks/bottle/sarsaparilla/examine(mob/user)
	. = ..()
	if(!is_drainable())
		. += "<span class='info'>The cap is still sealed.</span>"

/obj/item/sandstar
	name = "SandBlast Sarsaparilla star"
	desc = "Legend says something amazing happens when you collect enough of these."
	custom_price = 100
	custom_premium_price = 110
	icon = 'voidcrew/icons/obj/items_and_weapons.dmi'
	icon_state = "sandstar"
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/gold = 200)

/obj/item/storage/bottles
	name = "bottle crate"
	desc = "A small crate for storing bottles"
	icon = 'voidcrew/icons/obj/storage.dmi'
	icon_state = "bottlecrate"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	custom_materials = list(/datum/material/wood = 800)
	w_class = WEIGHT_CLASS_BULKY
	var/sealed = FALSE

/obj/item/storage/bottles/Initialize()
	. = ..()
	update_icon()
/*
/obj/item/storage/bottles/ComponentInitialize()
	. = ..()
	var/datum/component/storage/S = GetComponent(/datum/component/storage)
	S.max_w_class = WEIGHT_CLASS_NORMAL
	S.max_combined_w_class = 16
	S.max_items = 6
	S.set_holdable(list(
		/obj/item/reagent_containers/food/drinks/beer,
		/obj/item/reagent_containers/food/drinks/ale,
		/obj/item/reagent_containers/food/drinks/bottle
	))
	S.locked = sealed

/obj/item/storage/bottles/update_icon_state()
	if(sealed)
		icon_state = "[initial(icon_state)]_seal"
	else
		icon_state = "[initial(icon_state)]_[contents.len]"
*/
/obj/item/storage/bottles/examine(mob/user)
	. = ..()
	if(sealed)
		. += "<span class='info'>It is sealed. You could pry it open with a <i>crowbar</i> to access its contents.</span>"
/*
/obj/item/storage/bottles/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(sealed)
		var/datum/component/storage/S = GetComponent(/datum/component/storage)
		user.visible_message("<span class='notice'>[user] prys open \the [src].</span>", "You pry open \the [src]")
		playsound(src, 'sound/machines/wooden_closet_close.ogg', 20, 1)
		sealed = FALSE
		S.locked = FALSE
		new /obj/item/stack/sheet/mineral/wood(get_turf(src), 1)
		update_icon()
		return TRUE
*/
/obj/item/storage/bottles/sandblast
	name = "sarsaparilla bottle crate"
	desc = "Holds six bottles of the finest sarsaparilla this side of the sector."
	sealed = TRUE

/obj/item/storage/bottles/sandblast/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/food/drinks/bottle/sarsaparilla(src)
