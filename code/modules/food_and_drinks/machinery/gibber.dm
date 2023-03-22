/obj/machinery/gibber
	name = "gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/gibber

	var/operating = FALSE //Is it on?
	var/dirty = FALSE // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/meat_produced = 2
	var/ignore_clothing = FALSE


/obj/machinery/gibber/Initialize(mapload)
	. = ..()
	if(prob(5))
		name = "meat grinder"
		desc = "Okay, if I... if I chop you up in a meat grinder, and the only thing that comes out, that's left of you, is your eyeball, \
			you'r- you're PROBABLY DEAD! You're probably going to - not you, I'm just sayin', like, if you- if somebody were to, like, \
			push you into a meat grinder, and, like, your- one of your finger bones is still intact, they're not gonna pick it up and go, \
			Well see, yeah it wasn't deadly, it wasn't an instant kill move! You still got, like, this part of your finger left!"
	add_overlay("grjam")

/obj/machinery/gibber/RefreshParts()
	. = ..()
	gibtime = 40
	meat_produced = initial(meat_produced)
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		meat_produced += matter_bin.tier
	for(var/datum/stock_part/manipulator/manipulator in component_parts)
		gibtime -= 5 * manipulator.tier
		if(manipulator.tier >= 2)
			ignore_clothing = TRUE

/obj/machinery/gibber/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Outputting <b>[meat_produced]</b> meat slab(s) after <b>[gibtime*0.1]</b> seconds of processing.")
		for(var/datum/stock_part/manipulator/manipulator in component_parts)
			if(manipulator.tier >= 2)
				. += span_notice("[src] has been upgraded to process inorganic materials.")

/obj/machinery/gibber/update_overlays()
	. = ..()
	if(dirty)
		. +="grbloody"
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(!occupant)
		. += "grjam"
		return
	if(operating)
		. += "gruse"
		return
	. += "gridle"

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
		startgibbing(user)

/obj/machinery/gibber/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/gibber/attackby(obj/item/P, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", P))
		return

	else if(default_pry_open(P))
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

/obj/machinery/gibber/proc/startgibbing(mob/user)
	if(operating)
		return
	if(!occupant)
		audible_message(span_hear("You hear a loud metallic grinding sound."))
		return

	use_power(active_power_usage)
	audible_message(span_hear("You hear a loud squelchy grinding sound."))
	playsound(loc, 'sound/machines/juicer.ogg', 50, TRUE)
	operating = TRUE
	update_appearance()

	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
	var/mob/living/mob_occupant = occupant
	var/sourcename = mob_occupant.real_name
	var/sourcejob
	if(ishuman(occupant))
		var/mob/living/carbon/human/gibee = occupant
		sourcejob = gibee.job
	var/sourcenutriment = mob_occupant.nutrition / 15
	var/gibtype = /obj/effect/decal/cleanable/blood/gibs
	var/typeofmeat = /obj/item/food/meat/slab/human
	var/typeofskin

	var/obj/item/food/meat/slab/allmeat[meat_produced]
	var/obj/item/stack/sheet/animalhide/skin
	var/list/datum/disease/diseases = mob_occupant.get_static_viruses()

	if(ishuman(occupant))
		var/mob/living/carbon/human/gibee = occupant
		if(gibee.dna && gibee.dna.species)
			typeofmeat = gibee.dna.species.meat
			typeofskin = gibee.dna.species.skinned_type

	else if(iscarbon(occupant))
		var/mob/living/carbon/C = occupant
		typeofmeat = C.type_of_meat
		gibtype = C.gib_type
		if(isalien(C))
			typeofskin = /obj/item/stack/sheet/animalhide/xeno

	var/occupant_volume
	if(occupant?.reagents)
		occupant_volume = occupant.reagents.total_volume
	for (var/i=1 to meat_produced)
		var/obj/item/food/meat/slab/newmeat = new typeofmeat
		newmeat.name = "[sourcename] [newmeat.name]"
		newmeat.set_custom_materials(list(GET_MATERIAL_REF(/datum/material/meat/mob_meat, occupant) = 4 * MINERAL_MATERIAL_AMOUNT))
		if(istype(newmeat))
			newmeat.subjectname = sourcename
			newmeat.reagents.add_reagent (/datum/reagent/consumable/nutriment, sourcenutriment / meat_produced) // Thehehe. Fat guys go first
			if(occupant_volume)
				occupant.reagents.trans_to(newmeat, occupant_volume / meat_produced, remove_blacklisted = TRUE)
			if(sourcejob)
				newmeat.subjectjob = sourcejob
		allmeat[i] = newmeat

	if(typeofskin)
		skin = new typeofskin

	log_combat(user, occupant, "gibbed")
	mob_occupant.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
	mob_occupant.death(TRUE)
	mob_occupant.ghostize()
	set_occupant(null)
	qdel(mob_occupant)
	addtimer(CALLBACK(src, PROC_REF(make_meat), skin, allmeat, meat_produced, gibtype, diseases), gibtime)

/obj/machinery/gibber/proc/make_meat(obj/item/stack/sheet/animalhide/skin, list/obj/item/food/meat/slab/allmeat, meat_produced, gibtype, list/datum/disease/diseases)
	playsound(src.loc, 'sound/effects/splat.ogg', 50, TRUE)
	operating = FALSE
	var/turf/T = get_turf(src)
	var/list/turf/nearby_turfs = RANGE_TURFS(3,T) - T
	if(skin)
		skin.forceMove(loc)
		skin.throw_at(pick(nearby_turfs),meat_produced,3)
	for (var/i=1 to meat_produced)
		var/obj/item/meatslab = allmeat[i]
		meatslab.forceMove(loc)
		meatslab.throw_at(pick(nearby_turfs),i,3)
		for (var/turfs=1 to meat_produced)
			var/turf/gibturf = pick(nearby_turfs)
			if (!gibturf.density && (src in view(gibturf)))
				new gibtype(gibturf,i,diseases)

	pixel_x = base_pixel_x //return to its spot after shaking
	operating = FALSE
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
			victim.gib()
