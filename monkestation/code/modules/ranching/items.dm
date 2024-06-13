/obj/item/chicken_scanner
	name = "Chicken Scanner"
	desc = "Scans chickens to give you information about possible mutations that chicken can have"
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	inhand_icon_state = "healthanalyzer"
	worn_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'

	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON

	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	var/scan_mode = TRUE


/obj/item/chicken_scanner/attack(mob/living/M, mob/living/carbon/human/user)
	if(!istype(M, /mob/living/basic/chicken))
		return
	var/mob/living/basic/chicken/scanned_chicken = M
	user.visible_message("<span class='notice'>[user] analyzes [scanned_chicken]'s possible mutations.</span>")

	chicken_scan(user, scanned_chicken)

/obj/item/chicken_scanner/AltClick(mob/user)
	. = ..()
	scan_mode = !scan_mode
	to_chat(user, "<span class='info'>Switched to Stat Mode</span>")

/obj/item/chicken_scanner/proc/chicken_scan(mob/living/carbon/human/user, mob/living/basic/chicken/scanned_chicken)
	if(scan_mode)
		for(var/mutation in scanned_chicken.mutation_list)
			var/datum/mutation/ranching/chicken/held_mutation = new mutation
			var/list/combined_msg = list()
			combined_msg += "\t<span class='notice'>[initial(held_mutation.egg_type.name)]</span>"
			if(held_mutation.happiness)
				combined_msg += "\t<span class='info'>Required Happiness: [held_mutation.happiness]</span>"
			if(held_mutation.needed_temperature)
				combined_msg += "\t<span class='info'>Required Temperature: Within [held_mutation.temperature_variance] K of [held_mutation.needed_temperature] K</span>"
			if(held_mutation.needed_pressure)
				combined_msg += "\t<span class='info'>Required Pressure: Within [held_mutation.pressure_variance] Kpa of [held_mutation.needed_pressure] Kpa </span>"
			if(held_mutation.food_requirements.len)
				var/list/foods = list()
				for(var/food in held_mutation.food_requirements)
					var/obj/item/food/listed_food = food
					foods += "[initial(listed_food.name)]"
				var/food_string = foods.Join(" , ")
				combined_msg += "\t<span class='info'>Required Foods: [food_string]</span>"
			if(held_mutation.reagent_requirements.len)
				var/list/reagents = list()
				for(var/reagent in held_mutation.reagent_requirements)
					var/datum/reagent/listed_reagent = reagent
					reagents += "[initial(listed_reagent.name)]"
				var/reagent_string = reagents.Join(" , ")
				combined_msg += "\t<span class='info'>Required Reagents: [reagent_string]</span>"
			if(held_mutation.needed_turfs.len)
				var/list/turfs = list()
				for(var/tile in held_mutation.needed_turfs)
					var/turf/listed_turf = tile
					turfs += "[initial(listed_turf.name)]"
				var/turf_string = turfs.Join(" , ")
				combined_msg += "\t<span class='info'>Required Environmental Turfs: [turf_string]</span>"
			if(held_mutation.required_atmos.len)
				var/list/gases = list()
				for(var/gas in held_mutation.required_atmos)
					gases += "[held_mutation.required_atmos[gas]] Moles of [gas]"
				var/gas_string = gases.Join(" , ")
				combined_msg += "\t<span class='info'>Required Environmental Gases: [gas_string]</span>"
			if(held_mutation.required_rooster)
				var/mob/living/basic/chicken/rooster_type = held_mutation.required_rooster
				var/rooster_name = ""
				if(rooster_type.breed_name_male)
					rooster_name = initial(rooster_type.breed_name_male)
				else
					rooster_name = initial(rooster_type.name)
				combined_msg += "\t<span class='info'>Required Rooster:[rooster_name]</span>"
			if(held_mutation.player_job)
				combined_msg += "\t<span class='info'>Required Present Worker:[held_mutation.player_job]</span>"
			if(held_mutation.player_health)
				combined_msg += "\t<span class='info'>Requires Injured Personnel with atleast [held_mutation.player_health] damage taken </span>"
			if(held_mutation.needed_species)
				var/datum/species/species_type = held_mutation.needed_species
				combined_msg += "\t<span class='info'>Requires Present Worker that is a [initial(species_type.name)]</span>"
			if(held_mutation.liquid_depth)
				var/depth_name = ""
				switch(held_mutation.liquid_depth)
					if(0 to LIQUID_ANKLES_LEVEL_HEIGHT-1)
						depth_name = "A puddle"
					if(LIQUID_ANKLES_LEVEL_HEIGHT to LIQUID_WAIST_LEVEL_HEIGHT-1)
						depth_name = "ankle deep"
					if(LIQUID_WAIST_LEVEL_HEIGHT to LIQUID_SHOULDERS_LEVEL_HEIGHT-1)
						depth_name = "waist deep"
					if(LIQUID_SHOULDERS_LEVEL_HEIGHT to LIQUID_FULLTILE_LEVEL_HEIGHT-1)
						depth_name = "shoulder deep"
					if(LIQUID_FULLTILE_LEVEL_HEIGHT to INFINITY)
						depth_name = "above head height"
				combined_msg += "\t<span class='info'>Requires liquid that is atleast [depth_name]</span>"

			to_chat(user, examine_block(combined_msg.Join("\n")))
	else
		var/list/combined_msg = list()
		var/datum/component/happiness_container/container = scanned_chicken.GetComponent(/datum/component/happiness_container)

		combined_msg += "\t <span class='info'>Age:[SEND_SIGNAL(scanned_chicken, COMSIG_AGE_RETURN_AGE)]</span>"
		combined_msg += "\t <span class='info'>Happiness:[round(container.current_happiness, 1)]</span>"
		to_chat(user, examine_block(combined_msg.Join("\n")))

