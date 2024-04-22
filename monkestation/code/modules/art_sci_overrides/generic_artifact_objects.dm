/obj/structure/artifact
	name = "Artifact"
	desc = "Yell at coderbus."
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1" //for when something shits itself or a map editor
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	anchored = FALSE
	density = TRUE
	var/datum/component/artifact/assoc_comp
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
	assoc_comp = /datum/component/artifact/bonk

/obj/structure/artifact/bomb
	assoc_comp = /datum/component/artifact/bomb/explosive

/obj/structure/artifact/bomb/devastating
	assoc_comp = /datum/component/artifact/bomb/explosive/devastating

/obj/structure/artifact/bomb/gas
	assoc_comp = /datum/component/artifact/bomb/gas

/obj/structure/artifact/forcegen
	assoc_comp = /datum/component/artifact/forcegen

/obj/structure/artifact/heal
	assoc_comp = /datum/component/artifact/heal

/obj/structure/artifact/injector
	assoc_comp = /datum/component/artifact/injector

/obj/structure/artifact/lamp
	assoc_comp = /datum/component/artifact/lamp
	light_system = OVERLAY_LIGHT
	light_on = FALSE

/obj/structure/artifact/repulsor
	assoc_comp = /datum/component/artifact/repulsor

/obj/structure/artifact/vomit
	assoc_comp = /datum/component/artifact/vomit

/obj/structure/artifact/borger
	assoc_comp = /datum/component/artifact/borger

/obj/structure/artifact/emotegen
	assoc_comp = /datum/component/artifact/emotegen

/obj/structure/artifact/surgery
	assoc_comp = /datum/component/artifact/surgery

/obj/structure/artifact/smoke
	assoc_comp = /datum/component/artifact/smoke

/obj/structure/artifact/smoke/toxin
	assoc_comp = /datum/component/artifact/smoke/toxin

/obj/structure/artifact/smoke/flesh
	assoc_comp = /datum/component/artifact/smoke/flesh

/obj/structure/artifact/smoke/exotic
	assoc_comp = /datum/component/artifact/smoke/exotic
