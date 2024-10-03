/datum/component/clothing_dirt
	/// The ITEM_SLOT_* slot the item is equipped on, if it is.
	var/equipped_slot

	/// Mob wearing the clothing
	var/mob/living/carbon/wearer

	/// Amount of dirt stacks on the clothing
	var/dirtiness = 0

	/// Clothing we're applying tint on
	var/obj/item/clothing/clothing

/datum/component/clothing_dirt/Initialize()
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/clothing_dirt/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_remove))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

	clothing = parent
	if (iscarbon(clothing.loc))
		var/mob/living/carbon/mob_clothing = clothing.loc
		if ((mob_clothing.wear_mask == mob_clothing) || (mob_clothing.head == mob_clothing))
			wearer = mob_clothing
			RegisterSignal(wearer, COMSIG_ATOM_EXPOSE_REAGENT, PROC_REF(expose_atom))
	else
		RegisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENT, PROC_REF(expose_atom))

/datum/component/clothing_dirt/UnregisterFromParent()
	clothing = parent
	clothing.tint -= dirtiness
	dirtiness = 0
	if (!isnull(wearer))
		wearer.update_tint()
		UnregisterSignal(wearer, COMSIG_ATOM_EXPOSE_REAGENT)
	else
		UnregisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENT)
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_COMPONENT_CLEAN_ACT,
	))
	return ..()

/datum/component/clothing_dirt/proc/on_equip(datum/source, mob/equipper)
	SIGNAL_HANDLER
	UnregisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENT)
	wearer = equipper
	RegisterSignal(wearer, COMSIG_ATOM_EXPOSE_REAGENT, PROC_REF(expose_atom))

/datum/component/clothing_dirt/proc/on_remove()
	SIGNAL_HANDLER
	UnregisterSignal(wearer, COMSIG_ATOM_EXPOSE_REAGENT)
	wearer = null
	RegisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENT, PROC_REF(expose_atom))

/datum/component/clothing_dirt/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if (dirtiness > 0)
		examine_list += span_red("It appears to be covered in some oily substance. Won't see much while wearing it until you wash it off.")

/datum/component/clothing_dirt/proc/expose_atom(atom/parent_atom, datum/reagent/exposing_reagent, methods)
	SIGNAL_HANDLER
	if(QDELETED(wearer) || is_protected())
		return
	if(!istype(exposing_reagent, /datum/reagent/consumable/condensedcapsaicin))
		return
	clothing = parent
	if ((methods & VAPOR) || (methods & TOUCH))
		dirtiness += 1
		clothing.tint += 1
		if(!isnull(wearer))
			wearer.update_tint()

/datum/component/clothing_dirt/proc/is_protected()
	return wearer.check_obscured_slots(TRUE) & equipped_slot

/datum/component/clothing_dirt/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER
	clothing = parent
	if (clean_types & CLEAN_WASH & CLEAN_SCRUB)
		clothing.tint -= dirtiness
		dirtiness = 0
		if(!isnull(wearer))
			wearer.update_tint()
