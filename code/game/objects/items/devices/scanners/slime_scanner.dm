/obj/item/slime_scanner
	name = "slime scanner"
	desc = "A device that analyzes a slime's internal composition and measures its stats."
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "slime_scanner"
	inhand_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = CONDUCTS_ELECTRICITY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.30, /datum/material/glass=SMALL_MATERIAL_AMOUNT * 0.20)

/obj/item/slime_scanner/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	if(!user.can_read(src) || user.is_blind())
		return ITEM_INTERACT_BLOCKING
	if (!isslime(interacting_with))
		to_chat(user, span_warning("This device can only scan slimes!"))
		return ITEM_INTERACT_BLOCKING
	var/mob/living/basic/slime/scanned_slime = interacting_with
	playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
	slime_scan(scanned_slime, user)
	return ITEM_INTERACT_SUCCESS

/proc/slime_scan(mob/living/basic/slime/scanned_slime, mob/living/user)
	var/to_render = "<b>Slime scan results:</b>\
					\n[span_notice("[scanned_slime.slime_type.colour] [scanned_slime.life_stage] slime")]\
					\nNutrition: [scanned_slime.nutrition]/[SLIME_MAX_NUTRITION]"

	if (scanned_slime.nutrition < SLIME_STARVE_NUTRITION)
		to_render += "\n[span_warning("Warning: slime is starving!")]"
	else if (scanned_slime.nutrition < SLIME_HUNGER_NUTRITION)
		to_render += "\n[span_warning("Warning: slime is hungry")]"

	to_render += "\nElectric charge strength: [scanned_slime.powerlevel]\nHealth: [round(scanned_slime.health/scanned_slime.maxHealth,0.01)*100]%"

	to_render += "\nPossible mutation[scanned_slime.slime_type.mutations.len > 1 ? "s" : ""]: "
	var/list/mutation_text = list()
	for(var/datum/slime_type/key as anything in scanned_slime.slime_type.mutations)
		mutation_text += initial(key.colour)

	if(!mutation_text.len)
		to_render += " None detected."

	to_render += "[mutation_text.Join(", ")]"
	to_render += "\nGenetic instability: [scanned_slime.mutation_chance] % chance of mutation attempt on splitting."

	if (scanned_slime.cores > 1)
		to_render += "\nMultiple cores detected"
	to_render += "\nGrowth progress: [scanned_slime.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]"

	if(scanned_slime.crossbreed_modification)
		to_render += "\n[span_notice("Core mutation in progress: [scanned_slime.crossbreed_modification]")]\
					  \n[span_notice("Progress in core mutation: [scanned_slime.applied_crossbreed_amount] / [SLIME_EXTRACT_CROSSING_REQUIRED]")]"

	to_chat(user, boxed_message(jointext(to_render,"")))
