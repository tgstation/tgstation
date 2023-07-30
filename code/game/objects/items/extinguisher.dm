/obj/item/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'icons/obj/tools.dmi'
	icon_state = "fire_extinguisher0"
	worn_icon_state = "fire_extinguisher"
	inhand_icon_state = "fire_extinguisher"
	hitsound = 'sound/weapons/smash.ogg'
	flags_1 = CONDUCT_1
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 7
	force = 10
	demolition_mod = 1.25
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.9)
	attack_verb_continuous = list("slams", "whacks", "bashes", "thunks", "batters", "bludgeons", "thrashes")
	attack_verb_simple = list("slam", "whack", "bash", "thunk", "batter", "bludgeon", "thrash")
	dog_fashion = /datum/dog_fashion/back
	resistance_flags = FIRE_PROOF
	/// The max amount of water this extinguisher can hold.
	var/max_water = 50
	/// Does the welder extinguisher start with water.
	var/starting_water = TRUE
	/// Cooldown between uses.
	var/last_use = 1
	/// Chem we use for our extinguishing.
	var/chem = /datum/reagent/water
	/// Can we actually fire currently?
	var/safety = TRUE
	/// Can we refill this at a water tank?
	var/refilling = FALSE
	/// What tank we need to refill this.
	var/tanktype = /obj/structure/reagent_dispensers/watertank
	/// something that should be replaced with base_icon_state
	var/sprite_name = "fire_extinguisher"
	/// Maximum distance launched water will travel.
	var/power = 5
	/// By default, turfs picked from a spray are random, set to TRUE to make it always have at least one water effect per row.
	var/precision = FALSE
	/// Sets the cooling_temperature of the water reagent datum inside of the extinguisher when it is refilled.
	var/cooling_power = 2
	/// Icon state when inside a tank holder.
	var/tank_holder_icon_state = "holder_extinguisher"

/obj/item/extinguisher/empty
	starting_water = FALSE

/obj/item/extinguisher/mini
	name = "pocket fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	worn_icon_state = "miniFE"
	inhand_icon_state = "miniFE"
	hitsound = null //it is much lighter, after all.
	flags_1 = null //doesn't CONDUCT_1
	throwforce = 2
	w_class = WEIGHT_CLASS_SMALL
	force = 3
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT* 0.5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.4)
	max_water = 30
	sprite_name = "miniFE"
	dog_fashion = null

/obj/item/extinguisher/mini/empty
	starting_water = FALSE

/obj/item/extinguisher/crafted
	name = "Improvised cooling spray"
	desc = "Spraycan turned coolant dipsenser. Can be sprayed on containers to cool them. Refll using water."
	icon_state = "coolant0"
	worn_icon_state = "miniFE"
	inhand_icon_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	flags_1 = null //doesn't CONDUCT_1
	throwforce = 1
	w_class = WEIGHT_CLASS_SMALL
	force = 3
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.4)
	max_water = 30
	sprite_name = "coolant"
	dog_fashion = null
	cooling_power = 1.5
	power = 3

/obj/item/extinguisher/crafted/attack_self(mob/user)
	safety = !safety
	icon_state = "[sprite_name][!safety]"
	to_chat(user, "[safety ? "You remove the straw and put it on the side of the cool canister" : "You insert the straw, readying it for use"].")

/obj/item/extinguisher/proc/refill()
	if(!chem)
		return
	create_reagents(max_water, AMOUNT_VISIBLE)
	reagents.add_reagent(chem, max_water)

/obj/item/extinguisher/Initialize(mapload)
	. = ..()
	if(tank_holder_icon_state)
		AddComponent(/datum/component/container_item/tank_holder, tank_holder_icon_state)
	if(starting_water)
		refill()
	else if(chem)
		create_reagents(max_water, AMOUNT_VISIBLE)

/obj/item/extinguisher/advanced
	name = "advanced fire extinguisher"
	desc = "Used to stop thermonuclear fires from spreading inside your engine."
	icon_state = "foam_extinguisher0"
	worn_icon_state = "foam_extinguisher"
	inhand_icon_state = "foam_extinguisher"
	tank_holder_icon_state = "holder_foam_extinguisher"
	dog_fashion = null
	chem = /datum/reagent/firefighting_foam
	tanktype = /obj/structure/reagent_dispensers/foamtank
	sprite_name = "foam_extinguisher"
	precision = TRUE

/obj/item/extinguisher/advanced/empty
	starting_water = FALSE

/obj/item/extinguisher/suicide_act(mob/living/carbon/user)
	if (!safety && (reagents.total_volume >= 1))
		user.visible_message(span_suicide("[user] puts the nozzle to [user.p_their()] mouth. It looks like [user.p_theyre()] trying to extinguish the spark of life!"))
		afterattack(user,user)
		return OXYLOSS
	else if (safety && (reagents.total_volume >= 1))
		user.visible_message(span_warning("[user] puts the nozzle to [user.p_their()] mouth... The safety's still on!"))
		return SHAME
	else
		user.visible_message(span_warning("[user] puts the nozzle to [user.p_their()] mouth... [src] is empty!"))
		return SHAME

/obj/item/extinguisher/attack_self(mob/user)
	safety = !safety
	src.icon_state = "[sprite_name][!safety]"
	balloon_alert(user, "safety [safety ? "on" : "off"]")
	return

