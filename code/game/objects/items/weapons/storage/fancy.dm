/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * WARNING: var/icon_type is used for both examine text and sprite name. Please look at the procs below and adjust your sprite names accordingly
 *		TODO: Cigarette boxes should be ported to this standard
 *
 * Contains:
 *		Donut Box
 *		Egg Box
 *		Candle Box
 *		Cigarette Box
 *		Cigar Case
 */

/obj/item/weapon/storage/fancy
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "donutbox6"
	name = "donut box"
	resistance_flags = FLAMMABLE
	var/icon_type = "donut"
	var/spawn_type = null
	var/fancy_open = FALSE

/obj/item/weapon/storage/fancy/PopulateContents()
	for(var/i = 1 to storage_slots)
		new spawn_type(src)

/obj/item/weapon/storage/fancy/update_icon(itemremoved = 0)
	if(fancy_open)
		var/total_contents = src.contents.len - itemremoved
		icon_state = "[icon_type]box[total_contents]"
	else
		icon_state = "[icon_type]box"

/obj/item/weapon/storage/fancy/examine(mob/user)
	..()
	if(fancy_open)
		if(contents.len == 1)
			to_chat(user, "There is one [src.icon_type] left.")
		else
			to_chat(user, "There are [contents.len <= 0 ? "no" : "[src.contents.len]"] [src.icon_type]s left.")

/obj/item/weapon/storage/fancy/attack_self(mob/user)
	fancy_open = !fancy_open
	update_icon()

/obj/item/weapon/storage/fancy/content_can_dump(atom/dest_object, mob/user)
	. = ..()
	if(.)
		fancy_open = TRUE
		update_icon()

/obj/item/weapon/storage/fancy/handle_item_insertion(obj/item/W, prevent_warning = 0, mob/user)
	fancy_open = TRUE
	return ..()

/obj/item/weapon/storage/fancy/remove_from_storage(obj/item/W, atom/new_location, burn = 0)
	fancy_open = TRUE
	return ..()

/*
 * Donut Box
 */

/obj/item/weapon/storage/fancy/donut_box
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "donutbox6"
	icon_type = "donut"
	name = "donut box"
	storage_slots = 6
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/donut)
	spawn_type = /obj/item/weapon/reagent_containers/food/snacks/donut
	fancy_open = TRUE

/*
 * Egg Box
 */

/obj/item/weapon/storage/fancy/egg_box
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "eggbox"
	icon_type = "egg"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	name = "egg box"
	storage_slots = 12
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	spawn_type = /obj/item/weapon/reagent_containers/food/snacks/egg

/*
 * Candle Box
 */

/obj/item/weapon/storage/fancy/candle_box
	name = "candle pack"
	desc = "A pack of red candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox5"
	icon_type = "candle"
	item_state = "candlebox5"
	storage_slots = 5
	throwforce = 2
	slot_flags = SLOT_BELT
	spawn_type = /obj/item/candle
	fancy_open = TRUE

/obj/item/weapon/storage/fancy/candle_box/attack_self(mob_user)
	return

////////////
//CIG PACK//
////////////
/obj/item/weapon/storage/fancy/cigarettes
	name = "\improper Space Cigarettes packet"
	desc = "The most popular brand of cigarettes, sponsors of the Space Olympics."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig"
	item_state = "cigpacket"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	slot_flags = SLOT_BELT
	storage_slots = 6
	can_hold = list(/obj/item/clothing/mask/cigarette, /obj/item/weapon/lighter)
	icon_type = "cigarette"
	spawn_type = /obj/item/clothing/mask/cigarette/space_cigarette

/obj/item/weapon/storage/fancy/cigarettes/AltClick(mob/user)
	if(user.get_active_held_item())
		return
	for(var/obj/item/weapon/lighter/lighter in src)
		remove_from_storage(lighter, user.loc)
		user.put_in_active_hand(lighter)
		break

/obj/item/weapon/storage/fancy/cigarettes/update_icon()
	if(fancy_open || !contents.len)
		cut_overlays()
		if(!contents.len)
			icon_state = "[initial(icon_state)]_empty"
		else
			icon_state = initial(icon_state)
			add_overlay("[icon_state]_open")
			var/i = contents.len
			for(var/C in contents)
				var/mutable_appearance/inserted_overlay = mutable_appearance(icon)
				inserted_overlay.pixel_x = 1 * (i - 1)
				if(istype(C, /obj/item/weapon/lighter/greyscale))
					inserted_overlay.icon_state = "lighter_in"
				else if(istype(C, /obj/item/weapon/lighter))
					inserted_overlay.icon_state = "zippo_in"
				else
					inserted_overlay.icon_state = "cigarette"
				add_overlay(inserted_overlay)
				i--
	else
		cut_overlays()

