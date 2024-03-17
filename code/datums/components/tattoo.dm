/**
 * ### engraved component!
 *
 * component for walls that applies an engraved overlay and lets you examine it to read a story (+ art element yay)
 * new creations will get a high art value, cross round scrawlings will get a low one.
 * MUST be a component, though it doesn't look like it. SSPersistence demandeth
 */
/datum/component/tattoo
	///the generated story string
	var/tattoo_description

/datum/component/tattoo/Initialize(tattoo_description)
	. = ..()
	if(!isbodypart(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/bodypart/tatted_limb = parent


	if(!tattoo_description)
		///okay, i need to add some way to saved tattoos
		return COMPONENT_INCOMPATIBLE
	src.tattoo_description = tattoo_description
	tatted_limb.AddElement(/datum/element/art/commoner, 15)

	if(tatted_limb.owner)
		setup_tatted_owner(tatted_limb.owner)

/datum/component/tattoo/Destroy(force)
	if(!parent)
		return ..()
	var/obj/item/bodypart/tatted_limb = parent
	if(tatted_limb.owner)
		clear_tatted_owner(tatted_limb.owner)
	parent.RemoveElement(/datum/element/art/commoner)
	return ..()

/datum/component/tattoo/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/tattoo/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

/datum/component/tattoo/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_boldnotice(tattoo_description)

/datum/component/tattoo/proc/setup_tatted_owner(mob/living/carbon/new_owner)
	RegisterSignal(new_owner, COMSIG_ATOM_EXAMINE, PROC_REF(on_bodypart_owner_examine))

/datum/component/tattoo/proc/clear_tatted_owner(mob/living/carbon/old_owner)
	UnregisterSignal(old_owner, COMSIG_ATOM_EXAMINE)

/datum/component/tattoo/proc/on_bodypart_owner_examine(mob/living/carbon/bodypart_owner, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/obj/item/bodypart/tatted_limb = parent
	for(var/obj/item/clothing/possibly_blocking in bodypart_owner.get_equipped_items())
		if(possibly_blocking.body_parts_covered & tatted_limb.body_part) //check to see if something is obscuring their tattoo.
			return

	examine_list += span_notice("[tatted_limb] of [bodypart_owner] has a tattoo!")
	examine_list += span_boldnotice(tattoo_description)
