////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
GLOBAL_LIST_INIT(temp_stabilizers, typecacheof(list(
	/obj/structure/closet/crate/secure/hydroponics,
	/obj/structure/closet/crate/freezer,
	/obj/structure/closet/crate/hydroponics,
	/obj/structure/closet/secure_closet/freezer
	)))

/obj/item/reagent_containers/food
	possible_transfer_amounts = list()
	volume = 50	//Sets the default container amount for all food items.
	container_type = INJECTABLE_1
	resistance_flags = FLAMMABLE
	var/foodtype = NONE
	var/last_check_time
	var/cares_about_temperature = FALSE
	var/starting_temp = 200 // Farenheight
	var/current_temp = 200
	var/max_danger = 140 // HIGH WAY
	var/min_danger = 39 // TO THE
	var/rotten_reagent = "toxin" // DANGER ZONE
	var/time_spent_in_danger_zone = 0

/obj/item/reagent_containers/food/proc/can_temp_naturally_adjust()
	if(istype(loc, /obj/item/storage))
		var/obj/item/storage/S = loc
		if(is_type_in_typecache(S.loc, GLOB.temp_stabilizers))
			return TRUE
	if(is_type_in_typecache(loc, GLOB.temp_stabilizers))
		return TRUE
	return FALSE

/obj/item/reagent_containers/food/proc/in_danger_zone()
	if(current_temp >= min_danger && current_temp <= max_danger)
		return TRUE
	return FALSE

/obj/item/reagent_containers/food/Initialize(mapload)
	. = ..()
	if(!mapload)
		pixel_x = rand(-5, 5)
		pixel_y = rand(-5, 5)
	if(cares_about_temperature)
		current_temp = starting_temp
		START_PROCESSING(SSfood, src)

/obj/item/reagent_containers/food/Destroy()
	if(cares_about_temperature)
		STOP_PROCESSING(SSfood, src)
	. = ..()

/obj/item/reagent_containers/food/process()
	if(can_temp_naturally_adjust())
		if(current_temp > max_danger/2)
			current_temp -= 1
		else if(current_temp < max_danger/2)
			current_temp += 1
	if(in_danger_zone())
		time_spent_in_danger_zone++
		if(time_spent_in_danger_zone > 20)
			reagents.add_reagent(rotten_reagent, 1)
		if(time_spent_in_danger_zone > 40)
			desc += " I wouldn't eat that..."
			name = "rotten [name]"
			color = "#BCE060"

/obj/item/reagent_containers/food/proc/checkLiked(var/fraction, mob/M)
	if(last_check_time + 50 < world.time)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(foodtype & H.dna.species.toxic_food)
				to_chat(H,"<span class='warning'>What the hell was that thing?!</span>")
				H.adjust_disgust(25 + 30 * fraction)
			else if(foodtype & H.dna.species.disliked_food)
				to_chat(H,"<span class='notice'>That didn't taste very good...</span>")
				H.adjust_disgust(11 + 15 * fraction)
			else if(foodtype & H.dna.species.liked_food)
				to_chat(H,"<span class='notice'>I love this taste!</span>")
				H.adjust_disgust(-5 + -2.5 * fraction)
			last_check_time = world.time
