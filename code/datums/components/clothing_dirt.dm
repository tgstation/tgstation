/// This component applies tint to clothing when its exposed to pepperspray or spraycans

/datum/component/clothing_dirt
	/// Amount of dirt stacks on the clothing
	var/dirtiness = 0
	/// Icon state of the overlay to add to our parent when its dirty
	var/dirt_state
	/// Color of current overlay
	var/dirt_color = COLOR_WHITE
	/// Tracks if tint has been applied to parent
	VAR_FINAL/tint_applied = FALSE

/datum/component/clothing_dirt/Initialize(dirt_state = null)
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE
	src.dirt_state = dirt_state

/datum/component/clothing_dirt/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_expose), TRUE)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlays_updated))
	RegisterSignal(parent, COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS, PROC_REF(on_separate_worn_overlays))
	RegisterSignal(parent, COMSIG_CLOTHING_VISOR_TOGGLE, PROC_REF(on_visor_move))

/datum/component/clothing_dirt/UnregisterFromParent()
	var/obj/item/clothing/clothing = parent
	clothing.tint -= dirtiness
	if(iscarbon(clothing.loc))
		var/mob/living/carbon/wearer = clothing.loc
		wearer.update_tint()
		UnregisterSignal(wearer, list(COMSIG_ATOM_EXPOSE_REAGENTS, COMSIG_CARBON_SPRAYPAINTED))
	else
		UnregisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENTS)
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_MOB_UNEQUIPPED_ITEM,
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS,
		COMSIG_CLOTHING_VISOR_TOGGLE,
	))
	return ..()

/datum/component/clothing_dirt/process(seconds_per_tick)
	if(!dirtiness)
		return PROCESS_KILL
	if(!SPT_PROB(1, seconds_per_tick))
		return
	var/obj/item/clothing/clothing = parent
	if(!iscarbon(clothing.loc) || !(clothing.flags_cover & PEPPERPROOF) || clothing.tint < dirtiness || clothing.tint < TINT_MILD)
		return
	var/mob/living/carbon/wearer = clothing.loc
	to_chat(wearer, span_warning("It's hard to see with all the stuff covering your [clothing.name]..."))

/datum/component/clothing_dirt/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	var/obj/item/clothing/clothing = parent
	if (!(slot & clothing.slot_flags))
		return
	UnregisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENTS)
	RegisterSignal(user, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_expose), TRUE)
	RegisterSignal(user, COMSIG_CARBON_SPRAYPAINTED, PROC_REF(on_spraypaint), TRUE)

/datum/component/clothing_dirt/proc/on_drop(datum/source, mob/holder)
	SIGNAL_HANDLER
	UnregisterSignal(holder, list(COMSIG_ATOM_EXPOSE_REAGENTS, COMSIG_CARBON_SPRAYPAINTED))
	RegisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_expose), TRUE)
	RegisterSignal(parent, COMSIG_CARBON_SPRAYPAINTED, PROC_REF(on_spraypaint), TRUE)

