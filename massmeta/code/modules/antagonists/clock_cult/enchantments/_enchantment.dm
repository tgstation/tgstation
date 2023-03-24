/datum/component/enchantment
	//Examine text
	var/examine_description
	//Maximum enchantment level
	var/max_level = 1
	//Current enchantment level
	var/level

/datum/component/enchantment/Initialize()
	var/obj/item/I = parent
	if(!istype(I))
		return COMPONENT_INCOMPATIBLE
	//Get random level
	level = rand(1, max_level)
	//Apply effect
	apply_effect(I)
	//Add in examine effect
	RegisterSignal(I, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/enchantment/Destroy()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	return ..()

/datum/component/enchantment/proc/apply_effect(obj/item/target)
	return

/datum/component/enchantment/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!examine_description)
		return
	if(is_servant_of_ratvar(user) || !isliving(user))
		examine_list += "<hr><span class='neovgre'>[examine_description]</span>"
		examine_list += "\n<span class='neovgre'>Это благословение обладает силой [level]!</span>"
	else
		examine_list += "<hr>Он слегка светится!"
		var/mob/living/L = user
		if(istype(L.get_item_by_slot(ITEM_SLOT_EYES), /obj/item/clothing/glasses/science))
			examine_list += "\nОн излучает читаемый фактор ЭДС в размере [level]."
