/obj/structure/wormfarm
	name = "worm farm"
	desc = "A wonderfully dirty barrel where worms can have a happy little life."
	icon = 'monkestation/code/modules/blueshift/icons/structures.dmi'
	icon_state = "wormbarrel"
	density = TRUE
	anchored = FALSE
	/// How many worms can the barrel hold
	var/max_worm = 10
	/// How many worms the barrel is currently holding
	var/current_worm = 0
	/// How much food was inserted into the barrel that needs to be composted
	var/current_food = 0
	/// If the barrel is currently being used by someone
	var/in_use = FALSE
	// The cooldown between each worm "breeding"
	COOLDOWN_DECLARE(worm_timer)

/obj/structure/wormfarm/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	COOLDOWN_START(src, worm_timer, 30 SECONDS)

/obj/structure/wormfarm/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

//process is currently only used for making more worms
/obj/structure/wormfarm/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, worm_timer))
		return

	COOLDOWN_START(src, worm_timer, 30 SECONDS)

	if(current_worm >= 2 && current_worm < max_worm)
		current_worm++

	if(current_food > 0 && current_worm > 1)
		current_food--
		new /obj/item/stack/worm_fertilizer(get_turf(src))

/obj/structure/wormfarm/examine(mob/user)
	. = ..()
	. += span_notice("<br>There are currently [current_worm]/[max_worm] worms in the barrel.")
	if(current_worm < max_worm)
		. += span_notice("You can place more worms in the barrel.")
	if(current_worm > 0)
		. += span_notice("You can get fertilizer by feeding the worms food.")

/obj/structure/wormfarm/attack_hand(mob/living/user, list/modifiers)
	if(in_use)
		balloon_alert(user, "currently in use")
		return ..()

	balloon_alert(user, "digging up worms")
	var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_SPEED_MODIFIER)
	if(!do_after(user, 2 SECONDS * skill_modifier, src))
		balloon_alert(user, "stopped digging")
		in_use = FALSE
		return ..()

	if(current_worm <= 0)
		balloon_alert(user, "no worms available")
		in_use = FALSE
		return ..()

	new /obj/item/food/bait/worm(get_turf(src))
	current_worm--
	in_use = FALSE

	return ..()

/obj/structure/wormfarm/attackby(obj/item/attacking_item, mob/user, params)
	//we want to check for worms first because they are a type of food as well...
	if(istype(attacking_item, /obj/item/food/bait/worm))
		if(current_worm >= max_worm)
			balloon_alert(user, "too many worms in the barrel")
			return

		qdel(attacking_item)
		balloon_alert(user, "worm released into barrel")
		current_worm++
		return

	//if it aint a worm, lets check for any other food items
	if(istype(attacking_item, /obj/item/food))
		if(in_use)
			balloon_alert(user, "currently in use")
			return
		in_use = TRUE

		balloon_alert(user, "feeding the worms")
		var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_SPEED_MODIFIER)
		if(!do_after(user, 1 SECONDS * skill_modifier, src))
			balloon_alert(user, "stopped feeding the worms")
			in_use = FALSE
			return

		// if someone has built multiple worm farms, I want to make sure they can't just use one singular piece of food for more than one barrel
		if(!attacking_item)
			in_use = FALSE
			return

		qdel(attacking_item)
		balloon_alert(user, "feeding complete, check back later")

		current_food++
		if(prob(user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_PROBS_MODIFIER)))
			current_food++

		user.mind.adjust_experience(/datum/skill/primitive, 5)
		in_use = FALSE
		return

	if(istype(attacking_item, /obj/item/storage/bag/plants))
		if(in_use)
			balloon_alert(user, "currently in use")
			return
		in_use = TRUE

		balloon_alert(user, "feeding the worms")
		var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_SPEED_MODIFIER)
		for(var/obj/item/food/selected_food in attacking_item.contents)
			if(!do_after(user, 1 SECONDS * skill_modifier, src))
				in_use = FALSE
				return

			qdel(selected_food)
			current_food++
			if(prob(user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_PROBS_MODIFIER)))
				current_food++

		user.mind.adjust_experience(/datum/skill/primitive, 5)
		in_use = FALSE
		return

	//it wasn't a worm, or a piece of food
	return ..()

//produced by feeding worms food and can be ground up for plant nutriment or used directly on ash farming
/obj/item/stack/worm_fertilizer
	name = "worm fertilizer"
	desc = "When you fed your worms, you should have expected this."
	icon = 'monkestation/code/modules/blueshift/icons/misc_tools.dmi'
	icon_state = "fertilizer"
	grind_results = list(/datum/reagent/plantnutriment/eznutriment = 3, /datum/reagent/plantnutriment/left4zednutriment = 3, /datum/reagent/plantnutriment/robustharvestnutriment = 3)
	singular_name = "fertilizer"
	merge_type = /obj/item/stack/worm_fertilizer

/obj/structure/spawner/lavaland
	/// whether it has a curse attached to it
	var/cursed = FALSE

/obj/structure/spawner/lavaland/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/cursed_dagger))
		playsound(get_turf(src), 'sound/magic/demon_attack1.ogg', 50, TRUE)
		cursed = !cursed
		if(cursed)
			src.add_atom_colour("#41007e", TEMPORARY_COLOUR_PRIORITY)
		else
			src.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, "#41007e")
		balloon_alert_to_viewers("a curse has been [cursed ? "placed..." : "lifted..."]")
		if(isliving(user))
			var/mob/living/living_user = user
			living_user.adjustFireLoss(100)
		to_chat(user, span_warning("The knife sears your hand!"))
		return
	return ..()

