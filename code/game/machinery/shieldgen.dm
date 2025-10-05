/obj/structure/emergency_shield
	name = "emergency energy shield"
	desc = "An energy shield used to contain hull breaches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-old"
	integrity_failure = 0.5
	density = TRUE
	move_resist = INFINITY
	opacity = FALSE
	anchored = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 200 //The shield can only take so much beating (prevents perma-prisons)
	can_atmos_pass = ATMOS_PASS_DENSITY

/obj/structure/emergency_shield/Initialize(mapload)
	. = ..()
	setDir(pick(GLOB.cardinals))
	air_update_turf(TRUE, TRUE)

/obj/structure/emergency_shield/Destroy()
	air_update_turf(TRUE, FALSE)
	. = ..()

/obj/structure/emergency_shield/Move()
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/emergency_shield/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			take_damage(50, BRUTE, ENERGY, 0)

/obj/structure/emergency_shield/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)
		if(BRUTE)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)

/obj/structure/emergency_shield/take_damage(damage, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.) //damage was dealt
		new /obj/effect/temp_visual/impact_effect/ion(loc)

/// Subtype of shields that repair over time after sustaining integrity damage
/obj/structure/emergency_shield/regenerating
	name = "energy shield"
	desc = "An energy shield used to let ships through, but keep out the void of space."
	max_integrity = 400
	/// How much integrity is healed per second (per process multiplied by seconds per tick)
	var/heal_rate_per_second = 5

/obj/structure/emergency_shield/regenerating/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_NO_EXAMINE)

/obj/structure/emergency_shield/regenerating/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/emergency_shield/regenerating/take_damage(damage, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	if(.)
		// We took some damage so we'll start processing to heal said damage.
		START_PROCESSING(SSobj, src)

/obj/structure/emergency_shield/regenerating/process(seconds_per_tick)
	var/repaired_amount = repair_damage(heal_rate_per_second * seconds_per_tick)
	if(repaired_amount <= 0)
		// 0 damage repaired means we're at the max integrity, so don't need to process anymore
		STOP_PROCESSING(SSobj, src)

/obj/structure/emergency_shield/cult
	name = "cult barrier"
	desc = "A shield summoned by cultists to keep heretics away."
	max_integrity = 100
	icon_state = "shield-red"

/obj/structure/emergency_shield/cult/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_NO_EXAMINE)

/obj/structure/emergency_shield/cult/narsie
	name = "sanguine barrier"
	desc = "A potent shield summoned by cultists to defend their rites."
	max_integrity = 60

/obj/structure/emergency_shield/cult/weak
	name = "Invoker's Shield"
	desc = "A weak shield summoned by cultists to protect them while they carry out delicate rituals."
	color = COLOR_RED
	max_integrity = 20
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER

/obj/structure/emergency_shield/cult/barrier
	density = FALSE //toggled on right away by the parent rune
	can_atmos_pass = ATMOS_PASS_DENSITY
	///The rune that created the shield itself. Used to delete the rune when the shield is destroyed.
	var/obj/effect/rune/parent_rune

/obj/structure/emergency_shield/cult/barrier/attack_hand(mob/living/user, list/modifiers)
	parent_rune.attack_hand(user, modifiers)

/obj/structure/emergency_shield/cult/barrier/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(IS_CULTIST(user))
		parent_rune.attack_animal(user)
	else
		..()

/obj/structure/emergency_shield/cult/barrier/Destroy()
	if(parent_rune)
		parent_rune.visible_message(span_danger("The [parent_rune] fades away as [src] is destroyed!"))
		QDEL_NULL(parent_rune)
	return ..()

/**
*Turns the shield on and off.
*
*The shield has 2 states: on and off. When on, it will block movement,projectiles, items, etc. and be clearly visible, and block atmospheric gases.
*When off, the rune no longer blocks anything and turns invisible.
*The barrier itself is not intended to interact with the conceal runes cult spell for balance purposes.
*/
/obj/structure/emergency_shield/cult/barrier/proc/Toggle()
	set_density(!density)
	air_update_turf(TRUE, !density)
	if(!density)
		SetInvisibility(INVISIBILITY_OBSERVER, id=type)
	else
		RemoveInvisibility(type)

