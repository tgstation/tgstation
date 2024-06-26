/obj/vehicle/ridden/scooter
	name = "scooter"
	desc = "A fun way to get around."
	icon_state = "scooter"
	are_legs_exposed = TRUE

/obj/vehicle/ridden/scooter/Initialize(mapload)
	. = ..()
	make_ridable()

/obj/vehicle/ridden/scooter/proc/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter)

/obj/vehicle/ridden/scooter/wrench_act(mob/living/user, obj/item/I)
	..()
	to_chat(user, span_notice("You begin to remove the handlebars..."))
	if(!I.use_tool(src, user, 40, volume=50))
		return TRUE
	var/obj/vehicle/ridden/scooter/skateboard/improvised/skater = new(drop_location())
	new /obj/item/stack/rods(drop_location(), 2)
	to_chat(user, span_notice("You remove the handlebars from [src]."))
	if(has_buckled_mobs())
		var/mob/living/carbon/carbons = buckled_mobs[1]
		unbuckle_mob(carbons)
		skater.buckle_mob(carbons)
	qdel(src)
	return TRUE

/obj/vehicle/ridden/scooter/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		if(buckled_mob.num_legs > 0)
			buckled_mob.pixel_y = 5
		else
			buckled_mob.pixel_y = -4

/obj/vehicle/ridden/scooter/skateboard
	name = "skateboard"
	desc = "An old, battered skateboard. It's still rideable, but probably unsafe."
	icon_state = "skateboard"
	density = FALSE
	///Sparks datum for when we grind on tables
	var/datum/effect_system/spark_spread/sparks
	///Whether the board is currently grinding
	var/grinding = FALSE
	///Stores the time of the last crash plus a short cooldown, affects availability and outcome of certain actions
	var/next_crash
	///The handheld item counterpart for the board
	var/board_item_type = /obj/item/melee/skateboard
	///Stamina drain multiplier
	var/instability = 10
	///If true, riding the skateboard with walk intent on will prevent crashing.
	var/can_slow_down = TRUE

/obj/vehicle/ridden/scooter/skateboard/Initialize(mapload)
	. = ..()
	sparks = new
	sparks.set_up(1, 0, src)
	sparks.attach(src)

/obj/vehicle/ridden/scooter/skateboard/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter/skateboard)

/obj/vehicle/ridden/scooter/skateboard/Destroy()
	if(sparks)
		QDEL_NULL(sparks)
	return ..()

/obj/vehicle/ridden/scooter/skateboard/relaymove(mob/living/user, direction)
	if (grinding || world.time < next_crash)
		return FALSE
	return ..()

/obj/vehicle/ridden/scooter/skateboard/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/ridden/scooter/skateboard/ollie, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/ridden/scooter/skateboard/kickflip, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/ridden/scooter/skateboard/post_buckle_mob(mob/living/M)//allows skateboards to be non-dense but still allows 2 skateboarders to collide with each other
	set_density(TRUE)
	return ..()

/obj/vehicle/ridden/scooter/skateboard/post_unbuckle_mob(mob/living/M)
	if(!has_buckled_mobs())
		set_density(FALSE)
	return ..()

/obj/vehicle/ridden/scooter/skateboard/Bump(atom/bumped_thing)
	. = ..()
	if(!bumped_thing.density || !has_buckled_mobs() || world.time < next_crash)
		return
	var/mob/living/rider = buckled_mobs[1]
	if(rider.move_intent == MOVE_INTENT_WALK && can_slow_down) //Going slow prevents you from crashing.
		return

	next_crash = world.time + 10
	rider.adjustStaminaLoss(instability*6)
	playsound(src, 'sound/effects/bang.ogg', 40, TRUE)
	if(!iscarbon(rider) || rider.getStaminaLoss() >= 100 || grinding || iscarbon(bumped_thing))
		var/atom/throw_target = get_edge_target_turf(rider, pick(GLOB.cardinals))
		unbuckle_mob(rider)
		if((istype(bumped_thing, /obj/machinery/disposal/bin)))
			rider.Paralyze(8 SECONDS)
			rider.forceMove(bumped_thing)
			forceMove(bumped_thing)
			visible_message(span_danger("[src] crashes into [bumped_thing], and gets dumped straight into it!"))
			return
		rider.throw_at(throw_target, 3, 2)
		var/head_slot = rider.get_item_by_slot(ITEM_SLOT_HEAD)
		if(!head_slot || !(istype(head_slot,/obj/item/clothing/head/helmet) || istype(head_slot,/obj/item/clothing/head/utility/hardhat)))
			rider.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
			rider.updatehealth()
		visible_message(span_danger("[src] crashes into [bumped_thing], sending [rider] flying!"))
		rider.Paralyze(8 SECONDS)
		if(iscarbon(bumped_thing))
			var/mob/living/carbon/victim = bumped_thing
			var/grinding_mulitipler = 1
			if(grinding)
				grinding_mulitipler = 2
			victim.Knockdown(4 * grinding_mulitipler SECONDS)
	else
		var/backdir = REVERSE_DIR(dir)
		step(src, backdir)
		rider.spin(4, 1)

