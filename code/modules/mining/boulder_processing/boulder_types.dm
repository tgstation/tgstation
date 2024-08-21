///Boulders with special artificats that can give higher mining points
/obj/item/boulder/artifact
	name = "artifact boulder"
	desc = "This boulder is brimming with strange energy. Cracking it open could contain something unusual for science."
	icon_state = "boulder_artifact"
	/// This is the type of item that will be inside the boulder. Default is a strange object.
	var/artifact_type = /obj/item/relic/lavaland
	/// References to the relic inside the boulder, if any.
	var/obj/item/artifact_inside

/obj/item/boulder/artifact/Initialize(mapload)
	. = ..()
	artifact_inside = new artifact_type(src) /// This could be poggers for archaeology in the future.

/obj/item/boulder/artifact/Destroy(force)
	QDEL_NULL(artifact_inside)
	return ..()

/obj/item/boulder/artifact/convert_to_ore()
	. = ..()
	artifact_inside.forceMove(drop_location())
	artifact_inside = null

/obj/item/boulder/artifact/break_apart()
	artifact_inside = null
	return ..()

///Boulders usually spawned in lavaland labour camp area
/obj/item/boulder/gulag
	name = "low-quality boulder"
	desc = "This rocks. It's a low quality boulder, so it's probably not worth as much."

/obj/item/boulder/gulag/Initialize(mapload)
	. = ..()

	/// Static list of all minerals to populate gulag boulders with.
	var/list/static/gulag_minerals = list(
		/datum/material/diamond = 1,
		/datum/material/gold = 8,
		/datum/material/iron = 95,
		/datum/material/plasma = 30,
		/datum/material/silver = 20,
		/datum/material/titanium = 8,
		/datum/material/uranium = 3,
	)

	set_custom_materials(list(pick_weight(gulag_minerals) = SHEET_MATERIAL_AMOUNT))

///Boulders usually spawned in lavaland labour camp area but with bluespace material
/obj/item/boulder/gulag_expanded
	name = "low-density boulder"
	desc = "This rocks. It's not very well packed, and can't contain as many minerals."

/obj/item/boulder/gulag_expanded/Initialize(mapload)
	. = ..()

	/// Static list of all minerals to populate gulag boulders with, but with bluespace added where safe.
	var/list/static/expanded_gulag_minerals = list(
		/datum/material/bluespace = 1,
		/datum/material/diamond = 1,
		/datum/material/gold = 8,
		/datum/material/iron = 94,
		/datum/material/plasma = 30,
		/datum/material/silver = 20,
		/datum/material/titanium = 8,
		/datum/material/uranium = 3,
	)

	set_custom_materials(list(pick_weight(expanded_gulag_minerals) = SHEET_MATERIAL_AMOUNT))

///lowgrade boulder, most commonly spawned
/obj/item/boulder/shabby
	name = "shabby boulder"
	desc = "A bizzare, twisted boulder. Wait, wait no, it's just a rock."
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.1, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 1.1)
	durability = 1
