/obj/structure/artifact
	name = "Artifact"
	desc = "Yell at coderbus."
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1" //for when something shits itself or a map editor
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	anchored = 0
	density = TRUE
	var/datum/component/artifact/assoc_comp = /datum/component/artifact //should never be null

/obj/structure/artifact/Initialize(mapload, var/forced_origin = null)
	. = ..()
	START_PROCESSING(SSobj, src)
	assoc_comp = AddComponent(assoc_comp, forced_origin)

/obj/structure/artifact/process()
	if(assoc_comp?.active)
		assoc_comp.effect_process()

/obj/structure/artifact/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > BODYTEMP_HEAT_WOUND_LIMIT || exposed_temperature < BODYTEMP_COLD_DAMAGE_LIMIT)

/obj/structure/artifact/atmos_expose(datum/gas_mixture/mix, temperature)
	if(assoc_comp)
		assoc_comp.Stimulate(STIMULUS_HEAT, temperature)

/obj/effect/artifact_spawner/Initialize(mapload)
	. = ..()
	spawn_artifact(loc)
	qdel(src)