///Moves the vehicle forward and if it lands on a table, repeats
/obj/vehicle/ridden/scooter/skateboard/proc/grind()
	step(src, dir)
	if(!has_buckled_mobs() || !(locate(/obj/structure/table) in loc.contents) && !(locate(/obj/structure/fluff/tram_rail) in loc.contents))
		obj_flags = CAN_BE_HIT
		grinding = FALSE
		icon_state = "[initial(icon_state)]"
		return

	var/mob/living/skater = buckled_mobs[1]
	skater.adjustStaminaLoss(instability*0.3)
	if(skater.getStaminaLoss() >= 100)
		obj_flags = CAN_BE_HIT
		playsound(src, 'sound/effects/bang.ogg', 20, TRUE)
		unbuckle_mob(skater)
		var/atom/throw_target = get_edge_target_turf(src, pick(GLOB.cardinals))
		skater.throw_at(throw_target, 2, 2)
		visible_message(span_danger("[skater] loses [skater.p_their()] footing and slams on the ground!"))
		skater.Paralyze(4 SECONDS)
		grinding = FALSE
		icon_state = "[initial(icon_state)]"
		return
	playsound(src, 'sound/vehicles/skateboard_roll.ogg', 50, TRUE)
	var/turf/location = get_turf(src)

	if(location)
		if(prob(25))
			location.hotspot_expose(1000,1000)
			sparks.start() //the most radical way to start plasma fires
	for(var/mob/living/carbon/victim in location)
		if(victim.body_position == LYING_DOWN)
			playsound(location, 'sound/items/trayhit2.ogg', 40)
			victim.apply_damage(damage = 25, damagetype = BRUTE, def_zone = victim.get_random_valid_zone(even_weights = TRUE), wound_bonus = 20)
			victim.Paralyze(1.5 SECONDS)
			skater.adjustStaminaLoss(instability)
			victim.visible_message(span_danger("[victim] straight up gets grinded into the ground by [skater]'s [src]! Radical!"))
	addtimer(CALLBACK(src, PROC_REF(grind)), 0.1 SECONDS)

/obj/vehicle/ridden/scooter/skateboard/mouse_drop_dragged(atom/over_object, mob/user)
	var/mob/living/carbon/skater = user
	if(!istype(skater))
		return
	if (over_object == skater)
		pick_up_board(skater)

/obj/vehicle/ridden/scooter/skateboard/proc/pick_up_board(mob/living/carbon/skater)
	if (skater.incapacitated() || !Adjacent(skater))
		return
	if(has_buckled_mobs())
		to_chat(skater, span_warning("You can't lift this up when somebody's on it."))
		return
	skater.put_in_hands(new board_item_type(get_turf(skater)))
	qdel(src)

/obj/vehicle/ridden/scooter/skateboard/pro
	name = "skateboard"
	desc = "An EightO brand professional skateboard. Looks a lot more stable than the average board."
	icon_state = "skateboard2"
	board_item_type = /obj/item/melee/skateboard/pro
	instability = 6

/obj/vehicle/ridden/scooter/skateboard/pro/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter/skateboard/pro)

/obj/vehicle/ridden/scooter/skateboard/hoverboard
	name = "hoverboard"
	desc = "A blast from the past, so retro!"
	board_item_type = /obj/item/melee/skateboard/hoverboard
	instability = 3
	icon_state = "hoverboard_red"

/obj/vehicle/ridden/scooter/skateboard/hoverboard/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter/skateboard/hover)

/obj/vehicle/ridden/scooter/skateboard/hoverboard/can_z_move(direction, turf/start, turf/destination, z_move_flags = ZMOVE_FLIGHT_FLAGS, mob/living/rider)
	. = ..()
	if(!.)
		return
	if(rider && (z_move_flags & ZMOVE_CAN_FLY_CHECKS) && direction == UP)
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(rider, span_warning("[src] [p_are()] not powerful enough to fly upwards."))
		return FALSE

/obj/vehicle/ridden/scooter/skateboard/hoverboard/admin
	name = "\improper Board Of Directors"
	desc = "The engineering complexity of a spaceship concentrated inside of a board. Just as expensive, too."
	board_item_type = /obj/item/melee/skateboard/hoverboard/admin
	instability = 0
	icon_state = "hoverboard_nt"

/obj/vehicle/ridden/scooter/skateboard/improvised
	name = "improvised skateboard"
	desc = "An unfinished scooter which can only barely be called a skateboard. It's still rideable, but probably unsafe. Looks like you'll need to add a few rods to make handlebars."
	board_item_type = /obj/item/melee/skateboard/improvised
	instability = 12

