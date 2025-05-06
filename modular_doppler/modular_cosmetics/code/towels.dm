/// Default shape of the towel, when it's folded.
#define TOWEL_FOLDED ""
/// Chest-down variant of the towel.
#define TOWEL_FULL "chest"
/// Waist-down variant of the towel.
#define TOWEL_WAIST "waist"
/// Head variant of the towel.
#define TOWEL_HEAD "head"
/// Shape of the towel when it has been used, and is no longer neatly folded.
#define TOWEL_USED "used"

/// Icon path to the obj icon of the towel.
#define TOWEL_OBJ_ICON 'modular_doppler/modular_cosmetics/icons/obj/suit/towel.dmi'

/// How much cloth goes into a towel.
#define TOWEL_CLOTH_AMOUNT 2

/// Ratio of how much reagents are lost when a towel is wrung.
#define TOWEL_WRING_LOSS_FACTOR 0.5
/// How many reagents can be wrung at once.
#define TOWEL_WRING_AMOUNT 10

/// Portion (out of 1) of reagents that are lost during the transfer from a towel to a container.
#define SQUEEZING_DISPERSAL_RATIO 0.75


/obj/item/towel
	name = "towel"
	desc = "Everyone knows what a towel is. Use it to dry yourself, or wear it around your chest, your waist or even your head!"
	icon = TOWEL_OBJ_ICON
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/towel.dmi'
	icon_state = "towel"
	base_icon_state = "towel"
	lefthand_file = 'modular_doppler/modular_cosmetics/icons/mob/inhands/towel_lefthand.dmi'
	righthand_file = 'modular_doppler/modular_cosmetics/icons/mob/inhands/towel_righthand.dmi'
	inhand_icon_state = "towel"
	force = 0
	throwforce = 0
	throw_speed = 1
	throw_range = 2 // They're not very aerodynamic.
	w_class = WEIGHT_CLASS_SMALL // Don't ask me why other cloth-related items are considered tiny, and not small like this one.
	item_flags = NOBLUDGEON
	resistance_flags = FLAMMABLE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(BODYSHAPE_HUMANOID_T = 'modular_doppler/modular_cosmetics/icons/mob/suit/towel.dmi',
	BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/suit/towel_digi.dmi')
	/// The shape we're currently in.
	var/shape = TOWEL_FOLDED
	/// How many units of liquid can this towel store?
	var/max_reagent_volume = 25
	/// Are we currently wet?
	var/wet = FALSE


/obj/item/towel/Initialize(mapload)
	. = ..()

	create_reagents(max_reagent_volume)
	register_context()
	register_item_context()


/obj/item/towel/examine(mob/user)
	. = ..()

	if(wet)
		. += span_notice("\nIt appears to be wet.")


	if(!ishuman(user) && !iscyborg(user))
		return

	. += "" // Just for an empty line

	var/in_hands = TRUE
	if(ishuman(user))
		in_hands = user.get_active_held_item() == src || user.get_inactive_held_item() == src

		if(in_hands)
			. += span_notice("<b>Use in hand</b> to shape [src] into something different.")

	if(in_hands && shape != TOWEL_FOLDED)
		. += span_notice("<b>Ctrl-click</b> to [wet && ishuman(user) ? "wring parts of the liquids out of [src]" : "fold [src] neatly"].")

	if(iscyborg(user))
		return

	if(shape == TOWEL_FULL || shape == TOWEL_WAIST)
		. += span_notice("<b>Alt-click</b> to adjust the fit of [src].")

	if(wet)
		. += span_notice("<b>Right-click</b> [src] on a bucket to wring the liquids out of it and transfer a portion of them to the bucket.")
		. += span_notice("<b>Wash in a washing machine</b> in order to clean [src].")


/obj/item/towel/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(istype(held_item) && (held_item.tool_behaviour == TOOL_WIRECUTTER || held_item.get_sharpness()) && !(flags_1 & HOLOGRAM_1))
		context[SCREENTIP_CONTEXT_LMB] = "Shred into cloth"

	if(ishuman(user))
		if((shape == TOWEL_FULL || shape == TOWEL_WAIST))
			context[SCREENTIP_CONTEXT_ALT_LMB] = "Adjust Fit"

		var/mob/living/carbon/human/towel_user = user
		var/worn = towel_user.wear_suit == src || towel_user.head == src

		if(!worn)
			context[SCREENTIP_CONTEXT_LMB] = "Change Shape"
			context[SCREENTIP_CONTEXT_CTRL_LMB] = wet ? "Wring" : "Fold"

	if(iscyborg(user))
		context[SCREENTIP_CONTEXT_CTRL_LMB] = wet ? "Wring" : "Fold"

	return CONTEXTUAL_SCREENTIP_SET


/obj/item/towel/add_item_context(datum/source, list/context, mob/living/target)
	if(isliving(target) && target.fire_stacks < 0) // If the target indeed is a living mob, and has wet stacks (which are just negative fire stacks)
		context[SCREENTIP_CONTEXT_LMB] = "Dry up"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE


/obj/item/towel/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()
	if(!user.Adjacent(target_mob))
		return

	var/free_space = reagents.maximum_volume - reagents.total_volume
	if(free_space <= 0)
		to_chat(user, span_warning("Your [src] can't absorb any more liquid!"))
		return

	var/cleaning_themselves = target_mob == user

	target_mob.visible_message(span_notice("[user] starts drying [cleaning_themselves ? "themselves" : target_mob] up with [src]."), span_notice("[cleaning_themselves ? "You start drying yourself" : "[user] starts drying you"] up with \the [src]."), ignored_mobs = cleaning_themselves ? null : user)

	if(!cleaning_themselves)
		to_chat(user, span_notice("You start drying [target_mob] up with [src]."))

	if(!do_after(user, 2 SECONDS, src))
		to_chat(user, span_notice("You stop drying [target_mob]."))
		return


	target_mob.visible_message(span_notice("[user] finishes drying [cleaning_themselves ? "themselves" : target_mob] up with [src]."), span_notice("[cleaning_themselves ? "You finish drying yourself" : "[user] finishes drying you "] up with \the [src]."), ignored_mobs = cleaning_themselves ? null : user)

	if(!cleaning_themselves)
		to_chat(user, span_notice("You finish drying [target_mob] up with [src]."))

	var/water_to_remove = min(max(-target_mob.fire_stacks, 0), free_space)

	if(!water_to_remove)
		return

	reagents.add_reagent(/datum/reagent/water, water_to_remove)
	target_mob.set_wet_stacks(0, remove_fire_stacks = FALSE)

	set_wet(TRUE, update_visuals = shape != TOWEL_FOLDED)

	if(shape == TOWEL_FOLDED)
		change_towel_shape(user, TOWEL_USED, TRUE)


/obj/item/towel/attack_self(mob/user, modifiers)
	. = ..()

	/// Initializing this only once to avoid having to do it every time
	var/static/list/datum/radial_menu_choice/worn_options = list()

	if(!length(worn_options))
		for(var/variant in list(TOWEL_FULL, TOWEL_WAIST, TOWEL_HEAD))
			var/datum/radial_menu_choice/option = new
			var/image/variant_image = image(icon = TOWEL_OBJ_ICON, icon_state = "[base_icon_state]-[variant]")

			option.image = variant_image
			worn_options[capitalize(variant)] = option

	var/choice = show_radial_menu(user, src, worn_options, require_near = TRUE, tooltips = TRUE)

	if(!choice)
		return

	change_towel_shape(user, LOWER_TEXT(choice))


/obj/item/towel/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()

	if(!(attacking_item.tool_behaviour == TOOL_WIRECUTTER || attacking_item.get_sharpness()))
		return

	if(flags_1 & HOLOGRAM_1) // Just in case there's ever holographic towels.
		return

	var/obj/item/stack/sheet/cloth/shreds = new (get_turf(src), TOWEL_CLOTH_AMOUNT)

	if(!QDELETED(shreds)) //stacks merged
		transfer_fingerprints_to(shreds)
		shreds.add_fingerprint(user)

	to_chat(user, span_notice("You tear [src] up into cloth."))
	qdel(src)


/obj/item/towel/pre_attack_secondary(atom/target, mob/living/user, params)
	. = ..()

	if(!istype(target, /obj/item/reagent_containers/cup/bucket))
		return

	if(!reagents.total_volume)
		to_chat(user, span_warning("\The [src] is dry, you can't squeeze anything out!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/obj/item/reagent_containers/cup/bucket/target_bucket = target

	if(target_bucket.reagents.total_volume >= target_bucket.reagents.maximum_volume)
		to_chat(user, span_warning("[target] is full!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	transfer_towel_reagents_to(target_bucket.reagents, reagents.total_volume, user, loss_factor = SQUEEZING_DISPERSAL_RATIO, make_used = TRUE) // If it didn't have enough space, oh well, you lost like 3/4th of what was in the towel anyway, there's just even more loss that way. Doesn't really matter.

	to_chat(user, span_notice("You wring the liquid out of [src], transferring some of it to [target]."))

	playsound(target, 'sound/effects/slosh.ogg', 25, TRUE)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN


/obj/item/towel/click_alt(mob/user)
	if(!(shape == TOWEL_FULL || shape == TOWEL_WAIST))
		return CLICK_ACTION_BLOCKING

	if(!ishuman(user))
		return CLICK_ACTION_BLOCKING

	var/mob/living/carbon/human/towel_user = user
	var/worn = towel_user.wear_suit == src

	change_towel_shape(user, shape == TOWEL_FULL ? TOWEL_WAIST : TOWEL_FULL, silent = worn)

	// No need to display the different message if they're not wearing it.
	if(!worn)
		return CLICK_ACTION_SUCCESS

	to_chat(user, span_notice(shape == TOWEL_FULL ? "You raise \the [src] over your [shape]." : "You lower \the [src] down to your [shape]."))
	return CLICK_ACTION_SUCCESS


/obj/item/towel/item_ctrl_click(mob/user)
	if(!wet && shape == TOWEL_FOLDED) // You can't fold a wet towel, so you can't get a folded towel that's also wet. And you can't fold what's already folded, obviously.
		to_chat(user, span_warning("You can't fold a towel that's already folded!"))
		return

	if(ishuman(user) || iscyborg(user))
		if(iscyborg(user) && wet) // Cyborgs can't wring towels.
			to_chat(user, span_warning("Folding a wet towel doesn't really make sense. You stop yourself before doing that."))
			return CLICK_ACTION_BLOCKING

		var/in_hands = TRUE

		if(ishuman(user))
			in_hands = user.get_active_held_item() == src || user.get_inactive_held_item() == src


		if(!in_hands) // They need to be in your hands, unless you're a cyborg.
			return CLICK_ACTION_BLOCKING

		if(!wet)
			change_towel_shape(user, TOWEL_FOLDED, silent = TRUE)
			to_chat(user, span_notice("You fold [src] up neatly."))
			return CLICK_ACTION_SUCCESS

		// No cyborgs past this point.

		to_chat(user, span_warning("You start wringing [src], it's going to make a mess!"))

		if(!do_after(user, 2 SECONDS, src))
			to_chat(user, span_warning("You give wringing [src] a second thought, and stop doing it, maybe for the best..."))
			return CLICK_ACTION_BLOCKING

		var/turf/current_turf = get_turf(src) // It's done by a user so it should always have a turf.

		var/datum/reagents/temp_holder = new(max_reagent_volume)
		var/transfer_amount = min(reagents.total_volume, TOWEL_WRING_AMOUNT)

		transfer_towel_reagents_to(temp_holder, transfer_amount, user, loss_factor = TOWEL_WRING_LOSS_FACTOR, make_used = TRUE)

		wring(user, current_turf, temp_holder) //because we don't have a liquids subsystem, this proc just imitates the try_splash from reagent_containers but only for turf

		qdel(temp_holder)

		user.visible_message(span_warning("[user] wrings [src], making a mess on \the [current_turf]!"), span_warning("You wring [src], making a mess on \the [current_turf]!"))
		return CLICK_ACTION_SUCCESS

/obj/item/towel/proc/wring(mob/user, atom/target, datum/reagents/reagent_holder, datum/thrownthing/throwingdatum)
	var/reagent_text
	user.visible_message(
		span_danger("[user] splashes the contents of [src] onto [target]."),
		span_danger("You splash the contents of [src] onto [target]."),
		ignored_mobs = target,
	)
	SEND_SIGNAL(target, COMSIG_ATOM_SPLASHED)

	playsound(target, 'sound/effects/slosh.ogg', 25, TRUE)

	var/mutable_appearance/splash_animation = mutable_appearance('icons/effects/effects.dmi', "splash")
	splash_animation.icon_state = "splash_floor"
	splash_animation.color = mix_color_from_reagents(reagent_holder.reagent_list)
	target.flick_overlay_view(splash_animation, 1 SECONDS)

	for(var/datum/reagent/reagent as anything in reagent_holder.reagent_list)
		reagent_text += "[reagent] ([num2text(reagent.volume)]),"

	var/mob/thrown_by = throwingdatum?.get_thrower()
	if(isturf(target) && reagent_holder.reagent_list.len && thrown_by)
		log_combat(thrown_by, target, "splashed (thrown) [english_list(reagent_holder.reagent_list)]")
		message_admins("[ADMIN_LOOKUPFLW(thrown_by)] splashed (thrown) [english_list(reagent_holder.reagent_list)] on [target] at [ADMIN_VERBOSEJMP(target)].")

	reagent_holder.expose(target, TOUCH)
	log_combat(user, target, "splashed", reagent_text)
	reagent_holder.clear_reagents()

	return TRUE

/obj/item/towel/machine_wash(obj/machinery/washing_machine/washer)
	. = ..() // This isn't really needed, but I'm including it in case we ever get dyeable towels.

	// Washing allows you to remove all reagents from a towel, so it comes out clean!
	reagents.remove_all(reagents.total_volume)

	set_wet(FALSE, FALSE)
	make_used(null, silent = TRUE)

	var/fresh_mood = AddComponent(/datum/component/onwear_mood, saved_event_type = /datum/mood_event/fresh_laundry, examine_string = "[src] looks crisp and pristine.")

	QDEL_IN(fresh_mood, 2 MINUTES)


/obj/item/towel/dropped(mob/user, silent)
	. = ..()

	if(!ishuman(loc) && shape != TOWEL_FOLDED)
		make_used(user, silent = TRUE)


/**
 * Helper proc to handle setting the towel's `wet` variable, changing the icon_state
 * accordingly and making the towel look a little damp if wet, and removing that
 * color if not wet.
 *
 * Arguments:
 * * new_wetness - Whether we're now wet or not.
 * * update_visuals (optional) - Whether we call `update_appearance()` and
 * `update_slot_icon()`. Set to `FALSE` if you're already calling a proc that
 * updates the towel's appearance, like `change_towel_shape()` (if you're sure
 * that it WILL change the appearance). Defaults to `TRUE`.
 */
/obj/item/towel/proc/set_wet(new_wetness, update_visuals = TRUE)
	if(new_wetness == wet)
		return

	wet = new_wetness

	color = wet ? "#CCCCCC" : null

	if(wet) // This is to allow it to show what it contains, without saying that it contains nothing when it's dry.
		reagents.flags |= TRANSPARENT
	else
		reagents.flags &= ~TRANSPARENT

	if(update_visuals)
		update_appearance()
		update_slot_icon()


/**
 * Helper to change the shape of the towel, so that it updates its look both
 * in-hand and on the body of the wearer.
 *
 * Arguments:
 * * user - Mob that's trying to change the shape of the towel.
 * * new_shape - The new shape that the towel can be in.
 * * silent (optional) - Whether we produce a to_chat to the user to elaborate on
 * the new shape it is now in. Requires `user` to be non-null if `TRUE` in order to
 * do anything. Defaults to `FALSE`.
 */
/obj/item/towel/proc/change_towel_shape(mob/user, new_shape, silent = FALSE)
	if(new_shape == shape)
		return

	shape = new_shape

	icon_state = "[base_icon_state][shape ? "-[shape]" : ""]"

	if(shape == TOWEL_HEAD)
		flags_inv |= HIDEHAIR
	else
		flags_inv &= ~HIDEHAIR

	update_appearance()
	update_slot_related_flags()

	if(!silent && user)
		to_chat(user, span_notice(shape ? "You adjust [src] so that it can be worn over your [shape]." : "You fold [src] neatly."))


/**
 * Helper proc to change the slot flags of the towel based on its shape.
 */
/obj/item/towel/proc/update_slot_related_flags()
	switch(shape)
		if(TOWEL_FULL)
			slot_flags = ITEM_SLOT_OCLOTHING
			body_parts_covered = CHEST | GROIN | LEGS

		if(TOWEL_WAIST)
			slot_flags = ITEM_SLOT_OCLOTHING
			body_parts_covered = GROIN | LEGS

		if(TOWEL_HEAD)
			slot_flags = ITEM_SLOT_HEAD
			body_parts_covered = HEAD

		else
			slot_flags = NONE
			body_parts_covered = NONE

	update_slot_icon()


/**
 * Simple helper to make the towel into a used towel shape.
 *
 * Arguments:
 * * user - Mob that's making the towel used. Can be null if `silent` is `FALSE`.
 * * silent (optional) - Whether we produce a to_chat to the user to elaborate on
 * the new shape it is now in. Requires `user` to be non-null if `TRUE` in order to
 * do anything. Defaults to `FALSE`.
 */
/obj/item/towel/proc/make_used(mob/user, silent = FALSE)
	change_towel_shape(user, TOWEL_USED, silent)


/**
 * Helper to transfer reagents from the towel to something else, handling all
 * the work related to ensuring that the towel gets updated visually if it now
 * becomes dry, while also optionally applying a loss factor to the transfer.
 *
 * Arguments:
 * * target - Reagents target of the reagents transfer.
 * * amount - Amount of reagents that are going to be affected by the transfer.
 * Won't go above the maximum amount of volume of the target, and it will handle
 * making sure that it uses the right amount of reagents if the towel doesn't
 * have enough reagents in it for it.
 * * user - Mob that does the transfer, if any.
 * * loss_factor (optional) - Factor of reagents that get lost during transfer.
 * Defaults to 0.
 * * make_used (optional) - Whether or not we change the towel to the used sprite.
 * Defaults to `FALSE`.
 */
/obj/item/towel/proc/transfer_towel_reagents_to(datum/reagents/target, amount, mob/user, loss_factor = 0, make_used = FALSE)
	if(!reagents.total_volume || !target || !amount)
		return

	amount = min(amount, reagents.total_volume, (target.maximum_volume - target.total_volume) / (1 - loss_factor))

	if(!amount)
		return

	reagents.trans_to(target, amount * (1 - loss_factor), no_react = TRUE, transferred_by = user)

	if(loss_factor && reagents.total_volume)
		reagents.remove_all(amount * loss_factor)

	if(!reagents.total_volume)
		set_wet(FALSE, !make_used)

	if(make_used)
		make_used(user, silent = TRUE)


/**
 * Helper to transfer reagents to the towel.
 *
 * Arguments:
 * * source - Reagents source of the reagents transfer.
 * * amount - Amount of reagents that are going to be affected by the transfer.
 * Won't go above the maximum amount of volume of the towel, and it will handle
 * making sure that it uses the right amount of reagents if the source doesn't
 * have enough reagents for it.
 * * user - Mob that does the transfer, if any.
 * * make_used (optional) - Whether or not we change the towel to the used sprite.
 * Defaults to `TRUE`.
 */
/obj/item/towel/proc/transfer_reagents_to_towel(datum/reagents/source, amount, mob/user, make_used = TRUE)
	if(!source || !amount || !source.total_volume)
		return

	amount = min(amount, source.total_volume, reagents.maximum_volume - reagents.total_volume)

	if(!amount)
		return

	source.trans_to(reagents, amount, no_react = TRUE, transferred_by = user)

	if(!wet)
		set_wet(TRUE, !make_used || shape == TOWEL_USED)

	if(make_used)
		make_used(user, silent = TRUE)


#undef TOWEL_FOLDED
#undef TOWEL_FULL
#undef TOWEL_WAIST
#undef TOWEL_HEAD
#undef TOWEL_USED
#undef TOWEL_OBJ_ICON
#undef TOWEL_CLOTH_AMOUNT
#undef TOWEL_WRING_LOSS_FACTOR
#undef TOWEL_WRING_AMOUNT
#undef SQUEEZING_DISPERSAL_RATIO
