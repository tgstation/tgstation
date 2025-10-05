/obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = null
	abstract_type = /obj/item/reagent_containers
	w_class = WEIGHT_CLASS_TINY
	sound_vary = TRUE
	/// The maximum amount of reagents per transfer that will be moved out of this reagent container.
	var/amount_per_transfer_from_this = 5
	/// Does this container allow changing transfer amounts at all, the container can still have only one possible transfer value in possible_transfer_amounts at some point even if this is true
	var/has_variable_transfer_amount = TRUE
	/// The different possible amounts of reagent to transfer out of the container
	var/list/possible_transfer_amounts = list(5,10,15,20,25,30)
	/// The maximum amount of reagents this container can hold
	var/volume = 30
	/// The base reagent flags that our reagent datum takes on when created
	var/initial_reagent_flags = NONE
	/// A list of what initial reagents this container should spawn with
	var/list/list_reagents = null
	/// The purity of the spawned reagents in list_reagents. Default purity if `null`
	var/list_reagents_purity = null
	/// If this container should spawn with a disease type inside of it
	var/spawned_disease = null
	/// How much of a disease specified in spawned_disease should this container spawn with
	var/disease_amount = 20
	/// If the reagents inside of this container will splash out when the container tries to splash onto someone or something
	var/spillable = FALSE
	/**
	 * The different thresholds at which the reagent fill overlay will change. See medical/reagent_fillings.dmi.
	 *
	 * Should be a list of integers which correspond to a reagent unit threshold.
	 * If null, no automatic fill overlays are generated.
	 *
	 * For example, list(0) will mean it will gain a the overlay with any reagents present. This overlay is "overlayname0".
	 * list(0, 10) whill have two overlay options, for 0-10 units ("overlayname0") and 10+ units ("overlayname10").
	 */
	var/list/fill_icon_thresholds = null
	/// The optional custom name for the reagent fill icon_state prefix
	/// If not set, uses the current icon state.
	var/fill_icon_state = null
	/// The icon file to take fill icon appearances from
	var/fill_icon = 'icons/obj/medical/reagent_fillings.dmi'
	///The sound this container makes when picked up, dropped if there is liquid inside.
	var/reagent_container_liquid_sound
	///The sound this container makes when there is an amount of liquid over a certain threshold inside on drop
	var/filled_drop_sound
	///The sound this container makes when there is an amount of liquid over a certain threshold inside on throw drop
	var/filled_throw_drop_sound
	///The sound this container makes when there is an amount of liquid over a certain threshold inside on pickup
	var/filled_pickup_sound
	///The sound this container makes when there is an amount of liquid over a certain threshold inside on throw impact
	var/filled_throw_hit_sound
	///The sound this container makes when there is an amount of liquid over a certain threshold inside on hit
	var/filled_hitsound
	///The sound this container makes when there is an amount of liquid over a certain threshold inside on equip
	var/filled_equip_sound
	///If we want to the contrast of the reagent overlay if the reagent mix color is very dark.
	var/adjust_color_contrast = FALSE

/obj/item/reagent_containers/apply_fantasy_bonuses(bonus)
	. = ..()
	if(reagents)
		reagents.maximum_volume = modify_fantasy_variable("maximum_volume", reagents.maximum_volume, bonus * 10, minimum = 5)
	volume = modify_fantasy_variable("maximum_volume_beaker", volume, bonus * 10, minimum = 5)

/obj/item/reagent_containers/remove_fantasy_bonuses(bonus)
	if(reagents)
		reagents.maximum_volume = reset_fantasy_variable("maximum_volume", reagents.maximum_volume)
	volume = reset_fantasy_variable("maximum_volume_beaker", volume)
	return ..()

