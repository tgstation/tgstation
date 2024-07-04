/datum/component/enchantment
	//Examine text
	var/examine_description
	//Maximum enchantment level
	var/max_level = 1
	//Current enchantment level
	var/level

/datum/component/enchantment/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(on_reebe(parent)) //currently this is only added by stargazers so this should work fine
		max_level = 1
	//Get random level
	level = rand(1, max_level)
	//Apply effect
	apply_effect(parent)
	//Add in examine effect
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/enchantment/Destroy()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	return ..()

/datum/component/enchantment/proc/apply_effect(obj/item/target)
	return

/datum/component/enchantment/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!examine_description)
		return
	if(IS_CLOCK(user) || isobserver(user))
		examine_list += span_brass("[examine_description]")
		examine_list += span_brass("It's blessing has a power of [level]!")
	else
		examine_list += "It is glowing slightly!"
		var/mob/living/living_user = user
		if(istype(living_user.get_item_by_slot(ITEM_SLOT_EYES), /obj/item/clothing/glasses/science))
			examine_list += "It emits a readable EMF factor of [level]."
