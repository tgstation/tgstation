
/obj/machinery/processor
	name = "Food Processor"
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
	proc/process(loc, what)
		if (src.output && loc)
			new src.output(loc)
		if (what)
			del(what)

	/* objs */
	wheat
		input = /obj/item/weapon/reagent_containers/food/snacks/grown/wheat
		output = /obj/item/weapon/reagent_containers/food/snacks/flour

	meat
		input = /obj/item/weapon/reagent_containers/food/snacks/meat
		output = /obj/item/weapon/reagent_containers/food/snacks/faggot

	meat2
		input = /obj/item/weapon/syntiflesh
		output = /obj/item/weapon/reagent_containers/food/snacks/faggot
/*
	monkeymeat
		input = /obj/item/weapon/reagent_containers/food/snacks/meat/monkey
		output = /obj/item/weapon/reagent_containers/food/snacks/faggot

	humanmeat
		input = /obj/item/weapon/reagent_containers/food/snacks/meat/human
		output = /obj/item/weapon/reagent_containers/food/snacks/faggot
*/
	potato
		input = /obj/item/weapon/reagent_containers/food/snacks/grown/potato
		output = /obj/item/weapon/reagent_containers/food/snacks/fries

	carrot
		input = /obj/item/weapon/reagent_containers/food/snacks/grown/carrot
		output = /obj/item/weapon/reagent_containers/food/snacks/carrotfries

	soybeans
		input = /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
		output = /obj/item/weapon/reagent_containers/food/snacks/soydope

	flour
		input = /obj/item/weapon/reagent_containers/food/snacks/flour
		output = /obj/item/weapon/reagent_containers/food/snacks/spagetti

	/* mobs */
	mob
		process(loc, what)
			..()


		metroid
			input = /mob/living/carbon/metroid
			output = /obj/item/weapon/reagent_containers/food/drinks/jar

		monkey
			process(loc, what)
				var/mob/living/carbon/monkey/O = what
				if (O.client) //grief-proof
					O.loc = loc
					O.visible_message("\blue Suddenly [O] jumps out from the processor!", \
							"You jump out from the processor", \
							"You hear chimp")
					return
				var/obj/item/weapon/reagent_containers/glass/bucket/bucket_of_blood = new(loc)
				var/datum/reagent/blood/B = new()
				B.holder = bucket_of_blood
				B.volume = 70
				//set reagent data
				B.data["donor"] = O

				for(var/datum/disease/D in O.viruses)
					if(D.spread_type != SPECIAL)
						B.data["viruses"] = new D.type(0)

				B.data["blood_DNA"] = copytext(O.dna.unique_enzymes,1,0)
				if(O.resistances&&O.resistances.len)
					B.data["resistances"] = O.resistances.Copy()
				bucket_of_blood.reagents.reagent_list += B
				bucket_of_blood.reagents.update_total()
				bucket_of_blood.on_reagent_change()
				//bucket_of_blood.reagents.handle_reactions() //blood doesn't react
				..()

			input = /mob/living/carbon/monkey
			output = null

/obj/machinery/processor/proc/select_recipe(var/X)
	for (var/Type in typesof(/datum/food_processor_process) - /datum/food_processor_process - /datum/food_processor_process/mob)
		var/datum/food_processor_process/P = new Type()
		if (!istype(X, P.input))
			continue
		return P
	return 0

/obj/machinery/processor/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.processing)
		user << "\red The processor is in the process of processing."
		return 1
	if(src.contents.len > 0) //TODO: several items at once? several different items?
		user << "\red Something is already in the processing chamber."
		return 1
	var/what = O
	if (istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		what = G.affecting

	var/datum/food_processor_process/P = select_recipe(what)
	if (!P)
		user << "\red That probably won't blend."
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
		user << "\red The processor is in the process of processing."
		return 1
	if(src.contents.len == 0)
		user << "\red The processor is empty."
		return 1
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor havent suitable recipe. How do you put it in?") //-rastaf0
			continue
		src.processing = 1
		user.visible_message("\blue [user] turns on \a [src].", \
			"You turn on \a [src].", \
			"You hear a food processor")
		playsound(src.loc, 'blender.ogg', 50, 1)
		use_power(500)
		sleep(P.time)
		P.process(src.loc, O)
		src.processing = 0
	src.visible_message("\blue \the [src] finished processing.", \
		"You hear food processor stops")