/obj/machinery/shieldgen
	name = "anti-breach shielding projector"
	desc = "Used to seal minor hull breaches."
	icon = 'icons/obj/machines/shield_generator.dmi'
	icon_state = "shieldoff"
	density = TRUE
	opacity = FALSE
	anchored = FALSE
	pressure_resistance = 2*ONE_ATMOSPHERE
	req_access = list(ACCESS_ENGINEERING)
	max_integrity = 100
	var/active = FALSE
	var/list/deployed_shields
	var/locked = FALSE
	var/shield_range = 4

/obj/machinery/shieldgen/Initialize(mapload)
	. = ..()
	deployed_shields = list()
	if(mapload && active && anchored)
		shields_up()

/obj/machinery/shieldgen/Destroy()
	QDEL_LIST(deployed_shields)
	return ..()


/obj/machinery/shieldgen/proc/shields_up()
	active = TRUE
	update_appearance()
	move_resist = INFINITY

	for(var/turf/target_tile as anything in RANGE_TURFS(shield_range, src))
		if(isspaceturf(target_tile) && !(locate(/obj/structure/emergency_shield) in target_tile))
			if(!(machine_stat & BROKEN) || prob(33))
				deployed_shields += new /obj/structure/emergency_shield(target_tile)

/obj/machinery/shieldgen/proc/shields_down()
	active = FALSE
	move_resist = initial(move_resist)
	update_appearance()
	QDEL_LIST(deployed_shields)

/obj/machinery/shieldgen/process(seconds_per_tick)
	if((machine_stat & BROKEN) && active)
		if(deployed_shields.len && SPT_PROB(2.5, seconds_per_tick))
			qdel(pick(deployed_shields))

/obj/machinery/shieldgen/interact(mob/user)
	. = ..()
	if(.)
		return
	if(locked && !HAS_SILICON_ACCESS(user))
		to_chat(user, span_warning("The machine is locked, you are unable to use it!"))
		return
	if(panel_open)
		to_chat(user, span_warning("The panel must be closed before operating this machine!"))
		return

	if (active)
		user.visible_message(span_notice("[user] deactivated \the [src]."), \
			span_notice("You deactivate \the [src]."), \
			span_hear("You hear heavy droning fade out."))
		shields_down()
	else
		if(anchored)
			user.visible_message(span_notice("[user] activated \the [src]."), \
				span_notice("You activate \the [src]."), \
				span_hear("You hear heavy droning."))
			shields_up()
		else
			to_chat(user, span_warning("The device must first be secured to the floor!"))
	return

/obj/machinery/shieldgen/screwdriver_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src, 100)
	toggle_panel_open()
	if(panel_open)
		to_chat(user, span_notice("You open the panel and expose the wiring."))
	else
		to_chat(user, span_notice("You close the panel."))
	return TRUE

/obj/machinery/shieldgen/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(locked)
		to_chat(user, span_warning("The bolts are covered! Unlocking this would retract the covers."))
		return
	if(!anchored && !isinspace())
		tool.play_tool_sound(src, 100)
		balloon_alert(user, "secured")
		set_anchored(TRUE)
	else if(anchored)
		tool.play_tool_sound(src, 100)
		balloon_alert(user, "unsecured")
		if(active)
			to_chat(user, span_notice("\The [src] shuts off!"))
			shields_down()
		set_anchored(FALSE)


/obj/machinery/shieldgen/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(W, /obj/item/stack/cable_coil) && (machine_stat & BROKEN) && panel_open)
		var/obj/item/stack/cable_coil/coil = W
		if (coil.get_amount() < 1)
			to_chat(user, span_warning("You need one length of cable to repair [src]!"))
			return
		to_chat(user, span_notice("You begin to replace the wires..."))
		if(do_after(user, 3 SECONDS, target = src))
			if(coil.get_amount() < 1)
				return
			coil.use(1)
			atom_integrity = max_integrity
			set_machine_stat(machine_stat & ~BROKEN)
			to_chat(user, span_notice("You repair \the [src]."))
			update_appearance()

	else if(W.GetID())
		if(allowed(user) && !(obj_flags & EMAGGED))
			locked = !locked
			to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the controls."))
		else if(obj_flags & EMAGGED)
			to_chat(user, span_danger("Error, access controller damaged!"))
		else
			to_chat(user, span_danger("Access denied."))

	else
		return ..()

