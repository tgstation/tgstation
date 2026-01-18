/obj/machinery/gibber
	name = "gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/machines/kitchen.dmi'
	icon_state = "grinder"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/gibber
	anchored_tabletop_offset = 8

	//Is it on?
	var/operating = FALSE
	/// Does it need cleaning?
	var/dirty = FALSE
	/// Time from starting until meat appears
	var/gibtime = 40
	/// Average efficiency multiplier for how much meat we meet when we meat the meat per meat of each of meat's meat limbs
	var/efficiency = 0.25
	/// If the gibber should give the 'Subject may not have abiotic items on' message
	var/ignore_clothing = FALSE
	/// The DNA info of the last gibbed mob
	var/blood_dna_info

/obj/machinery/gibber/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_cleaned))
	if(prob(5))
		name = "meat grinder"
		desc = "Okay, if I... if I chop you up in a meat grinder, and the only thing that comes out, that's left of you, is your eyeball, \
			you'r- you're PROBABLY DEAD! You're probably going to - not you, I'm just sayin', like, if you- if somebody were to, like, \
			push you into a meat grinder, and, like, your- one of your finger bones is still intact, they're not gonna pick it up and go, \
			Well see, yeah it wasn't deadly, it wasn't an instant kill move! You still got, like, this part of your finger left!"
		dirty = TRUE
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/gibber/RefreshParts()
	. = ..()
	gibtime = 40
	efficiency = initial(efficiency)
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		efficiency += matter_bin.tier * 0.25
	for(var/datum/stock_part/servo/servo in component_parts)
		gibtime -= 5 * servo.tier
		if(servo.tier >= 2)
			ignore_clothing = TRUE

/obj/machinery/gibber/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Outputting <b>[efficiency]%</b> of meat after <b>[gibtime*0.1]</b> seconds of processing.")
		for(var/datum/stock_part/servo/servo in component_parts)
			if(servo.tier >= 2)
				. += span_notice("[src] has been upgraded to process inorganic materials.")

/obj/machinery/gibber/update_overlays()
	. = ..()
	if(dirty)
		var/mutable_appearance/blood_overlay = mutable_appearance(icon, "grinder_bloody", appearance_flags = RESET_COLOR|KEEP_APART)
		if(blood_dna_info)
			blood_overlay.color = get_color_from_blood_list(blood_dna_info)
		else
			blood_overlay.color = BLOOD_COLOR_RED
		. += blood_overlay
	if(machine_stat & (NOPOWER|BROKEN) || panel_open)
		return
	if(!occupant)
		. += "grinder_empty"
		. += emissive_appearance(icon, "grinder_empty", src, alpha = src.alpha)
		return
	if(operating)
		. += "grinder_active"
		. += emissive_appearance(icon, "grinder_active", src, alpha = src.alpha)
		. += "grinder_jaws_active"
		return
	. += "grinder_loaded"
	. += emissive_appearance(icon, "grinder_loaded", src, alpha = src.alpha)

/obj/machinery/gibber/on_set_panel_open(old_value)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/gibber/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/machinery/gibber/container_resist_act(mob/living/user)
	go_out()

/obj/machinery/gibber/relaymove(mob/living/user, direction)
	go_out()