/obj/structure/spawner/lavaland/Destroy()
	if(cursed)
		for(var/mob/living/carbon/human/selected_human in range(7))
			if(is_species(selected_human, /datum/species/lizard/ashwalker))
				continue
			selected_human.AddComponent(/datum/component/ash_cursed)
		for(var/mob/select_mob in GLOB.player_list)
			if(!is_species(select_mob, /datum/species/lizard/ashwalker))
				continue
			to_chat(select_mob, span_boldwarning("A cursed tendril has been broken! The target has been marked until they flee the lands!"))
	. = ..()

/datum/component/ash_cursed
	/// the person who is targeted by the curse
	var/mob/living/carbon/human/human_target

/datum/component/ash_cursed/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	human_target = parent
	ADD_TRAIT(human_target, TRAIT_NO_TELEPORT, REF(src))
	human_target.add_movespeed_modifier(/datum/movespeed_modifier/ash_cursed)
	RegisterSignal(human_target, COMSIG_MOVABLE_MOVED, PROC_REF(do_move))
	RegisterSignal(human_target, COMSIG_LIVING_DEATH, PROC_REF(remove_curse))

/datum/component/ash_cursed/Destroy(force, silent)
	. = ..()
	REMOVE_TRAIT(human_target, TRAIT_NO_TELEPORT, REF(src))
	human_target.remove_movespeed_modifier(/datum/movespeed_modifier/ash_cursed)
	UnregisterSignal(human_target, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DEATH))
	human_target = null

/datum/component/ash_cursed/proc/remove_curse()
	SIGNAL_HANDLER
	for(var/mob/select_mob in GLOB.player_list)
		if(!is_species(select_mob, /datum/species/lizard/ashwalker))
			continue
		to_chat(select_mob, span_boldwarning("A target has died, the curse has been lifted!"))
	Destroy()

/datum/component/ash_cursed/proc/do_move()
	SIGNAL_HANDLER
	var/turf/human_turf = get_turf(human_target)
	if(!is_mining_level(human_turf.z))
		Destroy()
		for(var/mob/select_mob in GLOB.player_list)
			if(!is_species(select_mob, /datum/species/lizard/ashwalker))
				continue
			to_chat(select_mob, span_boldwarning("A target has fled from the land, breaking the curse!"))
		return
	if(prob(75))
		return
	var/obj/effect/decal/cleanable/greenglow/ecto/spawned_goo = locate() in human_turf
	if(spawned_goo)
		return
	spawned_goo = new(human_turf)
	addtimer(CALLBACK(spawned_goo, TYPE_PROC_REF(/obj/effect/decal/cleanable/greenglow/ecto, do_qdel)), 5 MINUTES, TIMER_STOPPABLE|TIMER_DELETE_ME)

/obj/effect/decal/cleanable/greenglow/ecto/proc/do_qdel()
	qdel(src)

/datum/movespeed_modifier/ash_cursed
	multiplicative_slowdown = 1.0

/obj/item/stack/rail_track
	name = "railroad tracks"
	singular_name = "railroad track"
	desc = "A primitive form of transportation. Place on any floor to start building a railroad."
	icon = 'monkestation/code/modules/blueshift/icons/railroad.dmi'
	icon_state = "rail_item"
	merge_type = /obj/item/stack/rail_track

/obj/item/stack/rail_track/ten
	amount = 10

/obj/item/stack/rail_track/fifty
	amount = 50

/obj/item/stack/rail_track/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!isopenturf(target) || !proximity_flag)
		return ..()
	var/turf/target_turf = get_turf(target)
	var/obj/structure/railroad/check_rail = locate() in target_turf
	if(check_rail || !use(1))
		return ..()
	to_chat(user, span_notice("You place [src] on [target_turf]."))
	new /obj/structure/railroad(get_turf(target))

/obj/structure/railroad
	name = "railroad track"
	desc = "A primitive form of transportation. You may see some rail carts on it."
	icon = 'monkestation/code/modules/blueshift/icons/railroad.dmi'
	icon_state = "rail"
	anchored = TRUE

/obj/structure/railroad/Initialize(mapload)
	. = ..()
	for(var/obj/structure/railroad/rail in range(2, src))
		rail.change_look()

/obj/structure/railroad/Destroy()
	for(var/obj/structure/railroad/rail in range(2, src))
		rail.change_look(src)
	return ..()

/obj/structure/railroad/proc/change_look(obj/structure/target_structure = null)
	icon_state = "rail"
	var/turf/src_turf = get_turf(src)
	for(var/direction in GLOB.cardinals)
		var/obj/structure/railroad/locate_rail = locate() in get_step(src_turf, direction)
		if(!locate_rail || (target_structure && locate_rail == target_structure))
			continue
		icon_state = "[icon_state][direction]"
	update_appearance()

/obj/structure/railroad/crowbar_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	new /obj/item/stack/rail_track(get_turf(src))
	qdel(src)
	return

/obj/vehicle/ridden/rail_cart
	name = "rail cart"
	desc = "A wonderful form of locomotion. It will only ride while on tracks. It does have storage"
	icon = 'monkestation/code/modules/blueshift/icons/railroad.dmi'
	icon_state = "railcart"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_GREYSCALE | MATERIAL_COLOR
	/// The mutable appearance used for the overlay over buckled mobs.
	var/mutable_appearance/railoverlay
	/// whether there is sand in the cart
	var/has_sand = FALSE

/obj/vehicle/ridden/rail_cart/examine(mob/user)
	. = ..()
	. += span_notice("<br><b>Alt-Click</b> to attach a rail cart to this cart.")
	. += span_notice("<br>Filling it with <b>10 sand</b> will allow it to be used as a planter!")

/obj/vehicle/ridden/rail_cart/Initialize(mapload)
	. = ..()
	attach_trailer()
	railoverlay = mutable_appearance(icon, "railoverlay", ABOVE_MOB_LAYER, src, ABOVE_GAME_PLANE)
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/rail_cart)

	create_storage(max_total_storage = 21, max_slots = 21)