/obj/machinery/shieldgen/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The access controller is damaged!"))
		return FALSE
	obj_flags |= EMAGGED
	locked = FALSE
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(user, "access controller shorted")
	return TRUE

/obj/machinery/shieldgen/update_icon_state()
	icon_state = "shield[active ? "on" : "off"][(machine_stat & BROKEN) ? "br" : null]"
	return ..()

#define ACTIVE_SETUPFIELDS 1
#define ACTIVE_HASFIELDS 2
/obj/machinery/power/shieldwallgen
	name = "shield wall generator"
	desc = "A shield generator."
	icon = 'icons/obj/machines/shield_generator.dmi'
	icon_state = "shield_wall_gen"
	base_icon_state = "shield_wall_gen"
	light_on = FALSE
	light_range = 2.5
	light_power = 2
	light_color = LIGHT_COLOR_BLUE
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_TELEPORTER)
	obj_flags = CONDUCTS_ELECTRICITY
	use_power = NO_POWER_USE
	active_power_usage = 150
	circuit = /obj/item/circuitboard/machine/shieldwallgen
	max_integrity = 300
	/// whether the shield generator is active, ACTIVE_SETUPFIELDS will make it search for generators on process, and if that is successful, is set to ACTIVE_HASFIELDS
	var/active = FALSE
	/// are we locked?
	var/locked = TRUE
	/// how far do we seek another generator in our cardinal directions
	var/shield_range = 8
	/// the attached cable under us
	var/obj/structure/cable/attached

/obj/machinery/power/shieldwallgen/xenobiologyaccess //use in xenobiology containment
	name = "xenobiology shield wall generator"
	desc = "A shield generator meant for use in xenobiology."
	req_access = list(ACCESS_XENOBIOLOGY)

/obj/machinery/power/shieldwallgen/anchored
	anchored = TRUE

/obj/machinery/power/shieldwallgen/unlocked //for use in ruins, etc
	locked = FALSE
	req_access = null

/obj/machinery/power/shieldwallgen/unlocked/anchored
	anchored = TRUE

/obj/machinery/power/shieldwallgen/Initialize(mapload)
	. = ..()
	//Add to the early process queue to prioritize power draw
	SSmachines.processing_early += src
	if(anchored)
		connect_to_network()
	RegisterSignal(src, COMSIG_ATOM_SINGULARITY_TRY_MOVE, PROC_REF(block_singularity_if_active))
	set_wires(new /datum/wires/shieldwallgen(src))

/obj/machinery/power/shieldwallgen/update_appearance(updates)
	. = ..()
	set_light(l_on = !!active)

/obj/machinery/power/shieldwallgen/update_icon_state()
	icon_state = "[base_icon_state][active ? "_on" : ""]"
	return ..()

/obj/machinery/power/shieldwallgen/update_overlays()
	. = ..()
	if(!panel_open)
		return
	. += "shieldgen_wires"

/obj/machinery/power/shieldwallgen/Destroy()
	for(var/d in GLOB.cardinals)
		cleanup_field(d)
	return ..()

/obj/machinery/power/shieldwallgen/should_have_node()
	return anchored

