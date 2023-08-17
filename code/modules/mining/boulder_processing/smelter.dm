
/obj/machinery/bouldertech/smelter
	name = "boulder smeltery"
	desc = "BS for short. Accept boulders and refines metallic ores into sheets. Can be upgraded with stock parts or through gas inputs."
	icon_state = "furnace"
	holds_minerals = TRUE
	processable_materials = list(
		/datum/material/iron,
		/datum/material/titanium,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/uranium,
		/datum/material/mythril,
		/datum/material/adamantine,
		/datum/material/runite,
	)
	circuit = /obj/item/circuitboard/machine/smelter
	usage_sound = 'sound/machines/mining/smelter.ogg'