/obj/vehicle/ridden/rail_cart/post_buckle_mob(mob/living/M)
	. = ..()
	update_overlays()

/obj/vehicle/ridden/rail_cart/post_unbuckle_mob(mob/living/M)
	. = ..()
	update_overlays()

/obj/vehicle/ridden/rail_cart/update_overlays()
	. = ..()
	if(has_buckled_mobs())
		add_overlay(railoverlay)
	else
		cut_overlay(railoverlay)

/obj/vehicle/ridden/rail_cart/relaymove(mob/living/user, direction)
	var/obj/structure/railroad/locate_rail = locate() in get_step(src, direction)
	if(!canmove || !locate_rail)
		return FALSE
	if(is_driver(user))
		return relaydrive(user, direction)
	return FALSE

/obj/vehicle/ridden/rail_cart/AltClick(mob/user)
	attach_trailer()
	return

/obj/vehicle/ridden/rail_cart/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	atom_storage?.show_contents(user)

/obj/vehicle/ridden/rail_cart/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/use_item = attacking_item
		if(has_sand || !use_item.use(10))
			return ..()
		AddComponent(/datum/component/simple_farm, TRUE, TRUE, list(0, 16))
		has_sand = TRUE
		RemoveElement(/datum/element/ridable)
		return

	if(attacking_item.tool_behaviour == TOOL_SHOVEL)
		var/datum/component/remove_component = GetComponent(/datum/component/simple_farm)
		if(!remove_component)
			return ..()
		qdel(remove_component)
		has_sand = FALSE
		AddElement(/datum/element/ridable, /datum/component/riding/vehicle/rail_cart)
		return

	return ..()

/// searches the cardinal directions to add this cart to another cart's trailer
/obj/vehicle/ridden/rail_cart/proc/attach_trailer()
	if(trailer)
		remove_trailer()
		return
	for(var/direction in GLOB.cardinals)
		var/obj/vehicle/ridden/rail_cart/locate_cart = locate() in get_step(src, direction)
		if(!locate_cart || locate_cart.trailer == src)
			continue
		add_trailer(locate_cart)
		locate_cart.add_trailer(src)
		break

/datum/component/riding/vehicle/rail_cart
	vehicle_move_delay = 0.5
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/rail_cart/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 13), TEXT_SOUTH = list(0, 13), TEXT_EAST = list(0, 13), TEXT_WEST = list(0, 13)))
	set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/obj/structure/plant_tank
	name = "plant tank"
	desc = "A small little glass tank that is used to grow plants; this tank promotes the nitrogen and oxygen cycle."
	icon = 'monkestation/code/modules/blueshift/icons/structures.dmi'
	icon_state = "plant_tank_e"
	anchored = FALSE
	density = TRUE
	///the amount of times the tank can produce-- can be increased through feeding the tank
	var/operation_number = 0

/obj/structure/plant_tank/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/plant_tank/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/plant_tank/examine(mob/user)
	. = ..()
	. += span_notice("<br>Use food or worm fertilizer to allow nitrogen production and carbon dioxide processing!")
	. += span_notice("There are [operation_number] cycles left!")
	var/datum/component/simple_farm/find_farm = GetComponent(/datum/component/simple_farm)
	if(!find_farm)
		. += span_notice("<br>Use five sand to allow planting!")

/obj/structure/plant_tank/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/food) || istype(attacking_item, /obj/item/stack/worm_fertilizer))
		var/obj/item/stack/stack_item = attacking_item
		if(isstack(stack_item))
			if(!stack_item.use(1))
				return

		else
			qdel(attacking_item)

		balloon_alert(user, "[attacking_item] placed inside")
		user.mind.adjust_experience(/datum/skill/primitive, 5)
		operation_number += 2
		if(prob(user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_PROBS_MODIFIER)))
			operation_number += 2

		return

	if(istype(attacking_item, /obj/item/storage/bag/plants))
		balloon_alert(user, "placing food inside")
		var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_SPEED_MODIFIER)
		for(var/obj/item/food/selected_food in attacking_item.contents)
			if(!do_after(user, 1 SECONDS * skill_modifier, src))
				return

			qdel(selected_food)
			operation_number += 2
			if(prob(user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_PROBS_MODIFIER)))
				operation_number += 2

		user.mind.adjust_experience(/datum/skill/primitive, 5)
		return

	if(istype(attacking_item, /obj/item/stack/ore/glass))
		var/datum/component/simple_farm/find_farm = GetComponent(/datum/component/simple_farm)
		if(find_farm)
			balloon_alert(user, "no more [attacking_item] required")
			return

		var/obj/item/stack/attacking_stack = attacking_item
		if(!attacking_stack.use(5))
			balloon_alert(user, "farms require five sand")
			return

		AddComponent(/datum/component/simple_farm, TRUE, TRUE, list(0, 12))
		icon_state = "plant_tank_f"
		return

	return ..()

/obj/structure/plant_tank/process(seconds_per_tick)
	if(operation_number <= 0) //we require "fuel" to actually produce stuff
		return

	if(!locate(/obj/structure/simple_farm) in get_turf(src)) //we require a plant to process the "fuel"
		return

	operation_number--

	var/turf/open/src_turf = get_turf(src)
	if(!isopenturf(src_turf) || isspaceturf(src_turf) || src_turf.planetary_atmos) //must be open turf, can't be space turf, and can't be a turf that regenerates its atmos
		return

	var/datum/gas_mixture/src_mixture = src_turf.return_air()

	src_mixture.assert_gases(/datum/gas/carbon_dioxide, /datum/gas/oxygen, /datum/gas/nitrogen)

	var/proportion = src_mixture.gases[/datum/gas/carbon_dioxide][MOLES]
	if(proportion) //if there is carbon dioxide in the air, lets turn it into oxygen
		src_mixture.gases[/datum/gas/carbon_dioxide][MOLES] -= proportion
		src_mixture.gases[/datum/gas/oxygen][MOLES] += proportion

	src_mixture.gases[/datum/gas/nitrogen][MOLES] += MOLES_CELLSTANDARD //the nitrogen cycle-- plants (and bacteria) participate in the nitrogen cycle