/obj/machinery/power/shieldwallgen/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/shieldwallgen/process_early()
	if(active)
		if(active == ACTIVE_SETUPFIELDS)
			var/fields = 0
			for(var/d in GLOB.cardinals)
				if(setup_field(d))
					fields++
			if(fields)
				active = ACTIVE_HASFIELDS
			update_appearance()
		if(!active_power_usage || surplus() >= active_power_usage)
			add_load(active_power_usage)
		else
			visible_message(span_danger("[src] shuts down due to lack of power!"), \
				"If this message is ever seen, something is wrong.",
				span_hear("You hear heavy droning fade out."))
			deactivate()
			log_game("[src] deactivated due to lack of power at [AREACOORD(src)]")
	else
		update_appearance()
		for(var/d in GLOB.cardinals)
			cleanup_field(d)

/// Constructs the actual field walls in the specified direction, cleans up old/stuck shields before doing so
/obj/machinery/power/shieldwallgen/proc/setup_field(direction)
	if(!direction)
		return

	var/turf/T = loc
	var/obj/machinery/power/shieldwallgen/G
	var/steps = 0
	var/opposite_direction = REVERSE_DIR(direction)

	for(var/i in 1 to shield_range) //checks out to 8 tiles away for another generator
		T = get_step(T, direction)
		G = locate(/obj/machinery/power/shieldwallgen) in T
		if(G)
			if(!G.active)
				return
			G.cleanup_field(opposite_direction)
			break
		else
			steps++

	if(!G || !steps) //no shield gen or no tiles between us and the gen
		return

	for(var/i in 1 to steps) //creates each field tile
		T = get_step(T, opposite_direction)
		new/obj/machinery/shieldwall(T, src, G)
	return TRUE

/// cleans up fields in the specified direction if they belong to this generator
/obj/machinery/power/shieldwallgen/proc/cleanup_field(direction)
	var/obj/machinery/shieldwall/F
	var/obj/machinery/power/shieldwallgen/G
	var/turf/T = loc

	for(var/i in 1 to shield_range)
		T = get_step(T, direction)

		G = (locate(/obj/machinery/power/shieldwallgen) in T)
		if(G && !G.active)
			break

		F = (locate(/obj/machinery/shieldwall) in T)
		if(F && (F.gen_primary == src || F.gen_secondary == src)) //it's ours, kill it.
			qdel(F)

/obj/machinery/power/shieldwallgen/proc/block_singularity_if_active()
	SIGNAL_HANDLER

	if (active)
		return SINGULARITY_TRY_MOVE_BLOCK

/obj/machinery/power/shieldwallgen/can_be_unfasten_wrench(mob/user, silent)
	if(active)
		if(!silent)
			to_chat(user, span_warning("Turn off the shield generator first!"))
		return FAILED_UNFASTEN
	return ..()


/obj/machinery/power/shieldwallgen/wrench_act(mob/living/user, obj/item/tool)
	var/unfasten_result = default_unfasten_wrench(user, tool, time = 0)
	update_cable_icons_on_turf(get_turf(src))
	if(unfasten_result == SUCCESSFUL_UNFASTEN && anchored)
		connect_to_network()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/shieldwallgen/screwdriver_act(mob/user, obj/item/tool)
	if(!panel_open && locked)
		balloon_alert(user, "unlock first!")
		return
	update_appearance(UPDATE_OVERLAYS)
	return default_deconstruction_screwdriver(user, icon_state, icon_state, tool)

/obj/machinery/power/shieldwallgen/crowbar_act(mob/user, obj/item/tool)
	if(active)
		return
	return default_deconstruction_crowbar(tool)

/obj/machinery/power/shieldwallgen/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(W.GetID())
		if(allowed(user) && !(obj_flags & EMAGGED))
			locked = !locked
			balloon_alert(user, "[locked ? "locked!" : "unlocked"]")
		else if(obj_flags & EMAGGED)
			balloon_alert(user, "malfunctioning!")
		else
			balloon_alert(user, "no access!")
		return

	add_fingerprint(user)
	if(is_wire_tool(W) && panel_open)
		wires.interact(user)
		return


