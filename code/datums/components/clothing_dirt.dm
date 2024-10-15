/// This component applies tint to clothing when its exposed to pepperspray, used in /obj/item/clothing/mask/gas.

/datum/component/clothing_dirt
	/// Amount of dirt stacks on the clothing
	var/dirtiness = 0

/datum/component/clothing_dirt/Initialize()
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/clothing_dirt/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_expose), TRUE)

/datum/component/clothing_dirt/UnregisterFromParent()
	var/obj/item/clothing/clothing = parent
	clothing.tint -= dirtiness
	if(iscarbon(clothing.loc))
		var/mob/living/carbon/wearer = clothing.loc
		wearer.update_tint()
		UnregisterSignal(wearer, COMSIG_ATOM_EXPOSE_REAGENTS)
	else
		UnregisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENTS)
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_MOB_UNEQUIPPED_ITEM,
		COMSIG_COMPONENT_CLEAN_ACT,
	))
	return ..()

/datum/component/clothing_dirt/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	var/obj/item/clothing/clothing = parent
	if (!(slot & clothing.slot_flags))
		return
	UnregisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENTS)
	RegisterSignal(user, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_expose), TRUE)

/datum/component/clothing_dirt/proc/on_drop(datum/source, mob/holder)
	SIGNAL_HANDLER
	UnregisterSignal(holder, COMSIG_ATOM_EXPOSE_REAGENTS)
	RegisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_expose), TRUE)

/datum/component/clothing_dirt/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if (dirtiness > 0)
		examine_list += span_warning("It appears to be covered in some oily substance. Won't see much while wearing it until you wash it off.")

/datum/component/clothing_dirt/proc/on_expose(atom/target, list/reagents, datum/reagents/source, methods)
	SIGNAL_HANDLER

	var/mob/living/carbon/wearer
	if(iscarbon(target))
		wearer = target
		if(is_protected(wearer))
			return

	var/datum/reagent/consumable/condensedcapsaicin/pepper = locate() in reagents
	if(isnull(pepper))
		return

	var/obj/item/clothing/clothing = parent
	if (methods & (TOUCH | VAPOR))
		clothing.tint -= dirtiness
		dirtiness = min(dirtiness + round(reagents[pepper] / 5), 3)
		clothing.tint += dirtiness
		if(!isnull(wearer))
			wearer.update_tint()

/datum/component/clothing_dirt/proc/is_protected(mob/living/carbon/wearer)
	return wearer.head && (wearer.head.flags_cover & PEPPERPROOF)

/datum/component/clothing_dirt/proc/on_clean(datum/target, clean_types)
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
