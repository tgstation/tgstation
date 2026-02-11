#define EFFECT_PROB_VERYLOW 20
#define EFFECT_PROB_LOW 35
#define EFFECT_PROB_MEDIUM 50
#define EFFECT_PROB_HIGH 75
#define EFFECT_PROB_VERYHIGH 95

#define SCANTYPE_POKE "Poke"
#define SCANTYPE_IRRADIATE "Irradiate"
#define SCANTYPE_GAS "Gas"
#define SCANTYPE_HEAT "Heat"
#define SCANTYPE_COLD "Freeze"
#define SCANTYPE_OBLITERATE "Obliterate"
#define SCANTYPE_DISCOVER "Discover"
#define FAIL "Fail"

#define MSG_TYPE_NOTICE "notice"
#define MSG_TYPE_WARNING "warning"
#define MSG_TYPE_DANGER "danger"

/datum/experimentor_result_handler
	var/name
	var/fa_icon
	var/scantype
	var/start_message_template
	var/critical_prob
	var/critical_message_template
	var/start_message_type = MSG_TYPE_NOTICE

/datum/experimentor_result_handler/proc/execute(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	var/final_message = replacetext(start_message_template, "%ITEM%", exp_on)
	machine.show_start_message(final_message, start_message_type)

	var/critical = machine.is_critical_reaction(exp_on)
	if(critical && prob(critical_prob))
		handle_critical(machine, exp_on)
		return

	handle_malfunctions(machine, exp_on)

/datum/experimentor_result_handler/proc/handle_critical(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	if(critical_message_template)
		var/final_critical_message = replacetext(critical_message_template, "%ITEM%", exp_on)
		machine.visible_message(span_notice(final_critical_message))

/datum/experimentor_result_handler/proc/handle_malfunctions(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	return

/// Pokes the object
/datum/experimentor_result_handler/poke
	name = "Poke"
	fa_icon = "hand"
	scantype = SCANTYPE_POKE
	start_message_template = "prods at %ITEM% with mechanical arms."
	critical_prob = EFFECT_PROB_LOW
	critical_message_template = "%ITEM% is gripped in just the right way, enhancing its focus."

/datum/experimentor_result_handler/poke/handle_critical(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	..()
	machine.critical_malfunction_counter++
	machine.RefreshParts()

/datum/experimentor_result_handler/poke/handle_malfunctions(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		machine.visible_message(span_danger("[machine] malfunctions and destroys [exp_on], lashing its arms out at nearby people!"))
		for(var/mob/living/nearby_mob in oview(1, machine))
			nearby_mob.apply_damage(15, BRUTE, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST))
			machine.investigate_log("Experimentor dealt minor brute to [nearby_mob].", INVESTIGATE_EXPERIMENTOR)
		QDEL_NULL(machine.loaded_item)

	else if(prob(EFFECT_PROB_LOW * malf_chance))
		machine.visible_message(span_warning("[machine] malfunctions!"))
		machine.run_experiment(SCANTYPE_OBLITERATE)

	else if(prob(EFFECT_PROB_MEDIUM * malf_chance))
		machine.visible_message(span_danger("[machine] malfunctions, throwing the [exp_on]!"))
		var/mob/living/target = locate(/mob/living) in oview(7, machine)
		if(target)
			var/obj/item/throwing = machine.loaded_item
			machine.investigate_log("Experimentor has thrown [machine.loaded_item] at [key_name(target)]", INVESTIGATE_EXPERIMENTOR)
			machine.item_eject()
			if(throwing)
				throwing.throw_at(target, 10, 1)

/// Infuses it with radiation
/datum/experimentor_result_handler/irradiate
	name = "Irradiate"
	fa_icon = "radiation"
	scantype = SCANTYPE_IRRADIATE
	start_message_template = "reflects radioactive rays at %ITEM%!"
	start_message_type = MSG_TYPE_DANGER
	critical_prob = EFFECT_PROB_VERYLOW
	critical_message_template = "%ITEM% has activated an unknown subroutine!"

/datum/experimentor_result_handler/irradiate/handle_critical(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	..()
	machine.investigate_log("Experimentor has made a clone of [exp_on]", INVESTIGATE_EXPERIMENTOR)
	machine.item_eject(TRUE)

/datum/experimentor_result_handler/irradiate/handle_malfunctions(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		machine.visible_message(span_danger("[machine] malfunctions, melting [exp_on] and leaking radiation!"))
		playsound(machine, 'sound/effects/supermatter.ogg', 50, TRUE, -3)
		radiation_pulse(machine, max_range = 6, threshold = 0.3)
		QDEL_NULL(machine.loaded_item)

	else if(prob(EFFECT_PROB_LOW * malf_chance))
		machine.visible_message(span_warning("[machine] malfunctions, spewing toxic waste!"))
		for(var/turf/T in oview(1, machine))
			if(!T.density && prob(EFFECT_PROB_VERYHIGH) && !(locate(/obj/effect/decal/cleanable/greenglow) in T))
				var/obj/effect/decal/cleanable/reagentdecal = new/obj/effect/decal/cleanable/greenglow(T)
				reagentdecal.reagents.add_reagent(/datum/reagent/uranium/radium, 7)
		QDEL_NULL(machine.loaded_item)

	else if(prob(EFFECT_PROB_MEDIUM * malf_chance))
		var/savedName = "[exp_on]"
		QDEL_NULL(machine.loaded_item)
		var/newPath = text2path(pick_weight(machine.valid_items))
		machine.loaded_item = new newPath(machine)
		machine.visible_message(span_warning("[machine] malfunctions, transforming [savedName] into [machine.loaded_item]!"))
		machine.investigate_log("Experimentor has transformed [savedName] into [machine.loaded_item]", INVESTIGATE_EXPERIMENTOR)

		if(istype(machine.loaded_item, /obj/item/grenade/chem_grenade))
			var/obj/item/grenade/chem_grenade/CG = machine.loaded_item
			CG.detonate()

		machine.item_eject()

/// Fills the chamber with gas
/datum/experimentor_result_handler/gas
	name = "Gas"
	fa_icon = "cloud"
	scantype = SCANTYPE_GAS
	start_message_template = "fills its chamber with gas, %ITEM% included."
	start_message_type = MSG_TYPE_WARNING
	critical_prob = EFFECT_PROB_LOW
	critical_message_template = "%ITEM% achieves the perfect mix!"

/datum/experimentor_result_handler/gas/handle_critical(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	..()
	new /obj/item/stack/sheet/mineral/plasma(get_turf(pick(oview(1, machine))))

/datum/experimentor_result_handler/gas/handle_malfunctions(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()
	var/chosenchem

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		machine.visible_message(span_danger("[machine] destroys [exp_on], leaking dangerous gas!"))
		chosenchem = pick(
			/datum/reagent/carbon,
			/datum/reagent/uranium/radium,
			/datum/reagent/toxin,
			/datum/reagent/consumable/condensedcapsaicin,
			/datum/reagent/drug/mushroomhallucinogen,
			/datum/reagent/drug/space_drugs,
			/datum/reagent/consumable/ethanol,
			/datum/reagent/consumable/ethanol/beepsky_smash,
		)
		do_chem_smoke(0, machine, machine.loc, chosenchem, 50)
		machine.investigate_log("Experimentor has released [chosenchem] smoke.", INVESTIGATE_EXPERIMENTOR)
		playsound(machine, 'sound/effects/smoke.ogg', 50, TRUE, -3)
		QDEL_NULL(machine.loaded_item)

	else if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		machine.visible_message(span_danger("[machine]'s chemical chamber has sprung a leak!"))
		chosenchem = pick(
			/datum/reagent/mutationtoxin/classic,
			/datum/reagent/cyborg_mutation_nanomachines,
			/datum/reagent/toxin/acid,
		)
		do_chem_smoke(0, machine, machine.loc, chosenchem, 50)
		playsound(machine, 'sound/effects/smoke.ogg', 50, TRUE, -3)
		QDEL_NULL(machine.loaded_item)
		machine.warn_admins(usr, "[chosenchem] smoke")
		machine.investigate_log("Experimentor has released <font color='red'>[chosenchem]</font> smoke!", INVESTIGATE_EXPERIMENTOR)

	else if(prob(EFFECT_PROB_LOW * malf_chance))
		machine.visible_message(span_warning("[machine] malfunctions, spewing harmless gas."))
		do_smoke(1, machine, machine.loc)

	else if(prob(EFFECT_PROB_MEDIUM * malf_chance))
		machine.visible_message(span_warning("[machine] melts [exp_on], ionizing the air around it!"))
		empulse(machine.loc, 4, 6, emp_source = machine)
		machine.investigate_log("Experimentor has generated an Electromagnetic Pulse.", INVESTIGATE_EXPERIMENTOR)
		QDEL_NULL(machine.loaded_item)

/// Heats the object
/datum/experimentor_result_handler/heat
	name = "Heat"
	fa_icon = "fire"
	scantype = SCANTYPE_HEAT
	start_message_template = "raises %ITEM%'s temperature."
	start_message_type = MSG_TYPE_NOTICE
	critical_prob = EFFECT_PROB_LOW
	critical_message_template = "%ITEM%'s emergency coolant system gives off a small ding!"

/datum/experimentor_result_handler/heat/handle_critical(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	..()
	playsound(machine, 'sound/machines/ding.ogg', 50, TRUE)

	var/obj/item/reagent_containers/cup/glass/coffee/C = new /obj/item/reagent_containers/cup/glass/coffee(get_turf(pick(oview(1, machine))))
	var/chosenchem = pick(
		/datum/reagent/toxin/plasma,
		/datum/reagent/consumable/capsaicin,
		/datum/reagent/consumable/ethanol,
	)
	C.reagents.remove_all(25)
	C.reagents.add_reagent(chosenchem, 50)
	C.name = "Cup of Suspicious Liquid"
	C.desc = "It has a large hazard symbol printed on the side in fading ink."
	machine.investigate_log("Experimentor has made a cup of [chosenchem] coffee.", INVESTIGATE_EXPERIMENTOR)

/datum/experimentor_result_handler/heat/handle_malfunctions(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		var/turf/start = get_turf(machine)
		var/mob/target_mob = locate(/mob/living) in view(machine, 3)
		var/turf/target_turf = get_turf(target_mob)

		if(target_turf)
			machine.visible_message(span_danger("[machine] dangerously overheats, launching a flaming fuel orb!"))
			machine.investigate_log("Experimentor has launched a <font color='red'>fireball</font> at [target_mob]!", INVESTIGATE_EXPERIMENTOR)
			var/obj/projectile/magic/fireball/FB = new /obj/projectile/magic/fireball(start)
			FB.aim_projectile(target_turf, start)
			FB.fire()

	else if(prob(EFFECT_PROB_LOW * malf_chance))
		machine.visible_message(span_danger("[machine] malfunctions, melting [exp_on] and releasing a burst of flame!"))
		explosion(machine, devastation_range = -1, flame_range = 2, adminlog = FALSE)
		machine.investigate_log("Experimentor started a fire.", INVESTIGATE_EXPERIMENTOR)
		QDEL_NULL(machine.loaded_item)

	else if(prob(EFFECT_PROB_MEDIUM * malf_chance))
		machine.visible_message(span_warning("[machine] malfunctions, melting [exp_on] and leaking hot air!"))
		var/datum/gas_mixture/env = machine.loc.return_air()
		if(env)
			var/heat_capacity = max(env.heat_capacity(), 1)
			env.temperature = min((env.temperature * heat_capacity + 100000) / heat_capacity, 1000)
		machine.air_update_turf(FALSE, FALSE)
		machine.investigate_log("Experimentor has released hot air.", INVESTIGATE_EXPERIMENTOR)
		QDEL_NULL(machine.loaded_item)

	else if(prob(EFFECT_PROB_MEDIUM * malf_chance))
		machine.visible_message(span_warning("[machine] malfunctions, activating its emergency coolant systems!"))
		do_smoke(1, machine, machine.loc)
		for(var/mob/living/nearby_mob in oview(1, machine))
			nearby_mob.apply_damage(5, BURN, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST))
			machine.investigate_log("Experimentor has dealt minor burn damage to [key_name(nearby_mob)]", INVESTIGATE_EXPERIMENTOR)
		machine.item_eject()

/// Cools the object
/datum/experimentor_result_handler/cold
	name = "Freeze"
	fa_icon = "snowflake"
	scantype = SCANTYPE_COLD
	start_message_template = "lowers %ITEM%'s temperature."
	start_message_type = MSG_TYPE_NOTICE
	critical_prob = EFFECT_PROB_LOW
	critical_message_template = "%ITEM%'s emergency coolant system gives off a small ding!"

/datum/experimentor_result_handler/cold/handle_critical(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	..()
	playsound(machine, 'sound/machines/ding.ogg', 50, TRUE)

	var/obj/item/reagent_containers/cup/glass/coffee/C = new /obj/item/reagent_containers/cup/glass/coffee(get_turf(pick(oview(1, machine))))
	var/chosenchem = pick(
		/datum/reagent/uranium,
		/datum/reagent/consumable/frostoil,
		/datum/reagent/medicine/ephedrine,
	)
	C.reagents.remove_all(25)
	C.reagents.add_reagent(chosenchem, 50)
	C.name = "Cup of Suspicious Liquid"
	C.desc = "It has a large hazard symbol printed on the side in fading ink."
	machine.investigate_log("Experimentor has made a cup of [chosenchem] coffee.", INVESTIGATE_EXPERIMENTOR)

/datum/experimentor_result_handler/cold/handle_malfunctions(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		machine.visible_message(span_danger("[machine] malfunctions, shattering [exp_on] and releasing a dangerous cloud of coolant!"))
		do_chem_smoke(0, machine, machine.loc, /datum/reagent/consumable/frostoil, 50)
		machine.investigate_log("Experimentor has released frostoil gas.", INVESTIGATE_EXPERIMENTOR)
		playsound(machine, 'sound/effects/smoke.ogg', 50, TRUE, -3)
		QDEL_NULL(machine.loaded_item)

	else if(prob(EFFECT_PROB_LOW * malf_chance))
		machine.visible_message(span_warning("[machine] malfunctions, shattering [exp_on] and leaking cold air!"))
		var/datum/gas_mixture/env = machine.loc.return_air()
		if(env)
			var/heat_capacity = max(env.heat_capacity(), 1)
			env.temperature = max((env.temperature * heat_capacity - 75000) / heat_capacity, TCMB)
		machine.air_update_turf(FALSE, FALSE)
		machine.investigate_log("Experimentor has released cold air.", INVESTIGATE_EXPERIMENTOR)
		QDEL_NULL(machine.loaded_item)

	else if(prob(EFFECT_PROB_MEDIUM * malf_chance))
		machine.visible_message(span_warning("[machine] malfunctions, releasing a flurry of chilly air as [exp_on] pops out!"))
		do_smoke(1, machine, machine.loc)
		machine.item_eject()

/// Crushes the object
/datum/experimentor_result_handler/obliterate
	name = "Obliterate"
	fa_icon = "trash"
	scantype = SCANTYPE_OBLITERATE
	start_message_template = "activates the crushing mechanism, %ITEM% is destroyed!"
	start_message_type = MSG_TYPE_WARNING
	critical_prob = EFFECT_PROB_LOW
	critical_message_template = "%ITEM%'s crushing mechanism slowly and smoothly descends, flattening the %ITEM%!"

/datum/experimentor_result_handler/obliterate/handle_critical(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	..()
	new /obj/item/stack/sheet/plasteel(get_turf(pick(oview(1, machine))))

/datum/experimentor_result_handler/obliterate/handle_malfunctions(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		machine.visible_message(span_danger("[machine]'s crusher goes way too many levels too high, crushing right through space-time!"))
		playsound(machine, 'sound/effects/supermatter.ogg', 50, TRUE, -3)
		machine.investigate_log("Experimentor has triggered the 'throw things' reaction.", INVESTIGATE_EXPERIMENTOR)

		for(var/atom/movable/AM in oview(7, machine))
			if(!AM.anchored)
				AM.throw_at(machine, 10, 1)

	else if(prob(EFFECT_PROB_LOW * malf_chance))
		machine.visible_message(span_danger("[machine]'s crusher goes one level too high, crushing right into space-time!"))
		playsound(machine, 'sound/effects/supermatter.ogg', 50, TRUE, -3)
		machine.investigate_log("Experimentor has triggered the 'minor throw things' reaction.", INVESTIGATE_EXPERIMENTOR)

		var/list/throw_at = list()
		for(var/atom/movable/AM in oview(7, machine))
			if(!AM.anchored)
				throw_at.Add(AM)

		for(var/counter in 1 to throw_at.len)
			var/atom/movable/cast = throw_at[counter]
			cast.throw_at(pick(throw_at), 10, 1)

	QDEL_NULL(machine.loaded_item)

/// Discovers relic properties
/datum/experimentor_result_handler/discover
	scantype = SCANTYPE_DISCOVER
	start_message_template = "scans the %ITEM%, revealing its true nature!"
	start_message_type = MSG_TYPE_NOTICE

/datum/experimentor_result_handler/discover/execute(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	var/final_message = replacetext(start_message_template, "%ITEM%", exp_on)
	machine.show_start_message(final_message, start_message_type)
	playsound(machine, 'sound/effects/supermatter.ogg', 50, 3, -1)

	var/obj/item/relic/loaded_artifact = machine.loaded_item
	if(loaded_artifact)
		loaded_artifact.reveal()
		machine.investigate_log("Experimentor has revealed a relic with [span_danger("[loaded_artifact.hidden_power]")] effect.", INVESTIGATE_EXPERIMENTOR)
	machine.item_eject()

/// Experiment failure
/datum/experimentor_result_handler/fail
	start_message_type = MSG_TYPE_WARNING

/datum/experimentor_result_handler/fail/execute(obj/machinery/rnd/experimentor/machine, obj/item/exp_on)
	var/a = pick("rumbles", "shakes", "vibrates", "shudders", "honks")
	var/b = pick("crushes", "spins", "viscerates", "smashes", "insults")
	machine.visible_message(span_warning("[exp_on] [a], and [b], the experiment was a failure."))

#undef EFFECT_PROB_VERYLOW
#undef EFFECT_PROB_LOW
#undef EFFECT_PROB_MEDIUM
#undef EFFECT_PROB_HIGH
#undef EFFECT_PROB_VERYHIGH

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE
#undef SCANTYPE_DISCOVER
#undef FAIL

#undef MSG_TYPE_NOTICE
#undef MSG_TYPE_WARNING
#undef MSG_TYPE_DANGER
