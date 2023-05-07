
/obj/item/clothing/gloves/cargo_gauntlet
	name = "\improper H.A.U.L. gauntlets"
	desc = "These clunky gauntlets allow you to drag things with more confidence on them not getting nabbed from you."
	icon_state = "haul_gauntlet"
	greyscale_colors = "#2f2e31"
	equip_delay_self = 3 SECONDS
	equip_delay_other = 4 SECONDS
	clothing_traits = list(TRAIT_CHUNKYFINGERS)
	undyeable = TRUE
	var/datum/weakref/pull_component_weakref

/obj/item/clothing/gloves/cargo_gauntlet/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(on_glove_equip))
	RegisterSignal(src, COMSIG_ITEM_POST_UNEQUIP, PROC_REF(on_glove_unequip))

/// Called when the glove is equipped. Adds a component to the equipper and stores a weak reference to it.
/obj/item/clothing/gloves/cargo_gauntlet/proc/on_glove_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_GLOVES))
		return

	var/datum/component/strong_pull/pull_component = pull_component_weakref?.resolve()
	if(pull_component)
		stack_trace("Gloves already have a pull component associated with \[[pull_component.parent]\] when \[[equipper]\] is trying to equip them.")
		QDEL_NULL(pull_component_weakref)

	to_chat(equipper, span_notice("You feel the gauntlets activate as soon as you fit them on, making your pulls stronger!"))

	pull_component_weakref = WEAKREF(equipper.AddComponent(/datum/component/strong_pull))

/*
 * Called when the glove is unequipped. Deletes the component if one exists.
 *
 * No component being associated on equip is a valid state, as holding the gloves in your hands also counts
 * as having them equipped, or even in pockets. They only give the component when they're worn on the hands.
 */
/obj/item/clothing/gloves/cargo_gauntlet/proc/on_glove_unequip(datum/source, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER

	var/datum/component/strong_pull/pull_component = pull_component_weakref?.resolve()

	if(!pull_component)
		return

	to_chat(pull_component.parent, span_warning("You have lost the grip power of [src]!"))

	QDEL_NULL(pull_component_weakref)

/obj/item/clothing/gloves/rapid
	name = "Gloves of the North Star"
	desc = "Just looking at these fills you with an urge to beat the shit out of people."
	icon_state = "rapid"
	inhand_icon_state = null
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)

/obj/item/clothing/gloves/rapid/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/punchcooldown)

/obj/item/clothing/gloves/radio
	name = "translation gloves"
	desc = "A pair of electronic gloves which connect to nearby radios wirelessly. Allows for sign language users to 'speak' over comms."
	icon_state = "radio_g"
	inhand_icon_state = null
	clothing_traits = list(TRAIT_CAN_SIGN_ON_COMMS)

/obj/item/clothing/gloves/race
	name = "race gloves"
	desc = "Extremely finely made gloves meant for use by sportsmen in speed-shooting competitions."
	clothing_traits = list(TRAIT_DOUBLE_TAP)
	icon_state = "black"
	greyscale_colors = "#2f2e31"

/obj/item/clothing/gloves/captain
	desc = "Regal blue gloves, with a nice gold trim, a diamond anti-shock coating, and an integrated thermal barrier. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	inhand_icon_state = null
	greyscale_colors = null
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 60
	armor_type = /datum/armor/captain_gloves
	resistance_flags = NONE

/datum/armor/captain_gloves
	bio = 90
	fire = 70
	acid = 50

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	desc = "Cheap sterile gloves made from latex. Provides quicker carrying from a good grip."
	icon_state = "latex"
	inhand_icon_state = "latex_gloves"
	greyscale_colors = null
	siemens_coefficient = 0.3
	armor_type = /datum/armor/latex_gloves
	clothing_traits = list(TRAIT_QUICK_CARRY, TRAIT_FINGERPRINT_PASSTHROUGH)
	resistance_flags = NONE

/datum/armor/latex_gloves
	bio = 100

/obj/item/clothing/gloves/latex/nitrile
	name = "nitrile gloves"
	desc = "Pricy sterile gloves that are thicker than latex. Excellent grip ensures very fast carrying of patients along with the faster use time of various chemical related items."
	icon_state = "nitrile"
	inhand_icon_state = "greyscale_gloves"
	greyscale_colors = "#99eeff"
	clothing_traits = list(TRAIT_QUICKER_CARRY, TRAIT_FASTMED)

/obj/item/clothing/gloves/latex/coroner
	name = "coroner's gloves"
	desc = "Black gloves made from latex with a superhydrophobic coating. Useful for picking bodies up instead of dragging blood behind."
	icon_state = "latex_black"
	inhand_icon_state = "greyscale_gloves"
	greyscale_colors = "#15191a"

/obj/item/clothing/gloves/latex/coroner/add_blood_DNA(list/blood_DNA_to_add)
	return FALSE

/obj/item/clothing/gloves/tinkerer
	name = "tinker's gloves"
	desc = "Overdesigned engineering gloves that have automated construction subrutines dialed in, allowing for faster construction while worn."
	inhand_icon_state = "greyscale_gloves"
	icon_state = "clockwork_gauntlets"
	greyscale_colors = "#db6f05"
	siemens_coefficient = 0.8
	armor_type = /datum/armor/tinker_gloves
	clothing_traits = list(TRAIT_QUICK_BUILD)
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT, /datum/material/silver=HALF_SHEET_MATERIAL_AMOUNT*1.5, /datum/material/gold =HALF_SHEET_MATERIAL_AMOUNT)
	resistance_flags = NONE

/datum/armor/tinker_gloves
	bio = 70

/obj/item/clothing/gloves/atmos
	name = "atmospheric extrication gloves"
	desc = "Heavy duty gloves for firefighters. These are thick, non-flammable and let you carry people faster."
	icon_state = "atmos"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	siemens_coefficient = 0.3
	clothing_traits = list(TRAIT_QUICKER_CARRY, TRAIT_CHUNKYFINGERS)
	clothing_flags = THICKMATERIAL
