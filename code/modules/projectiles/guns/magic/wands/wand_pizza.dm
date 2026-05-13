/**
 * Turns things you hit into pizza.
 */
/obj/item/gun/magic/wand/pizza
	name = "wand of snacking"
	desc = "The incredible power of this wand transforms certain objects and surfaces into edible pizza."
	school = SCHOOL_TRANSMUTATION
	ammo_type = /obj/item/ammo_casing/magic/pizza
	icon_state = "pizzawand"
	base_icon_state = "pizzawand"
	fire_sound = 'sound/effects/magic/staff_change.ogg'
	max_charges = 20

/obj/item/gun/magic/wand/pizza/zap_self(mob/living/user, suicide = FALSE)
	to_chat(user, span_notice("You can't bring yourself to commit to a permanent transformation into pizza right now."))
	return

/obj/item/gun/magic/wand/pizza/do_suicide(mob/living/user)
	charges--
	playsound(user, fire_sound, 50, TRUE)
	var/turf/user_loc = get_turf(user)
	user.unequip_everything()

	new /obj/effect/particle_effect/fluid/smoke(user_loc)

	var/list/slice_types = subtypesof(/obj/item/food/pizzaslice)
	var/special_slice = pick(slice_types)
	var/obj/item/pizza = new special_slice(user_loc)

	pizza.name = "[user.real_name] slice"
	user.ghostize()
	qdel(user)

	return MANUAL_SUICIDE

/obj/item/ammo_casing/magic/pizza
	projectile_type = /obj/projectile/magic/pizza
	harmful = FALSE

/obj/projectile/magic/pizza
	name = "bolt of snacking"
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pizzamargherita"

/obj/projectile/magic/pizza/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/turf/hit_turf = get_turf(target)
	var/datum/dimension_theme/pizza/converter = new()
	if(converter.can_convert(hit_turf))
		converter.apply_theme(hit_turf)

	var/mob/living/lunch_haver = target
	if (!istype(lunch_haver))
		return

	var/list/slice_types = subtypesof(/obj/item/food/pizzaslice)
	var/special_slice = pick(slice_types)

	var/obj/item/the_piz = new special_slice()

	if (!length(lunch_haver.held_items))
		the_piz.forceMove(lunch_haver.drop_location())
	else
		if (!iscarbon(lunch_haver))
			if (lunch_haver.put_in_hands(the_piz))
				if (lunch_haver.get_active_held_item() != the_piz)
					lunch_haver.swap_hand()
		else if (!lunch_haver.put_in_active_hand(the_piz))
			if (istype(lunch_haver.get_active_held_item(), /obj/item/food/pizzaslice))
				the_piz.forceMove(lunch_haver.drop_location())
			else
				// If you've got arms and refused to pick up pizza then woe be upon you
				var/obj/item/bodypart/my_arm = lunch_haver.get_active_hand()

				if (my_arm && my_arm.dismember())
					the_piz.forceMove(lunch_haver.drop_location())
				else
					// I would love to use plaintext_zone but what if they don't have an arm?
					var/hand_index = IS_LEFT_INDEX(lunch_haver.active_hand_index) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
					var/hand_zone = IS_LEFT_INDEX(lunch_haver.active_hand_index) ? "left arm" : "right arm"

					var/mob/living/carbon/edward_pizza_hands = lunch_haver
					edward_pizza_hands.make_item_prosthetic(the_piz, hand_index)
					edward_pizza_hands.visible_message(span_warning("[edward_pizza_hands]'s [hand_zone] is transformed into \a [the_piz]!"))

	lunch_haver.set_combat_mode(FALSE) // You can't eat pizza if you're on combat mode
	the_piz.attack(lunch_haver, lunch_haver)