/obj/structure/plant_tank/wrench_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "[anchored ? "un" : ""]bolting")
	tool.play_tool_sound(src, 50)
	if(!tool.use_tool(src, user, 2 SECONDS))
		return TRUE

	anchored = !anchored
	balloon_alert(user, "[anchored ? "" : "un"]bolted")
	return TRUE

/obj/structure/plant_tank/screwdriver_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "deconstructing")
	tool.play_tool_sound(src, 50)
	if(!tool.use_tool(src, user, 2 SECONDS))
		return TRUE

	deconstruct()
	return TRUE

/obj/structure/plant_tank/deconstruct(disassembled)
	var/target_turf = get_turf(src)
	for(var/loop in 1 to 4)
		new /obj/item/stack/sheet/glass(target_turf)
		new /obj/item/stack/rods(target_turf)
	new /obj/item/smithed_part/forged_plate(target_turf)
	return ..()

/datum/crafting_recipe/plant_tank
	name = "Plant Tank"
	result = /obj/structure/plant_tank
	reqs = list(
		/obj/item/smithed_part/forged_plate = 1,
		/obj/item/stack/sheet/glass = 4,
		/obj/item/stack/rods = 4,
	)
	category = CAT_STRUCTURE

/obj/structure/ore_container/gutlunch_trough/attackby(obj/item/attacking_item, mob/living/carbon/human/user, list/modifiers)
	if(!istype(attacking_item, /obj/item/storage/bag/ore))
		return ..()

	for(var/obj/item/stack/ore/stored_ore in attacking_item.contents)
		attacking_item.atom_storage?.attempt_remove(stored_ore, src)

//CODE CREDIT TO JJPARK-KB
//Infinite welding fuel source, lets ashwalkers have infinite fuel without needing high-tech welders.

/obj/structure/sink/fuel_well
	name = "fuel well"
	desc = "A bubbling pool of fuel. This would probably be valuable, had bluespace technology not destroyed the need for fossil fuels 200 years ago."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "puddle-oil"
	dispensedreagent = /datum/reagent/fuel
	color = "#742912"	//Gives it a weldingfuel hue

/obj/structure/sink/fuel_well/Initialize(mapload)
	.=..()
	create_reagents(20)
	reagents.add_reagent(dispensedreagent, 20)

/obj/structure/sink/fuel_well/attack_hand(mob/user, list/modifiers)
	flick("puddle-oil-splash",src)
	reagents.expose(user, TOUCH, 20) //Covers target in 20u of fuel.
	to_chat(user, span_notice("You touch the pool of fuel, only to get fuel all over yourself. It would be wise to wash this off with water."))

/obj/structure/sink/fuel_well/attackby(obj/item/O, mob/living/user, params)
	flick("puddle-oil-splash",src)
	if(O.tool_behaviour == TOOL_SHOVEL) //attempt to deconstruct the puddle with a shovel //attempt to deconstruct the puddle with a shovel
		to_chat(user, "You fill in the fuel well with soil.")
		O.play_tool_sound(src)
		deconstruct()
		return 1
	if(istype(O, /obj/item/reagent_containers)) //Refilling bottles with oil
		var/obj/item/reagent_containers/RG = O
		if(RG.is_refillable())
			if(!RG.reagents.holder_full())
				RG.reagents.add_reagent(dispensedreagent, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
				to_chat(user, span_notice("You fill [RG] from [src]."))
				return TRUE
			to_chat(user, span_notice("\The [RG] is full."))
			return FALSE
	if(O.tool_behaviour == TOOL_WELDER)
		if(!reagents.has_reagent(/datum/reagent/fuel))
			to_chat(user, span_warning("[src] is out of fuel!"))
			return
		var/obj/item/weldingtool/W = O
		if(istype(W) && !W.welding)
			if(W.reagents.has_reagent(/datum/reagent/fuel, W.max_fuel))
				to_chat(user, span_warning("Your [W.name] is already full!"))
				return
			reagents.trans_to(W, W.max_fuel, transfered_by = user)
			user.visible_message(span_notice("[user] refills [user.p_their()] [W.name]."), span_notice("You refill [W]."))
			playsound(src, 'sound/effects/refill.ogg', 50, TRUE)
			W.update_appearance()
		return
	else
		return ..()

#define REQUIRED_OBSERVERS 2
#define MEGAFAUNA_MEAT_AMOUNT 20

//this is for revitalizing/preserving regen cores
/obj/structure/lavaland/ash_walker/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!istype(attacking_item, /obj/item/organ/internal/monster_core/regenerative_core))
		return ..()

	if(!user.mind.has_antag_datum(/datum/antagonist/ashwalker))
		balloon_alert(user, "must be an ashwalker!")
		return

	var/obj/item/organ/internal/monster_core/regenerative_core/regen_core = attacking_item

	if(!regen_core.preserve())
		balloon_alert(user, "organ decayed!")
		return
	playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
	balloon_alert_to_viewers("[src] revitalizes [regen_core]!")
	return

//this is for logging the destruction of the tendril
/obj/structure/lavaland/ash_walker/Destroy()
	var/compiled_string = "The [src] has been destroyed at [loc_name(src.loc)], nearest mobs are "
	var/found_anyone = FALSE

	for(var/mob/living/carbon/carbons_nearby in range(7))
		compiled_string += "[key_name(carbons_nearby)],"
		found_anyone = TRUE

	if(!found_anyone)
		compiled_string += "nobody."

	log_game(compiled_string)
	return ..()

