


/*
field_generator power level display
The icon used for the field_generator need to have 6 icon states
named 'Field_Gen +p[num]' where 'num' ranges from 1 to 6

The power level is displayed using overlays. The current displayed power level is stored in 'powerlevel'.
The overlay in use and the powerlevel variable must be kept in sync.  A powerlevel equal to 0 means that
no power level overlay is currently in the overlays list.
-Aygar
*/

#define field_generator_max_power 250

#define FG_OFFLINE 0
#define FG_CHARGING 1
#define FG_ONLINE 2

//field generator construction defines
#define FG_UNSECURED 0
#define FG_SECURED 1
#define FG_WELDED 2

/obj/machinery/field/generator
	name = "field generator"
	desc = "A large thermal battery that projects a high amount of energy when powered."
	icon = 'icons/obj/machines/field_generator.dmi'
	icon_state = "Field_Gen"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	max_integrity = 500
	can_atmos_pass = ATMOS_PASS_YES
	//100% immune to lasers and energy projectiles since it absorbs their energy.
	armor_type = /datum/armor/field_generator
	///Amount of energy stored, used for visual overlays (over 9000?)
	var/power_level = 0
	///Current power mode of the machine, between FG_OFFLINE, FG_CHARGING, FG_ONLINE
	var/active = FG_OFFLINE
	/// Current amount of power
	var/power = 20
	///Current state of the machine, between FG_UNSECURED, FG_SECURED, FG_WELDED
	var/state = FG_UNSECURED
	///Timer between 0 and 3 before the field gets made
	var/warming_up = 0
	///List of every containment fields connected to this generator
	var/list/obj/machinery/field/containment/fields = list()
	///List of every field generators connected to this one
	var/list/obj/machinery/field/generator/connected_gens = list()
	///Check for asynk cleanups for this and the connected gens
	var/clean_up = FALSE
	/// we warm up and cool down instantly
	var/instantenous = FALSE

/datum/armor/field_generator
	melee = 25
	bullet = 10
	laser = 100
	energy = 100
	fire = 50
	acid = 70
	bomb = 100 //Explosive resistance only protects the turfs behind itself from the epicenter.

/obj/machinery/field/generator/update_overlays()
	. = ..()
	if(warming_up)
		. += "+a[warming_up]"
	if(LAZYLEN(fields))
		. += "+on"
	if(power_level)
		. += "+p[power_level]"


/obj/machinery/field/generator/Initialize(mapload)
	AddElement(/datum/element/blocks_explosives)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES)
	RegisterSignal(src, COMSIG_ATOM_SINGULARITY_TRY_MOVE, PROC_REF(block_singularity_if_active))

/obj/machinery/field/generator/anchored/Initialize(mapload)
	. = ..()
	set_anchored(TRUE)

/obj/machinery/field/generator/process()
	if(active == FG_ONLINE)
		calc_power()

/obj/machinery/field/generator/interact(mob/user)
	if(state != FG_WELDED)
		to_chat(user, span_warning("[src] needs to be firmly secured to the floor first!"))
		return
	if(get_dist(src, user) > 1)//Need to actually touch the thing to turn it on
		return
	if(active >= FG_CHARGING)
		to_chat(user, span_warning("You are unable to turn off [src] once it is online!"))
		return TRUE

	user.visible_message(
		span_notice("[user] turns on [src]."),
		span_notice("You turn on [src]."),
		span_hear("You hear heavy droning."))
	turn_on()
	investigate_log("activated by [key_name(user)].", INVESTIGATE_ENGINE)

	add_fingerprint(user)

/obj/machinery/field/generator/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	if(active)
		turn_off()
	state = anchorvalue ? FG_SECURED : FG_UNSECURED