/obj/item/weapon/storage/fancy/cigarettes/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!ismob(M))
		return
	var/obj/item/clothing/mask/cigarette/cig = locate(/obj/item/clothing/mask/cigarette) in contents
	if(cig)
		if(M == user && contents.len > 0 && !user.wear_mask)
			var/obj/item/clothing/mask/cigarette/W = cig
			remove_from_storage(W, M)
			M.equip_to_slot_if_possible(W, slot_wear_mask)
			contents -= W
			to_chat(user, "<span class='notice'>You take a [icon_type] out of the pack.</span>")
		else
			..()
	else
		to_chat(user, "<span class='notice'>There are no [icon_type]s left in the pack.</span>")

/obj/item/weapon/storage/fancy/cigarettes/dromedaryco
	name = "\improper DromedaryCo packet"
	desc = "A packet of six imported DromedaryCo cancer sticks. A label on the packaging reads, \"Wouldn't a slow death make a change?\""
	icon_state = "dromedary"
	spawn_type = /obj/item/clothing/mask/cigarette/dromedary

/obj/item/weapon/storage/fancy/cigarettes/cigpack_uplift
	name = "\improper Uplift Smooth packet"
	desc = "Your favorite brand, now menthol flavored."
	icon_state = "uplift"
	spawn_type = /obj/item/clothing/mask/cigarette/uplift

/obj/item/weapon/storage/fancy/cigarettes/cigpack_robust
	name = "\improper Robust packet"
	desc = "Smoked by the robust."
	icon_state = "robust"
	spawn_type = /obj/item/clothing/mask/cigarette/robust

/obj/item/weapon/storage/fancy/cigarettes/cigpack_robustgold
	name = "\improper Robust Gold packet"
	desc = "Smoked by the truly robust."
	icon_state = "robustg"
	spawn_type = /obj/item/clothing/mask/cigarette/robustgold

/obj/item/weapon/storage/fancy/cigarettes/cigpack_carp
	name = "\improper Carp Classic packet"
	desc = "Since 2313."
	icon_state = "carp"
	spawn_type = /obj/item/clothing/mask/cigarette/carp

/obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate
	name = "cigarette packet"
	desc = "An obscure brand of cigarettes."
	icon_state = "syndie"
	spawn_type = /obj/item/clothing/mask/cigarette/syndicate

/obj/item/weapon/storage/fancy/cigarettes/cigpack_midori
	name = "\improper Midori Tabako packet"
	desc = "You can't understand the runes, but the packet smells funny."
	icon_state = "midori"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie

/obj/item/weapon/storage/fancy/cigarettes/cigpack_shadyjims
	name = "\improper Shady Jim's Super Slims packet"
	desc = "Is your weight slowing you down? Having trouble running away from gravitational singularities? Can't stop stuffing your mouth? Smoke Shady Jim's Super Slims and watch all that fat burn away. Guaranteed results!"
	icon_state = "shadyjim"
	spawn_type = /obj/item/clothing/mask/cigarette/shadyjims

/obj/item/weapon/storage/fancy/rollingpapers
	name = "rolling paper pack"
	desc = "A pack of Nanotrasen brand rolling papers."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	storage_slots = 10
	icon_type = "rolling paper"
	can_hold = list(/obj/item/weapon/rollingpaper)
	spawn_type = /obj/item/weapon/rollingpaper

/obj/item/weapon/storage/fancy/rollingpapers/update_icon()
	cut_overlays()
	if(!contents.len)
		add_overlay("[icon_state]_empty")

/////////////
//CIGAR BOX//
/////////////

/obj/item/weapon/storage/fancy/cigarettes/cigars
	name = "\improper premium cigar case"
	desc = "A case of premium cigars. Very expensive."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigarcase"
	w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 5
	can_hold = list(/obj/item/clothing/mask/cigarette/cigar)
	icon_type = "premium cigar"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar

/obj/item/weapon/storage/fancy/cigarettes/cigars/update_icon()
	cut_overlays()
	if(fancy_open)
		add_overlay("[icon_state]_open")
		var/mutable_appearance/cigar_overlay = mutable_appearance(icon, icon_type)
		for(var/c = contents.len, c >= 1, c--)
			cigar_overlay.pixel_x = 4 * (c - 1)
			add_overlay(cigar_overlay)
	else
		icon_state = "cigarcase"

/obj/item/weapon/storage/fancy/cigarettes/cigars/cohiba
	name = "\improper cohiba robusto cigar case"
	desc = "A case of imported Cohiba cigars, renowned for their strong flavor."
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/cohiba

/obj/item/weapon/storage/fancy/cigarettes/cigars/havana
	name = "\improper premium havanian cigar case"
	desc = "A case of classy Havanian cigars."
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/havana