//CONSTRUCTION
/obj/item/scooter_frame
	name = "scooter frame"
	desc = "A metal frame for building a scooter. Looks like you'll need to add some iron to make wheels."
	icon = 'icons/mob/rideables/vehicles.dmi'
	icon_state = "scooter_frame"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/scooter_frame/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/stack/sheet/iron))
		return ..()
	if(!I.tool_start_check(user, amount=5))
		return
	to_chat(user, span_notice("You begin to add wheels to [src]."))
	if(!I.use_tool(src, user, 80, volume=50, amount=5))
		return
	to_chat(user, span_notice("You finish making wheels for [src]."))
	new /obj/vehicle/ridden/scooter/skateboard/improvised(user.loc)
	qdel(src)

/obj/item/scooter_frame/wrench_act(mob/living/user, obj/item/I)
	..()
	to_chat(user, span_notice("You deconstruct [src]."))
	new /obj/item/stack/rods(drop_location(), 10)
	I.play_tool_sound(src)
	qdel(src)
	return TRUE

/obj/vehicle/ridden/scooter/skateboard/wrench_act(mob/living/user, obj/item/I)
	return

/obj/vehicle/ridden/scooter/skateboard/improvised/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/stack/rods))
		return ..()
	if(!I.tool_start_check(user, amount=2))
		return
	to_chat(user, span_notice("You begin making handlebars for [src]."))
	if(!I.use_tool(src, user, 25, volume=50, amount=2))
		return
	to_chat(user, span_notice("You add the rods to [src], creating handlebars."))
	var/obj/vehicle/ridden/scooter/skaterskoot = new(loc)
	if(has_buckled_mobs())
		var/mob/living/carbon/skaterboy = buckled_mobs[1]
		unbuckle_mob(skaterboy)
		skaterskoot.buckle_mob(skaterboy)
	qdel(src)

/obj/vehicle/ridden/scooter/skateboard/improvised/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	to_chat(user, span_notice("You begin to deconstruct and remove the wheels on [src]..."))
	if(!I.use_tool(src, user, 20, volume=50))
		return
	to_chat(user, span_notice("You deconstruct the wheels on [src]."))
	new /obj/item/stack/sheet/iron(drop_location(), 5)
	new /obj/item/scooter_frame(drop_location())
	if(has_buckled_mobs())
		var/mob/living/carbon/skatergirl = buckled_mobs[1]
		unbuckle_mob(skatergirl)
	qdel(src)
	return TRUE

//Wheelys
/obj/vehicle/ridden/scooter/skateboard/wheelys
	name = "Wheely-Heels"
	desc = "Uses patented retractable wheel technology. Never sacrifice speed for style - not that this provides much of either."
	icon_state = null
	density = FALSE
	instability = 12
	///Stores the shoes associated with the vehicle
	var/obj/item/clothing/shoes/wheelys/shoes = null
	///Name of the wheels, for visible messages
	var/wheel_name = "wheels"
	///Component typepath to attach in [/obj/vehicle/ridden/scooter/skateboard/wheelys/proc/make_ridable()]
	var/component_type = /datum/component/riding/vehicle/scooter/skateboard/wheelys

/obj/vehicle/ridden/scooter/skateboard/wheelys/make_ridable()
	AddElement(/datum/element/ridable, component_type)

/obj/vehicle/ridden/scooter/skateboard/wheelys/post_unbuckle_mob(mob/living/M)
	if(!has_buckled_mobs())
		to_chat(M, span_notice("You pop the [wheel_name] back into place."))
		moveToNullspace()
		shoes.toggle_wheels(FALSE)
	return ..()

/obj/vehicle/ridden/scooter/skateboard/wheelys/pick_up_board(mob/living/carbon/Skater)
	return

/obj/vehicle/ridden/scooter/skateboard/wheelys/post_buckle_mob(mob/living/M)
	to_chat(M, span_notice("You pop out the [wheel_name]."))
	shoes.toggle_wheels(TRUE)
	return ..()

///Sets the shoes that the vehicle is associated with, called when the shoes are initialized
/obj/vehicle/ridden/scooter/skateboard/wheelys/proc/link_shoes(newshoes)
	shoes = newshoes

/obj/vehicle/ridden/scooter/skateboard/wheelys/rollerskates
	name = "roller skates"
	desc = "An EightO brand pair of roller skates. Vintage, yet functional!"
	instability = 8
	component_type = /datum/component/riding/vehicle/scooter/skateboard/wheelys/rollerskates

/obj/vehicle/ridden/scooter/skateboard/wheelys/skishoes
	name = "ski shoes"
	desc = "A pair of shoes equipped with foldable skis! Very handy to move in snowy environments unimpeded."
	instability = 8
	wheel_name = "skis"
	component_type = /datum/component/riding/vehicle/scooter/skateboard/wheelys/skishoes
