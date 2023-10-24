/obj/structure/artifact
	name = "Artifact"
	desc = "Yell at coderbus."
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1" //for when something shits itself or a map editor
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	anchored = FALSE
	density = TRUE
	var/datum/component/artifact/assoc_comp

ARTIFACT_SETUP(/obj/structure/artifact, SSobj)

/obj/effect/artifact_spawner
	name = "Random Artifact Spawner"
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "wiznerd-1"

/obj/effect/artifact_spawner/Initialize(mapload)
	. = ..()
	spawn_artifact(loc)
	qdel(src)
