

/*
 * Wrapping Paper
 */

/obj/item/stack/wrapping_paper
	name = "wrapping paper"
	desc = "Wrap packages with this festive paper to make gifts."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "wrap_paper"
	inhand_icon_state = "wrap_paper"
	greyscale_config = /datum/greyscale_config/wrap_paper
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/wrapping_paper
	singular_name = "wrapping paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 5
	hitsound = 'sound/effects/bonk.ogg'

/obj/item/stack/wrapping_paper/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CUSTOM_TAP_SOUND, INNATE_TRAIT)

/obj/item/stack/wrapping_paper/attack(mob/living/target_mob, mob/living/user, list/modifiers)
	. = ..()
	user.visible_message(
		span_warning("[user] baps [target_mob] on the head with [src]!"),
		span_warning("You bap [target_mob] on the head with [src]!"),
	)
	target_mob.add_mood_event("roll", /datum/mood_event/bapped)

/obj/item/stack/wrapping_paper/Initialize(mapload)
	. = ..()
	if(!greyscale_colors)
		//Generate random valid colors for paper and ribbon
		var/generated_base_color = "#" + random_color()
		var/generated_ribbon_color = "#" + random_color()
		var/list/base_hsv = rgb2hsv(generated_base_color)
		var/list/ribbon_hsv = rgb2hsv(generated_ribbon_color)

		//If colors are too dark, set to original colors
		if(base_hsv[3] < 50)
			generated_base_color = COLOR_VIBRANT_LIME
		if(ribbon_hsv[3] < 50)
			generated_ribbon_color = COLOR_RED

		//Set layers to these colors, base then ribbon
		set_greyscale(colors = list(generated_base_color, generated_ribbon_color))

/obj/item/stack/wrapping_paper/click_alt(mob/user)
	var/new_base = input(user, "", "Select a base color", color) as color
	var/new_ribbon = input(user, "", "Select a ribbon color", color) as color
	if(!new_base || !new_ribbon)
		return CLICK_ACTION_BLOCKING

	set_greyscale(colors = list(new_base, new_ribbon))
	return CLICK_ACTION_SUCCESS

//preset wrapping paper meant to fill the original color configuration
/obj/item/stack/wrapping_paper/xmas
	greyscale_colors = "#00FF00#FF0000"

/obj/item/stack/wrapping_paper/use(used, transfer, check = TRUE)
	var/turf/T = get_turf(src)
	. = ..()
	if(QDELETED(src) && !transfer)
		new /obj/item/c_tube(T)

/obj/item/stack/wrapping_paper/small
	desc = "Wrap packages with this festive paper to make gifts. This roll looks a bit skimpy."
	amount = 10
	merge_type = /obj/item/stack/wrapping_paper/small

/*
 * Package Wrap
 */

/obj/item/stack/package_wrap
	name = "package wrapper"
	singular_name = "wrapping sheet"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "deliveryPaper"
	item_flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE
	grind_results = list(/datum/reagent/cellulose = 5)
	merge_type = /obj/item/stack/package_wrap

/obj/item/stack/package_wrap/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins wrapping [user.p_them()]self in \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	if(use(3))
		var/obj/item/delivery/big/parcel = new(get_turf(user.loc))
		parcel.base_icon_state = "deliverypackage5"
		parcel.update_icon()
		user.forceMove(parcel)
		parcel.add_fingerprint(user)
		return OXYLOSS
	else
		balloon_alert(user, "not enough paper!")
		return SHAME

/obj/item/proc/can_be_package_wrapped() //can the item be wrapped with package wrapper into a delivery package
	return TRUE

/obj/item/storage/can_be_package_wrapped()
	return FALSE

/obj/item/storage/box/can_be_package_wrapped()
	return TRUE

/obj/item/delivery/can_be_package_wrapped()
	return FALSE