//this is for transforming a person into an ashwalker
/obj/structure/lavaland/ash_walker/attack_hand(mob/living/user, list/modifiers)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	if(istype(human_user.dna.species, /datum/species/lizard/ashwalker))
		return

	var/allow_transform = 0

	for(var/mob/living/carbon/human/count_human in range(2, src))
		if(!istype(count_human.dna.species, /datum/species/lizard/ashwalker))
			continue

		allow_transform++

	if(allow_transform < REQUIRED_OBSERVERS)
		balloon_alert_to_viewers("[src] rejects the request, not enough viewers!")
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		human_user.adjustBruteLoss(10)
		return

	else
		balloon_alert_to_viewers("[src] reaches out to [human_user]...")
		var/choice = tgui_alert(human_user, "Become an Ashwalker? You will abandon your previous life and body.", "Major Choice", list("Yes", "No"))

		if(choice != "Yes")
			balloon_alert_to_viewers("[src] feels rejected and punishes [human_user]!")
			playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
			human_user.adjustBruteLoss(50)
			return

		balloon_alert_to_viewers("[src] rejoices and transforms [human_user]!")
		human_user.unequip_everything()
		human_user.set_species(/datum/species/lizard/ashwalker)
		human_user.underwear = "Nude"
		human_user.update_body()
		human_user.mind.add_antag_datum(/datum/antagonist/ashwalker)

		if(SSmapping.level_trait(human_user.z, ZTRAIT_ICE_RUINS) || SSmapping.level_trait(human_user.z, ZTRAIT_ICE_RUINS_UNDERGROUND))
			ADD_TRAIT(human_user, TRAIT_NOBREATH, ROUNDSTART_TRAIT)
			ADD_TRAIT(human_user, TRAIT_RESISTCOLD, ROUNDSTART_TRAIT)

		ADD_TRAIT(human_user, TRAIT_PRIMITIVE, ROUNDSTART_TRAIT)
		playsound(src, 'sound/magic/demon_dies.ogg', 50, TRUE)
		meat_counter++

	return ..()

//this is the skyrat override
/obj/structure/lavaland/ash_walker/consume()
	for(var/mob/living/viewable_living in view(src, 1)) //Only for corpse right next to/on same tile
		if(!viewable_living.stat)
			continue

		viewable_living.unequip_everything()

		if(issilicon(viewable_living)) //no advantage to sacrificing borgs...
			viewable_living.investigate_log("has been gibbed via ashwalker sacrifice as a borg.", INVESTIGATE_DEATHS)
			viewable_living.gib()
			return

		if(viewable_living.mind?.has_antag_datum(/datum/antagonist/ashwalker) && (viewable_living.ckey || viewable_living.get_ghost(FALSE, TRUE))) //special interactions for dead lava lizards with ghosts attached
			revive_ashwalker(viewable_living)
			return

		if(ismegafauna(viewable_living))
			meat_counter += MEGAFAUNA_MEAT_AMOUNT

		else
			meat_counter++

		playsound(get_turf(src),'sound/magic/demon_consume.ogg', 100, TRUE)
		var/delivery_key = viewable_living.fingerprintslast //key of whoever brought the body
		var/mob/living/delivery_mob = get_mob_by_key(delivery_key) //mob of said key

		//there is a 40% chance that the Lava Lizard unlocks their respawn with each sacrifice
		if(delivery_mob && (delivery_mob.mind?.has_antag_datum(/datum/antagonist/ashwalker)) && (delivery_key in ashies.players_spawned) && prob(40))
			to_chat(delivery_mob, span_boldwarning("The Necropolis is pleased with your sacrifice. You feel confident your existence after death is secure."))
			ashies.players_spawned -= delivery_key

		viewable_living.investigate_log("has been gibbed via ashwalker sacrifice.", INVESTIGATE_DEATHS)
		viewable_living.gib()
		atom_integrity = min(atom_integrity + max_integrity * 0.05, max_integrity) //restores 5% hp of tendril

		for(var/mob/living/living_observers in view(src, 5))
			if(living_observers.mind?.has_antag_datum(/datum/antagonist/ashwalker))
				living_observers.add_mood_event("oogabooga", /datum/mood_event/sacrifice_good)

			else
				living_observers.add_mood_event("oogabooga", /datum/mood_event/sacrifice_bad)

		ashies.sacrifices_made++

/**
 * Proc that will spawn the egg that will revive the ashwalker
 * This is also the Skyrat replacement for /proc/remake_walker
 */
/obj/structure/lavaland/ash_walker/proc/revive_ashwalker(mob/living/carbon/human/revived_ashwalker)
	var/obj/structure/reviving_ashwalker_egg/spawned_egg = new(get_step(loc, pick(GLOB.alldirs)))
	revived_ashwalker.forceMove(spawned_egg)
	to_chat(revived_ashwalker, span_warning("The tendril has decided to be merciful and revive you within a minute, have patience."))

/obj/structure/reviving_ashwalker_egg
	name = "occupied ashwalker egg"
	desc = "Past the typical appearance of the yellow, man-sized egg, there seems to be a body floating within!"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | FREEZE_PROOF
	max_integrity = 80

/obj/structure/reviving_ashwalker_egg/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(do_revive)), 30 SECONDS)

/**
 * Proc that will fully revive the living content inside and then destroy itself
 */
/obj/structure/reviving_ashwalker_egg/proc/do_revive()
	var/mob/living/living_inside = locate() in contents

	if(!living_inside)
		qdel(src)
		return

	living_inside.revive(ADMIN_HEAL_ALL)
	living_inside.forceMove(get_turf(src))
	living_inside.mind.grab_ghost()
	living_inside.balloon_alert_to_viewers("[living_inside] breaks out of [src]!")
	qdel(src)

#undef REQUIRED_OBSERVERS
#undef MEGAFAUNA_MEAT_AMOUNT