/obj/item/reagent_containers/Initialize(mapload, vol)
	. = ..()
	if(isnum(vol) && vol > 0)
		volume = vol
	if(!force)
		item_flags |= NOBLUDGEON
	create_reagents(volume, initial_reagent_flags)
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease()
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent(/datum/reagent/blood, disease_amount, data)
	add_initial_reagents()
	AddElement(/datum/element/reagents_exposed_on_fire)

/obj/item/reagent_containers/examine(mob/user)
	. = ..()
	if(has_variable_transfer_amount)
		if(possible_transfer_amounts.len > 1)
			. += span_notice("Left-click or right-click in-hand to increase or decrease its transfer amount. It is currently set to [amount_per_transfer_from_this] units.")
		else if(possible_transfer_amounts.len)
			. += span_notice("Left-click or right-click in-hand to view its transfer amount.")
	if(isliving(user) && HAS_TRAIT(user, TRAIT_REMOTE_TASTING))
		var/mob/living/living_user = user
		living_user.taste_container(reagents)

/obj/item/reagent_containers/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagent_change))

/obj/item/reagent_containers/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents, added_purity = list_reagents_purity)

/obj/item/reagent_containers/attack_self(mob/user)
	if(reagents.flags & SEALED_CONTAINER)
		return TRUE
	if(has_variable_transfer_amount)
		change_transfer_amount(user, FORWARD)
		return TRUE

/obj/item/reagent_containers/attack_self_secondary(mob/user)
	if(has_variable_transfer_amount)
		change_transfer_amount(user, BACKWARD)

/obj/item/reagent_containers/proc/mode_change_message(mob/user)
	return

/obj/item/reagent_containers/proc/change_transfer_amount(mob/user, direction = FORWARD)
	var/list_len = length(possible_transfer_amounts)
	if(!list_len)
		return
	var/index = possible_transfer_amounts.Find(amount_per_transfer_from_this) || 1
	switch(direction)
		if(FORWARD)
			index = (index % list_len) + 1
		if(BACKWARD)
			index = (index - 1) || list_len
		else
			CRASH("change_transfer_amount() called with invalid direction value")
	amount_per_transfer_from_this = possible_transfer_amounts[index]
	balloon_alert(user, "transferring [amount_per_transfer_from_this]u")
	mode_change_message(user)

/obj/item/reagent_containers/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!user.combat_mode)
		return NONE // non-combat-mode-rmb allows for stuff like opening containers or attacking (bottle breaking)
	if(try_splash(user, interacting_with))
		return ITEM_INTERACT_SUCCESS
	return NONE

/// Tries to splash the target, called when right-clicking with a reagent container.
/obj/item/reagent_containers/proc/try_splash(mob/user, atom/target)
	if (!is_open_container() || (reagents.flags & NO_SPLASH))
		return FALSE

	if (!reagents?.total_volume)
		return FALSE

	var/punctuation = ismob(target) ? "!" : "."

	user.visible_message(
		span_danger("[user] splashes the contents of [src] onto [target][punctuation]"),
		span_danger("You splash the contents of [src] onto [target][punctuation]"),
		ignored_mobs = target,
	)
	SEND_SIGNAL(target, COMSIG_ATOM_SPLASHED)
	if (ismob(target))
		var/mob/target_mob = target
		target_mob.show_message(
			span_userdanger("[user] splashes the contents of [src] onto you!"),
			MSG_VISUAL,
			span_userdanger("You feel drenched!"),
		)

	playsound(target, 'sound/effects/slosh.ogg', 25, TRUE)

	var/mutable_appearance/splash_animation = mutable_appearance('icons/effects/effects.dmi', "splash")
	if(isturf(target))
		splash_animation.icon_state = "splash_floor"
	splash_animation.color = mix_color_from_reagents(reagents.reagent_list)
	target.flick_overlay_view(splash_animation, 1 SECONDS)

	reagents.expose(target, TOUCH)
	log_combat(user, target, "splashed", reagents.get_reagent_log_string())
	reagents.clear_reagents()

	return TRUE

