// if you need to access this elsewhere you already fucked up
#define TRAIT_WARDROBE_USED "wardrobe_used"

/obj/structure/outfit_wardrobe
	name = "outfit wardrobe"
	desc = "Peek in and select one of several snazzy outfits. Narnia not included."
	icon = 'icons/obj/storage/closet.dmi'
	icon_state = "fullcabinet"
	base_icon_state = "fullcabinet"
	obj_flags = INDESTRUCTIBLE
	density = TRUE
	anchored = TRUE
	/**
	 * Assoc list of outfits to how many charges left.
	 * If value is INFINITY, the amount is infinite. Otherwise, it decreases by one per use.
	 * At zero it can't be picked.
	 * Value is unique per wardrobe.
	 */
	var/list/selectable_outfits_to_amount = list(
		/datum/outfit/cat_butcher = INFINITY,
		/datum/outfit/job/clown = 2,
		)
	/// Adds a trait with the source of wardrobe_id if this is TRUE, which is checked to prevent reuse.
	var/one_use = TRUE
	/// All wardrobes that share this id, share the one use restriction. If one_use is FALSE, it effectively does nothing.
	var/wardrobe_id = "asparagus"
	/// Humanize species that need unique environments to survive.
	var/humanize_plasmamen = TRUE

/obj/structure/outfit_wardrobe/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/human_user = user
	if(!ishuman(human_user))
		return

	if(one_use && HAS_TRAIT_FROM(human_user, TRAIT_WARDROBE_USED, wardrobe_id))
		to_chat(human_user, span_notice("You already picked an outfit!"))
		return

	var/list/display_classes = list()
	var/datum/outfit/chosen_class

	for(var/datum/outfit/dressup as anything in selectable_outfits_to_amount)
		if(selectable_outfits_to_amount[dressup] == 0)
			continue
		var/datum/radial_menu_choice/option = new(src)
		// We take the type of either the suit storage or head item (Likely to be relevant) or barring that the uniform
		var/obj/item/sprite_path = initial(dressup.suit_store) || initial(dressup.head) || initial(dressup.uniform)
		if(!sprite_path)
			stack_trace("[dressup] outfit got no god damn items to use for sprite")
			sprite_path = /obj/item/food/grown/citrus/orange_3d
		option.image  = image(icon = initial(sprite_path.icon), icon_state = initial(sprite_path.icon_state))
		option.info = span_boldnotice("[initial(dressup.name)]") // no desc..
		display_classes[dressup] = option

	if(!length(display_classes))
		to_chat(human_user, span_warning("There are no available outfits!"))
		return

	sort_list(display_classes)
	var/choice = show_radial_menu(human_user, src, display_classes, radius = 38, require_near = TRUE)
	if(!choice)
		return

	chosen_class = choice

	human_user.balloon_alert(human_user, LOWER_TEXT(chosen_class.name))
	playsound(human_user, 'sound/items/zip/un_zip.ogg', 33)
	playsound(src, 'sound/machines/closet/wooden_closet_open.ogg', 25)
	icon_state = "fullcabinet_open"
	if(!do_after(human_user, 3 SECONDS) || selectable_outfits_to_amount[choice] == 0)
		playsound(src, 'sound/machines/closet/wooden_closet_close.ogg', 50)
		icon_state = base_icon_state
		return
	selectable_outfits_to_amount[choice]--
	playsound(src, 'sound/machines/closet/wooden_closet_close.ogg', 50)
	icon_state = base_icon_state
	playsound(human_user, 'sound/items/zip/zip_up.ogg', 33)

	human_user.drop_everything()
	human_user.equipOutfit(chosen_class)
	ADD_TRAIT(human_user, TRAIT_WARDROBE_USED, wardrobe_id)

#undef TRAIT_WARDROBE_USED
