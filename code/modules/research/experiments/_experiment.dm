/datum/experiment
	var/weight = 0				//How likely this experiment occurs
	var/power_use = 750
	var/is_bad = FALSE			//Whether the weight is affected by the bad_things_coeff
	var/experiment_type			//Path of the experiment type that should trigger this experiment, use /datum/experiment_type for any, null for none
	var/valid_types 			//Which types of items this experiment works on
	var/performed_times = 0 	//How often this experiment occured
	var/base_points = 500 		//This value determines how many techweb points are generated from this reaction. It's divided by the number of times triggered squared, so (1, 1/4, 1/9, 1/16, ...)
	var/allow_boost = TRUE     //Whether this experiment can boost techweb nodes (Whatever that means go away kevinz)
	var/critical = FALSE		//Only allow critical items to trigger this reaction

//Override this to assign non-constant values to vars (like changing which typecache the experiment uses)
/datum/experiment/proc/init()
	if(critical)
		valid_types = GLOB.critical_items
	else
		valid_types = typecacheof(/obj/item)

//Override this proc to check for other qualities of the item (slime core charges, valid bomb, etc)
/datum/experiment/proc/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = is_type_in_typecache(O,valid_types)
	if(. && critical)
		. = is_valid_critical(O)

//Where the nitty gritty happens
/datum/experiment/proc/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = TRUE
	performed_times++

//Override this proc to do your own point gathering formula
/datum/experiment/proc/gather_data(obj/machinery/rnd/experimentor/E,datum/techweb/T,success)
	var/gained_points = round(base_points / (performed_times ** 2),1)
	if(success && gained_points > 1) //This way we'll always be correct!
		T.research_points["General Research"] += gained_points
		E.say("Experiment gathered [gained_points] points from dataset.")

//This is just a subtype for experiments that should destroy the object and return the materials
/datum/experiment/destroy
	var/immune_flags = INDESTRUCTIBLE //any of these flags prevent the item from being destroyed

/datum/experiment/destroy/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(O.resistance_flags & immune_flags)
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
	var/obj/item/reagent_containers/food/drinks/coffee/C = new /obj/item/reagent_containers/food/drinks/coffee(get_turf(pick(oview(1,E))))
	var/list/chosenchems = list()
	C.reagents.remove_any(remove_amt)
	for(var/i in 1 to times)
		var/chosenchem = pick(valid_reagents)
		C.reagents.add_reagent(chosenchem , add_amt)
		chosenchems += chosenchem
	C.name = "Cup of Suspicious Liquid"
	C.desc = "It has a large hazard symbol printed on the side in fading ink."
	E.investigate_log("Experimentor has made a cup of [english_list(chosenchems)] coffee.", INVESTIGATE_EXPERIMENTOR)

/datum/experiment/destroy/transform/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	var/oldname = O.name
	. = ..()
	O = make_transform_item(get_turf(pick(oview(1,E))))
	E.visible_message("<span class='warning'>[E] malfunctions, transforming [oldname] into [O]!</span>")

/datum/experiment/destroy/transform/proc/make_transform_item(atom/location)

/datum/experiment/proc/is_valid_critical(obj/item/O)
	if(istype(O,/obj/item/transfer_valve))
		return is_valid_bomb(O)
	else if(istype(O,/obj/item/slime_extract))
		return is_valid_slimecore(O)
	else if(istype(O,/obj/item/grenade/chem_grenade))
		return is_valid_grenade(O)
	return TRUE

/datum/experiment/proc/is_valid_bomb(obj/item/transfer_valve/O)
	return O.tank_one && O.tank_two && O.attached_device

/datum/experiment/proc/is_valid_slimecore(obj/item/slime_extract/O)
	return O.Uses > 0

/datum/experiment/proc/is_valid_grenade(obj/item/grenade/chem_grenade/O)
	return O.stage == 3 //state=3 means state=READY //looks stupid but READY is undefined at the end of the chem_grenade file so we can't use it here

/datum/experiment/proc/is_relic_undiscovered(obj/item/relic/O)
	return !O.revealed