/obj/machinery/field/generator/can_be_unfasten_wrench(mob/user, silent)
	if(active)
		if(!silent)
			to_chat(user, span_warning("Turn \the [src] off first!"))
		return FAILED_UNFASTEN

	else if(state == FG_WELDED)
		if(!silent)
			to_chat(user, span_warning("[src] is welded to the floor!"))
		return FAILED_UNFASTEN

	return ..()

/obj/machinery/field/generator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/field/generator/welder_act(mob/living/user, obj/item/welder)
	. = ..()
	if(active)
		to_chat(user, span_warning("[src] needs to be off!"))
		return TRUE

	switch(state)
		if(FG_UNSECURED)
			to_chat(user, span_warning("[src] needs to be wrenched to the floor!"))

		if(FG_SECURED)
			if(!welder.tool_start_check(user, amount=1))
				return TRUE
			user.visible_message(
				span_notice("[user] starts to weld [src] to the floor."),
				span_notice("You start to weld \the [src] to the floor..."),
				span_hear("You hear welding."))
			if(welder.use_tool(src, user, 20, volume=50) && state == FG_SECURED)
				state = FG_WELDED
				to_chat(user, span_notice("You weld the field generator to the floor."))

		if(FG_WELDED)
			if(!welder.tool_start_check(user, amount=1))
				return TRUE
			user.visible_message(
				span_notice("[user] starts to cut [src] free from the floor."),
				span_notice("You start to cut \the [src] free from the floor..."),
				span_hear("You hear welding."))
			if(welder.use_tool(src, user, 20, volume=50) && state == FG_WELDED)
				state = FG_SECURED
				to_chat(user, span_notice("You cut \the [src] free from the floor."))

	return TRUE


/obj/machinery/field/generator/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(user.environment_smash == ENVIRONMENT_SMASH_RWALLS && active == FG_OFFLINE && state != FG_UNSECURED)
		set_anchored(FALSE)
		user.visible_message(span_warning("[user] rips [src] free from its moorings!"))
	else
		..()
	if(!anchored)
		step(src, get_dir(user, src))

/obj/machinery/field/generator/blob_act(obj/structure/blob/B)
	if(active)
		return FALSE
	else
		return ..()

/obj/machinery/field/generator/bullet_act(obj/projectile/considered_bullet)
	if(considered_bullet.armor_flag != BULLET)
		power = min(power + considered_bullet.damage, field_generator_max_power)
		check_power_level()
	. = ..()


/obj/machinery/field/generator/Destroy()
	cleanup()
	return ..()

/**
 *The power level is displayed using overlays. The current displayed power level is stored in 'powerlevel'.
 *The overlay in use and the powerlevel variable must be kept in sync.  A powerlevel equal to 0 means that
 *no power level overlay is currently in the overlays list.
 */
/obj/machinery/field/generator/proc/check_power_level()
	var/new_level = round(6 * power / field_generator_max_power)
	if(new_level != power_level)
		power_level = new_level
		update_appearance()

/obj/machinery/field/generator/proc/turn_off()
	active = FG_OFFLINE
	can_atmos_pass = ATMOS_PASS_YES
	air_update_turf(TRUE, FALSE)
	INVOKE_ASYNC(src, PROC_REF(cleanup))
	RemoveElement(/datum/element/give_turf_traits, string_list(list(TRAIT_CONTAINMENT_FIELD)))
	if(instantenous)
		warming_up = 0
		return
	addtimer(CALLBACK(src, PROC_REF(cool_down)), 5 SECONDS)

/obj/machinery/field/generator/proc/cool_down()
	if(active || warming_up <= 0)
		return
	warming_up--
	update_appearance()
	if(warming_up > 0)
		addtimer(CALLBACK(src, PROC_REF(cool_down)), 5 SECONDS)

/obj/machinery/field/generator/proc/turn_on()
	AddElement(/datum/element/give_turf_traits, string_list(list(TRAIT_CONTAINMENT_FIELD)))
	if(instantenous)
		active = FG_ONLINE
		warming_up = 3
		start_fields()
		return
	active = FG_CHARGING
	addtimer(CALLBACK(src, PROC_REF(warm_up)), 5 SECONDS)

