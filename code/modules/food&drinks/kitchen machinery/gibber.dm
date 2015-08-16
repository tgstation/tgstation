
/obj/machinery/gibber
	name = "gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = 1
	anchored = 1
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/typeofmeat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human
	var/meat_produced = 0
	var/ignore_clothing = 0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 500

//auto-gibs anything that bumps into it
/obj/machinery/gibber/autogibber
	var/turf/input_plate

/obj/machinery/gibber/autogibber/New()
	..()
	spawn(5)
		for(var/i in cardinal)
			var/obj/machinery/mineral/input/input_obj = locate( /obj/machinery/mineral/input, get_step(src.loc, i) )
			if(input_obj)
				if(isturf(input_obj.loc))
					input_plate = input_obj.loc
					qdel(input_obj)
					break

		if(!input_plate)
			diary << "a [src] didn't find an input plate."
			return

/obj/machinery/gibber/autogibber/Bumped(atom/A)
	if(!input_plate) return

	if(ismob(A))
		var/mob/M = A

		if(M.loc == input_plate)
			M.loc = src
			M.gib()


/obj/machinery/gibber/New()
	..()
	src.overlays += image('icons/obj/kitchen.dmi', "grjam")
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/gibber(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/gibber/RefreshParts()
	var/gib_time = 40
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		meat_produced += 3 * B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		gib_time -= 5 * M.rating
		gibtime = gib_time
		if(M.rating >= 2)
			ignore_clothing = 1

/obj/machinery/gibber/update_icon()
	overlays.Cut()
	if (dirty)
		src.overlays += image('icons/obj/kitchen.dmi', "grbloody")
	if(stat & (NOPOWER|BROKEN))
		return
	if (!occupant)
		src.overlays += image('icons/obj/kitchen.dmi', "grjam")
	else if (operating)
		src.overlays += image('icons/obj/kitchen.dmi', "gruse")
	else
		src.overlays += image('icons/obj/kitchen.dmi', "gridle")

/obj/machinery/gibber/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/gibber/container_resist()
	src.go_out()
	return

/obj/machinery/gibber/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		user << "<span class='danger'>It's locked and running.</span>"
		return
	else
		src.startgibbing(user)

/obj/machinery/gibber/attackby(obj/item/P, mob/user, params)
	if (istype(P, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = P
		if(!istype(G.affecting, /mob/living/carbon/))
			user << "<span class='danger'>This item is not suitable for the gibber!</span>"
			return
		if(G.affecting.abiotic(1) && !ignore_clothing)
			user << "<span class='danger'>Subject may not have abiotic items on.</span>"
			return

		user.visible_message("<span class='danger'>[user] starts to put [G.affecting] into the gibber!</span>")
		src.add_fingerprint(user)
		if(do_after(user, gibtime, target = src) && G && G.affecting && !occupant)
			user.visible_message("<span class='danger'>[user] stuffs [G.affecting] into the gibber!</span>")
			var/mob/M = G.affecting
			if(M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.loc = src
			src.occupant = M
			qdel(G)
			update_icon()

	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", P))
		return

	if(exchange_parts(user, P))
		return

	if(default_pry_open(P))
		return

	if(default_unfasten_wrench(user, P))
		return

	default_deconstruction_crowbar(P)



/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "empty gibber"
	set src in oview(1)

	if(usr.stat || !usr.canmove || usr.restrained())
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
	src.operating = 1
	update_icon()
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
	var/sourcename = src.occupant.real_name
	var/sourcejob
	if(ishuman(occupant))
		var/mob/living/carbon/human/gibee = occupant
		sourcejob = gibee.job
	var/sourcenutriment = src.occupant.nutrition / 15
	var/sourcetotalreagents = src.occupant.reagents.total_volume
	var/gibtype = /obj/effect/decal/cleanable/blood/gibs

	var/obj/item/weapon/reagent_containers/food/snacks/meat/slab/allmeat[meat_produced]

	if(ishuman(occupant))
		var/mob/living/carbon/human/gibee = occupant
		if(gibee.dna && gibee.dna.species)
			typeofmeat = gibee.dna.species.meat
		else
			typeofmeat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human
	else
		if(iscarbon(occupant))
			var/mob/living/carbon/C = occupant
			typeofmeat = C.type_of_meat
			gibtype = C.gib_type
	for (var/i=1 to meat_produced)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/slab/newmeat = new typeofmeat
		newmeat.name = sourcename + newmeat.name
		newmeat.subjectname = sourcename
		if(sourcejob)
			newmeat.subjectjob = sourcejob
		newmeat.reagents.add_reagent ("nutriment", sourcenutriment / meat_produced) // Thehehe. Fat guys go first
		src.occupant.reagents.trans_to (newmeat, round (sourcetotalreagents / meat_produced, 1)) // Transfer all the reagents from the
		allmeat[i] = newmeat

	add_logs(user, occupant, "gibbed")
	src.occupant.death(1)
	src.occupant.ghostize()
	qdel(src.occupant)
	spawn(src.gibtime)
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
		operating = 0
		for (var/i=1 to meat_produced)
			var/list/nearby_turfs = orange(3, get_turf(src))
			var/obj/item/meatslab = allmeat[i]
			meatslab.loc = src.loc
			meatslab.throw_at(pick(nearby_turfs),i,3)
			for (var/turfs=1 to meat_produced*3)
				var/turf/gibturf = pick(nearby_turfs)
				if (!gibturf.density && src in viewers(gibturf))
					new gibtype(gibturf,i)

		pixel_x = initial(pixel_x) //return to its spot after shaking
		src.operating = 0
		update_icon()


