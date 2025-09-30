/obj/item/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'icons/obj/tools.dmi'
	icon_state = "fire_extinguisher0"
	worn_icon_state = "fire_extinguisher"
	inhand_icon_state = "fire_extinguisher"
	icon_angle = 90
	hitsound = 'sound/items/weapons/smash.ogg'
	pickup_sound = 'sound/items/handling/gas_tank/gas_tank_pick_up.ogg'
	drop_sound = 'sound/items/handling/gas_tank/gas_tank_drop.ogg'
	obj_flags = CONDUCTS_ELECTRICITY
	throwforce = 13
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 7
	force = 13
	demolition_mod = 1.25
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.9)
	attack_verb_continuous = list("slams", "whacks", "bashes", "thunks", "batters", "bludgeons", "thrashes")
	attack_verb_simple = list("slam", "whack", "bash", "thunk", "batter", "bludgeon", "thrash")
	dog_fashion = /datum/dog_fashion/back
	resistance_flags = FIRE_PROOF
	interaction_flags_click = NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING
	/// The max amount of water this extinguisher can hold.
	var/max_water = 100
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
	var/tanktypes = list(
		/obj/structure/reagent_dispensers/watertank,
		/obj/structure/reagent_dispensers/plumbed,
		/obj/structure/reagent_dispensers/water_cooler,
	)
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
	///The sound a fire extinguisher makes when picked up, dropped if there is liquid inside.
	var/fire_extinguisher_reagent_sloshing_sound = SFX_DEFAULT_LIQUID_SLOSH


/obj/item/extinguisher/Initialize(mapload)
	. = ..()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/ghettojetpack)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

	register_context()

/obj/item/extinguisher/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(held_item != src)
		return
	context[SCREENTIP_CONTEXT_LMB] = "Engage nozzle"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Empty"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/extinguisher/dropped(mob/user, silent)
	. = ..()
	if(fire_extinguisher_reagent_sloshing_sound && reagents.total_volume > 0)
		playsound(src, fire_extinguisher_reagent_sloshing_sound, LIQUID_SLOSHING_SOUND_VOLUME, vary = TRUE, ignore_walls = FALSE)

/obj/item/extinguisher/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if((slot & ITEM_SLOT_HANDS) && fire_extinguisher_reagent_sloshing_sound && reagents.total_volume > 0)
		playsound(src, fire_extinguisher_reagent_sloshing_sound, LIQUID_SLOSHING_SOUND_VOLUME, vary = TRUE, ignore_walls = FALSE)

// A secondary attack letting you wind up the extinguisher for a real wallopping to your targets head
/obj/item/extinguisher/attack_secondary(mob/living/victim, mob/living/user, params)
	// This only makes sense for heavier extinguishers
	if(w_class < WEIGHT_CLASS_BULKY)
		return SECONDARY_ATTACK_CALL_NORMAL

	if(issilicon(user))
		return SECONDARY_ATTACK_CALL_NORMAL

	if(!iscarbon(victim))
		return SECONDARY_ATTACK_CALL_NORMAL

	var/mob/living/carbon/wallopee = victim
	var/obj/item/bodypart/head/head_to_bash = wallopee.get_bodypart(BODY_ZONE_HEAD)

	if(!head_to_bash)
		return SECONDARY_ATTACK_CALL_NORMAL

	var/head_name = head_to_bash.name

	if(fire_extinguisher_reagent_sloshing_sound && reagents.total_volume > 0)
		playsound(src, fire_extinguisher_reagent_sloshing_sound, LIQUID_SLOSHING_SOUND_VOLUME, vary = TRUE, ignore_walls = FALSE)

	log_combat(user, wallopee, "prepared to use a bash attack with a [src] against [wallopee]")

	wallopee.visible_message(span_danger("[user] begins to raise [src] above [wallopee]'s [head_name]."), span_userdanger("[user] begins to raise [src], aiming to cave in your [head_name]!"))

	if(!do_after(user,  2 SECONDS, target = wallopee))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	wallopee.visible_message(span_danger("[user] brings [src] heavily down on [wallopee]'s [head_name]."), span_userdanger("[user] brings [src] heavily down on your [head_name]!"))

	var/min_wound = head_to_bash.get_wound_threshold_of_wound_type(WOUND_BLUNT, WOUND_SEVERITY_SEVERE, return_value_if_no_wound = 30, wound_source = src)
	var/max_wound = head_to_bash.get_wound_threshold_of_wound_type(WOUND_BLUNT, WOUND_SEVERITY_CRITICAL, return_value_if_no_wound = 50, wound_source = src)

	wallopee.apply_damage(src.force * 3, src.damtype, head_to_bash, wound_bonus = rand(min_wound, max_wound + 10), attacking_item = src)
	wallopee.emote("scream")
	log_combat(user, wallopee, "used a bash attack with a [src] against [wallopee]")
	user.do_attack_animation(wallopee, used_item = src)

	if(fire_extinguisher_reagent_sloshing_sound && reagents.total_volume > 0)
		playsound(src, fire_extinguisher_reagent_sloshing_sound, LIQUID_SLOSHING_SOUND_VOLUME, vary = TRUE, ignore_walls = FALSE)

	playsound(source = src, soundin = src.hitsound, vol = src.get_clamped_volume(), vary = TRUE)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/extinguisher/empty
	starting_water = FALSE

