/datum/element/outfit_icon_gen
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/icon/generated_icon

/datum/element/outfit_icon_gen/Attach(atom/target, outfit_path = /datum/outfit, species_path = /datum/species/human, l_hand, r_hand, bloody_slots = NONE)
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	if(!outfit_path || !species_path)
		return ELEMENT_INCOMPATIBLE
	if(generated_icon)
		target.icon = generated_icon
		return
	var/datum/outfit/outfit = new outfit_path()
	if(l_hand != FALSE)
		outfit.l_hand = l_hand
	if(r_hand != FALSE)
		outfit.r_hand = r_hand
	var/mob/living/carbon/human/dummy/dummy = new()
	dummy.set_species(species_path)
	dummy.underwear = "Nude"
	dummy.undershirt = "Nude"
	dummy.socks = "Nude"
	dummy.equipOutfit(outfit)
	for(var/obj/item/carried_item in dummy)
		if(dummy.is_holding(carried_item))
			if(carried_item.GetComponent(/datum/component/two_handed))
				dummy.swap_hand(dummy.get_held_index_of_item(carried_item))
				carried_item.attack_self(dummy)
			if(carried_item.GetComponent(/datum/component/transforming))
				carried_item.attack_self(dummy)
		if(bloody_slots & carried_item.slot_flags)
			carried_item.add_mob_blood(dummy)
	dummy.update_inv_hands()
	COMPILE_OVERLAYS(dummy)
	var/icon/output = icon('icons/blanks/32x32.dmi', "nothing")
	for(var/direction in GLOB.cardinals)
		var/icon/partial = getFlatIcon(dummy, defdir = direction)
		output.Insert(partial, dir = direction)
	generated_icon = output
	qdel(dummy)
	target.icon = generated_icon