/obj/item/stack/package_wrap/interact_with_atom(obj/interacting_with, mob/living/user, list/modifiers)
	if(!isobj(interacting_with))
		return NONE
	if(interacting_with.anchored)
		return NONE

	if(isitem(interacting_with))
		var/obj/item/item = interacting_with
		if(!item.can_be_package_wrapped())
			if(SHOULD_SKIP_INTERACTION(interacting_with, src, user))
				return NONE // put it in the bag instead of yelling
			balloon_alert(user, "can't be wrapped!")
			return ITEM_INTERACT_BLOCKING
		if(user.is_holding(item))
			if(!user.dropItemToGround(item))
				return ITEM_INTERACT_BLOCKING
		else if(!isturf(item.loc))
			return ITEM_INTERACT_BLOCKING
		if(use(1))
			var/obj/item/delivery/small/parcel = new(get_turf(item.loc))
			if(user.Adjacent(item))
				parcel.add_fingerprint(user)
				item.add_fingerprint(user)
				user.put_in_hands(parcel)
			item.forceMove(parcel)
			var/size = round(item.w_class)
			parcel.name = "[weight_class_to_text(size)] parcel"
			parcel.update_weight_class(size)
			size = min(size, 5)
			parcel.base_icon_state = "deliverypackage[size]"
			parcel.update_icon()
		else
			return ITEM_INTERACT_BLOCKING

	else if(istype(interacting_with, /obj/structure/closet))
		var/obj/structure/closet/closet = interacting_with
		if(closet.opened)
			balloon_alert(user, "can't wrap while open!")
			return ITEM_INTERACT_BLOCKING
		if(!closet.delivery_icon) //no delivery icon means unwrappable closet (e.g. body bags)
			balloon_alert(user, "can't wrap!")
			return ITEM_INTERACT_BLOCKING
		if(use(3))
			var/obj/item/delivery/big/parcel = new(get_turf(closet.loc))
			parcel.base_icon_state = closet.delivery_icon
			parcel.update_icon()
			parcel.drag_slowdown = closet.drag_slowdown
			closet.forceMove(parcel)
			parcel.add_fingerprint(user)
			closet.add_fingerprint(user)
		else
			balloon_alert(user, "not enough paper!")
			return ITEM_INTERACT_BLOCKING
	else if(istype(interacting_with,  /obj/machinery/portable_atmospherics))
		var/obj/machinery/portable_atmospherics/portable_atmospherics = interacting_with
		if(portable_atmospherics.anchored)
			balloon_alert(user, "can't wrap while anchored!")
			return ITEM_INTERACT_BLOCKING
		if(use(3))
			var/obj/item/delivery/big/parcel = new(get_turf(portable_atmospherics.loc))
			parcel.base_icon_state = "deliverybox"
			parcel.update_icon()
			parcel.drag_slowdown = portable_atmospherics.drag_slowdown
			portable_atmospherics.forceMove(parcel)
			parcel.add_fingerprint(user)
			portable_atmospherics.add_fingerprint(user)
		else
			balloon_alert(user, "not enough paper!")
			return ITEM_INTERACT_BLOCKING

	else
		balloon_alert(user, "can't wrap!")
		return ITEM_INTERACT_BLOCKING

	user.visible_message(span_notice("[user] wraps [interacting_with]."))
	user.log_message("has used [name] on [key_name(interacting_with)]", LOG_ATTACK, color="blue")
	return ITEM_INTERACT_SUCCESS

/obj/item/stack/package_wrap/use(used, transfer = FALSE, check = TRUE)
	var/turf/T = get_turf(src)
	. = ..()
	if(QDELETED(src) && !transfer)
		new /obj/item/c_tube(T)

/obj/item/stack/package_wrap/small
	desc = "You can use this to wrap items in. This roll looks a bit skimpy."
	w_class = WEIGHT_CLASS_SMALL
	amount = 5
	merge_type = /obj/item/stack/package_wrap/small

/obj/item/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "c_tube"
	inhand_icon_state = "c_tube"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 5
	hitsound = 'sound/effects/bonk.ogg'

/obj/item/c_tube/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CUSTOM_TAP_SOUND, INNATE_TRAIT)

/obj/item/c_tube/attack(mob/living/target_mob, mob/living/user, list/modifiers)
	. = ..()
	user.visible_message(
		span_warning("[user] baps [target_mob] on the head with [src]!"),
		span_warning("You bap [target_mob] on the head with [src]!"),
	)
	target_mob.add_mood_event("roll", /datum/mood_event/bapped)

