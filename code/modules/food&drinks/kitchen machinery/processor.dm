
/obj/machinery/processor
	name = "food processor"
	desc = "An industrial grinder used to process meat and other foods. Keep hands clear of intake area while operating."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	layer = 2.9
	density = 1
	anchored = 1
	var/broken = 0
	var/processing = 0
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50



/datum/food_processor_process
	var/input
	var/output
	var/time = 40
/datum/food_processor_process/proc/process_food(loc, what)
	if (src.output && loc)
		new src.output(loc)
	if (what)
		qdel(what) // Note to self: Make this safer

	/* objs */
/datum/food_processor_process/meat
	input = /obj/item/weapon/reagent_containers/food/snacks/meat/slab
	output = /obj/item/weapon/reagent_containers/food/snacks/faggot

/datum/food_processor_process/potato
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/potato
	output = /obj/item/weapon/reagent_containers/food/snacks/fries

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

/datum/food_processor_process/sweetpotato
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/sweetpotato
	output = /obj/item/weapon/reagent_containers/food/snacks/yakiimo


/* mobs */
/datum/food_processor_process/mob/process_food(loc, what)
	..()


/datum/food_processor_process/mob/slime/process_food(loc, what)
	var/mob/living/simple_animal/slime/S = what
	var/C = S.cores
	if(S.stat != DEAD)
		S.loc = loc
		S.visible_message("<span class='notice'>[C] crawls free of the processor!</span>")
		return
	for(var/i = 1, i <= C, i++)
		new S.coretype(loc)
		feedback_add_details("slime_core_harvested","[replacetext(S.colour," ","_")]")
	..()

/datum/food_processor_process/mob/slime/input = /mob/living/simple_animal/slime
/datum/food_processor_process/mob/slime/output = null

/datum/food_processor_process/mob/monkey/process_food(loc, what)
	var/mob/living/carbon/monkey/O = what
	if (O.client) //grief-proof
		O.loc = loc
		O.visible_message("<span class='notice'>Suddenly [O] jumps out from the processor!</span>", \
				"<span class='notice'>You jump out from the processor!</span>", \
				"<span class='italics'>You hear chimpering.</span>")
		return
	var/obj/item/weapon/reagent_containers/glass/bucket/bucket_of_blood = new(loc)
	var/datum/reagent/blood/B = new()
	B.holder = bucket_of_blood
	B.volume = 70
	//set reagent data
	B.data["donor"] = O

	for(var/datum/disease/D in O.viruses)
		if(!(D.spread_flags & SPECIAL))
			B.data["viruses"] += D.Copy()
	if(check_dna_integrity(O))
		B.data["blood_DNA"] = copytext(O.dna.unique_enzymes,1,0)

	if(O.resistances&&O.resistances.len)
		B.data["resistances"] = O.resistances.Copy()
	bucket_of_blood.reagents.reagent_list += B
	bucket_of_blood.reagents.update_total()
	bucket_of_blood.on_reagent_change()
	//bucket_of_blood.reagents.handle_reactions() //blood doesn't react
	..()

/datum/food_processor_process/mob/monkey/input = /mob/living/carbon/monkey
/datum/food_processor_process/mob/monkey/output = null

/obj/machinery/processor/proc/select_recipe(var/X)
	for (var/Type in typesof(/datum/food_processor_process) - /datum/food_processor_process - /datum/food_processor_process/mob)
		var/datum/food_processor_process/P = new Type()
		if (!istype(X, P.input))
			continue
		return P
	return 0

/obj/machinery/processor/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(src.processing)
		user << "<span class='warning'>The processor is in the process of processing!</span>"
		return 1
	if(default_unfasten_wrench(user, O))
		return
	var/what = O
	if (istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		if(!user.Adjacent(G.affecting))
			return
		what = G.affecting

	var/datum/food_processor_process/P = select_recipe(what)
	if (!P)
		user << "<span class='warning'>That probably won't blend!</span>"
		return 1
	user.visible_message("[user] put [what] into [src].", \
		"You put the [what] into [src].")
	user.drop_item()
	what:loc = src
	return

/obj/machinery/processor/attack_hand(var/mob/user as mob)
	if (src.stat != 0) //NOPOWER etc
		return
	if(src.processing)
		user << "<span class='warning'>The processor is in the process of processing!</span>"
		return 1
	if(src.contents.len == 0)
		user << "<span class='warning'>The processor is empty!</span>"
		return 1
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor havent suitable recipe. How do you put it in?") //-rastaf0
			continue
		src.processing = 1
		user.visible_message("[user] turns on \a [src].", \
			"<span class='notice'>You turn on \a [src].</span>", \
			"<span class='italics'>You hear a food processor.</span>")
		playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
		animate(src, pixel_x = pixel_x + 2, time = 0.2, loop = P.time*5) //start shaking
		use_power(500)
		sleep(P.time)
		animate(src, pixel_x = initial(pixel_x), time = 1) //return to its spot after shaking
		P.process_food(src.loc, O)
		src.processing = 0
	src.visible_message("\the [src] finishes processing.")

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

