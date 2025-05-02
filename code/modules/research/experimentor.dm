//this is designed to replace the destructive analyzer

//NEEDS MAJOR CODE CLEANUP

#define SCANTYPE_POKE 1
#define SCANTYPE_IRRADIATE 2
#define SCANTYPE_GAS 3
#define SCANTYPE_HEAT 4
#define SCANTYPE_COLD 5
#define SCANTYPE_OBLITERATE 6
#define SCANTYPE_DISCOVER 7

#define EFFECT_PROB_VERYLOW 20
#define EFFECT_PROB_LOW 35
#define EFFECT_PROB_MEDIUM 50
#define EFFECT_PROB_HIGH 75
#define EFFECT_PROB_VERYHIGH 95

#define FAIL 8
/obj/machinery/rnd/experimentor
	name = "\improper E.X.P.E.R.I-MENTOR"
	desc = "A \"replacement\" for the destructive analyzer with a slight tendency to catastrophically fail."
	icon = 'icons/obj/machines/experimentator.dmi'
	icon_state = "h_lathe"
	base_icon_state = "h_lathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	circuit = /obj/item/circuitboard/machine/experimentor
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN|INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_OPEN_SILICON
	var/recentlyExperimented = 0
	/// Weakref to the first ian we can find at init
	var/datum/weakref/tracked_ian_ref
	/// Weakref to the first runtime we can find at init
	var/datum/weakref/tracked_runtime_ref
	///Determines the probability of a malfunction.
	var/malfunction_probability_coeff = 0
	///Keeps track of how many times we've had a critical reaction
	var/malfunction_probability_coeff_modifier = 0
	var/resetTime = 15
	var/cloneMode = FALSE
	var/list/item_reactions
	var/static/list/valid_items //valid items for special reactions like transforming
	var/list/critical_items_typecache //items that can cause critical reactions

/obj/machinery/rnd/experimentor/proc/valid_items()
	RETURN_TYPE(/list)

	if (isnull(valid_items))
		generate_valid_items_and_item_reactions()

	return valid_items

/obj/machinery/rnd/experimentor/proc/item_reactions()
	RETURN_TYPE(/list)

	if (isnull(item_reactions))
		generate_valid_items_and_item_reactions()

	return item_reactions

/obj/machinery/rnd/experimentor/proc/generate_valid_items_and_item_reactions()
	var/static/list/banned_typecache = typecacheof(list(
		/obj/item/stock_parts/power_store/cell/infinite,
		/obj/item/grenade/chem_grenade/tuberculosis
	))

	item_reactions = list()
	valid_items = list()

	for(var/I in typesof(/obj/item))
		if(ispath(I, /obj/item/relic))
			item_reactions["[I]"] = SCANTYPE_DISCOVER
		else
			item_reactions["[I]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)

		if(is_type_in_typecache(I, banned_typecache))
			continue

		if(ispath(I, /obj/item/stock_parts) || ispath(I, /obj/item/grenade/chem_grenade) || ispath(I, /obj/item/knife))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null) //check it's an actual usable item, in a hacky way
				valid_items["[I]"] += 15

		if(ispath(I, /obj/item/food))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null) //check it's an actual usable item, in a hacky way
				valid_items["[I]"] += rand(1,4)

/obj/machinery/rnd/experimentor/Initialize(mapload)
	. = ..()

	tracked_ian_ref = WEAKREF(locate(/mob/living/basic/pet/dog/corgi/ian) in GLOB.mob_living_list)
	tracked_runtime_ref = WEAKREF(locate(/mob/living/basic/pet/cat/runtime) in GLOB.mob_living_list)

	critical_items_typecache = typecacheof(list(
		/obj/item/construction/rcd,
		/obj/item/grenade,
		/obj/item/aicard,
		/obj/item/slime_extract,
		/obj/item/transfer_valve))

/obj/machinery/rnd/experimentor/RefreshParts()
	. = ..()
	malfunction_probability_coeff = malfunction_probability_coeff_modifier
	resetTime = initial(resetTime)
	for(var/datum/stock_part/servo/servo in component_parts)
		resetTime = max(1, resetTime - servo.tier)
	for(var/datum/stock_part/scanning_module/scanning_module in component_parts)
		malfunction_probability_coeff += scanning_module.tier * 2
	for(var/datum/stock_part/micro_laser/micro_laser in component_parts)
		malfunction_probability_coeff += micro_laser.tier

/obj/machinery/rnd/experimentor/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Malfunction probability reduced by <b>[malfunction_probability_coeff]%</b>.<br>Cooldown interval between experiments at <b>[resetTime*0.1]</b> seconds.")

/obj/machinery/rnd/experimentor/attackby(obj/item/weapon, mob/living/user, params)
	if(user.combat_mode)
		return ..()
	if(!is_insertion_ready(user))
		return ..()
	if(!user.transferItemToLoc(weapon, src))
		to_chat(user, span_warning("\The [weapon] is stuck to your hand, you cannot put it in \the [src]!"))
		return TRUE
	loaded_item = weapon
	to_chat(user, span_notice("You add [weapon] to the machine."))
	flick("h_lathe_load", src)
	return TRUE

/obj/machinery/rnd/experimentor/default_deconstruction_crowbar(obj/item/O)
	ejectItem()
	return ..(O)

