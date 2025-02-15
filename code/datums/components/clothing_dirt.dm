/// This component applies tint to clothing when its exposed to pepperspray or spraycans

/datum/component/clothing_dirt
	/// Amount of dirt stacks on the clothing
	var/dirtiness = 0
	/// Overlay to add to our parent when its dirty
	var/mutable_appearance/dirt_overlay
	/// Color of current overlay
	var/dirt_color = COLOR_WHITE

/datum/component/clothing_dirt/Initialize(dirt_overlay = null)
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE
	src.dirt_overlay = dirt_overlay

/datum/component/clothing_dirt/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_expose), TRUE)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlays_updated))

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
	))
	QDEL_NULL(dirt_overlay)
	return ..()

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
	if (dirtiness > 0)
		examine_list += span_warning("It appears to be covered in something. Won't see much while wearing it until you wash it off.")

/datum/component/clothing_dirt/proc/on_overlays_updated(obj/item/clothing/source, list/overlays)
	SIGNAL_HANDLER
	if (dirtiness > 0 && dirt_overlay && (source.flags_cover & PEPPERPROOF))
		dirt_overlay.color = dirt_color
		overlays += dirt_overlay

/datum/component/clothing_dirt/proc/on_expose(atom/target, list/reagents, datum/reagents/source, methods)
	SIGNAL_HANDLER

	var/mob/living/carbon/wearer
	var/obj/item/clothing/clothing = parent
	if(iscarbon(target))
		wearer = target
		if(is_protected(wearer))
			return

		if(!(wearer.get_slot_by_item(clothing) & clothing.slot_flags))
			return

	var/datum/reagent/consumable/condensedcapsaicin/pepper = locate() in reagents
	if(isnull(pepper) || !(methods & (TOUCH | VAPOR)))
		return

	dirt_color = pepper.color
	clothing.tint -= dirtiness
	dirtiness = min(dirtiness + round(reagents[pepper] / 5), 3)
	clothing.tint += dirtiness
	clothing.update_appearance()
	if(!isnull(wearer))
		wearer.update_tint()

/datum/component/clothing_dirt/proc/is_protected(mob/living/carbon/wearer)
	return wearer.head && wearer.head != parent && (wearer.head.flags_cover & PEPPERPROOF)

/datum/component/clothing_dirt/proc/on_spraypaint(mob/living/carbon/wearer, mob/user, obj/item/toy/crayon/spraycan/spraycan)
	SIGNAL_HANDLER

	if(is_protected(wearer))
		return

	var/obj/item/clothing/clothing = parent
	if(!(wearer.get_slot_by_item(clothing) & clothing.slot_flags))
		return

	dirt_color = spraycan.paint_color
	clothing.tint -= dirtiness
	dirtiness = min(3, dirtiness + rand(2, 3))
	clothing.tint += dirtiness
	clothing.update_appearance()
	wearer.update_tint()
	user.visible_message(span_danger("[user] sprays [spraycan] into the face of [wearer]!"))
	to_chat(wearer, span_userdanger("[user] sprays [spraycan] into your face!"))
	return COMPONENT_CANCEL_SPRAYPAINT

/datum/component/clothing_dirt/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER
	var/obj/item/clothing/clothing = parent
	var/mob/living/carbon/wearer
	if(iscarbon(clothing.loc))
		wearer = clothing.loc

	if (clean_types & (CLEAN_WASH|CLEAN_SCRUB))
		clothing.tint -= dirtiness
		dirtiness = 0
		if(!isnull(wearer))
			wearer.update_tint()
