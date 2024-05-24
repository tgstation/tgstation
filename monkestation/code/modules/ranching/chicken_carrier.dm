/obj/item/chicken_carrier
	name = "chicken carrier"
	desc = "Useful for moving a chicken from one location to another"

	icon = 'goon/icons/items.dmi' //icon grabbed from the goonwiki which is under cc-by-sa 3.0 so in goon folder
	icon_state = "carrier"

	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_LPOCKET | ITEM_SLOT_RPOCKET | ITEM_SLOT_BELT

	///our stored chicken
	var/mob/living/basic/chicken/stored_chicken

/obj/item/chicken_carrier/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!user.CanReach(target))
		return ..()

	if(stored_chicken && isturf(target))
		user.visible_message(span_notice("[user] releases the [stored_chicken]."))
		SET_PLANE_EXPLICIT(stored_chicken, PLANE_TO_TRUE(initial(stored_chicken.plane)), target)
		stored_chicken.layer = initial(layer)
		stored_chicken.forceMove(target)
		stored_chicken = null
		update_appearance()
		return

	if(!istype(target, /mob/living/basic/chicken) && !istype(target, /mob/living/basic/chick))
		return ..()

	var/mob/living/basic/chicken/chicken_target = target
	if(stored_chicken)
		return ..()
	user.visible_message(span_notice("[user] scoops up the [chicken_target]."))
	chicken_target.forceMove(src)
	stored_chicken = chicken_target
	update_appearance()
	return

/obj/item/chicken_carrier/attackby(obj/item/attacking_item, mob/user, params)
	if(!stored_chicken)
		return .. ()

	if(istype(attacking_item, /obj/item/food) || istype(attacking_item, /obj/item/chicken_feed) && istype(stored_chicken))
		stored_chicken.attackby(attacking_item, user, params)
		return
	. = ..()

/obj/item/chicken_carrier/update_overlays()
	. = ..()
	if(!stored_chicken)
		return

	stored_chicken.pixel_x = 0
	stored_chicken.pixel_y = 0

	SET_PLANE_EXPLICIT(stored_chicken, PLANE_TO_TRUE(plane), src)
	stored_chicken.layer = layer - 0.1
	var/mutable_appearance/chicken_image = stored_chicken.appearance
	. += chicken_image

/obj/item/chicken_carrier/dropped(mob/user, silent)
	. = ..()
	update_appearance()

/obj/item/chicken_carrier/pickup(mob/user)
	. = ..()
	update_appearance()

/obj/item/chicken_carrier/on_mouse_enter(client/client) // we overwrite mouse enter with the stored chicken
	. = ..()
	if(stored_chicken)
		stored_chicken.on_mouse_enter(client)

/datum/design/chicken_carrier
	name = "Chicken Carrier"
	id = "chicken_carrier"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/chicken_carrier
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_BOTANY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE
