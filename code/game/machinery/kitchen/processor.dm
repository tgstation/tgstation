
/obj/machinery/processor
	name = "Food Processor"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	layer = 2.9
	density = 1
	anchored = 1
	var/broken = 0
	var/processing = 0
	var/opened = 0.0

	machine_flags = SCREWTOGGLE | CROWDESTROY

	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/processor/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/processor,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser/high,
		/obj/item/weapon/stock_parts/micro_laser/high
	)

	RefreshParts()

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
	meat
		input = /obj/item/weapon/reagent_containers/food/snacks/meat
		output = /obj/item/weapon/reagent_containers/food/snacks/faggot

	meat2
		input = /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
		output = /obj/item/weapon/reagent_containers/food/snacks/faggot

	potato
		input = /obj/item/weapon/reagent_containers/food/snacks/grown/potato
		output = /obj/item/weapon/reagent_containers/food/snacks/fries

	carrot
		input = /obj/item/weapon/reagent_containers/food/snacks/grown/carrot
		output = /obj/item/weapon/reagent_containers/food/snacks/carrotfries

	soybeans
		input = /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
		output = /obj/item/weapon/reagent_containers/food/snacks/soydope


	/* mobs */
	mob
		process(loc, what)
			..()


		slime
			time=0//It's painful enough

			process(loc, what)

				var/mob/living/carbon/slime/S = what
				var/C = S.cores
				if(S.stat != DEAD)
					S.loc = loc
					S.visible_message("\blue [C] crawls free of the processor!")
					return
				for(var/i = 1, i <= C, i++)
					new S.coretype(loc)
					feedback_add_details("slime_core_harvested","[replacetext(S.colour," ","_")]")
				..()
			input = /mob/living/carbon/slime
			output = null

		monkey
			process(loc, what)
				var/mob/living/carbon/monkey/O = what
				if (O.client) //grief-proof
					O.loc = loc
					O.visible_message("<span class='notice'>[O] suddenly jumps out of [src]!</span>", \
							"You jump out from the processor", \
							"You hear a slimy sound")
					return
				var/obj/item/weapon/reagent_containers/glass/bucket/bucket_of_blood = new(loc)
				var/datum/reagent/blood/B = new()
				B.holder = bucket_of_blood
				B.volume = 70
				//set reagent data
				B.data["donor"] = O

				for(var/datum/disease/D in O.viruses)
					if(D.spread_type != SPECIAL)
						B.data["viruses"] += D.Copy()

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

/obj/machinery/processor/crowbarDestroy(mob/user)
	if(contents.len)
		user << "You can't do that while something is loaded in \the [src]."
		return -1
	return ..()

/obj/machinery/processor/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.processing)
		user << "<span class='warning'>[src] is already processing!</span>"
		return 1

	if(..())
		return 1
	if(src.contents.len > 0) //TODO: several items at once? several different items?
		user << "<span class='warning'>Something is already in [src]</span>."
		return 1
	var/what = O
	if (istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		what = G.affecting

	var/datum/food_processor_process/P = select_recipe(what)
	if (!P)
		user << "<span class='warning'>This probably won't blend.</span>"
		return 1
	user.visible_message("<span class='notice'>[user] puts [what] into [src].</span>", \
		"You put [what] into the [src].")
	user.drop_item()
	what:loc = src
	return

/obj/machinery/processor/attack_hand(var/mob/user as mob)
	if (src.stat != 0) //NOPOWER etc
		return
	if(!anchored)
		user << "<span class='warning'>[src] must be anchored first!</span>"
		return
	if(src.processing)
		user << "<span class='warning'>[src] is already processing!</span>"
		return 1
	if(src.contents.len == 0)
		user << "<span class='warning'>[src] is empty!</span>"
		return 1
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor is not suitable. How did you put it in?") //-rastaf0
			continue
		src.processing = 1
		user.visible_message("<span class='notice'>[user] turns on [src]</span>.", \
			"You turn on \a [src].", \
			"You hear [src] start")
		playsound(get_turf(src), 'sound/machines/blender.ogg', 50, 1)
		use_power(500)
		sleep(P.time)
		P.process(src.loc, O)
		src.processing = 0
	src.visible_message("<span class='notice'>[src] is done.</span>", \
		"You hear [src] stop")

/obj/machinery/processor/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	attackby(O,user)