/datum/component/simple_farm
	///whether we limit the amount of plants you can have per turf
	var/one_per_turf = TRUE
	///the reference to the movable parent the component is attached to
	var/atom/atom_parent
	///the amount of pixels shifted (x,y)
	var/list/pixel_shift = 0

/datum/component/simple_farm/Initialize(set_plant = FALSE, set_turf_limit = TRUE, list/set_shift = list(0, 0))
	//we really need to check if its movable
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	atom_parent = parent
	//important to allow people to just straight up set allowing to plant
	one_per_turf = set_turf_limit
	pixel_shift = set_shift
	//now lets register the signals
	RegisterSignal(atom_parent, COMSIG_ATOM_ATTACKBY, PROC_REF(check_attack))
	RegisterSignal(atom_parent, COMSIG_ATOM_EXAMINE, PROC_REF(check_examine))
	RegisterSignal(atom_parent, COMSIG_QDELETING, PROC_REF(delete_farm))

/datum/component/simple_farm/Destroy(force, silent)
	//lets not hard del
	UnregisterSignal(atom_parent, list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_EXAMINE, COMSIG_QDELETING))
	atom_parent = null
	return ..()

/**
 * check_attack is meant to listen for the COMSIG_ATOM_ATTACKBY signal, where it essentially functions like the attackby proc
 */
/datum/component/simple_farm/proc/check_attack(datum/source, obj/item/attacking_item, mob/user)
	SIGNAL_HANDLER

	//if its a seed, lets try to plant
	if(istype(attacking_item, /obj/item/seeds))
		var/obj/structure/simple_farm/locate_farm = locate() in get_turf(atom_parent)

		if(one_per_turf && locate_farm)
			atom_parent.balloon_alert_to_viewers("cannot plant more seeds here!")
			return

		locate_farm = new(get_turf(atom_parent))
		user.mind.adjust_experience(/datum/skill/primitive, 5)
		locate_farm.pixel_x = pixel_shift[1]
		locate_farm.pixel_y = pixel_shift[2]
		locate_farm.layer = atom_parent.layer + 0.1
		if(ismovable(atom_parent))
			var/atom/movable/movable_parent = atom_parent
			locate_farm.glide_size = movable_parent.glide_size
		attacking_item.forceMove(locate_farm)
		locate_farm.planted_seed = attacking_item
		locate_farm.attached_atom = atom_parent
		atom_parent.balloon_alert_to_viewers("seed has been planted!")
		locate_farm.update_appearance()
		locate_farm.late_setup()

/**
 * check_examine is meant to listen for the COMSIG_ATOM_EXAMINE signal, where it will put additional information in the examine
 */
/datum/component/simple_farm/proc/check_examine(datum/source, mob/user, list/examine_list)
	examine_list += span_notice("<br>You are able to plant seeds here!")

/**
 * delete_farm is meant to be called when the parent of this component has been deleted-- thus deleting the ability to grow the simple farm
 * it will delete the farm that can be found on the turf of the parent of this component
 */
/datum/component/simple_farm/proc/delete_farm()
	SIGNAL_HANDLER

	var/obj/structure/simple_farm/locate_farm = locate() in get_turf(atom_parent)
	if(locate_farm)
		qdel(locate_farm)

/obj/structure/simple_farm
	name = "simple farm"
	desc = "A small little plant that has adapted to the surrounding environment."
	//it needs to be able to be walked through
	density = FALSE
	//it should not be pulled by anything
	anchored = TRUE
	///the atom the farm is attached to
	var/atom/attached_atom
	///the seed that is held within
	var/obj/item/seeds/planted_seed
	///the max amount harvested from the plants
	var/max_harvest = 3
	///the cooldown amount between each harvest
	var/harvest_cooldown = 1 MINUTES
	///the extra potency applied to the seed
	var/bonus_potency = 0
	//the cooldown between each harvest
	COOLDOWN_DECLARE(harvest_timer)

/obj/structure/simple_farm/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	COOLDOWN_START(src, harvest_timer, harvest_cooldown)

/obj/structure/simple_farm/Destroy()
	STOP_PROCESSING(SSobj, src)

	if(planted_seed)
		planted_seed.forceMove(get_turf(src))
		planted_seed = null

	if(attached_atom)
		if(ismovable(attached_atom))
			UnregisterSignal(attached_atom, COMSIG_MOVABLE_MOVED)

		attached_atom = null

	return ..()

/obj/structure/simple_farm/examine(mob/user)
	. = ..()
	. += span_notice("<br>[src] will be ready for harvest in [DisplayTimeText(COOLDOWN_TIMELEFT(src, harvest_timer))]")
	if(max_harvest < 6)
		. += span_notice("<br>You can use sinew or worm fertilizer to lower the time between each harvest!")
	if(harvest_cooldown > 30 SECONDS)
		. += span_notice("You can use goliath hides or worm fertilizer to increase the amount dropped per harvest!")
	if(bonus_potency < 50)
		. += span_notice("You can use worm fertilizer to increase the potency of dropped crops!")

/obj/structure/simple_farm/process(seconds_per_tick)
	update_appearance()

/obj/structure/simple_farm/update_appearance(updates)
	if(!planted_seed)
		return

	icon = planted_seed.growing_icon

	if(COOLDOWN_FINISHED(src, harvest_timer))
		if(planted_seed.icon_harvest)
			icon_state = planted_seed.icon_harvest

		else
			icon_state = "[planted_seed.icon_grow][planted_seed.growthstages]"

		name = lowertext(planted_seed.plantname)

	else
		icon_state = "[planted_seed.icon_grow]1"
		name = lowertext("harvested [planted_seed.plantname]")

	return ..()

/obj/structure/simple_farm/attack_hand(mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, harvest_timer))
		balloon_alert(user, "plant not ready for harvest!")
		return

	COOLDOWN_START(src, harvest_timer, harvest_cooldown)
	create_harvest()
	user.mind.adjust_experience(/datum/skill/primitive, 5)
	update_appearance()
	return ..()