/obj/item/reagent_containers/proc/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return FALSE
	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return FALSE
	var/mob/living/carbon/as_carbon = eater
	var/covered = ""
	if(as_carbon.is_mouth_covered(ITEM_SLOT_HEAD))
		covered = "headgear"
	else if(as_carbon.is_mouth_covered(ITEM_SLOT_MASK))
		covered = "mask"
	if(covered)
		var/who = (isnull(user) || eater == user) ? "your" : "[eater.p_their()]"
		to_chat(user, span_warning("You have to remove [who] [covered] first!"))
		return FALSE
	return TRUE

/// Sets reagent flags to the passed flags outright
/obj/item/reagent_containers/proc/update_container_flags(new_flags)
	reagents.flags = new_flags

/// Adds the passed flags to the current reagent flags
/obj/item/reagent_containers/proc/add_container_flags(new_flags)
	reagents.flags |= new_flags

/// Resets to base flags
/obj/item/reagent_containers/proc/reset_container_flags()
	reagents.flags = initial_reagent_flags

/*
 * On accidental consumption, transfer a portion of the reagents to the eater and the item it's in, then continue to the base proc (to deal with shattering glass containers)
 */
/obj/item/reagent_containers/on_accidental_consumption(mob/living/carbon/M, mob/living/carbon/user, obj/item/source_item,  discover_after = TRUE)
	M.losebreath += 2
	reagents?.trans_to(M, min(15, reagents.total_volume / rand(5,10)), transferred_by = user, methods = INGEST)
	if(source_item?.reagents)
		reagents.trans_to(source_item, min(source_item.reagents.total_volume / 2, reagents.total_volume / 5), transferred_by = user, methods = TOUCH)

	return ..()

/obj/item/reagent_containers/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum, do_splash = TRUE)
	. = ..()
	if(do_splash)
		splash_reagents(hit_atom, throwingdatum?.get_thrower(), was_thrown = TRUE, allow_closed_splash = FALSE)

/obj/item/reagent_containers/proc/bartender_check(atom/target, mob/thrown_by)
	. = FALSE
	if(target.CanPass(src, get_dir(target, src)) && thrown_by && HAS_TRAIT(thrown_by, TRAIT_BOOZE_SLIDER))
		. = TRUE

/**
 * Attempts to splash the reagents in the container onto the target.
 *
 * * target - The target to splash the reagents onto.
 * * throwingdatum - The throwingdatum behind the throw if the
 */
/obj/item/reagent_containers/proc/splash_reagents(atom/target, mob/splasher, was_thrown = FALSE, allow_closed_splash = FALSE)
	if(!reagents || !reagents.total_volume || (!is_open_container() && !allow_closed_splash) || (reagents.flags & NO_SPLASH))
		return

	if(ismob(target) && target.reagents)
		var/splash_multiplier = 1
		if(was_thrown)
			splash_multiplier *= (rand(5,10) * 0.1) //Not all of it makes contact with the target
		var/turf_splash_multiplier = 1 - splash_multiplier
		var/mob/M = target
		var/turf/target_turf = get_turf(target)
		target.visible_message(span_danger("[M] is splashed with something!"), \
						span_userdanger("[M] is splashed with something!"))
		if(splasher)
			log_combat(splasher, M, "splashed", src, "containing [reagents.get_reagent_log_string()] [was_thrown ? "(thrown)" : ""]")
		reagents.expose(target, TOUCH, splash_multiplier)
		if(turf_splash_multiplier > 0)
			reagents.expose(target_turf, TOUCH, turf_splash_multiplier) // 1 - splash_multiplier because it's what didn't hit the target

	else if(bartender_check(target, splasher) && was_thrown)
		visible_message(span_notice("[src] lands onto \the [target] without spilling a single drop."))
		return

	else
		if(isturf(target) && length(reagents.reagent_list) && splasher)
			log_combat(splasher, target, "splashed [english_list(reagents.reagent_list)]", src, "in [AREACOORD(target)] [was_thrown ? "(thrown)" : ""]")
			message_admins("[ADMIN_LOOKUPFLW(splasher)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [ADMIN_VERBOSEJMP(target)].")
		visible_message(span_notice("[src] spills its contents all over [target]."))
		reagents.expose(target, TOUCH)
		if(QDELETED(src))
			return

	playsound(target, 'sound/effects/slosh.ogg', 25, TRUE)

	var/mutable_appearance/splash_animation = mutable_appearance('icons/effects/effects.dmi', "splash")
	if(isturf(target))
		splash_animation.icon_state = "splash_floor"
	splash_animation.color = mix_color_from_reagents(reagents.reagent_list)
	target.flick_overlay_view(splash_animation, 1.0 SECONDS)

	reagents.clear_reagents()