/datum/design/chicken_scanner
	name = "Chicken Scanner"
	id = "chicken_scanner"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/chicken_scanner
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/obj/machinery/feed_machine
	name = "Feed Producer"
	desc = "It converts food and reagents into usable feed for chickens. \n Alt-Click the machine in order to produce feed"

	icon = 'monkestation/icons/obj/structures.dmi'
	icon_state = "feed_producer"

	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	max_integrity = 300

	circuit = /obj/item/circuitboard/machine/feed_machine

	///the current held beaker used when feed is produced to add reagents to it
	var/obj/item/reagent_containers/cup/beaker/beaker = null
	///list of all currently held foods
	var/list/held_foods = list()
	///the first food object put into the feed machine this cycle
	var/obj/item/food/first_food
	///number of food inserted
	var/food_inserted = 0

/obj/machinery/feed_machine/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(!typesof(I, /obj/item/food) || !typesof(I, /obj/item/reagent_containers)) ///if not a food or reagent type early return
		return

	if(istype(I, /obj/item/food)) // if food we do this
		if(food_inserted > 4)
			to_chat(user, span_notice("The [src] is filled to the brim, it can't hold anymore."))
			return
		var/obj/item/food/attacked_food = I

		if(!first_food) // set the food type to this, used for color and naming
			first_food = attacked_food
		held_foods |= attacked_food.type //we add the type to this as we don't want a ton of random objects stored inside the feed
		food_inserted++
		qdel(I)
		return

	else //if not this
		var/obj/item/reagent_containers/cup/beaker/attacked_reagent_container = I
		if(!istype(attacked_reagent_container))
			return
		if(!user.transferItemToLoc(attacked_reagent_container, src))
			return
		if(beaker)
			beaker.forceMove(drop_location())
			if(user && Adjacent(user) && !issiliconoradminghost(user))
				user.put_in_hands(beaker)
		beaker = attacked_reagent_container
		return

/obj/machinery/feed_machine/AltClick(mob/user)
	. = ..()
	if(length(held_foods) == 0)
		return
	var/obj/item/chicken_feed/produced_feed = new(src.loc)
	produced_feed.placements_left *= food_inserted

	if(beaker && beaker.reagents)
		produced_feed.name = "[initial(first_food.name)] Chicken Feed infused with [beaker?.reagents.reagent_list[1].name]"
	else
		produced_feed.name = "[initial(first_food.name)] Chicken Feed"
	for(var/food in held_foods)
		var/obj/item/food/listed_food = new food(src.loc)
		produced_feed.held_foods |= listed_food.type
		qdel(listed_food)
	if(beaker && beaker.reagents)
		for(var/datum/reagent/reagent as anything in beaker.reagents.reagent_list)
			produced_feed.reagents.add_reagent(reagent.type, reagent.volume)

		beaker.forceMove(drop_location())
		beaker.reagents.remove_all(1000)
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(beaker)
		beaker = null

	first_food = null
	held_foods = list()
	food_inserted = 0

