#define LOG_BURN_TIMER 150
#define PAPER_BURN_TIMER 5
#define MAXIMUM_BURN_TIMER 3000

/obj/structure/fireplace
	name = "fireplace"
	desc = "A large stone brick fireplace."
	icon = 'icons/obj/fluff/fireplace.dmi'
	icon_state = "fireplace"
	density = FALSE
	anchored = TRUE
	pixel_x = -16
	resistance_flags = FIRE_PROOF
	light_color = LIGHT_COLOR_FIRE
	light_angle = 170
	light_flags = LIGHT_IGNORE_OFFSET
	/// is the fireplace lit?
	var/lit = FALSE
	/// the amount of fuel for the fire
	var/fuel_added = 0
	/// how much time is left before fire runs out of fuel
	var/flame_expiry_timer
	/// the looping sound effect that is played while burning
	var/datum/looping_sound/burning/burning_loop

/obj/structure/fireplace/Initialize(mapload)
	. = ..()
	burning_loop = new(src)

/obj/structure/fireplace/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(burning_loop)
	remove_shared_particles(/particles/smoke/burning)
	. = ..()

/obj/structure/fireplace/setDir(newdir)
	. = ..()
	set_light(l_dir = dir)

/// We're offset back into the wall, account for that
/obj/structure/fireplace/get_light_offset()
	var/list/hand_back = ..()
	var/list/dir_offset = dir2offset(REVERSE_DIR(dir))
	hand_back[1] += dir_offset[1] * 0.5
	hand_back[2] += dir_offset[2] * 0.5
	return hand_back

/obj/structure/fireplace/proc/try_light(obj/item/O, mob/user)
	if(lit)
		to_chat(user, span_warning("It's already lit!"))
		return FALSE
	if(!fuel_added)
		to_chat(user, span_warning("[src] needs some fuel to burn!"))
		return FALSE
	var/msg = O.ignition_effect(src, user)
	if(msg)
		visible_message(msg)
		ignite()
		return TRUE

/obj/structure/fireplace/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stack/sheet/mineral/wood))
		var/obj/item/stack/sheet/mineral/wood/wood = tool
		var/space_remaining = MAXIMUM_BURN_TIMER - burn_time_remaining()
		var/space_for_logs = round(space_remaining / LOG_BURN_TIMER)
		if(space_for_logs < 1)
			to_chat(user, span_warning("You can't fit any more of [tool] in [src]!"))
			return ITEM_INTERACT_BLOCKING

		var/logs_used = min(space_for_logs, wood.amount)
		wood.use(logs_used)
		adjust_fuel_timer(LOG_BURN_TIMER * logs_used)
		user.visible_message(span_notice("[user] tosses some wood into [src]."), span_notice("You add some fuel to [src]."))
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/paper_bin))
		var/obj/item/paper_bin/paper_bin = tool
		user.visible_message(span_notice("[user] throws [tool] into [src]."), span_notice("You add [tool] to [src]."))
		adjust_fuel_timer(PAPER_BURN_TIMER * paper_bin.total_paper)
		qdel(paper_bin)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/paper))
		user.visible_message(span_notice("[user] throws [tool] into [src]."), span_notice("You throw [tool] into [src]."))
		adjust_fuel_timer(PAPER_BURN_TIMER)
		qdel(tool)
		return ITEM_INTERACT_SUCCESS

	if(tool.ignition_effect(src, user))
		try_light(tool, user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/structure/fireplace/update_overlays()
	. = ..()
	if(!lit)
		return

	switch(burn_time_remaining())
		if(0 to 500)
			. += "fireplace_fire0"
		if(500 to 1000)
			. += "fireplace_fire1"
		if(1000 to 1500)
			. += "fireplace_fire2"
		if(1500 to 2000)
			. += "fireplace_fire3"
		if(2000 to MAXIMUM_BURN_TIMER)
			. += "fireplace_fire4"
	. += "fireplace_glow"

/obj/structure/fireplace/proc/adjust_light()
	if(!lit)
		set_light(0)
		return

	switch(burn_time_remaining())
		if(0 to 500)
			set_light(1)
		if(500 to 1000)
			set_light(2)
		if(1000 to 1500)
			set_light(3)
		if(1500 to 2000)
			set_light(4)
		if(2000 to MAXIMUM_BURN_TIMER)
			set_light(6)

/obj/structure/fireplace/process(seconds_per_tick)
	if(!lit)
		return
	if(world.time > flame_expiry_timer)
		put_out()
		return

	var/turf/T = get_turf(src)
	T.hotspot_expose(700, 2.5 * seconds_per_tick)
	update_appearance()
	adjust_light()

/obj/structure/fireplace/extinguish()
	. = ..()
	if(lit)
		var/fuel = burn_time_remaining()
		flame_expiry_timer = 0
		put_out()
		adjust_fuel_timer(fuel)

/obj/structure/fireplace/proc/adjust_fuel_timer(amount)
	if(lit)
		flame_expiry_timer += amount
		if(burn_time_remaining() < MAXIMUM_BURN_TIMER)
			flame_expiry_timer = world.time + MAXIMUM_BURN_TIMER
	else
		fuel_added = clamp(fuel_added + amount, 0, MAXIMUM_BURN_TIMER)

/obj/structure/fireplace/proc/burn_time_remaining()
	if(lit)
		return max(0, flame_expiry_timer - world.time)
	else
		return max(0, fuel_added)

/obj/structure/fireplace/proc/ignite()
	START_PROCESSING(SSobj, src)
	burning_loop.start()
	lit = TRUE
	desc = "A large stone brick fireplace, warm and cozy."
	flame_expiry_timer = world.time + fuel_added
	fuel_added = 0
	update_appearance()
	adjust_light()
	var/obj/effect/abstract/shared_particle_holder/smoke_particles = add_shared_particles(/particles/smoke/burning, "fireplace_[dir]")

	switch(dir)
		if(SOUTH)
			smoke_particles.pixel_w = 16
			smoke_particles.pixel_z = 45
		if(EAST)
			smoke_particles.pixel_w = -4
			smoke_particles.pixel_z = 25
		if(WEST)
			smoke_particles.pixel_w = 36
			smoke_particles.pixel_z = 25
		if(NORTH) // there is no icon state for SOUTH
			remove_shared_particles(/particles/smoke/burning)

/obj/structure/fireplace/proc/put_out()
	STOP_PROCESSING(SSobj, src)
	burning_loop.stop()
	lit = FALSE
	update_appearance()
	adjust_light()
	desc = initial(desc)
	remove_shared_particles(/particles/smoke/burning)

#undef LOG_BURN_TIMER
#undef PAPER_BURN_TIMER
#undef MAXIMUM_BURN_TIMER
