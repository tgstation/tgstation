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
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/atmos_sensitive, mapload)
	assoc_datum = new assoc_datum()
	assoc_datum.setup(src,forced_origin)

/obj/structure/artifact/process()
	if(assoc_datum?.active)
		assoc_datum.effect_process()

/obj/structure/artifact/Destroy()
	. = ..()
	SSartifacts.artifacts -= src

/obj/structure/artifact/atom_destruction()
	assoc_datum?.Destroyed()

/obj/structure/artifact/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > BODYTEMP_HEAT_WOUND_LIMIT || exposed_temperature < BODYTEMP_COLD_DAMAGE_LIMIT)

/obj/structure/artifact/atmos_expose(datum/gas_mixture/mix, temperature)
	if(assoc_datum)
		assoc_datum.Stimulate(STIMULUS_HEAT, temperature)

/obj/structure/artifact/emp_act(severity)
	. = ..()
	assoc_datum?.emp_act(severity)

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
	assoc_datum?.ex_act(severity)

/obj/effect/artifact_spawner/Initialize(mapload)
	. = ..()
	spawn_artifact(loc)
	qdel(src)

/obj/item/artifact
	name = "Artifact"
	desc = "Yell at coderbus."
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1"
	resistance_flags = LAVA_PROOF | ACID_PROOF
	armor_type = /datum/armor/obj_machinery/artifact // not machinery but they should be the same anyway
	var/datum/artifact/assoc_datum = /datum/artifact //should never be null

/obj/item/artifact/Initialize(mapload, var/forced_origin = null)
	. = ..()
	START_PROCESSING(SSobj, src)
	assoc_datum = new assoc_datum()
	assoc_datum.setup(src,forced_origin)

/obj/item/artifact/process()
	if(assoc_datum?.active)
		assoc_datum.effect_process()

/obj/item/artifact/Destroy()
	. = ..()
	SSartifacts.artifacts -= src

/obj/item/artifact/atom_destruction()
	assoc_datum?.Destroyed()

/obj/item/artifact/emp_act(severity)
	. = ..()
	assoc_datum?.emp_act(severity)

/obj/item/artifact/examine()
	. = ..()
	if(assoc_datum?.examine_hint)
		. += span_warning(assoc_datum.examine_hint)

/obj/item/artifact/pickup(mob/living/user)
	assoc_datum?.Touched(user)

/obj/item/artifact/attack_self(mob/living/user)
	assoc_datum?.Touched(user)

/obj/item/artifact/attackby(obj/item/I, mob/user, params)
	if(assoc_datum?.attack_by(I,user))
		return ..()

/obj/item/artifact/ex_act(severity)
	. = ..()
	assoc_datum?.ex_act(severity)