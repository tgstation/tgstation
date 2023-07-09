/obj/structure/artifact
	name = "Artifact"
	desc = "Yell at coderbus."
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1" //for when something shits itself or a map editor
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	anchored = FALSE
	density = TRUE
	ARTIFACT_SETUP(/obj/structure/artifact, /datum/component/artifact, SSobj)

/obj/effect/artifact_spawner/Initialize(mapload)
	. = ..()
	spawn_artifact(loc)
	qdel(src)