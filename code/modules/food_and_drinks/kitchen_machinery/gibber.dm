
/obj/machinery/gibber
	name = "gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500
	circuit = /obj/item/circuitboard/machine/gibber

	var/operating = FALSE //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/meat_produced = 0
	var/ignore_clothing = 0


/obj/machinery/gibber/Initialize()
	. = ..()
	add_overlay("grjam")

/obj/machinery/gibber/RefreshParts()
	var/gib_time = 40
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		meat_produced += B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		gib_time -= 5 * M.rating
		gibtime = gib_time
		if(M.rating >= 2)
			ignore_clothing = 1

/obj/machinery/gibber/update_icon()
	cut_overlays()
	if (dirty)
		add_overlay("grbloody")
	if(stat & (NOPOWER|BROKEN))
		return
	if (!occupant)
		add_overlay("grjam")
	else if (operating)
		add_overlay("gruse")
	else
		add_overlay("gridle")

/obj/machinery/gibber/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/gibber/container_resist(mob/living/user)
	go_out()

/obj/machinery/gibber/relaymove(mob/living/user)
	go_out()

/obj/machinery/gibber/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		to_chat(user, "<span class='danger'>It's locked and running.</span>")
		return

	if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(!iscarbon(L))
			to_chat(user, "<span class='danger'>This item is not suitable for the gibber!</span>")
			return
		var/mob/living/carbon/C = L
		if(C.buckled ||C.has_buckled_mobs())
			to_chat(user, "<span class='warning'>[C] is attached to something!</span>")
			return
		if(C.abiotic(1) && !ignore_clothing)
			to_chat(user, "<span class='danger'>Subject may not have abiotic items on.</span>")
			return

		user.visible_message("<span class='danger'>[user] starts to put [C] into the gibber!</span>")
		src.add_fingerprint(user)
		if(do_after(user, gibtime, target = src))
			if(C && user.pulling == C && !C.buckled && !C.has_buckled_mobs() && !occupant)
				user.visible_message("<span class='danger'>[user] stuffs [C] into the gibber!</span>")
				C.forceMove(src)
				occupant = C
				update_icon()
	else
		startgibbing(user)

/obj/machinery/gibber/attackby(obj/item/P, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", P))
		return

	else if(exchange_parts(user, P))
		return

	else if(default_pry_open(P))
		return

	else if(default_unfasten_wrench(user, P))
		return

	else if(default_deconstruction_crowbar(P))
		return
	else
		return ..()



/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "empty gibber"
	set src in oview(1)

	if(usr.incapacitated())
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/gibber/proc/go_out()
	dropContents()
	update_icon()

/obj/machinery/gibber/proc/startgibbing(mob/user)
	if(src.operating)
		return
	if(!src.occupant)
		visible_message("<span class='italics'>You hear a loud metallic grinding sound.</span>")
		return
	use_power(1000)
	visible_message("<span class='italics'>You hear a loud squelchy grinding sound.</span>")
	playsound(src.loc, 'sound/machines/juicer.ogg', 50, 1)
	operating = TRUE
	update_icon()

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
	var/typeofmeat = /obj/item/reagent_containers/food/snacks/meat/slab/human
	var/typeofskin

	var/obj/item/reagent_containers/food/snacks/meat/slab/allmeat[meat_produced]
	var/obj/item/stack/sheet/animalhide/skin

	if(ishuman(occupant))
		var/mob/living/carbon/human/gibee = occupant
		if(gibee.dna && gibee.dna.species)
			typeofmeat = gibee.dna.species.meat
			typeofskin = gibee.dna.species.skinned_type

	else if(iscarbon(occupant))
		var/mob/living/carbon/C = occupant
		typeofmeat = C.type_of_meat
		gibtype = C.gib_type
		if(ismonkey(C))
			typeofskin = /obj/item/stack/sheet/animalhide/monkey
		else if(isalien(C))
			typeofskin = /obj/item/stack/sheet/animalhide/xeno

	for (var/i=1 to meat_produced)
		var/obj/item/reagent_containers/food/snacks/meat/slab/newmeat = new typeofmeat
		newmeat.name = "[sourcename] [newmeat.name]"
		if(istype(newmeat))
			newmeat.subjectname = sourcename
			newmeat.reagents.add_reagent ("nutriment", sourcenutriment / meat_produced) // Thehehe. Fat guys go first
			if(sourcejob)
				newmeat.subjectjob = sourcejob
		allmeat[i] = newmeat

	if(typeofskin)
		skin = new typeofskin

	add_logs(user, occupant, "gibbed")
	mob_occupant.death(1)
	mob_occupant.ghostize()
	qdel(src.occupant)
	spawn(src.gibtime)
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
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
				if (!gibturf.density && src in view(gibturf))
					new gibtype(gibturf,i)

		pixel_x = initial(pixel_x) //return to its spot after shaking
		operating = FALSE
		update_icon()

//auto-gibs anything that bumps into it
/obj/machinery/gibber/autogibber
	var/turf/input_plate

/obj/machinery/gibber/autogibber/Initialize()
	. = ..()
	for(var/i in GLOB.cardinals)
		var/obj/machinery/mineral/input/input_obj = locate() in get_step(loc, i)
		if(input_obj)
			if(isturf(input_obj.loc))
				input_plate = input_obj.loc
				qdel(input_obj)
				break

	if(!input_plate)
		CRASH("Didn't find an input plate.")
		return

/obj/machinery/gibber/autogibber/CollidedWith(atom/movable/AM)
	if(!input_plate)
		return

	if(ismob(AM))
		var/mob/M = AM

		if(M.loc == input_plate)
			M.forceMove(src)
			M.gib()