/obj/structure/simple_farm/attackby(obj/item/attacking_item, mob/user, params)
	//if its a shovel or knife, dismantle
	if(attacking_item.tool_behaviour == TOOL_SHOVEL || attacking_item.tool_behaviour == TOOL_KNIFE)
		var/turf/src_turf = get_turf(src)
		src_turf.balloon_alert_to_viewers("the plant crumbles!")
		Destroy()
		return

	//if its sinew, lower the cooldown
	else if(istype(attacking_item, /obj/item/stack/sheet/sinew))
		var/obj/item/stack/sheet/sinew/use_item = attacking_item

		if(!use_item.use(1))
			return

		decrease_cooldown(user)
		user.mind.adjust_experience(/datum/skill/primitive, 5)
		return

	//if its goliath hide, increase the amount dropped
	else if(istype(attacking_item, /obj/item/stack/sheet/animalhide/goliath_hide))
		var/obj/item/stack/sheet/animalhide/goliath_hide/use_item = attacking_item

		if(!use_item.use(1))
			return

		increase_yield(user)
		user.mind.adjust_experience(/datum/skill/primitive, 5)
		return

	else if(istype(attacking_item, /obj/item/stack/worm_fertilizer))

		var/obj/item/stack/attacking_stack = attacking_item

		if(!allow_yield_increase() && !allow_decrease_cooldown())
			balloon_alert(user, "plant is already fully upgraded")
			return

		if(!attacking_stack.use(1))
			balloon_alert(user, "unable to use [attacking_item]")
			return

		if(!decrease_cooldown(user, silent = TRUE) && !increase_yield(user, silent = TRUE) && !increase_potency(user, silent = TRUE))
			balloon_alert(user, "plant is already fully upgraded")

		else
			balloon_alert(user, "plant was upgraded")
			user.mind.adjust_experience(/datum/skill/primitive, 5)

		return

	else if(istype(attacking_item, /obj/item/storage/bag/plants))
		if(!COOLDOWN_FINISHED(src, harvest_timer))
			return

		COOLDOWN_START(src, harvest_timer, harvest_cooldown)
		create_harvest(attacking_item, user)
		user.mind.adjust_experience(/datum/skill/primitive, 5)
		update_appearance()
		return

	return ..()

/**
 * a proc that will check if we can increase the yield-- without increasing it
 */
/obj/structure/simple_farm/proc/allow_yield_increase()
	if(max_harvest >= 6)
		return FALSE

	return TRUE

/**
 * a proc that will increase the amount of items the crop could produce (at a maximum of 6, from base of 3)
 */
/obj/structure/simple_farm/proc/increase_yield(mob/user, var/silent = FALSE)
	if(!allow_yield_increase())
		if(!silent)
			balloon_alert(user, "plant is at maximum yield")

		return FALSE

	max_harvest++

	if(!silent)
		balloon_alert_to_viewers("plant will have increased yield")

	return TRUE

/**
 * a proc that will check if we can decrease the time-- without increasing it
 */
/obj/structure/simple_farm/proc/allow_decrease_cooldown()
	if(harvest_cooldown <= 30 SECONDS)
		return FALSE

	return TRUE

/**
 * a proc that will decrease the amount of time it takes to be ready for harvest (at a maximum of 30 seconds, from a base of 1 minute)
 */
/obj/structure/simple_farm/proc/decrease_cooldown(mob/user, var/silent = FALSE)
	if(!allow_decrease_cooldown())
		if(!silent)
			balloon_alert(user, "already at maximum growth speed!")

		return FALSE

	harvest_cooldown -= 10 SECONDS

	if(!silent)
		balloon_alert_to_viewers("plant will grow faster")

	return TRUE

/**
 * a proc that will increase the potency the crop grows at
 */
/obj/structure/simple_farm/proc/increase_potency(mob/user, var/silent = FALSE)
	if(bonus_potency >= 50)
		if(!silent)
			balloon_alert(user, "plant is at maximum potency")

		return FALSE

	bonus_potency += 10

	if(!silent)
		balloon_alert_to_viewers("plant will have increased potency")

	return TRUE

/**
 * used during the component so that it can move when its attached atom moves
 */
/obj/structure/simple_farm/proc/late_setup()
	if(!ismovable(attached_atom))
		return
	RegisterSignal(attached_atom, COMSIG_MOVABLE_MOVED, PROC_REF(move_plant))

/**
 * a simple proc to forcemove the plant on top of the movable atom its attached to
 */
/obj/structure/simple_farm/proc/move_plant()
	forceMove(get_turf(attached_atom))

/**
 * will create a harvest of the seeds product, with a chance to create a mutated version
 */
/obj/structure/simple_farm/proc/create_harvest(var/obj/item/storage/bag/plants/plant_bag, var/mob/user)
	if(!planted_seed)
		return

	for(var/i in 1 to rand(1, max_harvest))
		var/obj/item/seeds/seed
		if(prob(15) && length(planted_seed.mutatelist))
			var/type = pick(planted_seed.mutatelist)
			seed = new type
			balloon_alert_to_viewers("something special drops!")
		else
			seed = new planted_seed.type(null)

		seed.potency = 50 + bonus_potency

		var/harvest_type = seed.product || seed.type
		var/harvest = new harvest_type(get_turf(src), seed)
		plant_bag?.atom_storage?.attempt_insert(harvest, user, TRUE)

/turf/open/misc/asteroid/basalt/getDug()
	. = ..()
	AddComponent(/datum/component/simple_farm)

/turf/open/misc/asteroid/basalt/refill_dug()
	. = ..()
	qdel(GetComponent(/datum/component/simple_farm))

/turf/open/misc/asteroid/snow/getDug()
	. = ..()
	AddComponent(/datum/component/simple_farm)