/// Updates the icon of the container when the reagents change. Eats signal args
/obj/item/reagent_containers/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	update_appearance()

/obj/item/reagent_containers/update_overlays()
	. = ..()
	if(!fill_icon_thresholds)
		return
	if(!reagents.total_volume)
		return

	var/fill_name = fill_icon_state ? fill_icon_state : icon_state
	var/mutable_appearance/filling = mutable_appearance(fill_icon, "[fill_name][fill_icon_thresholds[1]]")

	var/percent = round((reagents.total_volume / volume) * 100)
	for(var/i in 1 to fill_icon_thresholds.len)
		var/threshold = fill_icon_thresholds[i]
		var/threshold_end = (i == fill_icon_thresholds.len) ? INFINITY : fill_icon_thresholds[i+1]
		if(threshold <= percent && percent < threshold_end)
			filling.icon_state = "[fill_name][fill_icon_thresholds[i]]"


	if(!adjust_color_contrast)
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling
		return

	var/list/mix_colors = rgb2num(mix_color_from_reagents(reagents.reagent_list))
	//reagent color red
	var/float_r = mix_colors[1] / 255
	//reagent color green
	var/float_g = mix_colors[2] / 255
	//reagent color blue
	var/float_b = mix_colors[3] / 255
	//reagent color alpha
	var/float_a = mix_colors.len > 3 ? mix_colors[4] / 255 : 1

	//value, used to make modifications depending on if our reagent color is light or dark.
	var/float_v = (float_r + float_g + float_b) / 3

	//max result of float_b - float_v is 0.6666 so we multiply with 1.5 to get something close to 1 at max blueness.
	var/blue_mod = max(float_b - float_v, 0) * 1.5

	//red multiplier
	var/red_scale = 1.6
	//green_multiplier
	var/green_scale = 1.5
	//blue scale
	var/blue_scale = 1.1 * (1 + 0.60 * blue_mod)

	//additive red - modifies red across the board by val * 255
	var/red_base = -0.07 - (0.035 * float_v)
	//additive green - modifies green across the board by val * 255
	var/green_base = -0.06 - (0.03 * float_v)
	//additive blue - modifies blue across the board by val * 255
	var/blue_base = 0.10 - (0.050 * float_v) - (0.40 * blue_mod)

	var/list/reagent_color_and_contrast_matrix  = list(
		//Red - RR, RG, RB, RA
		float_r * red_scale, 0, 0, 0,
		//Green - GR - GG - GB - GA
		0, float_g * green_scale, 0, 0,
		///Blue - BR, BG, BB, BA
		0.25 * blue_mod, 0.33 * blue_mod, float_b * blue_scale, 0,
		//Alpha - AR, AG, AB, AA
		0, 0, 0, float_a,
		//Constant - CR, CG, CB, CA
		red_base, green_base, blue_base, 0)

	filling.color = reagent_color_and_contrast_matrix

	. += filling