/obj/machinery/gibber/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(operating)
		to_chat(user, span_danger("It's locked and running."))
		return

	if(!anchored)
		to_chat(user, span_warning("[src] cannot be used unless bolted to the ground!"))
		return

	if(user.pulling && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(!iscarbon(L))
			to_chat(user, span_warning("This item is not suitable for [src]!"))
			return
		var/mob/living/carbon/C = L
		if(C.buckled || C.has_buckled_mobs())
			to_chat(user, span_warning("[C] is attached to something!"))
			return

		if(!ignore_clothing)
			for(var/obj/item/I in C.held_items + C.get_equipped_items())
				if(!HAS_TRAIT(I, TRAIT_NODROP))
					to_chat(user, span_warning("Subject may not have abiotic items on!"))
					return

		user.visible_message(span_danger("[user] starts to put [C] into [src]!"))

		add_fingerprint(user)

		if(do_after(user, gibtime, target = src))
			if(C && user.pulling == C && !C.buckled && !C.has_buckled_mobs() && !occupant)
				user.visible_message(span_danger("[user] stuffs [C] into [src]!"))
				C.forceMove(src)
				set_occupant(C)
				update_appearance()
	else
		start_gibbing(user)

/obj/machinery/gibber/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/gibber/attackby(obj/item/P, mob/user, list/modifiers, list/attack_modifiers)
	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", P))
		return

	else if(default_pry_open(P, close_after_pry = TRUE))
		return

	else if(default_deconstruction_crowbar(P))
		return
	else
		return ..()

/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "Empty gibber"
	set src in oview(1)
	if (usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if(!usr.can_perform_action(src))
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/gibber/proc/go_out()
	dump_inventory_contents()
	update_appearance()

/obj/machinery/gibber/proc/start_gibbing(mob/user)
	if(operating)
		return

	if(!occupant)
		audible_message(span_hear("You hear a loud metallic grinding sound."))
		return

	if(occupant.flags_1 & HOLOGRAM_1)
		audible_message(span_hear("You hear a very short metallic grinding sound."))
		playsound(loc, 'sound/machines/hiss.ogg', 20, TRUE)
		qdel(occupant)
		set_occupant(null)
		return

	use_energy(active_power_usage)
	audible_message(span_hear("You hear a loud squelchy grinding sound."))
	playsound(loc, 'sound/machines/juicer.ogg', 50, TRUE)
	operating = TRUE
	update_appearance()
	Shake(pixelshiftx = 1, pixelshifty = 0, duration = gibtime)

	var/mob/living/victim = occupant
	var/list/results = list()
	var/list/datum/disease/diseases = list()
	for(var/datum/disease/disease as anything in victim.get_static_viruses())
		// admin or special viruses that should not be reproduced
		if(!(disease.spread_flags & (DISEASE_SPREAD_SPECIAL | DISEASE_SPREAD_NON_CONTAGIOUS)))
			diseases += disease

	blood_dna_info = victim.get_blood_dna_list()

	if (!ishuman(victim))
		var/meat_type = /obj/item/food/meat/slab
		var/skin_type = null
		var/meat_produced = 2
		var/skin_produced = 1
		if (victim.butcher_results || victim.guaranteed_butcher_results)
			for (var/possible_drop in victim.butcher_results | victim.guaranteed_butcher_results)
				if (ispath(possible_drop, /obj/item/food/meat/slab))
					meat_type = possible_drop
					meat_produced = victim.butcher_results[possible_drop] + victim.guaranteed_butcher_results[possible_drop]
				else if (ispath(possible_drop, /obj/item/stack/sheet/animalhide))
					skin_type = possible_drop
					skin_produced = victim.butcher_results[possible_drop] + victim.guaranteed_butcher_results[possible_drop]

		else if (iscarbon(victim))
			var/mob/living/carbon/as_carbon = victim
			meat_type = as_carbon.type_of_meat
			if (isalien(victim))
				skin_type = /obj/item/stack/sheet/animalhide/xeno

		for (var/i in 1 to rand(floor(meat_produced * efficiency / initial(efficiency)), ceil(meat_produced * efficiency / initial(efficiency))))
			results += spawn_meat(victim, meat_type, diseases)

		if (skin_type && skin_produced)
			for (var/i in 1 to rand(floor(skin_produced * efficiency / initial(efficiency)), ceil(skin_produced * efficiency / initial(efficiency))))
				results += new skin_type(src)

		SEND_SIGNAL(victim, COMSIG_LIVING_GIBBER_ACT, user, src, results)
		process_results(victim, results)
		addtimer(CALLBACK(src, PROC_REF(finish_gibbing), results, victim.get_gibs_type(), diseases), gibtime)
		log_combat(user, victim, "gibbed")
		victim.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
		victim.death(TRUE)
		victim.ghostize()
		set_occupant(null)
		qdel(victim)
		return

	var/mob/living/carbon/human/agent_whiskey = victim
	var/drop_chance = 0
	for (var/obj/item/bodypart/limb as anything in agent_whiskey.bodyparts)
		if (!limb.butcher_drops)
			continue

		for (var/obj/item/drop_type as anything in limb.butcher_drops)
			var/amount = limb.butcher_drops[drop_type] || 1
			drop_chance += amount * efficiency
			if (drop_chance > 1)
				amount = floor(drop_chance)
				if (prob(drop_chance * 100))
					amount += 1
			else
				amount = 1
				if (!prob(drop_chance * 100))
					continue
			drop_chance = 0

			if (ispath(drop_type, /obj/item/food/meat))
				for (var/i in 1 to amount)
					results += spawn_meat(victim, drop_type, diseases)
				continue

			if (ispath(drop_type, /obj/item/stack))
				if (ispath(drop_type, /obj/item/stack/sheet/animalhide/carbon))
					results += new drop_type(src, amount, /*merge = */TRUE, /*mat_override = */null, /*mat_amount = */1, limb.skin_tone || limb.species_color)
				else
					results += new drop_type(src, amount)
				continue

			for (var/i in 1 to amount)
				results += new drop_type(src)

	SEND_SIGNAL(victim, COMSIG_LIVING_GIBBER_ACT, user, src, results)
	process_results(victim, results)
	addtimer(CALLBACK(src, PROC_REF(finish_gibbing), results, victim.get_gibs_type(), diseases), gibtime)
	log_combat(user, victim, "gibbed")
	victim.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
	victim.death(TRUE)
	victim.ghostize()
	set_occupant(null)
	qdel(victim)

/obj/machinery/gibber/proc/spawn_meat(mob/living/victim, meat_type = /obj/item/food/meat/slab, list/datum/disease/diseases)
	var/obj/item/food/meat/meat = new meat_type(src, blood_dna_info)
	meat.name = "[victim.real_name]'s [meat.name]"
	meat.set_custom_materials(list(GET_MATERIAL_REF(/datum/material/meat/mob_meat, victim) = 4 * SHEET_MATERIAL_AMOUNT))
	if (!istype(meat))
		return
	meat.subjectname = victim.real_name
	meat.subjectjob = victim.job
	if (length(diseases))
		meat.AddComponent(/datum/component/infective, diseases)
	return meat

/obj/machinery/gibber/proc/process_results(mob/living/victim, list/obj/item/results)
	var/reagents_in_produced = 0
	for(var/obj/item/result as anything in results)
		if(result.reagents)
			reagents_in_produced += 1

	for(var/obj/item/result as anything in results)
		if (victim.reagents)
			victim.reagents.trans_to(result, victim.reagents.total_volume / reagents_in_produced, remove_blacklisted = TRUE)
		result.reagents?.add_reagent(/datum/reagent/consumable/nutriment/fat, victim.nutrition / 15 / reagents_in_produced)

/obj/machinery/gibber/proc/finish_gibbing(list/obj/item/results, gibs_type, list/datum/disease/diseases)
	playsound(src.loc, 'sound/effects/splat.ogg', 50, TRUE)
	operating = FALSE
	if (!dirty && prob(50))
		dirty = TRUE

	if(blood_dna_info)
		add_blood_DNA(blood_dna_info)

	var/turf/our_turf = get_turf(src)
	var/list/turf/nearby_turfs = RANGE_TURFS(3, our_turf) - our_turf
	for (var/obj/item/result as anything in results)
		result.forceMove(our_turf)
		result.throw_at(pick(nearby_turfs), rand(1, length(results)), 1)

	if (!gibs_type)
		pixel_x = base_pixel_x
		update_appearance()
		return

	var/obj/effect/gibspawner/spawner = new gibs_type()
	var/list/gibs = spawner.gibtypes
	if (!length(gibs))
		pixel_x = base_pixel_x
		update_appearance()
		return

	for (var/i in 1 to length(results))
		var/gib_dir = pick(GLOB.alldirs)
		var/turf/gib_turf = get_step(src, gib_dir)
		if (gib_turf.is_blocked_turf(TRUE))
			continue
		var/gib_type = pick(gibs)
		var/obj/effect/decal/cleanable/blood/gibs/gib = new gib_type(gib_turf, diseases, blood_dna_info)
		gib.streak(gib_dir)

	pixel_x = base_pixel_x
	update_appearance()

//auto-gibs anything that bumps into it
/obj/machinery/gibber/autogibber
	var/input_dir = NORTH

/obj/machinery/gibber/autogibber/Bumped(atom/movable/AM)
	var/atom/input = get_step(src, input_dir)
	if(isliving(AM))
		var/mob/living/victim = AM

		if(victim.loc == input)
			victim.forceMove(src)
			victim.gib(DROP_ALL_REMAINS)

/obj/machinery/gibber/proc/on_cleaned(obj/source_component, obj/source)
	SIGNAL_HANDLER

	. = NONE

	dirty = FALSE
	update_appearance(UPDATE_OVERLAYS)
	. |= COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP
