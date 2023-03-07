/obj/structure/artifact
	name = "Artifact"
	desc = "Yell at coderbus."
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1" //for when something shits itself or a map editor
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	anchored = FALSE
	density = TRUE
	var/datum/component/artifact/assoc_comp = /datum/component/artifact //should never be null

/obj/structure/artifact/Initialize(mapload, var/forced_origin = null)
	. = ..()
	START_PROCESSING(SSobj, src)
	assoc_comp = AddComponent(assoc_comp, forced_origin)

/obj/structure/artifact/process()
	if(assoc_comp?.active)
		assoc_comp.effect_process()

/obj/effect/artifact_spawner/Initialize(mapload)
	. = ..()
	spawn_artifact(loc)
	qdel(src)