/obj/machinery/rnd/experimentor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new (user, src, "Experimentator")
		ui.open()

/obj/machinery/rnd/experimentor/ui_data(mob/user)
	var/list/data = list()

	data["hasItem"] = !!loaded_item
	data["isOnCooldown"] = recentlyExperimented
	data["isServerConnected"] = !!stored_research

	if(!isnull(loaded_item))
		var/list/item_data = list()

		item_data["name"] = loaded_item.name
		item_data["icon"] = icon2base64(getFlatIcon(loaded_item, no_anim = TRUE))
		item_data["isRelic"] = istype(loaded_item, /obj/item/relic)

		item_data["associatedNodes"] = list()
		var/list/unlockable_nodes = techweb_item_unlock_check(loaded_item)
		for(var/node_id in unlockable_nodes)
			var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_id)

			item_data["associatedNodes"] += list(list(
				"name" = node.display_name,
				"isUnlocked" = !(node_id in stored_research.hidden_nodes),
			))

		data["loadedItem"] = item_data

	return data

/obj/machinery/rnd/experimentor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject")
			ejectItem()
			return TRUE

		if("experiment")
			var/reaction = text2num(params["id"])
			if(isnull(reaction))
				return

			try_perform_experiment(reaction)
			return TRUE

/obj/machinery/rnd/experimentor/proc/ejectItem(delete = FALSE)
	if(isnull(loaded_item))
		return

	if(delete)
		QDEL_NULL(loaded_item)
		return

	var/atom/drop_atom = get_step(src, EAST) || drop_location()
	if(cloneMode)
		visible_message(span_notice("A duplicate of \the [loaded_item] pops out!"))
		new loaded_item.type(drop_atom)
		cloneMode = FALSE
		return

	loaded_item.forceMove(drop_atom)
	loaded_item = null

/obj/machinery/rnd/experimentor/proc/match_reaction(obj/item/matching, target_reaction)
	PRIVATE_PROC(TRUE)
	if(isnull(matching) || isnull(target_reaction))
		return FAIL

	var/list/item_reactions = item_reactions()
	if("[matching.type]" in item_reactions)
		var/associated_reaction = item_reactions["[matching.type]"]
		if(associated_reaction == target_reaction)
			return associated_reaction

	return FAIL

/obj/machinery/rnd/experimentor/proc/try_perform_experiment(reaction)
	PRIVATE_PROC(TRUE)
	if(isnull(stored_research))
		return

	if(recentlyExperimented)
		return

	if(isnull(loaded_item))
		return

	if(reaction != SCANTYPE_DISCOVER)
		reaction = match_reaction(loaded_item, reaction)

	if(reaction != FAIL)
		var/picked_node_id = pick(techweb_item_unlock_check(loaded_item))
		stored_research.unhide_node(SSresearch.techweb_node_by_id(picked_node_id))

	experiment(reaction, loaded_item)
	use_energy(750 JOULES)

/obj/machinery/rnd/experimentor/proc/throwSmoke(turf/where)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, holder = src, location = where)
	smoke.start()