/obj/item/chicken_feed
	name = "chicken feed"
	icon = 'monkestation/icons/obj/ranching/feed.dmi'
	icon_state = "feed_sack"

	///list of contained foods
	var/list/held_foods = list()

	///how many placements left
	var/placements_left = 5

/obj/item/chicken_feed/Initialize(mapload)
	. = ..()
	reagents = new(1000)
	var/mutable_appearance/feed_top = mutable_appearance(src.icon, "feed_seed")
	if(reagents?.reagent_list.len)
		feed_top.color = mix_color_from_reagents(reagents.reagent_list)
	else
		feed_top.color = "#cacc52"
	add_overlay(feed_top)

/obj/item/chicken_feed/afterattack(atom/attacked_atom, mob/user)
	if(!user.Adjacent(attacked_atom))
		return
	try_place(attacked_atom)

/obj/item/chicken_feed/proc/try_place(atom/target)
	if(!isopenturf(target))
		return FALSE
	var/turf/open/targeted_turf = get_turf(target)
	var/list/compiled_reagents = list()
	for(var/datum/reagent/listed_reagent in reagents.reagent_list)
		compiled_reagents += new listed_reagent.type
		compiled_reagents[listed_reagent] = listed_reagent.volume

	new /obj/effect/chicken_feed(targeted_turf, held_foods, compiled_reagents, mix_color_from_reagents(reagents.reagent_list), name)
	placements_left--

	if(placements_left <= 0)
		qdel(src)

/obj/effect/chicken_feed
	name = "chicken feed"
	icon = 'monkestation/icons/effects/feed.dmi'

	var/list/held_foods = list()

	var/list/held_reagents = list()

/obj/effect/chicken_feed/New(loc, list/held_foods, list/held_reagents, color, name)
	. = ..()
	src.name = name
	src.held_foods = held_foods
	src.held_reagents = held_reagents
	if(color)
		src.color = color
	else
		src.color = "#cacc52"
	icon_state = "feed_[rand(1,4)]"

/obj/item/storage/bag/egg
	name = "egg bag"
	icon = 'monkestation/icons/obj/ranching.dmi'
	icon_state = "egg_bag"
	worn_icon_state = "plantbag"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/egg/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 50
	atom_storage.set_holdable(list(
		/obj/item/food/egg,
	))

/obj/machinery/egg_incubator
	name = "Incubator"
	desc = "For most eggs this can force them to hatch, that is unless a fresh mutation."
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500

	max_integrity = 300
	circuit = /obj/item/circuitboard/machine/egg_incubator

	icon = 'monkestation/icons/obj/structures.dmi'
	icon_state = "incubator"

	var/current_state = FALSE

/obj/machinery/egg_incubator/attack_hand(mob/living/user)
	. = ..()
	current_state = !current_state
	var/extra_text = current_state ? "On" : "Off"
	to_chat(user,  span_notice("You flip the [src] [extra_text]"))
	desc = null
	if(current_state)
		START_PROCESSING(SSobj, src)
		desc += "For most eggs this can force them to hatch, that is unless a fresh mutation."
		desc += "\n The incubator glows with a soft orange hue, it appears to be on."
	else
		STOP_PROCESSING(SSobj, src)
		desc += "For most eggs this can force them to hatch, that is unless a fresh mutation."
		desc += "\n The incubator appears cold and dark, unsuitable for incubation"

/obj/machinery/egg_incubator/process()
	. = ..()
	for(var/obj/item/food/egg/contained_egg in loc.contents)
		if(contained_egg.fresh_mutation)
			continue
		if(contained_egg.datum_flags & DF_ISPROCESSING)
			continue
		if(!contained_egg.layer_hen_type)
			contained_egg.layer_hen_type = /mob/living/basic/chicken
		START_PROCESSING(SSobj, contained_egg)
		flop_animation(contained_egg)
		contained_egg.desc = "You can hear pecking from the inside of this seems it may hatch soon."

/obj/machinery/egg_incubator/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/storage/bag/tray))
		var/obj/item/storage/bag/tray/T = I
		if(T.contents.len > 0) // If the tray isn't empty
			I.atom_storage.remove_all(drop_location())
			user.visible_message(span_notice("[user] empties [I] on [src]."))
			return

	if(!(user.istate & ISTATE_HARM) && !(I.item_flags & ABSTRACT))
		if(user.transferItemToLoc(I, drop_location(), silent = FALSE))
			var/list/click_params = params2list(params)
			//Center the icon where the user clicked.
			if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
			I.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
			return TRUE
	else
		return ..()