/obj/item/extinguisher/mini
	name = "pocket fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	worn_icon_state = "miniFE"
	inhand_icon_state = "miniFE"
	hitsound = null //it is much lighter, after all.
	obj_flags = NONE //doesn't conduct electricity
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
	desc = "Spraycan turned coolant dispenser. Can be sprayed on containers to cool them. Refill using water."
	icon_state = "coolant0"
	worn_icon_state = "miniFE"
	inhand_icon_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	obj_flags = NONE //doesn't conduct electricity
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
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	chem = /datum/reagent/firefighting_foam
	tanktypes = list(
		/obj/structure/reagent_dispensers/foamtank,
		/obj/structure/reagent_dispensers/plumbed,
	)
	sprite_name = "foam_extinguisher"
	precision = TRUE

/obj/item/extinguisher/advanced/empty
	starting_water = FALSE

/obj/item/extinguisher/suicide_act(mob/living/carbon/user)
	if (!safety && (reagents.total_volume >= 1))
		user.visible_message(span_suicide("[user] puts the nozzle to [user.p_their()] mouth. It looks like [user.p_theyre()] trying to extinguish the spark of life!"))
		interact_with_atom(user, user)
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

/obj/item/extinguisher/attack_atom(obj/attacked_obj, mob/living/user, list/modifiers, list/attack_modifiers)
	if(AttemptRefill(attacked_obj, user))
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
	if(is_type_in_list(target, tanktypes) && target.Adjacent(user))
		if(reagents.total_volume == reagents.maximum_volume)
			balloon_alert(user, "already full!")
			return TRUE
		// Make sure we're refilling with the proper chem.
		if(!(target.reagents.has_reagent(chem, check_subtypes = TRUE)))
			balloon_alert(user, "can't refill with this liquid!")
			return TRUE
		var/obj/structure/reagent_dispensers/W = target //will it work?
		var/transferred = W.reagents.trans_to(src, max_water, transferred_by = user)
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

/obj/item/extinguisher/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(interacting_with.loc == user)
		return NONE
	// Always skip interaction if it's a bag or table (that's not on fire)
	if(!(interacting_with.resistance_flags & ON_FIRE) && HAS_TRAIT(interacting_with, TRAIT_COMBAT_MODE_SKIP_INTERACTION))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/extinguisher/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(refilling)
		refilling = FALSE
		return NONE
	if(safety)
		return NONE

	if (src.reagents.total_volume < 1)
		balloon_alert(user, "it's empty!")
		return .

	if (world.time < src.last_use + 12)
		return .

	src.last_use = world.time

	playsound(src.loc, 'sound/effects/extinguish.ogg', 75, TRUE, -3)

	var/direction = get_dir(src,interacting_with)

	if(user.buckled && isobj(user.buckled) && !user.buckled.anchored)
		var/obj/B = user.buckled
		var/movementdirection = REVERSE_DIR(direction)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/extinguisher, move_chair), B, movementdirection), 0.1 SECONDS)
	else
		user.newtonian_move(dir2angle(REVERSE_DIR(direction)))

	//Get all the turfs that can be shot at
	var/turf/T = get_turf(interacting_with)
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
		reagents.trans_to(water, 1, transferred_by = user)

	//Make em move dat ass, hun
	move_particles(water_particles)
	return ITEM_INTERACT_SKIP_TO_ATTACK // You can smack while spraying

//Particle movement loop
/obj/item/extinguisher/proc/move_particles(list/particles)
	var/delay = 2
	// Second loop: Get all the water particles and make them move to their target
	for(var/obj/effect/particle_effect/water/extinguisher/water as anything in particles)
		water.move_at(particles[water], delay, power)

//Chair movement loop
/obj/item/extinguisher/proc/move_chair(obj/buckled_object, movementdirection)
	var/datum/move_loop/loop = GLOB.move_manager.move(buckled_object, movementdirection, 1, timeout = 9, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
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

/obj/item/extinguisher/click_alt(mob/user)
	if(!user.is_holding(src))
		to_chat(user, span_notice("You must be holding the [src] in your hands do this!"))
		return CLICK_ACTION_BLOCKING
	EmptyExtinguisher(user)
	return CLICK_ACTION_SUCCESS

/obj/item/extinguisher/proc/EmptyExtinguisher(mob/user)
	if(loc == user && reagents.total_volume)
		reagents.expose(user.loc, TOUCH)
		reagents.clear_reagents()
		user.visible_message(span_notice("[user] empties out \the [src] onto the floor using the release valve."), span_info("You quietly empty out \the [src] using its release valve."))

//firebot assembly
/obj/item/extinguisher/attackby(obj/O, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(O, /obj/item/bodypart/arm/left/robot) || istype(O, /obj/item/bodypart/arm/right/robot))
		to_chat(user, span_notice("You add [O] to [src]."))
		qdel(O)
		qdel(src)
		user.put_in_hands(new /obj/item/bot_assembly/firebot)
	else
		..()

/obj/item/extinguisher/anti
	name = "fire extender"
	desc = "A traditional red fire extinguisher. Made in Britain... wait, what?"
	chem = /datum/reagent/fuel
	tanktypes = list(
		/obj/structure/reagent_dispensers/fueltank,
		/obj/structure/reagent_dispensers/plumbed
	)
	cooling_power = 0
