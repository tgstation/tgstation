
/obj/machinery/processor
	name = "food processor"
	desc = "An industrial grinder used to process meat and other foods. Keep hands clear of intake area while operating."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor1"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	anchored = TRUE
	var/broken = 0
	var/processing = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 50
	var/rating_speed = 1
	var/rating_amount = 1

/obj/machinery/processor/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/processor(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/processor
	name = "Food Processor (Machine Board)"
	build_path = /obj/machinery/processor
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/processor
	name = "Food Processor (Machine Board)"
	build_path = /obj/machinery/processor

/obj/item/weapon/circuitboard/machine/processor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(build_path == /obj/machinery/processor)
			name = "Slime Processor (Machine Board)"
			build_path = /obj/machinery/processor/slime
			to_chat(user, "<span class='notice'>Name protocols successfully updated.</span>")
		else
			name = "Food Processor (Machine Board)"
			build_path = /obj/machinery/processor
			to_chat(user, "<span class='notice'>Defaulting name protocols.</span>")
	else
		return ..()

/obj/machinery/processor/RefreshParts()
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		rating_amount = B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		rating_speed = M.rating

/obj/machinery/processor/process()
	..()
	// The irony
	// To be clear, if it's grinding, then it can't suck them up
	if(processing)
		return
	var/mob/living/simple_animal/slime/picked_slime
	for(var/mob/living/simple_animal/slime/slime in range(1,src))
		if(slime.loc == src)
			continue
		if(istype(slime, /mob/living/simple_animal/slime))
			if(slime.stat)
				picked_slime = slime
				break
	if(!picked_slime)
		return
	var/datum/food_processor_process/P = select_recipe(picked_slime)
	if (!P)
		return

	src.visible_message("[picked_slime] is sucked into [src].")
	picked_slime.loc = src

/datum/food_processor_process
	var/input
	var/output
	var/time = 40
/datum/food_processor_process/proc/process_food(loc, what, obj/machinery/processor/processor)
	if (src.output && loc && processor)
		for(var/i = 0, i < processor.rating_amount, i++)
			new src.output(loc)
	if (what)
		qdel(what) // Note to self: Make this safer

	/* objs */
/datum/food_processor_process/meat
	input = /obj/item/weapon/reagent_containers/food/snacks/meat/slab
	output = /obj/item/weapon/reagent_containers/food/snacks/faggot

/datum/food_processor_process/bacon
	input = /obj/item/weapon/reagent_containers/food/snacks/meat/rawcutlet
	output = /obj/item/weapon/reagent_containers/food/snacks/meat/rawbacon

/datum/food_processor_process/potatowedges
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/potato/wedges
	output = /obj/item/weapon/reagent_containers/food/snacks/fries

/datum/food_processor_process/sweetpotato
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/potato/sweet
	output = /obj/item/weapon/reagent_containers/food/snacks/yakiimo

/datum/food_processor_process/potato
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/potato
	output = /obj/item/weapon/reagent_containers/food/snacks/tatortot

/datum/food_processor_process/carrot
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	output = /obj/item/weapon/reagent_containers/food/snacks/carrotfries

/datum/food_processor_process/soybeans
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	output = /obj/item/weapon/reagent_containers/food/snacks/soydope

/datum/food_processor_process/spaghetti
	input = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	output = /obj/item/weapon/reagent_containers/food/snacks/spaghetti

/datum/food_processor_process/corn
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/corn
	output = /obj/item/weapon/reagent_containers/food/snacks/tortilla

/datum/food_processor_process/parsnip
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/parsnip
	output = /obj/item/weapon/reagent_containers/food/snacks/roastparsnip

/* mobs */
/datum/food_processor_process/mob/process_food(loc, what, processor)
	..()


/datum/food_processor_process/mob/slime/process_food(loc, what, obj/machinery/processor/processor)
	var/mob/living/simple_animal/slime/S = what
	var/C = S.cores
	if(S.stat != DEAD)
		S.loc = loc
		S.visible_message("<span class='notice'>[C] crawls free of the processor!</span>")
		return
	for(var/i in 1 to (C+processor.rating_amount-1))
		new S.coretype(loc)
		SSblackbox.add_details("slime_core_harvested","[replacetext(S.colour," ","_")]")
	..()

/datum/food_processor_process/mob/slime/input = /mob/living/simple_animal/slime
/datum/food_processor_process/mob/slime/output = null

/datum/food_processor_process/mob/monkey/process_food(loc, what, processor)
	var/mob/living/carbon/monkey/O = what
	if (O.client) //grief-proof
		O.loc = loc
		O.visible_message("<span class='notice'>Suddenly [O] jumps out from the processor!</span>", \
				"<span class='notice'>You jump out from the processor!</span>", \
				"<span class='italics'>You hear chimpering.</span>")
		return
	var/obj/bucket = new /obj/item/weapon/reagent_containers/glass/bucket(loc)

	var/datum/reagent/blood/B = new()
	B.holder = bucket
	B.volume = 70
	//set reagent data
	B.data["donor"] = O

	for(var/thing in O.viruses)
		var/datum/disease/D = thing
		if(!(D.spread_flags & SPECIAL))
			B.data["viruses"] += D.Copy()
	if(O.has_dna())
		B.data["blood_DNA"] = O.dna.unique_enzymes

	if(O.resistances&&O.resistances.len)
		B.data["resistances"] = O.resistances.Copy()
	bucket.reagents.reagent_list += B
	bucket.reagents.update_total()
	bucket.on_reagent_change()
	//bucket_of_blood.reagents.handle_reactions() //blood doesn't react
	..()

/datum/food_processor_process/mob/monkey/input = /mob/living/carbon/monkey
/datum/food_processor_process/mob/monkey/output = null

/obj/machinery/processor/proc/select_recipe(X)
	for (var/Type in subtypesof(/datum/food_processor_process) - /datum/food_processor_process/mob)
		var/datum/food_processor_process/P = new Type()
		if (!istype(X, P.input))
			continue
		return P
	return 0

/obj/machinery/processor/attackby(obj/item/O, mob/user, params)
	if(src.processing)
		to_chat(user, "<span class='warning'>The processor is in the process of processing!</span>")
		return 1
	if(default_deconstruction_screwdriver(user, "processor", "processor1", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		return

	if(default_deconstruction_crowbar(O))
		return

	if(istype(O, /obj/item/weapon/storage/bag/tray))
		var/obj/item/weapon/storage/T = O
		var/loaded = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/S in T.contents)
			var/datum/food_processor_process/P = select_recipe(S)
			if(P)
				T.remove_from_storage(S, src)
				loaded++

		if(loaded)
			to_chat(user, "<span class='notice'>You insert [loaded] items into [src].</span>")
		return

	var/datum/food_processor_process/P = select_recipe(O)
	if(P)
		user.visible_message("[user] put [O] into [src].", \
			"You put [O] into [src].")
		user.drop_item()
		O.loc = src
		return 1
	else
		if(user.a_intent != INTENT_HARM)
			to_chat(user, "<span class='warning'>That probably won't blend!</span>")
			return 1
		else
			return ..()

/obj/machinery/processor/attack_hand(mob/user)
	if (src.stat != 0) //NOPOWER etc
		return
	if(src.processing)
		to_chat(user, "<span class='warning'>The processor is in the process of processing!</span>")
		return 1
	if(user.a_intent == INTENT_GRAB && user.pulling && (isslime(user.pulling) || ismonkey(user.pulling)))
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return
		var/mob/living/pushed_mob = user.pulling
		visible_message("<span class='warner'>[user] stuffs [pushed_mob] into [src]!</span>")
		pushed_mob.forceMove(src)
		user.stop_pulling()
		return
	if(src.contents.len == 0)
		to_chat(user, "<span class='warning'>The processor is empty!</span>")
		return 1
	processing = TRUE
	user.visible_message("[user] turns on [src].", \
		"<span class='notice'>You turn on [src].</span>", \
		"<span class='italics'>You hear a food processor.</span>")
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	use_power(500)
	var/total_time = 0
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor hasnt got a suitable recipe. How did it get in there? Please report it immediatly!!!")
			continue
		total_time += P.time
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = (total_time / rating_speed)*5) //start shaking
	sleep(total_time / rating_speed)
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor havent suitable recipe. How do you put it in?") //-rastaf0
			continue
		P.process_food(src.loc, O, src)
	pixel_x = initial(pixel_x) //return to its spot after shaking
	processing = FALSE
	src.visible_message("\The [src] finishes processing.")

/obj/machinery/processor/verb/eject()
	set category = "Object"
	set name = "Eject Contents"
	set src in oview(1)

	if(usr.stat || !usr.canmove || usr.restrained())
		return
	src.empty()
	add_fingerprint(usr)
	return

/obj/machinery/processor/proc/empty()
	for (var/obj/O in src)
		O.loc = src.loc
	for (var/mob/M in src)
		M.loc = src.loc
	return

/obj/machinery/processor/slime
	name = "Slime processor"
	desc = "An industrial grinder with a sticker saying appropriated for science department. Keep hands clear of intake area while operating."

/obj/machinery/processor/slime/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/processor/slime(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/processor/slime
	name = "Slime Processor (Machine Board)"
	build_path = /obj/machinery/processor/slime