/obj/machinery/field/generator/proc/warm_up()
	if(!active)
		return
	warming_up++
	update_appearance()
	if(warming_up >= 3)
		start_fields()
	else
		addtimer(CALLBACK(src, PROC_REF(warm_up)), 5 SECONDS)

/obj/machinery/field/generator/proc/calc_power(set_power_draw)
	var/power_draw = 2 + fields.len
	if(set_power_draw)
		power_draw = set_power_draw

	if(draw_power(round(power_draw * 0.5, 1)))
		check_power_level()
		return TRUE
	else
		visible_message(span_danger("\The [src] shuts down!"), span_hear("You hear something shutting down."))
		turn_off()
		investigate_log("ran out of power and DEACTIVATED.", INVESTIGATE_ENGINE)
		power = 0
		check_power_level()
		return FALSE

//This could likely be better, it tends to start loopin if you have a complex generator loop setup.  Still works well enough to run the engine fields will likely recode the field gens and fields sometime -Mport
/obj/machinery/field/generator/proc/draw_power(draw = 0, failsafe = FALSE, obj/machinery/field/generator/other_generator = null, obj/machinery/field/generator/last = null)
	if((other_generator && (other_generator == src)) || (failsafe >= 8))//Loopin, set fail
		return FALSE
	else
		failsafe++

	if(power >= draw)//We have enough power
		power -= draw
		return TRUE

	//Need more power
	draw -= power
	power = 0
	for(var/connected_generator in connected_gens)
		var/obj/machinery/field/generator/considered_generator = connected_generator
		if(considered_generator == last)//We just asked you
			continue
		if(other_generator)//Another gen is askin for power and we dont have it
			if(considered_generator.draw_power(draw, failsafe, other_generator, src))//Can you take the load
				return TRUE
			return FALSE
		//We are askin another for power
		if(considered_generator.draw_power(draw, failsafe, src, src))
			return TRUE
		return FALSE


/obj/machinery/field/generator/proc/start_fields()
	if(state != FG_WELDED || !anchored)
		turn_off()
		return
	move_resist = INFINITY
	set_explosion_block(INFINITY)
	can_atmos_pass = ATMOS_PASS_NO
	air_update_turf(TRUE, TRUE)
	addtimer(CALLBACK(src, PROC_REF(setup_field), 1), 0.1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(setup_field), 2), 0.2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(setup_field), 4), 0.3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(setup_field), 8), 0.4 SECONDS)
	addtimer(VARSET_CALLBACK(src, active, FG_ONLINE), 0.5 SECONDS)

/obj/machinery/field/generator/proc/setup_field(NSEW)
	var/turf/current_turf = loc
	if(!istype(current_turf))
		return FALSE

	var/obj/machinery/field/generator/found_generator = null
	var/steps = 0
	if(!NSEW)//Make sure its ran right
		return FALSE
	for(var/dist in 0 to 7) // checks out to 8 tiles away for another generator
		current_turf = get_step(current_turf, NSEW)
		if(current_turf.density)//We cant shoot a field though this
			return FALSE

		found_generator = locate(/obj/machinery/field/generator) in current_turf
		if(found_generator)
			steps -= 1
			if(!found_generator.active)
				return FALSE
			break

		for(var/turf_content in current_turf.contents)
			var/atom/found_atom = turf_content
			if(ismob(found_atom))
				continue
			if(found_atom.density)
				return FALSE

		steps++

	if(!found_generator)
		return FALSE

	current_turf = loc
	for(var/dist in 0 to steps) // creates each field tile
		var/field_dir = get_dir(current_turf, get_step(found_generator.loc, NSEW))
		current_turf = get_step(current_turf, NSEW)
		if(!locate(/obj/machinery/field/containment) in current_turf)
			var/obj/machinery/field/containment/created_field = new(current_turf)
			created_field.set_master(src,found_generator)
			created_field.setDir(field_dir)
			fields += created_field
			found_generator.fields += created_field
			for(var/mob/living/shocked_mob in current_turf)
				created_field.on_entered(src, shocked_mob)

	connected_gens |= found_generator
	found_generator.connected_gens |= src
	shield_floor(TRUE)
	update_appearance()


