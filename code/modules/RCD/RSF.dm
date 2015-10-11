//Yes, subtype of engineering. (compressed matter handling.)
/obj/item/device/rcd/matter/rsf
	name				= "\improper Rapid-Service-Fabricator"
	desc				= "A device used to rapidly deploy service items."

	icon_state			= "rsf"

	starting_materials	= list(MAT_IRON = 40000)

	max_matter = 40

	schematics			= list(
	/datum/rcd_schematic/rsf/glass,
	/datum/rcd_schematic/rsf/flask,
	/datum/rcd_schematic/rsf/paper,
	/datum/rcd_schematic/rsf/candle,
	/datum/rcd_schematic/rsf/dice,
	/datum/rcd_schematic/rsf/cards,
	/datum/rcd_schematic/rsf/cardboard
	)
/obj/item/device/rcd/matter/rsf/attack_self(var/mob/living/user)
	if(!selected || user.shown_schematics_background || !selected.show(user))
		user.hud_used.toggle_show_schematics_display(schematics["Service"], 0, src)

/obj/item/device/rcd/borg/rsf
	name				= "\improper Rapid-Service-Fabricator"
	desc				= "A device used to rapidly deploy service items."

	icon_state			= "rsf"

	cell_power_per_energy = 50

	schematics			= list(
	/datum/rcd_schematic/rsf/glass,
	/datum/rcd_schematic/rsf/flask,
	/datum/rcd_schematic/rsf/paper,
	/datum/rcd_schematic/rsf/candle,
	/datum/rcd_schematic/rsf/dice,
	/datum/rcd_schematic/rsf/cards,
	/datum/rcd_schematic/rsf/cardboard
	)
	//datum/rcd_schematic/rsf/dosh,
/obj/item/device/rcd/borg/rsf/attack_self(var/mob/living/user)
	if(!selected || user.shown_schematics_background || !selected.show(user))
		user.hud_used.toggle_show_schematics_display(schematics["Service"], 0, src)
