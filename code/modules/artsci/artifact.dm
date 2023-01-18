/datum/armor/obj_machinery/artifact
	melee = 70

/obj/structure/artifact
	name = "Artifact"
	desc = "Yell at coderbus."
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1" //for when something shits itself or a map editor
	resistance_flags = LAVA_PROOF | ACID_PROOF
	anchored = 0
	density = TRUE
	armor_type = /datum/armor/obj_machinery/artifact
	var/datum/artifact/assoc_datum = /datum/artifact //should never be null

/obj/structure/artifact/Initialize(mapload, var/forced_origin = null)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)
	SSartifacts.artifacts += src
	assoc_datum = new assoc_datum(src)
	if(forced_origin)
		assoc_datum.valid_origins = list(forced_origin)
	assoc_datum.setup(src)

/obj/structure/artifact/process()
	if(assoc_datum)
		assoc_datum.effect_process()

/obj/structure/artifact/Destroy()
	. = ..()
	SSartifacts.artifacts -= src

/obj/structure/artifact/atom_destruction()
	if(assoc_datum)
		assoc_datum.Destroyed()

/obj/structure/artifact/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > BODYTEMP_HEAT_WOUND_LIMIT || exposed_temperature < BODYTEMP_COLD_DAMAGE_LIMIT)

/obj/structure/artifact/atmos_expose(datum/gas_mixture/mix, temperature)
	if(assoc_datum)
		assoc_datum.Stimulate(STIMULUS_HEAT, temperature)

/obj/structure/artifact/emp_act(severity)
	. = ..()
	if(assoc_datum)
		assoc_datum.Stimulate(STIMULUS_SHOCK, 800)
		assoc_datum.Stimulate(STIMULUS_RADIATION, 4)

/obj/structure/artifact/examine()
	. = ..()
	if(assoc_datum?.examine_hint)
		. += span_warning(assoc_datum.examine_hint)

/obj/structure/artifact/attack_hand(mob/user)
	assoc_datum.Touched(user)
	return

/obj/structure/artifact/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/structure/artifact/attackby(obj/item/I, mob/user, params)
	if(assoc_datum?.attack_by(I,user))
		return ..()

/obj/structure/artifact/ex_act(severity)
	. = ..()
	if(!assoc_datum)
		return .()
	switch(severity)
		if(EXPLODE_DEVASTATE)
			assoc_datum.Stimulate(STIMULUS_FORCE,200)
			assoc_datum.Stimulate(STIMULUS_HEAT,600)
		if(EXPLODE_HEAVY)
			assoc_datum.Stimulate(STIMULUS_FORCE,100)
			assoc_datum.Stimulate(STIMULUS_HEAT,450)
		if(EXPLODE_LIGHT)
			assoc_datum.Stimulate(STIMULUS_FORCE,40)
			assoc_datum.Stimulate(STIMULUS_HEAT,360)

/obj/effect/artifact_spawner/Initialize(mapload)
	. = ..()
	spawn_artifact(loc)
	qdel(src)