/datum/component/clothing_dirt/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/obj/item/clothing/clothing = parent
	if (dirtiness > 0)
		examine_list += span_warning("It appears to be covered in something. [clothing.tint >= TINT_MILD ? "Won't see much while wearing it until you wash it off." : "Any more and you might struggle to see through it."]")

/datum/component/clothing_dirt/proc/on_overlays_updated(obj/item/clothing/source, list/overlays)
	SIGNAL_HANDLER

	if (!dirtiness || !dirt_state && !(source.flags_cover & PEPPERPROOF))
		return

	var/mutable_appearance/dirt_overlay = mutable_appearance(source.icon, dirt_state, appearance_flags = KEEP_APART|RESET_COLOR)
	dirt_overlay.color = dirt_color
	overlays += dirt_overlay

/datum/component/clothing_dirt/proc/on_separate_worn_overlays(obj/item/source, list/overlays, mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
	SIGNAL_HANDLER

	if (isinhands || !dirtiness || !dirt_state || !(source.flags_cover & PEPPERPROOF))
		return

	var/mutable_appearance/dirt_overlay = mutable_appearance(source.worn_icon, dirt_state)
	dirt_overlay.color = dirt_color
	overlays += dirt_overlay

/datum/component/clothing_dirt/proc/on_expose(atom/target, list/reagents, datum/reagents/source, methods)
	SIGNAL_HANDLER

	var/obj/item/clothing/clothing = parent
	if(iscarbon(target))
		var/mob/living/carbon/wearer = target
		if(is_protected(wearer))
			return

		if(!(wearer.get_slot_by_item(clothing) & clothing.slot_flags))
			return

	if(!(clothing.flags_cover & PEPPERPROOF))
		return

	var/datum/reagent/consumable/condensedcapsaicin/pepper = locate() in reagents
	if(isnull(pepper) || !(methods & (TOUCH | VAPOR)))
		return

	if(!dirtiness)
		START_PROCESSING(SSobj, src)

	dirt_color = pepper.color
	remove_tint(FALSE)
	dirtiness = min(dirtiness + round(reagents[pepper] / 5, 0.25), 3)
	apply_tint(TRUE)

/datum/component/clothing_dirt/proc/is_protected(mob/living/carbon/wearer)
	return wearer.head && wearer.head != parent && (wearer.head.flags_cover & PEPPERPROOF)

/datum/component/clothing_dirt/proc/remove_tint(updates = TRUE)
	if(!tint_applied)
		return

	tint_applied = FALSE
	var/obj/item/clothing/clothing = parent
	clothing.tint -= dirtiness
	if(!updates)
		return
	clothing.update_appearance()
	clothing.update_slot_icon()
	if(iscarbon(clothing.loc))
		var/mob/living/carbon/wearer = clothing.loc
		wearer.update_tint()

/datum/component/clothing_dirt/proc/apply_tint(updates = TRUE)
	if(tint_applied || !dirtiness)
		return

	tint_applied = TRUE
	var/obj/item/clothing/clothing = parent
	clothing.tint += dirtiness
	if(!updates)
		return
	clothing.update_appearance()
	clothing.update_slot_icon()
	if(iscarbon(clothing.loc))
		var/mob/living/carbon/wearer = clothing.loc
		wearer.update_tint()

/datum/component/clothing_dirt/proc/on_spraypaint(mob/living/carbon/wearer, mob/user, obj/item/toy/crayon/spraycan/spraycan)
	SIGNAL_HANDLER

	if(is_protected(wearer))
		return

	var/obj/item/clothing/clothing = parent
	if(!(wearer.get_slot_by_item(clothing) & clothing.slot_flags))
		return

	if(!dirtiness)
		START_PROCESSING(SSobj, src)

	dirt_color = spraycan.paint_color
	remove_tint(FALSE)
	dirtiness = min(3, dirtiness + rand(2, 3))
	apply_tint(TRUE)
	user.visible_message(span_danger("[user] sprays [spraycan] into the face of [wearer]!"))
	to_chat(wearer, span_userdanger("[user] sprays [spraycan] into your face!"))
	return COMPONENT_CANCEL_SPRAYPAINT

/datum/component/clothing_dirt/proc/on_clean(obj/item/clothing/source, clean_types)
	SIGNAL_HANDLER

	if (!dirtiness || !(clean_types & (CLEAN_WASH|CLEAN_SCRUB)))
		return NONE

	remove_tint(TRUE)
	STOP_PROCESSING(SSobj, src)
	dirtiness = 0
	return COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP

/datum/component/clothing_dirt/proc/on_visor_move(obj/item/clothing/source, up)
	SIGNAL_HANDLER
	if(dirtiness <= 0)
		return

	if(source.flags_cover & PEPPERPROOF)
		apply_tint(TRUE)
	else
		remove_tint(TRUE)
