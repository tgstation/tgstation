/obj/structure/artifact
	name = "Artifact"
	desc = "Yell at coderbus."
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1" //for when something shits itself or a map editor
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	anchored = FALSE
	density = TRUE
	var/datum/artifact_effect/forced_effect
	var/datum/component/artifact/assoc_comp = /datum/component/artifact
	var/mutable_appearance/extra_effect

ARTIFACT_SETUP(/obj/structure/artifact, SSobj)

/obj/effect/artifact_spawner
	name = "Random Artifact Spawner"
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "wiznerd-1"

/obj/effect/artifact_spawner/Initialize(mapload)
	. = ..()
	spawn_artifact(loc)
	qdel(src)

/obj/structure/artifact/bonk
	forced_effect = /datum/artifact_effect/bonk

/obj/structure/artifact/bomb
	forced_effect = /datum/artifact_effect/bomb/explosive

/obj/structure/artifact/bomb/devastating
	forced_effect = /datum/artifact_effect/bomb/explosive/devastating

/obj/structure/artifact/bomb/gas
	forced_effect = /datum/artifact_effect/bomb/gas

/obj/structure/artifact/forcegen
	forced_effect = /datum/artifact_effect/forcegen

/obj/structure/artifact/heal
	forced_effect = /datum/artifact_effect/heal

/obj/structure/artifact/injector
	forced_effect = /datum/artifact_effect/injector

/obj/structure/artifact/lamp
	forced_effect = /datum/artifact_effect/lamp
	light_system = OVERLAY_LIGHT
	light_on = FALSE

/obj/structure/artifact/repulsor
	forced_effect = /datum/artifact_effect/repulsor

/obj/structure/artifact/vomit
	forced_effect = /datum/artifact_effect/vomit

/obj/structure/artifact/borger
	forced_effect = /datum/artifact_effect/borger

/obj/structure/artifact/emotegen
	forced_effect = /datum/artifact_effect/emotegen

/obj/structure/artifact/surgery
	forced_effect = /datum/artifact_effect/surgery

/obj/structure/artifact/smoke
	forced_effect = /datum/artifact_effect/smoke

/obj/structure/artifact/smoke/toxin
	forced_effect = /datum/artifact_effect/smoke/toxin

/obj/structure/artifact/smoke/flesh
	forced_effect = /datum/artifact_effect/smoke/flesh

/obj/structure/artifact/smoke/exotic
	forced_effect = /datum/artifact_effect/smoke/exotic
