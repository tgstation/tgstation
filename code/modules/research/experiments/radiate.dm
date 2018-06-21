/datum/experiment_type/radiate
	name = "Irradiate"

/datum/experiment/enable_clone
	weight = 0 //disabled until further testing
	experiment_type = /datum/experiment_type/radiate
	base_points = 2500
	critical = TRUE

/datum/experiment/enable_clone/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(. && E.linked_console)
		var/datum/techweb/web = E.linked_console.stored_research
		. = web.all_experiment_types[/datum/experiment_type/clone].hidden || web.all_experiment_types[/datum/experiment_type/radiate].uses <= 0 //Only perform if clonemode is not enabled or is out of uses

/datum/experiment/enable_clone/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(E.linked_console)
		var/datum/techweb/web = E.linked_console.stored_research
		var/datum/experiment_type/clone/mode = web.all_experiment_types[/datum/experiment_type/clone]
		mode.hidden = FALSE
		mode.uses = E.bad_thing_coeff
		E.experiments[mode.type] = mode //Give it to this experimentor. Others need to relink to unlock.

		E.visible_message("[E] has activated an unknown subroutine!")
		playsound(E, 'sound/effects/genetics.ogg', 50, 1)

/datum/experiment/destroy/radiation
	weight = 30
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
	weight = 50
	is_bad = TRUE
	experiment_type = /datum/experiment_type/radiate

/datum/experiment/toxic_waste/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[E] malfunctions, spewing toxic waste!</span>")
	for(var/turf/T in oview(1, E))
		if(!T.density && prob(70) && !(locate(/obj/effect/decal/cleanable/greenglow) in T))
			var/obj/effect/decal/cleanable/reagentdecal = new/obj/effect/decal/cleanable/greenglow(T)
			reagentdecal.reagents.add_reagent("radium", 7)

/datum/experiment/contaminate
	weight = 30
	is_bad = TRUE
	experiment_type = /datum/experiment_type/radiate

/datum/experiment/contaminate/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/datum/component/rad_insulation/insulation = O.GetComponent(/datum/component/rad_insulation)
	if(insulation && insulation.contamination_proof) //Don't irradiate items that are immune to radiation-ish
		. = FALSE

/datum/experiment/contaminate/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='danger'>[E] malfunctions, irradiating [O]!</span>")
	O.rad_act(300)
	O.AddComponent(/datum/component/radioactive, 50, E)

/datum/experiment/supermatter 	//Gives an object the effects of a supermatter shard
	weight = 30					//using the relic component (see /code/modules/research/relics/effects_passive.dm).
	is_bad = TRUE				//It's incredibly dangerous but can only happen to already irridiated objects.
	experiment_type = /datum/experiment_type/radiate

/datum/experiment/supermatter/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/datum/component/rad_insulation/insulation = O.GetComponent(/datum/component/rad_insulation)
	if(insulation && insulation.contamination_proof) //Don't affect items that are immune to radiation-ish
		return FALSE
	var/rad_strength = 0
	var/datum/component/radioactive/radiation = O.GetComponent(/datum/component/radioactive)
	if(radiation)
		rad_strength = radiation.strength

	if(!(rad_strength >= 200))
		return FALSE

/datum/experiment/supermatter/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='danger'>[O] begins to resonate uncontrollably!</span>")
	var/datum/relic_type/holder = new /datum/relic_type()
	var/datum/relic_effect/passive/supermatter/sm = new /datum/relic_effect/passive/supermatter()
	sm.init()
	holder.added_effects += sm
	holder.hogged_signals += sm.hogged_signals
	holder.apply_effects(O)

	if(O.name == "super matter bin")
		O.name = "Supermatter bin" //I just had to do this joke

	E.eject_item()

/datum/experiment/neutron_layer
	weight = 20
	experiment_type = /datum/experiment_type/radiate

/datum/experiment/neutron_layer/init()
	valid_types = typecacheof(/obj/item/clothing)

/datum/experiment/neutron_layer/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='danger'>[E] adds a thick layer of neutrons to [O].</span>")
	O.AddComponent(/datum/component/rad_insulation, RAD_LIGHT_INSULATION, TRUE, FALSE)
