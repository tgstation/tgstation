/datum/experiment_type/radiate
	name = "Irradiate"

/datum/experiment/enable_clone
	weight = 20
	experiment_type = /datum/experiment_type/radiate
	base_points = 250

/datum/experiment/enable_clone/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(. && E.linked_console)
		var/datum/techweb/web = E.linked_console.stored_research
		return web.all_experiment_types[/datum/experiment_type/clone].hidden //Only perform if clonemode is not enabled

/datum/experiment/enable_clone/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(E.linked_console)
		var/datum/techweb/web = E.linked_console.stored_research
		var/datum/experiment_type/clone/mode = web.all_experiment_types[/datum/experiment_type/clone]
		mode.hidden = FALSE
		mode.uses = E.bad_thing_coeff
		E.experiments |= mode //Give it to this experimentor. Others need to relink to unlock.

		E.visible_message("[E] has activated an unknown subroutine!")
		playsound(E, 'sound/effects/genetics.ogg', 50, 1)

/datum/experiment/destroy/radiation
	weight = 20
	is_bad = TRUE
	experiment_type = /datum/experiment_type/radiate

/datum/experiment/destroy/radiation/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/datum/component/rad_insulation/insulation = O.GetComponent(/datum/component/rad_insulation)
	if(insulation && insulation.amount >= RAD_EXTREME_INSULATION) //Don't melt items that are immune to radiation-ish
		. = FALSE

/datum/experiment/destroy/radiation/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='danger'>[E] malfunctions, melting [O] and leaking radiation!</span>")
	radiation_pulse(E, 500)

/datum/experiment/toxic_waste
	weight = 20
	is_bad = TRUE
	experiment_type = /datum/experiment_type/radiate

/datum/experiment/toxic_waste/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	E.visible_message("<span class='warning'>[E] malfunctions, spewing toxic waste!</span>")
	for(var/turf/T in oview(1, E))
		if(!T.density && prob(70))
			var/obj/effect/decal/cleanable/reagentdecal = new/obj/effect/decal/cleanable/greenglow(T)
			reagentdecal.reagents.add_reagent("radium", 7)

/datum/experiment/contaminate
	weight = 20
	is_bad = TRUE
	experiment_type = /datum/experiment_type/radiate

/datum/experiment/contaminate/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/datum/component/rad_insulation/insulation = O.GetComponent(/datum/component/rad_insulation)
	if(insulation && insulation.contamination_proof) //Don't melt items that are immune to radiation-ish
		. = FALSE

/datum/experiment/contaminate/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='danger'>[E] malfunctions, irradiating [O]!</span>")
	O.rad_act(300)
	O.AddComponent(/datum/component/radioactive, 50, E)