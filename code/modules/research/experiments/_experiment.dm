/datum/experiment
	var/weight = 0				//How likely this experiment occurs
	var/power_use = 750
	var/is_bad = FALSE			//Whether the weight is affected by the bad_things_coeff
	var/experiment_type			//Path of the experiment type that should trigger this experiment, use /datum/experiment_type for any
	var/valid_types 			//Which types of items this experiment works on
	var/performed_times = 0 	//How often this experiment occured
	var/base_points = 25 		//This value determines how many techweb points are generated from this reaction. It's divided by the number of times triggered squared, so (1, 1/4, 1/9, 1/16, ...)
	var/allow_boost = FALSE     //Whether this experiment can boost techweb nodes (Whatever that means go away kevinz)

//Override this to assign non-constant values to vars (like changing which typecache the experiment uses)
/datum/experiment/proc/init()
	valid_types = typecacheof(/obj/item)

//Override this proc to check for other qualities of the item (slime core charges, valid bomb, etc)
/datum/experiment/proc/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = valid_types[O]

//Where the nitty gritty happens
/datum/experiment/proc/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = TRUE
	performed_times++

//Override this proc to do your own point gathering formula
/datum/experiment/proc/gather_data(obj/machinery/rnd/experimentor/E,datum/techweb/T,success)
	var/gained_points = round(base_points / (performed_times ** 2),1)
	if(success && gained_points > 1) //This way we'll always be correct!
		T.research_points += gained_points
		E.say("Experiment gathered [gained_points] points from dataset.")

//This is just a subtype for experiments that should destroy the object and return the materials
/datum/experiment/destroy/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(. && O.resistance_flags & INDESTRUCTIBLE)
		. = FALSE

/datum/experiment/destroy/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.destroy_item()

//Subtype for experiments that make coffee cups filled with suspicious liquids
/datum/experiment/coffee
	var/list/valid_reagents = list("coffee")
	var/times = 1 		//number of times to add
	var/remove_amt = 25 //amount removed once (to clear the coffee)
	var/add_amt = 50 	//amount added each time

/datum/experiment/coffee/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/obj/item/reagent_containers/food/drinks/coffee/C = new /obj/item/reagent_containers/food/drinks/coffee(get_turf(pick(oview(1,src))))
	var/list/chosenchems = list()
	C.reagents.remove_any(remove_amt)
	for(var/i in 1 to times)
		var/chosenchem = pick(valid_reagents)
		C.reagents.add_reagent(chosenchem , add_amt)
		chosenchems += chosenchem
	C.name = "Cup of Suspicious Liquid"
	C.desc = "It has a large hazard symbol printed on the side in fading ink."
	E.investigate_log("Experimentor has made a cup of [english_list(chosenchems)] coffee.", INVESTIGATE_EXPERIMENTOR)