/obj/machinery/rnd/experimentor/proc/experiment(exp,obj/item/exp_on)
	recentlyExperimented = 1
	icon_state = "[base_icon_state]_wloop"
	var/chosenchem
	var/criticalReaction = is_type_in_typecache(exp_on,  critical_items_typecache)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_POKE)
		visible_message(span_notice("[src] prods at [exp_on] with mechanical arms."))
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message(span_notice("[exp_on] is gripped in just the right way, enhancing its focus."))
			malfunction_probability_coeff_modifier++
			RefreshParts() //recalculate malfunction_probability_coeff
		else if(prob(EFFECT_PROB_VERYLOW * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_danger("[src] malfunctions and destroys [exp_on], lashing its arms out at nearby people!"))
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(15, BRUTE, pick(BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_CHEST))
				investigate_log("Experimentor dealt minor brute to [m].", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_warning("[src] malfunctions!"))
			exp = SCANTYPE_OBLITERATE
		else if(prob(EFFECT_PROB_MEDIUM * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_danger("[src] malfunctions, throwing the [exp_on]!"))
			var/mob/living/target = locate(/mob/living) in oview(7,src)
			if(target)
				var/obj/item/throwing = loaded_item
				investigate_log("Experimentor has thrown [loaded_item] at [key_name(target)]", INVESTIGATE_EXPERIMENTOR)
				ejectItem()
				if(throwing)
					throwing.throw_at(target, 10, 1)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_IRRADIATE)
		visible_message(span_danger("[src] reflects radioactive rays at [exp_on]!"))
		if(prob(EFFECT_PROB_VERYLOW) && criticalReaction)
			visible_message(span_notice("[exp_on] has activated an unknown subroutine!"))
			cloneMode = TRUE
			investigate_log("Experimentor has made a clone of [exp_on]", INVESTIGATE_EXPERIMENTOR)
			ejectItem()
		else if(prob(EFFECT_PROB_VERYLOW * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_danger("[src] malfunctions, melting [exp_on] and leaking radiation!"))
			radiation_pulse(src, max_range = 6, threshold = 0.3)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_warning("[src] malfunctions, spewing toxic waste!"))
			for(var/turf/T in oview(1, src))
				if(!T.density)
					if(prob(EFFECT_PROB_VERYHIGH) && !(locate(/obj/effect/decal/cleanable/greenglow) in T))
						var/obj/effect/decal/cleanable/reagentdecal = new/obj/effect/decal/cleanable/greenglow(T)
						reagentdecal.reagents.add_reagent(/datum/reagent/uranium/radium, 7)
		else if(prob(EFFECT_PROB_MEDIUM * (100 - malfunction_probability_coeff) * 0.01))
			var/savedName = "[exp_on]"
			ejectItem(TRUE)
			var/newPath = text2path(pick_weight(valid_items()))
			loaded_item = new newPath(src)
			visible_message(span_warning("[src] malfunctions, transforming [savedName] into [loaded_item]!"))
			investigate_log("Experimentor has transformed [savedName] into [loaded_item]", INVESTIGATE_EXPERIMENTOR)
			if(istype(loaded_item, /obj/item/grenade/chem_grenade))
				var/obj/item/grenade/chem_grenade/CG = loaded_item
				CG.detonate()
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_GAS)
		visible_message(span_warning("[src] fills its chamber with gas, [exp_on] included."))
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message(span_notice("[exp_on] achieves the perfect mix!"))
			new /obj/item/stack/sheet/mineral/plasma(get_turf(pick(oview(1,src))))
		else if(prob(EFFECT_PROB_VERYLOW * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_danger("[src] destroys [exp_on], leaking dangerous gas!"))
			chosenchem = pick(/datum/reagent/carbon,/datum/reagent/uranium/radium,/datum/reagent/toxin,/datum/reagent/consumable/condensedcapsaicin,/datum/reagent/drug/mushroomhallucinogen,/datum/reagent/drug/space_drugs,/datum/reagent/consumable/ethanol,/datum/reagent/consumable/ethanol/beepsky_smash)
			var/datum/reagents/tmp_holder = new/datum/reagents(50)
			tmp_holder.my_atom = src
			tmp_holder.add_reagent(chosenchem , 50)
			investigate_log("Experimentor has released [chosenchem] smoke.", INVESTIGATE_EXPERIMENTOR)
			var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
			smoke.set_up(0, holder = src, location = src, carry = tmp_holder, silent = TRUE)
			playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
			smoke.start()
			qdel(tmp_holder)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_VERYLOW * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_danger("[src]'s chemical chamber has sprung a leak!"))
			chosenchem = pick(/datum/reagent/mutationtoxin/classic,/datum/reagent/cyborg_mutation_nanomachines,/datum/reagent/toxin/acid)
			var/datum/reagents/tmp_holder = new/datum/reagents(50)
			tmp_holder.my_atom = src
			tmp_holder.add_reagent(chosenchem , 50)
			var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
			smoke.set_up(0, holder = src, location = src, carry = tmp_holder, silent = TRUE)
			playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
			smoke.start()
			qdel(tmp_holder)
			ejectItem(TRUE)
			warn_admins(usr, "[chosenchem] smoke")
			investigate_log("Experimentor has released <font color='red'>[chosenchem]</font> smoke!", INVESTIGATE_EXPERIMENTOR)
		else if(prob(EFFECT_PROB_LOW * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_warning("[src] malfunctions, spewing harmless gas."))
			throwSmoke(loc)
		else if(prob(EFFECT_PROB_MEDIUM * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_warning("[src] melts [exp_on], ionizing the air around it!"))
			empulse(loc, 4, 6)
			investigate_log("Experimentor has generated an Electromagnetic Pulse.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_HEAT)
		visible_message(span_notice("[src] raises [exp_on]'s temperature."))
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message(span_warning("[src]'s emergency coolant system gives off a small ding!"))
			playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
			var/obj/item/reagent_containers/cup/glass/coffee/C = new /obj/item/reagent_containers/cup/glass/coffee(get_turf(pick(oview(1,src))))
			chosenchem = pick(/datum/reagent/toxin/plasma,/datum/reagent/consumable/capsaicin,/datum/reagent/consumable/ethanol)
			C.reagents.remove_all(25)
			C.reagents.add_reagent(chosenchem , 50)
			C.name = "Cup of Suspicious Liquid"
			C.desc = "It has a large hazard symbol printed on the side in fading ink."
			investigate_log("Experimentor has made a cup of [chosenchem] coffee.", INVESTIGATE_EXPERIMENTOR)
		else if(prob(EFFECT_PROB_VERYLOW * (100 - malfunction_probability_coeff) * 0.01))
			var/turf/start = get_turf(src)
			var/mob/M = locate(/mob/living) in view(src, 3)
			var/turf/MT = get_turf(M)
			if(MT)
				visible_message(span_danger("[src] dangerously overheats, launching a flaming fuel orb!"))
				investigate_log("Experimentor has launched a <font color='red'>fireball</font> at [M]!", INVESTIGATE_EXPERIMENTOR)
				var/obj/projectile/magic/fireball/FB = new /obj/projectile/magic/fireball(start)
				FB.aim_projectile(MT, start)
				FB.fire()
		else if(prob(EFFECT_PROB_LOW * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_danger("[src] malfunctions, melting [exp_on] and releasing a burst of flame!"))
			explosion(src, devastation_range = -1, flame_range = 2, adminlog = FALSE)
			investigate_log("Experimentor started a fire.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_warning("[src] malfunctions, melting [exp_on] and leaking hot air!"))
			var/datum/gas_mixture/env = loc.return_air()
			if(env)
				var/heat_capacity = max(env.heat_capacity(), 1)
				env.temperature = min((env.temperature * heat_capacity + 100000) / heat_capacity, 1000)
			air_update_turf(FALSE, FALSE)
			investigate_log("Experimentor has released hot air.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_warning("[src] malfunctions, activating its emergency coolant systems!"))
			throwSmoke(loc)
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(5, BURN, pick(BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_CHEST))
				investigate_log("Experimentor has dealt minor burn damage to [key_name(m)]", INVESTIGATE_EXPERIMENTOR)
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_COLD)
		visible_message(span_notice("[src] lowers [exp_on]'s temperature."))
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message(span_warning("[src]'s emergency coolant system gives off a small ding!"))
			var/obj/item/reagent_containers/cup/glass/coffee/C = new /obj/item/reagent_containers/cup/glass/coffee(get_turf(pick(oview(1,src))))
			playsound(src, 'sound/machines/ding.ogg', 50, TRUE) //Ding! Your death coffee is ready!
			chosenchem = pick(/datum/reagent/uranium,/datum/reagent/consumable/frostoil,/datum/reagent/medicine/ephedrine)
			C.reagents.remove_all(25)
			C.reagents.add_reagent(chosenchem , 50)
			C.name = "Cup of Suspicious Liquid"
			C.desc = "It has a large hazard symbol printed on the side in fading ink."
			investigate_log("Experimentor has made a cup of [chosenchem] coffee.", INVESTIGATE_EXPERIMENTOR)
		else if(prob(EFFECT_PROB_VERYLOW * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_danger("[src] malfunctions, shattering [exp_on] and releasing a dangerous cloud of coolant!"))
			var/datum/reagents/tmp_holder = new/datum/reagents(50)
			tmp_holder.my_atom = src
			tmp_holder.add_reagent(/datum/reagent/consumable/frostoil, 50)
			investigate_log("Experimentor has released frostoil gas.", INVESTIGATE_EXPERIMENTOR)
			var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
			smoke.set_up(0, holder = src, location = src, carry = tmp_holder, silent = TRUE)
			playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
			smoke.start()
			qdel(tmp_holder)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_warning("[src] malfunctions, shattering [exp_on] and leaking cold air!"))
			var/datum/gas_mixture/env = loc.return_air()
			if(env)
				var/heat_capacity = max(env.heat_capacity(), 1)
				env.temperature = max((env.temperature * heat_capacity - 75000) / heat_capacity, TCMB)
			air_update_turf(FALSE, FALSE)
			investigate_log("Experimentor has released cold air.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_warning("[src] malfunctions, releasing a flurry of chilly air as [exp_on] pops out!"))
			var/datum/effect_system/fluid_spread/smoke/smoke = new
			smoke.set_up(0, holder = src, location = loc)
			smoke.start()
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_OBLITERATE)
		visible_message(span_warning("[exp_on] activates the crushing mechanism, [exp_on] is destroyed!"))
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message(span_warning("[src]'s crushing mechanism slowly and smoothly descends, flattening the [exp_on]!"))
			new /obj/item/stack/sheet/plasteel(get_turf(pick(oview(1,src))))
		else if(prob(EFFECT_PROB_VERYLOW * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_danger("[src]'s crusher goes way too many levels too high, crushing right through space-time!"))
			playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE, -3)
			investigate_log("Experimentor has triggered the 'throw things' reaction.", INVESTIGATE_EXPERIMENTOR)
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					AM.throw_at(src,10,1)
		else if(prob(EFFECT_PROB_LOW * (100 - malfunction_probability_coeff) * 0.01))
			visible_message(span_danger("[src]'s crusher goes one level too high, crushing right into space-time!"))
			playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE, -3)
			investigate_log("Experimentor has triggered the 'minor throw things' reaction.", INVESTIGATE_EXPERIMENTOR)
			var/list/throwAt = list()
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					throwAt.Add(AM)
			for(var/counter in 1 to throwAt.len)
				var/atom/movable/cast = throwAt[counter]
				cast.throw_at(pick(throwAt),10,1)
		ejectItem(TRUE)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == FAIL)
		var/a = pick("rumbles","shakes","vibrates","shudders","honks")
		var/b = pick("crushes","spins","viscerates","smashes","insults")
		visible_message(span_warning("[exp_on] [a], and [b], the experiment was a failure."))

	if(exp == SCANTYPE_DISCOVER)
		visible_message(span_notice("[src] scans the [exp_on], revealing its true nature!"))
		playsound(src, 'sound/effects/supermatter.ogg', 50, 3, -1)
		var/obj/item/relic/loaded_artifact = loaded_item
		loaded_artifact.reveal()
		investigate_log("Experimentor has revealed a relic with [span_danger("[loaded_artifact.hidden_power]")] effect.", INVESTIGATE_EXPERIMENTOR)
		ejectItem()

	//Global reactions
	if(prob(EFFECT_PROB_VERYLOW * (100 - malfunction_probability_coeff) * 0.01) && loaded_item)
		var/globalMalf = rand(1,100)
		if(globalMalf < 15)
			visible_message(span_warning("[src]'s onboard detection system has malfunctioned!"))
			item_reactions()["[exp_on.type]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
			ejectItem()
		if(globalMalf > 16 && globalMalf < 35)
			visible_message(span_warning("[src] melts [exp_on], ian-izing the air around it!"))
			throwSmoke(loc)
			var/mob/living/tracked_ian = tracked_ian_ref?.resolve()
			if(tracked_ian)
				throwSmoke(tracked_ian.loc)
				tracked_ian.forceMove(loc)
				investigate_log("Experimentor has stolen Ian!", INVESTIGATE_EXPERIMENTOR) //...if anyone ever fixes it...
			else
				new /mob/living/basic/pet/dog/corgi(loc)
				investigate_log("Experimentor has spawned a new corgi.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		if(globalMalf > 36 && globalMalf < 50)
			visible_message(span_warning("Experimentor draws the life essence of those nearby!"))
			for(var/mob/living/m in view(4,src))
				to_chat(m, span_danger("You feel your flesh being torn from you, mists of blood drifting to [src]!"))
				m.apply_damage(50, BRUTE, BODY_ZONE_CHEST)
				investigate_log("Experimentor has taken 50 brute a blood sacrifice from [m]", INVESTIGATE_EXPERIMENTOR)
		if(globalMalf > 51 && globalMalf < 75)
			visible_message(span_warning("[src] encounters a run-time error!"))
			throwSmoke(loc)
			var/mob/living/tracked_runtime = tracked_runtime_ref?.resolve()
			if(tracked_runtime)
				throwSmoke(tracked_runtime.loc)
				tracked_runtime.forceMove(drop_location())
				investigate_log("Experimentor has stolen Runtime!", INVESTIGATE_EXPERIMENTOR)
			else
				new /mob/living/basic/pet/cat(loc)
				investigate_log("Experimentor failed to steal runtime, and instead spawned a new cat.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		if(globalMalf > 76 && globalMalf < 98)
			visible_message(span_warning("[src] begins to smoke and hiss, shaking violently!"))
			use_energy(500 KILO JOULES)
			investigate_log("Experimentor has drained power from its APC", INVESTIGATE_EXPERIMENTOR)
		if(globalMalf == 99)
			visible_message(span_warning("[src] begins to glow and vibrate. It's going to blow!"))
			addtimer(CALLBACK(src, PROC_REF(boom)), 5 SECONDS)
		if(globalMalf == 100)
			visible_message(span_warning("[src] begins to glow and vibrate. It's going to blow!"))
			addtimer(CALLBACK(src, PROC_REF(honk)), 5 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(reset_exp)), resetTime)

/obj/machinery/rnd/experimentor/proc/boom()
	explosion(src, devastation_range = 1, heavy_impact_range = 5, light_impact_range = 10, flash_range = 5, adminlog = TRUE)

/obj/machinery/rnd/experimentor/proc/honk()
	playsound(src, 'sound/items/bikehorn.ogg', 500)
	new /obj/item/grown/bananapeel(loc)

/obj/machinery/rnd/experimentor/proc/reset_exp()
	update_appearance()
	recentlyExperimented = FALSE

/obj/machinery/rnd/experimentor/update_icon_state()
	icon_state = base_icon_state
	return ..()

/obj/machinery/rnd/experimentor/proc/warn_admins(user, ReactionName)
	var/turf/T = get_turf(user)
	message_admins("Experimentor reaction: [ReactionName] generated by [ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(T)]")
	log_game("Experimentor reaction: [ReactionName] generated by [key_name(user)] in [AREACOORD(T)]")

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE
#undef SCANTYPE_DISCOVER

#undef EFFECT_PROB_VERYLOW
#undef EFFECT_PROB_LOW
#undef EFFECT_PROB_MEDIUM
#undef EFFECT_PROB_HIGH
#undef EFFECT_PROB_VERYHIGH

#undef FAIL


// Relic \\

/obj/item/relic
	name = "strange object"
	desc = "What mysteries could this hold? Maybe Research & Development could find out."
	icon = 'icons/obj/devices/artefacts.dmi'
	icon_state = "debug_artefact"
	//The name this artefact will have when it's activated.
	var/real_name = "artefact"
	//Has this artefact been activated?
	var/activated = FALSE
	//What effect this artefact has when used. Randomly determined when activated.
	var/hidden_power
	//Minimum possible cooldown.
	var/min_cooldown = 6 SECONDS
	//Max possible cooldown.
	var/max_cooldown = 30 SECONDS
	//Cooldown length. Randomly determined at activation if it isn't determined here.
	var/cooldown_timer
	COOLDOWN_DECLARE(cooldown)
	//What visual theme this artefact has. Current possible choices: "prototype", "necrotech"
	var/artifact_theme = "prototype"
	var/datum/effect_system/spark_spread/sparks

/obj/item/relic/Initialize(mapload)
	. = ..()
	sparks = new()
	sparks.set_up(5, 1, src)
	sparks.attach(src)
	random_themed_appearance()

/obj/item/relic/Destroy(force)
	QDEL_NULL(sparks)
	. = ..()

/obj/item/relic/proc/random_themed_appearance()
	var/themed_name_prefix
	var/themed_name_suffix
	if(artifact_theme == "prototype")
		icon_state = pick("prototype1", "prototype2", "prototype3", "prototype4", "prototype5", "prototype6", "prototype7", "prototype8","prototype9")
		themed_name_prefix = pick("experimental","prototype","artificial","handcrafted","ramshackle","odd")
		themed_name_suffix = pick("device","assembly","gadget","gizmo","contraption","machine","widget","object")
		real_name = "[pick(themed_name_prefix)] [pick(themed_name_suffix)]"
		name = "strange [pick(themed_name_suffix)]"
	if(artifact_theme == "necrotech")
		icon_state = pick("necrotech1", "necrotech2", "necrotech3", "necrotech4", "necrotech5", "necrotech6")
		themed_name_prefix = pick("dark","bloodied","unholy","archeotechnological","dismal","ruined","thrumming")
		themed_name_suffix = pick("instrument","shard","fetish","bibelot","trinket","offering","relic")
		real_name = "[pick(themed_name_prefix)] [pick(themed_name_suffix)]"
		name = "strange relic"
	update_appearance()

/obj/item/relic/lavaland
	name = "strange relic"
	artifact_theme = "necrotech"

/obj/item/relic/proc/reveal()
	if(activated) //no rerolling
		return
	activated = TRUE
	name = real_name
	if(!cooldown_timer)
		cooldown_timer = rand(min_cooldown, max_cooldown)
	if(!hidden_power)
		hidden_power = pick(
			PROC_REF(corgi_cannon),
			PROC_REF(cleaning_foam),
			PROC_REF(flashbanger),
			PROC_REF(summon_animals),
			PROC_REF(uncontrolled_teleport),
			PROC_REF(heat_and_explode),
			PROC_REF(rapid_self_dupe),
			PROC_REF(drink_dispenser),
			PROC_REF(tummy_ache),
			PROC_REF(charger),
			PROC_REF(hugger),
			PROC_REF(dimensional_shift),
			PROC_REF(disguiser),
			)

/obj/item/relic/attack_self(mob/user)
	if(!activated)
		to_chat(user, span_notice("You aren't quite sure what this is. Maybe R&D knows what to do with it?"))
		return
	if(!COOLDOWN_FINISHED(src, cooldown))
		to_chat(user, span_warning("[src] does not react!"))
		return
	if(loc != user)
		return
	COOLDOWN_START(src, cooldown, cooldown_timer)
	call(src, hidden_power)(user)

/obj/item/relic/proc/throw_smoke(turf/where)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, holder = src, location = get_turf(where))
	smoke.start()

// Artefact Powers \\

/obj/item/relic/proc/corgi_cannon(mob/user)
	playsound(src, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/mob/living/basic/pet/dog/corgi/sad_corgi = new(get_turf(user))
	sad_corgi.throw_at(pick(oview(10,user)), 10, rand(3,8), callback = CALLBACK(src, PROC_REF(throw_smoke), sad_corgi))
	warn_admins(user, "Corgi Cannon", 0)

/obj/item/relic/proc/cleaning_foam(mob/user)
	playsound(src, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/obj/item/grenade/chem_grenade/cleaner/spawned_foamer = new/obj/item/grenade/chem_grenade/cleaner(get_turf(user))
	spawned_foamer.detonate()
	qdel(spawned_foamer)
	warn_admins(user, "Foam", 0)

/obj/item/relic/proc/flashbanger(mob/user)
	playsound(src, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/obj/item/grenade/flashbang/spawned_flashbang = new/obj/item/grenade/flashbang(user.loc)
	spawned_flashbang.detonate()
	warn_admins(user, "Flash")

/obj/item/relic/proc/summon_animals(mob/user)
	var/message = span_danger("[src] begins to shake, and in the distance the sound of rampaging animals arises!")
	visible_message(message)
	to_chat(user, message)
	var/static/list/valid_animals = list(
		/mob/living/basic/bear,
		/mob/living/basic/bee,
		/mob/living/basic/butterfly,
		/mob/living/basic/carp,
		/mob/living/basic/crab,
		/mob/living/basic/lizard,
		/mob/living/basic/mouse,
		/mob/living/basic/parrot,
		/mob/living/basic/pet/cat,
		/mob/living/basic/pet/dog/corgi,
		/mob/living/basic/pet/dog/pug,
		/mob/living/basic/pet/fox,
	)
	for(var/counter in 1 to rand(1, 25))
		var/animal_spawn = pick(valid_animals)
		new animal_spawn(get_turf(src))
	warn_admins(user, "Mass Mob Spawn")
	if(prob(60))
		to_chat(user, span_warning("[src] falls apart!"))
		qdel(src)

/obj/item/relic/proc/rapid_self_dupe(mob/user)
	audible_message("[src] emits a loud pop!")
	var/list/dummy_artifacts = list()
	for(var/counter in 1 to rand(5,10))
		var/obj/item/relic/duped = new type(get_turf(src))
		duped.name = name
		duped.desc = desc
		duped.real_name = real_name
		duped.hidden_power = hidden_power
		duped.activated = TRUE
		dummy_artifacts += duped
		duped.throw_at(pick(oview(7,get_turf(src))),10,1)
	QDEL_LIST_IN(dummy_artifacts, rand(1 SECONDS, 10 SECONDS))
	warn_admins(user, "Rapid duplicator", 0)

/obj/item/relic/proc/heat_and_explode(mob/user)
	to_chat(user, span_danger("[src] begins to heat up!"))
	addtimer(CALLBACK(src, PROC_REF(blow_up), user), rand(3.5 SECONDS, 10 SECONDS))

/obj/item/relic/proc/blow_up(mob/user)
	if(loc == user)
		visible_message(span_notice("\The [src]'s top opens, releasing a powerful blast!"))
		explosion(src, heavy_impact_range = rand(1,5), light_impact_range = rand(1,5), flame_range = 2, flash_range = rand(1,5), adminlog = TRUE)
		warn_admins(user, "Explosion")
		qdel(src) //Comment this line to produce a light grenade (the bomb that keeps on exploding when used)!!

/obj/item/relic/proc/uncontrolled_teleport(mob/user)
	to_chat(user, span_notice("[src] begins to vibrate!"))
	addtimer(CALLBACK(src, PROC_REF(do_the_teleport), user), rand(1 SECONDS, 3 SECONDS))

/obj/item/relic/proc/do_the_teleport(mob/user)
	var/turf/userturf = get_turf(user)
	//Because Nuke Ops bringing this back on their shuttle, then looting the ERT area is 2fun4you!
	if(is_centcom_level(userturf.z))
		return
	var/to_teleport = ismovable(loc) ? loc : src
	visible_message(span_notice("[to_teleport] twists and bends, relocating itself!"))
	throw_smoke(get_turf(to_teleport))
	do_teleport(to_teleport, userturf, 8, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	throw_smoke(get_turf(to_teleport))
	warn_admins(user, "Teleport", 0)

// Creates a glass and fills it up with a drink.
/obj/item/relic/proc/drink_dispenser(mob/user)
	var/obj/item/reagent_containers/cup/glass/drinkingglass/freebie = new(get_step_rand(user))
	playsound(freebie, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	sparks.start()
	addtimer(CALLBACK(src, PROC_REF(dispense_drink), freebie), 0.5 SECONDS)

/obj/item/relic/proc/dispense_drink(obj/item/reagent_containers/cup/glass/glasser)
	playsound(glasser, 'sound/effects/phasein.ogg', rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	glasser.reagents.add_reagent(get_random_drink_id(), rand(glasser.volume * 0.3, glasser.volume))
	throw_smoke(get_turf(glasser))

// Scrambles your organs. 33% chance to delete after use.
/obj/item/relic/proc/tummy_ache(mob/user)
	new /obj/effect/temp_visual/circle_wave/bioscrambler/light(get_turf(src))
	to_chat(user, span_notice("Your stomach starts growling..."))
	addtimer(CALLBACK(src, PROC_REF(scrambliticus), user), rand(1 SECONDS, 3 SECONDS)) // throw it away!

/obj/item/relic/proc/scrambliticus(mob/user)
	new /obj/effect/temp_visual/circle_wave/bioscrambler/light(get_turf(src))
	playsound(src, 'sound/effects/magic/cosmic_energy.ogg', vol = 50, vary = TRUE)
	for(var/mob/living/carbon/nearby in range(2, get_turf(src))) //needs get_turf() to work
		nearby.bioscramble(name)
		playsound(nearby, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		throw_smoke(get_turf(nearby))
		to_chat(nearby, span_notice("You feel weird."))
	if(prob(33))
		qdel(src)

// Charges an item or two in your inventory. Also yourself.
/obj/item/relic/proc/charger(mob/living/user)
	to_chat(user, span_danger("You're recharged!"))
	var/stunner = 1.25 SECONDS
	if(iscarbon(user))
		var/mob/living/carbon/carboner = user
		carboner.electrocute_act(15, src, flags = SHOCK_NOGLOVES, stun_duration = stunner)
	else
		user.electrocute_act(15, src, flags = SHOCK_NOGLOVES)
	playsound(user, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	var/list/chargeable_batteries = list()
	for(var/obj/item/stock_parts/power_store/C in user.get_all_contents())
		if(C.charge < (C.maxcharge * 0.95)) // otherwise the PDA always gets recharged
			chargeable_batteries |= C

	lightning_fx(user, stunner)
	var/recharges = rand(1, 2)
	if(!length(chargeable_batteries))
		to_chat(user, span_notice("You have a strange feeling for a moment, but then it passes."))
		return
	for(var/obj/item/stock_parts/power_store/to_charge as anything in chargeable_batteries)
		if(!recharges)
			return
		recharges--
		to_charge = pick(chargeable_batteries)
		to_charge.charge = to_charge.maxcharge
		// The device powered by the cell is assumed to be its location.
		var/obj/device = to_charge.loc
		// If it's not an object, or the loc's assigned power_store isn't the cell, undo.
		if(!istype(device) || (device.get_cell() != to_charge))
			device = to_charge
		device.update_appearance(UPDATE_ICON|UPDATE_OVERLAYS)
		to_chat(user, span_notice("[device] feels energized!"))
		lightning_fx(device, 0.8 SECONDS)

/obj/item/relic/proc/lightning_fx(atom/shocker, time)
	var/lightning = mutable_appearance('icons/effects/effects.dmi', "electricity3", layer = ABOVE_MOB_LAYER)
	shocker.add_overlay(lightning)
	addtimer(CALLBACK(src, PROC_REF(cut_the_overlay), shocker, lightning), time)

/obj/item/relic/proc/cut_the_overlay(atom/shocker, lightning)
	shocker.cut_overlay(lightning)

// Hugs/shakes everyone in range!
/obj/item/relic/proc/hugger(mob/user)
	var/list/mob/living/carbon/huggeds = oviewers(3, user)
	for(var/mob/living/carbon/victim in huggeds)
		victim.help_shake_act(user, force_friendly = TRUE)
		new /obj/effect/temp_visual/heart(victim.loc)
	if(length(huggeds))
		to_chat(user, span_nicegreen("You feel friendly!"))
	else
		to_chat(user, pick(span_notice("You hug yourself, for some reason."), span_notice("You have a strange feeling for a moment, but then it passes.")))

// Converts a 3x3 area into a random dimensional theme.
/obj/item/relic/proc/dimensional_shift(mob/user)
	var/new_theme_path = pick(subtypesof(/datum/dimension_theme))
	var/datum/dimension_theme/shifter = SSmaterials.dimensional_themes[new_theme_path]
	for(var/turf/shiftee in range(1, user))
		shifter.apply_theme(shiftee, show_effect = TRUE)
	// prevent *total* spam conversion
	min_cooldown += 2 SECONDS
	max_cooldown += 2 SECONDS

// Replaces your clothing with a random costume, and your ID with a cardboard one.
// TODO: make them part of the same kit (lobster hat, lobster suit)
/obj/item/relic/proc/disguiser(mob/user)
	if(!iscarbon(user))
		to_chat(user, span_notice("You have a strange feeling for a moment, but then it passes."))
		return

	if(prob(80)) // >:)
		ADD_TRAIT(user, TRAIT_NO_JUMPSUIT, REF(src)) // prevent dropping pockets & belt

	// magic trick!
	playsound(user, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	throw_smoke(user)

	// carbons always get a hat at least
	var/mob/living/carbon/carbonius = user
	//hat
	var/obj/item/clothing/head/costume/disguise_hat = roll_costume(ITEM_SLOT_HEAD, HIDEMASK)
	carbonius.dropItemToGround(carbonius.head)
	carbonius.equip_to_slot_or_del(disguise_hat, ITEM_SLOT_HEAD)
	if(!ishuman(carbonius))
		to_chat(user, span_notice("You have a peculiar feeling for a moment, but then it passes."))
		return

	var/mob/living/carbon/human/humerus = carbonius
	// uniform
	var/obj/item/clothing/under/costume/disguise_uniform = roll_costume(ITEM_SLOT_ICLOTHING)
	humerus.dropItemToGround(humerus.w_uniform)
	humerus.equip_to_slot_or_del(disguise_uniform, ITEM_SLOT_ICLOTHING)
	// suit
	var/obj/item/clothing/suit/costume/disguise_suit = roll_costume(ITEM_SLOT_OCLOTHING)
	humerus.dropItemToGround(humerus.wear_suit)
	humerus.equip_to_slot_or_del(disguise_suit, ITEM_SLOT_OCLOTHING)
	// id
	var/obj/item/card/cardboard/card_id = new()
	humerus.dropItemToGround(humerus.wear_id)
	humerus.equip_to_slot_or_del(card_id, ITEM_SLOT_ID)

	// edit the card to a random job & name
	if(!card_id)
		return
	card_id.scribbled_name = "[pick(GLOB.first_names)] [pick(GLOB.last_names)]"
	card_id.details_colors = list(ready_random_color(), ready_random_color(), ready_random_color())
	card_id.item_flags |= DROPDEL

	var/datum/id_trim/random_trim = pick(subtypesof(/datum/id_trim)) // this can pick silly things
	random_trim = new random_trim()
	if(random_trim.trim_state && random_trim.assignment)
		card_id.scribbled_trim = replacetext(random_trim.trim_state, "trim_", "cardboard_")
	card_id.scribbled_assignment = random_trim.assignment
	card_id.update_appearance()
	REMOVE_TRAIT(user, TRAIT_NO_JUMPSUIT, REF(src))

/obj/item/relic/proc/roll_costume(slot, flagcheck)
	var/list/candidates = list()
	for(var/obj/item/costume as anything in GLOB.all_autodrobe_items)
		if(flagcheck && !(initial(costume.flags_inv) & flagcheck))
			continue
		if(slot && !(initial(costume.slot_flags) & slot))
			continue
		candidates |= costume
	var/obj/item/new_costume = pick(candidates)
	new_costume = new new_costume()
	new_costume.item_flags |= DROPDEL
	return new_costume

//Admin Warning proc for relics
/obj/item/relic/proc/warn_admins(mob/user, relic_type, priority = 1)
	var/turf/location = get_turf(src)
	var/log_msg = "[relic_type] relic used by [key_name(user)] in [AREACOORD(location)]"
	if(priority) //For truly dangerous relics that may need an admin's attention. BWOINK!
		message_admins("[relic_type] relic activated by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(location)]")
	log_game(log_msg)
	investigate_log(log_msg, "experimentor")
