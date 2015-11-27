//Yes, subtype of engineering. (compressed matter handling.)
/obj/item/device/rcd/matter/rsf
	name				= "\improper Rapid-Service-Fabricator"
	desc				= "A device used to rapidly deploy service items."

	icon_state			= "rsf"

	starting_materials	= list(MAT_IRON = 40000)

	max_matter = 40

	schematics			= list(
	/datum/rcd_schematic/rsf/glass,
	/datum/rcd_schematic/rsf/mug,
	/datum/rcd_schematic/rsf/flask,
	/datum/rcd_schematic/rsf/paper,
	/datum/rcd_schematic/rsf/pen,
	/datum/rcd_schematic/rsf/candle,
	/datum/rcd_schematic/rsf/dice,
	/datum/rcd_schematic/rsf/cards,
	/datum/rcd_schematic/rsf/cardboard,
	/datum/rcd_schematic/rsf/zippo,
	/datum/rcd_schematic/rsf/camera,
	/datum/rcd_schematic/rsf/film,
	/datum/rcd_schematic/rsf/cigar,
	/datum/rcd_schematic/rsf/cigarettes,
	/datum/rcd_schematic/rsf/fork
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
	/datum/rcd_schematic/rsf/mug,
	/datum/rcd_schematic/rsf/flask,
	/datum/rcd_schematic/rsf/paper,
	/datum/rcd_schematic/rsf/pen,
	/datum/rcd_schematic/rsf/candle,
	/datum/rcd_schematic/rsf/dice,
	/datum/rcd_schematic/rsf/cards,
	/datum/rcd_schematic/rsf/cardboard,
	/datum/rcd_schematic/rsf/zippo,
	/datum/rcd_schematic/rsf/camera,
	/datum/rcd_schematic/rsf/film,
	/datum/rcd_schematic/rsf/cigar,
	/datum/rcd_schematic/rsf/cigarettes,
	/datum/rcd_schematic/rsf/fork
	)
	//datum/rcd_schematic/rsf/dosh,
/obj/item/device/rcd/borg/rsf/attack_self(var/mob/living/user)
	if(!selected || user.shown_schematics_background || !selected.show(user))
		user.hud_used.toggle_show_schematics_display(schematics["Service"], 0, src)

//Override of preattack to perform a check on what is being attacked
/obj/item/device/rcd/matter/rsf/preattack(var/atom/A, mob/user, proximity_flag)
	if (istype(A, /obj/structure/table))
		afterattack(A,user) //If it's a table call afterattack now, and return 1 so it doesn't call the table attackby proc.
		return 1
	return 0 //Otherwise proceed as normal.