/turf/open/misc/asteroid/snow/refill_dug()
	. = ..()
	qdel(GetComponent(/datum/component/simple_farm))

/obj/machinery/vending/ashclothingvendor
	name = "\improper Ashland Clothing Storage"
	desc = "A large container, filled with various clothes for the Ash Walkers."
	product_ads = "Praise the Necropolis"
	icon = 'monkestation/code/modules/blueshift/icons/vending.dmi'
	icon_state = "ashclothvendor"
	icon_deny = "necrocrate"

	products = list( //Relatively normal to have, I GUESS
		/obj/item/clothing/under/costume/gladiator/ash_walker/tribal = 15,
		/obj/item/clothing/under/costume/gladiator/ash_walker/chestwrap = 15,
		/obj/item/clothing/under/costume/gladiator/ash_walker/robe = 15,
		/obj/item/clothing/under/costume/gladiator/ash_walker/shaman = 15,
		/obj/item/clothing/under/costume/gladiator/ash_walker/chiefrags = 15,
		/obj/item/clothing/under/costume/gladiator/ash_walker/yellow = 15,
		/obj/item/clothing/under/costume/gladiator/ash_walker/caesar_clothes = 15,
		/obj/item/clothing/under/costume/gladiator/ash_walker/legskirt_d = 15,
		/obj/item/clothing/suit/ashwalkermantle = 12,
		/obj/item/clothing/suit/ashwalkermantle/cape = 12,
		/obj/item/clothing/shoes/jackboots/ashwalker = 12,
		/obj/item/clothing/shoes/jackboots/ashwalker/legate = 12,
		/obj/item/clothing/shoes/wraps/ashwalker/mundanewraps = 15,
		/obj/item/clothing/shoes/wraps/ashwalker = 10,
		/obj/item/clothing/shoes/wraps/ashwalker/tribalwraps = 2,,
		/obj/item/clothing/head/shamanash = 3,
		/obj/item/clothing/neck/cloak/tribalmantle = 2,
		/obj/item/clothing/gloves/military/claw = 5,
		/obj/item/clothing/gloves/military/ashwalk = 10,
	)

/obj/machinery/vending/ashclothingvendor/Initialize(mapload)
	. = ..()
	onstation = FALSE

/obj/structure/antfarm
	name = "ant farm"
	desc = "Though it may look natural, this was not made by ants."
	icon = 'monkestation/code/modules/blueshift/icons/structures.dmi'
	icon_state = "anthill"
	density = TRUE
	anchored = TRUE
	/// If the farm is occupied by ants
	var/has_ants = FALSE
	/// the chance for the farm to get ants
	var/ant_chance = 0
	/// the list of ore-y stuff that ants can drag up from deep within their nest
	var/list/ore_list = list(
		/obj/item/stack/ore/iron = 20,
		/obj/item/stack/ore/glass/basalt = 20,
		/obj/item/stack/ore/plasma = 14,
		/obj/item/stack/ore/silver = 8,
		/obj/item/stack/stone = 8,
		/obj/item/stack/sheet/mineral/coal = 8,
		/obj/item/stack/ore/titanium = 8,
		/obj/item/stack/ore/uranium = 3,
		/obj/item/stack/ore/gold = 3,
	)
	// The cooldown between each worm "breeding"
	COOLDOWN_DECLARE(ant_timer)

/obj/structure/antfarm/Initialize(mapload)
	. = ..()
	var/turf/src_turf = get_turf(src)
	if(!src_turf.GetComponent(/datum/component/simple_farm))
		src_turf.balloon_alert_to_viewers("must be on farmable surface")
		return INITIALIZE_HINT_QDEL

	for(var/obj/structure/antfarm/found_farm in range(2, get_turf(src)))
		if(found_farm == src)
			continue

		src_turf.balloon_alert_to_viewers("too close to another farm")
		return INITIALIZE_HINT_QDEL

	START_PROCESSING(SSobj, src)
	COOLDOWN_START(src, ant_timer, 30 SECONDS)

/obj/structure/antfarm/Destroy()
	STOP_PROCESSING(SSobj, src)
	new /obj/item/stack/ore/glass/ten(get_turf(src))
	return ..()

/obj/structure/antfarm/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, ant_timer))
		return

	COOLDOWN_START(src, ant_timer, 30 SECONDS)

	if(!has_ants)
		if(prob(ant_chance))
			balloon_alert_to_viewers("ants have appeared!")
			has_ants = TRUE

		return

	var/spawned_ore = pick_weight(ore_list)
	new spawned_ore(get_turf(src))

/obj/structure/antfarm/examine(mob/user)
	. = ..()
	. += span_notice("<br>There are currently [has_ants ? "" : "no "]ants in the farm.")
	. += span_notice("To add ants, feed the farm some food.")

/obj/structure/antfarm/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/food))
		qdel(attacking_item)
		balloon_alert(user, "food has been placed")
		user.mind.adjust_experience(/datum/skill/primitive, 5)
		ant_chance++
		if(prob(user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_PROBS_MODIFIER)))
			ant_chance++
		return

	if(istype(attacking_item, /obj/item/storage/bag/plants))
		balloon_alert(user, "feeding the ants")
		var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_SPEED_MODIFIER)
		for(var/obj/item/food/selected_food in attacking_item.contents)
			if(!do_after(user, 1 SECONDS * skill_modifier, src))
				return

			qdel(selected_food)
			user.mind.adjust_experience(/datum/skill/primitive, 5)
			ant_chance++
			if(prob(user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_PROBS_MODIFIER)))
				ant_chance++

		return

	return ..()

/obj/item/stack/ore/glass/ten
	amount = 10

/obj/item/smithed_part/forged_plate
	name = "plate"
	desc = "A plate, best used in combination with multiple plates."
	icon_state = "plate"
	icon = 'monkestation/code/modules/blueshift/icons/forge_items.dmi'