/obj/machinery/field/generator/proc/cleanup()
	clean_up = TRUE
	for (var/field in fields)
		qdel(field)

	shield_floor(FALSE)

	for(var/connected_generator in connected_gens)
		var/obj/machinery/field/generator/considered_generator = connected_generator
		considered_generator.connected_gens -= src
		if(!considered_generator.clean_up)//Makes the other gens clean up as well
			considered_generator.cleanup()
		connected_gens -= considered_generator
	clean_up = FALSE
	update_appearance()

	move_resist = initial(move_resist)
	set_explosion_block(0)

/obj/machinery/field/generator/proc/shield_floor(create)
	if(connected_gens.len < 2)
		return
	var/connected_gen_counter
	for(connected_gen_counter = 1; connected_gen_counter < connected_gens.len, connected_gen_counter++)

		var/list/connected_gen_list = ((connected_gens[connected_gen_counter].connected_gens & connected_gens[connected_gen_counter+1].connected_gens)^src)
		if(!connected_gen_list.len)
			return
		var/obj/machinery/field/generator/considered_generator = connected_gen_list[1]

		var/x_step
		var/y_step
		if(considered_generator.x > x && considered_generator.y > y)
			for(x_step=x; x_step <= considered_generator.x; x_step++)
				for(y_step=y; y_step <= considered_generator.y; y_step++)
					place_floor(locate(x_step,y_step,z),create)
		else if(considered_generator.x > x && considered_generator.y < y)
			for(x_step=x; x_step <= considered_generator.x; x_step++)
				for(y_step=y; y_step >= considered_generator.y; y_step--)
					place_floor(locate(x_step,y_step,z),create)
		else if(considered_generator.x < x && considered_generator.y > y)
			for(x_step=x; x_step >= considered_generator.x; x_step--)
				for(y_step=y; y_step <= considered_generator.y; y_step++)
					place_floor(locate(x_step,y_step,z),create)
		else
			for(x_step=x; x_step >= considered_generator.x; x_step--)
				for(y_step=y; y_step >= considered_generator.y; y_step--)
					place_floor(locate(x_step,y_step,z),create)


/obj/machinery/field/generator/proc/place_floor(Location,create)
	if(create && !locate(/obj/effect/shield) in Location)
		new/obj/effect/shield(Location)
	else if(!create)
		var/obj/effect/shield/created_shield = locate(/obj/effect/shield) in Location
		if(created_shield)
			qdel(created_shield)

/obj/machinery/field/generator/proc/block_singularity_if_active()
	SIGNAL_HANDLER

	if (active)
		return SINGULARITY_TRY_MOVE_BLOCK

/obj/machinery/field/generator/shock(mob/living/user)
	if(fields.len)
		..()

/obj/machinery/field/generator/bump_field(atom/movable/AM as mob|obj)
	if(fields.len)
		..()

/obj/machinery/field/generator/starts_on
	anchored = TRUE
	state = FG_WELDED

/obj/machinery/field/generator/starts_on/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/field/generator/starts_on/post_machine_initialize()
	. = ..()
	turn_on()

/obj/machinery/field/generator/starts_on/magic
	power_level = 6 //forces the highest level overlay
	instantenous = TRUE

/obj/machinery/field/generator/starts_on/magic/process()
	return PROCESS_KILL // this is the only place calc_power is called, and doing it here avoids one unnecessary proc call

#undef FG_UNSECURED
#undef FG_SECURED
#undef FG_WELDED

#undef FG_OFFLINE
#undef FG_CHARGING
#undef FG_ONLINE