/obj/item/reagent_containers/proc/reagent_container_sound_chain(filled_sound, empty_sound, target, volume)
	if(reagents.total_volume <= round((reagents.maximum_volume * 0.2), 1))
		if(empty_sound)
			playsound(target, empty_sound, volume, vary = sound_vary, ignore_walls = FALSE)
			return TRUE
		return FALSE

	if(reagent_container_liquid_sound)
		playsound(target, reagent_container_liquid_sound, LIQUID_SLOSHING_SOUND_VOLUME, vary = TRUE, ignore_walls = FALSE)
	if(filled_sound)
		playsound(target, filled_sound, volume, vary = sound_vary, ignore_walls = FALSE)
		return TRUE
	if(empty_sound)
		playsound(target, empty_sound, volume, vary = sound_vary, ignore_walls = FALSE)
		return TRUE
	return FALSE

/obj/item/reagent_containers/play_pickup_sound(volume = PICKUP_SOUND_VOLUME)
	return reagent_container_sound_chain(filled_pickup_sound, pickup_sound, src, volume)

/obj/item/reagent_containers/play_drop_sound(volume = DROP_SOUND_VOLUME)
	return reagent_container_sound_chain(filled_drop_sound, drop_sound, src, volume)

/obj/item/reagent_containers/play_throw_drop_sound(volume = YEET_SOUND_VOLUME)
	return reagent_container_sound_chain(filled_throw_drop_sound, throw_drop_sound, src, volume)

/obj/item/reagent_containers/play_mob_throw_hit_sound(target, volume = DROP_SOUND_VOLUME)
	return reagent_container_sound_chain(filled_throw_hit_sound, mob_throw_hit_sound, target, volume)

/obj/item/reagent_containers/play_hit_sound(target, volume = HALFWAY_SOUND_VOLUME)
	return reagent_container_sound_chain(filled_hitsound, filled_hitsound, target, volume)

/obj/item/reagent_containers/play_equip_sound(volume = EQUIP_SOUND_VOLUME)
	return reagent_container_sound_chain(filled_equip_sound, equip_sound, src, volume)

/obj/item/reagent_containers/used_in_craft(atom/result, datum/crafting_recipe/current_recipe)
	. = ..()
	// If consumed in crafting, we should dump contents out before qdeling them.
	if(!is_type_in_list(src, current_recipe.parts))
		reagents.expose(loc, TOUCH)

/obj/item/reagent_containers/proc/try_refill(atom/target, mob/living/user)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return ITEM_INTERACT_BLOCKING

	if(target.reagents.holder_full())
		to_chat(user, span_warning("[target] is full."))
		return ITEM_INTERACT_BLOCKING

	var/trans = round(reagents.trans_to(target, amount_per_transfer_from_this, transferred_by = user), CHEMICAL_VOLUME_ROUNDING)
	playsound(target.loc, SFX_LIQUID_POUR, 50, TRUE)
	to_chat(user, span_notice("You transfer [trans] unit\s of the solution to [target]."))
	SEND_SIGNAL(src, COMSIG_REAGENTS_CUP_TRANSFER_TO, target)
	target.update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/proc/try_drain(atom/target, mob/living/user)
	if(!target.reagents.total_volume)
		to_chat(user, span_warning("[target] is empty and can't be refilled!"))
		return ITEM_INTERACT_BLOCKING

	if(reagents.holder_full())
		to_chat(user, span_warning("[src] is full."))
		return ITEM_INTERACT_BLOCKING

	var/trans = round(target.reagents.trans_to(src, amount_per_transfer_from_this, transferred_by = user), CHEMICAL_VOLUME_ROUNDING)
	playsound(target.loc, SFX_LIQUID_POUR, 50, TRUE)
	to_chat(user, span_notice("You fill [src] with [trans] unit\s of the contents of [target]."))
	SEND_SIGNAL(src, COMSIG_REAGENTS_CUP_TRANSFER_FROM, target)
	target.update_appearance()
	return ITEM_INTERACT_SUCCESS