/obj/item/extinguisher/attack(mob/M, mob/living/user)
	if(!user.combat_mode && !safety) //If we're on help intent and going to spray people, don't bash them.
		return FALSE
	else
		return ..()

/obj/item/extinguisher/attack_atom(obj/O, mob/living/user, params)
	if(AttemptRefill(O, user))
		refilling = TRUE
		return FALSE
	else
		return ..()

/obj/item/extinguisher/examine(mob/user)
	. = ..()
	. += "The safety is [safety ? "on" : "off"]."

	if(reagents.total_volume)
		. += span_notice("Alt-click to empty it.")

/obj/item/extinguisher/proc/AttemptRefill(atom/target, mob/user)
	if(istype(target, tanktype) && target.Adjacent(user))
		if(reagents.total_volume == reagents.maximum_volume)
			balloon_alert(user, "already full!")
			return TRUE
		var/obj/structure/reagent_dispensers/W = target //will it work?
		var/transferred = W.reagents.trans_to(src, max_water, transfered_by = user)
		if(transferred > 0)
			to_chat(user, span_notice("\The [src] has been refilled by [transferred] units."))
			playsound(src.loc, 'sound/effects/refill.ogg', 50, TRUE, -6)
			for(var/datum/reagent/water/R in reagents.reagent_list)
				R.cooling_temperature = cooling_power
		else
			to_chat(user, span_warning("\The [W] is empty!"))

		return TRUE
	else
		return FALSE

/obj/item/extinguisher/afterattack(atom/target, mob/user , flag)
	. = ..()
	// Make it so the extinguisher doesn't spray yourself when you click your inventory items
	if (target.loc == user)
		return

	. |= AFTERATTACK_PROCESSED_ITEM

	if(refilling)
		refilling = FALSE
		return .
	if (!safety)


		if (src.reagents.total_volume < 1)
			balloon_alert(user, "it's empty!")
			return .

		if (world.time < src.last_use + 12)
			return .

		src.last_use = world.time

		playsound(src.loc, 'sound/effects/extinguish.ogg', 75, TRUE, -3)

		var/direction = get_dir(src,target)

		if(user.buckled && isobj(user.buckled) && !user.buckled.anchored)
			var/obj/B = user.buckled
			var/movementdirection = REVERSE_DIR(direction)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/extinguisher, move_chair), B, movementdirection), 1)
		else
			user.newtonian_move(REVERSE_DIR(direction))

		//Get all the turfs that can be shot at
		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))
		var/list/the_targets = list(T,T1,T2)
		if(precision)
			var/turf/T3 = get_step(T1, turn(direction, 90))
			var/turf/T4 = get_step(T2,turn(direction, -90))
			the_targets.Add(T3,T4)

		var/list/water_particles = list()
		for(var/a in 1 to 5)
			var/obj/effect/particle_effect/water/extinguisher/water = new /obj/effect/particle_effect/water/extinguisher(get_turf(src))
			var/my_target = pick(the_targets)
			water_particles[water] = my_target
			// If precise, remove turf from targets so it won't be picked more than once
			if(precision)
				the_targets -= my_target
			var/datum/reagents/water_reagents = new /datum/reagents(5)
			water.reagents = water_reagents
			water_reagents.my_atom = water
			reagents.trans_to(water, 1, transfered_by = user)

		//Make em move dat ass, hun
		move_particles(water_particles)

	return .

//Particle movement loop
/obj/item/extinguisher/proc/move_particles(list/particles)
	var/delay = 2
	// Second loop: Get all the water particles and make them move to their target
	for(var/obj/effect/particle_effect/water/extinguisher/water as anything in particles)
		water.move_at(particles[water], delay, power)

//Chair movement loop
/obj/item/extinguisher/proc/move_chair(obj/buckled_object, movementdirection)
	var/datum/move_loop/loop = SSmove_manager.move(buckled_object, movementdirection, 1, timeout = 9, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	//This means the chair slowing down is dependant on the extinguisher existing, which is weird
	//Couldn't figure out a better way though
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(manage_chair_speed))

/obj/item/extinguisher/proc/manage_chair_speed(datum/move_loop/move/source)
	SIGNAL_HANDLER
	switch(source.lifetime)
		if(4 to 5)
			source.delay = 2
		if(1 to 3)
			source.delay = 3

/obj/item/extinguisher/AltClick(mob/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY|NEED_HANDS))
		return
	if(!user.is_holding(src))
		to_chat(user, span_notice("You must be holding the [src] in your hands do this!"))
		return
	EmptyExtinguisher(user)

/obj/item/extinguisher/proc/EmptyExtinguisher(mob/user)
	if(loc == user && reagents.total_volume)
		reagents.clear_reagents()

		var/turf/T = get_turf(loc)
		if(isopenturf(T))
			var/turf/open/theturf = T
			theturf.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)

		user.visible_message(span_notice("[user] empties out \the [src] onto the floor using the release valve."), span_info("You quietly empty out \the [src] using its release valve."))

//firebot assembly
/obj/item/extinguisher/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/bodypart/arm/left/robot) || istype(O, /obj/item/bodypart/arm/right/robot))
		to_chat(user, span_notice("You add [O] to [src]."))
		qdel(O)
		qdel(src)
		user.put_in_hands(new /obj/item/bot_assembly/firebot)
	else
		..()