/obj/machinery/power/shieldwallgen/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!anchored)
		balloon_alert(user, "not secured!")
		return
	if(locked && !HAS_SILICON_ACCESS(user))
		balloon_alert(user, "locked!")
		return
	if(!powernet)
		balloon_alert(user, "needs to be powered by wire!")
		return
	if(panel_open)
		balloon_alert(user, "panel open!")
		return

	if(active)
		user.visible_message(span_notice("[user] turned \the [src] off."), \
			span_notice("You turn off \the [src]."), \
			span_hear("You hear heavy droning fade out."))
		deactivate()
		user.log_message("deactivated [src].", LOG_GAME)
	else
		user.visible_message(span_notice("[user] turned \the [src] on."), \
			span_notice("You turn on \the [src]."), \
			span_hear("You hear heavy droning."))
		activate()
		user.log_message("activated [src].", LOG_GAME)
	add_fingerprint(user)

/obj/machinery/power/shieldwallgen/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The access controller is damaged!"))
		return FALSE
	obj_flags |= EMAGGED
	locked = FALSE
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(user, "access controller shorted")
	return TRUE

/// Turn the machine on with side effects
/obj/machinery/power/shieldwallgen/proc/activate()
	active = ACTIVE_SETUPFIELDS
	AddElement(/datum/element/give_turf_traits, string_list(list(TRAIT_CONTAINMENT_FIELD)))

/// Turn the machine off with side effects
/obj/machinery/power/shieldwallgen/proc/deactivate()
	active = FALSE
	for(var/d in GLOB.cardinals)
		cleanup_field(d)
	update_appearance()
	RemoveElement(/datum/element/give_turf_traits, string_list(list(TRAIT_CONTAINMENT_FIELD)))

//////////////Containment Field START
/obj/machinery/shieldwall
	name = "shield wall"
	desc = "An energy shield."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldwall"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 2.5
	light_power = 0.7
	light_color = LIGHT_COLOR_BLUE
	var/primary_direction = NONE
	var/needs_power = FALSE
	var/obj/machinery/power/shieldwallgen/gen_primary
	var/obj/machinery/power/shieldwallgen/gen_secondary

/obj/machinery/shieldwall/Initialize(mapload, obj/machinery/power/shieldwallgen/first_gen, obj/machinery/power/shieldwallgen/second_gen)
	. = ..()
	gen_primary = first_gen
	gen_secondary = second_gen
	if(gen_primary && gen_secondary)
		needs_power = TRUE
		setDir(get_dir(gen_primary, gen_secondary))
	for(var/mob/living/L in get_turf(src))
		visible_message(span_danger("\The [src] is suddenly occupying the same space as \the [L]!"))
		L.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
		L.gib(DROP_ALL_REMAINS)
	RegisterSignal(src, COMSIG_ATOM_SINGULARITY_TRY_MOVE, PROC_REF(block_singularity))
	AddElement(/datum/element/give_turf_traits, string_list(list(TRAIT_CONTAINMENT_FIELD)))

/obj/machinery/shieldwall/Destroy()
	gen_primary = null
	gen_secondary = null
	return ..()

/obj/machinery/shieldwall/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src, alpha = 200)

/obj/machinery/shieldwall/process()
	if(needs_power)
		if(!gen_primary || !gen_primary.active || !gen_secondary || !gen_secondary.active)
			qdel(src)
			return

		drain_power(10)

/obj/machinery/shieldwall/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)
		if(BRUTE)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)

//the shield wall is immune to damage but it drains the stored power of the generators.
/obj/machinery/shieldwall/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(damage_type == BRUTE || damage_type == BURN)
		drain_power(damage_amount)

/// succs power from the connected shield wall generator
/obj/machinery/shieldwall/proc/drain_power(drain_amount)
	if(needs_power && gen_primary)
		gen_primary.add_load(drain_amount * 0.5)
		if(gen_secondary) //using power may cause us to be destroyed
			gen_secondary.add_load(drain_amount * 0.5)

/obj/machinery/shieldwall/proc/block_singularity()
	SIGNAL_HANDLER

	return SINGULARITY_TRY_MOVE_BLOCK

/obj/machinery/shieldwall/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return prob(20)
	else
		if(isprojectile(mover))
			return prob(10)

#undef ACTIVE_SETUPFIELDS
#undef ACTIVE_HASFIELDS
