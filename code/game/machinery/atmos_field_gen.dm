/// off
#define GENERATOR_INACTIVE 0
/// waiting for power/retrying, will activate and do things if powered
#define GENERATOR_WANTPOWER 1
/// active
#define GENERATOR_ACTIVE 2

/obj/machinery/atmos_shield_gen
	name = "Atmospheric Shield Generator"
	desc = "Produces an atmos shield in a line between itself and another generator with both facing the other, while active. Powered by APC. Field must not be obstructed by wall, or an atmos shield field. Will turn on after gaining power if turned off due to power loss."
	icon = 'icons/obj/machines/atmosshieldgen.dmi'
	base_icon_state = "atmosshield"
	icon_state = "atmosshield"
	density = FALSE
	layer = ABOVE_MOB_LAYER
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	circuit = /obj/item/circuitboard/machine/atmos_shield_gen
	req_one_access = list(ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ENGINE_EQUIP)
	can_atmos_pass = ATMOS_PASS_PROC
	power_channel = AREA_USAGE_ENVIRON
	armor_type = /datum/armor/atmos_shield_gen

	/// are we locked
	var/locked = FALSE
	/// are we on
	var/on = GENERATOR_INACTIVE
	/// Max tiles between this generator and another generator. 0 would mean the generator can only do its thing if both are on the same tile.
	var/max_range = 2
	/// our shields
	var/list/fields = list()
	/// the shield generator we belong to that is actually making shields
	var/obj/machinery/atmos_shield_gen/master = null

/datum/armor/atmos_shield_gen
	melee = 50
	fire = 100
	acid = 50

/obj/machinery/atmos_shield_gen/Initialize(mapload)
	. = ..()
	register_context()
	AddComponent(/datum/component/simple_rotation)
	set_wires(new /datum/wires/atmosshieldgen(src))
	SSmachines.processing_early += src
	if(on)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/atmos_shield_gen/post_machine_initialize()
	. = ..()
	process_early() // not risking processing falling behind and letting gas out

/obj/machinery/atmos_shield_gen/Destroy(force)
	QDEL_LIST(fields)
	master?.turn_off()
	master = null
	return ..()

/obj/machinery/atmos_shield_gen/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE

	if(!isnull(held_item))
		if(istype(held_item, /obj/item/card/id))
			context[SCREENTIP_CONTEXT_LMB] = (locked ? "Unlock" : "Lock")
			return CONTEXTUAL_SCREENTIP_SET
		if(locked)
			return
		if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
			return CONTEXTUAL_SCREENTIP_SET
		else if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
			context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
			return CONTEXTUAL_SCREENTIP_SET
	else
		context[SCREENTIP_CONTEXT_LMB] = "Toggle"
		context[SCREENTIP_CONTEXT_RMB] = (locked ? "Unlock" : "Lock")
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/atmos_shield_gen/examine(mob/user)
	. += ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	. += span_notice("The status display reads:")
	. += span_notice("Currently [on ? "" : "in"]active.")
	if(locked)
		. += span_boldwarning("LOCKED")
		return
	. += span_notice("Maximum field length: [max_range] tiles")
	. += span_notice("Its maintenance panel can be [EXAMINE_HINT("screwed")] [panel_open ? "close" : "open"]")
	if(panel_open)
		. += span_notice("It can be [EXAMINE_HINT("pried")] apart")

/obj/machinery/atmos_shield_gen/RefreshParts()
	. = ..()
	var/datum/stock_part/capacitor/capacitor = locate() in component_parts
	active_power_usage = initial(active_power_usage) / capacitor.tier // 0.25kw per tile at tier 4
	var/datum/stock_part/micro_laser/laser = locate() in component_parts
	max_range = laser.tier + 2

/obj/machinery/atmos_shield_gen/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		return
	if(!on)
		return
	. += (on == GENERATOR_ACTIVE ? "active" : "wantpower")
	. += emissive_appearance(icon, on == GENERATOR_ACTIVE ? "active" : "wantpower", src, alpha = src.alpha)

/obj/machinery/atmos_shield_gen/screwdriver_act(mob/user, obj/item/tool)
	if(!panel_open && locked)
		balloon_alert(user, "locked!")
		return ITEM_INTERACT_FAILURE
	return default_deconstruction_screwdriver(user, icon_state, icon_state, tool)

/obj/machinery/atmos_shield_gen/crowbar_act(mob/user, obj/item/tool)
	if(on)
		balloon_alert(user, "turn off first!")
		return ITEM_INTERACT_FAILURE
	return default_deconstruction_crowbar(tool)

/obj/machinery/atmos_shield_gen/wrench_act(mob/living/user, obj/item/tool)
	if(on)
		balloon_alert(user, "turn off first!")
		return ITEM_INTERACT_FAILURE
	if(locked)
		balloon_alert(user, "unlock first!")
		return ITEM_INTERACT_FAILURE
	if(default_unfasten_wrench(user, tool) && !anchored)
		turn_off()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/atmos_shield_gen/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!anchored)
		balloon_alert(user, "not anchored!")
		return
	if(locked && !issilicon(user))
		balloon_alert(user, "locked!")
		return
	toggle(user)

/obj/machinery/atmos_shield_gen/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(allowed(user))
		locked = !locked
		balloon_alert(user, "[locked ? "" : "un"]locked!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	balloon_alert(user, "no access!")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/atmos_shield_gen/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = NONE
	add_fingerprint(user)
	if(is_wire_tool(tool) && panel_open)
		wires.interact(user)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/card/id) && check_access(tool))
		locked = !locked
		balloon_alert(user, "[locked ? "" : "un"]locked!")
		return ITEM_INTERACT_SUCCESS

/obj/machinery/atmos_shield_gen/process_early()
	if(on == GENERATOR_ACTIVE && !powered())
		turn_off(power_failure = TRUE)
	else if(on == GENERATOR_WANTPOWER && powered())
		on = GENERATOR_ACTIVE
		update_appearance(UPDATE_OVERLAYS)

	if(on != GENERATOR_ACTIVE)
		if(length(fields))
			QDEL_LIST(fields)
		return

	if(!isnull(master))
		if(master.on != GENERATOR_ACTIVE) // FUCK
			turn_off()
		return
	var/field_len = length(fields)
	if(field_len)
		use_energy(active_power_usage * field_len)
		return
	var/turf/current_turf = get_turf(src)
	var/found_slave = null
	for(var/i in 1 to max_range)
		if(isclosedturf(current_turf)) // we were blocked by a closed turf
			return
		if(isnull(found_slave))
			for(var/obj/machinery/atmos_shield_gen/generator in current_turf)
				if(generator == src || !generator.powered() || generator.dir != REVERSE_DIR(dir) || !isnull(generator.master) || !generator.anchored)
					continue
				found_slave = generator
				generator.change_master(src)
				break
			if(!isnull(found_slave))
				break
		current_turf = get_step(current_turf, dir) // advance

	if(isnull(found_slave))
		on = GENERATOR_WANTPOWER
		update_appearance(UPDATE_OVERLAYS)
		return

	var/turf/line = get_line(src, found_slave)
	for(var/turf/line_turf as anything in line)
		fields += new /obj/effect/atmos_shield(line_turf, src)

/obj/machinery/atmos_shield_gen/proc/toggle(mob/user)
	if(on)
		turn_off()
	else
		on = GENERATOR_WANTPOWER
		update_appearance(UPDATE_OVERLAYS)
	if(!isnull(user))
		balloon_alert(user, "turned [on ? "on" : "off"]")

/obj/machinery/atmos_shield_gen/proc/turn_off(power_failure = FALSE)
	if(!on)
		return
	if(power_failure)
		balloon_alert_to_viewers("no power!")
		playsound(src, 'sound/machines/cryo_warning.ogg', 65)
	on = power_failure ? GENERATOR_WANTPOWER : GENERATOR_INACTIVE
	master?.turn_off(power_failure)
	change_master(null)
	if(!power_failure) // so that it will get cleaned up on the next process so they can react
		QDEL_LIST(fields)
	update_appearance(UPDATE_OVERLAYS)

/// Changes our master variable and (un)registers signals. Does not check whether active and stuff. Will activate generator if new_master is not null
/obj/machinery/atmos_shield_gen/proc/change_master(new_master)
	if(master == new_master)
		return
	if(!isnull(master) && master != new_master)
		UnregisterSignal(master, COMSIG_QDELETING)
	if(isnull(new_master))
		master = null
		on = GENERATOR_INACTIVE
		update_appearance(UPDATE_OVERLAYS)
		return
	master = new_master
	RegisterSignal(master, COMSIG_QDELETING, PROC_REF(master_deleted))
	on = GENERATOR_ACTIVE
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/atmos_shield_gen/proc/master_deleted(datum/source)
	SIGNAL_HANDLER
	turn_off()

/obj/machinery/atmos_shield_gen/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/atmos_shield_gen/attack_ai_secondary(mob/user)
	return attack_hand_secondary(user)

/obj/machinery/atmos_shield_gen/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/atmos_shield_gen/attack_robot_secondary(mob/user)
	return attack_hand_secondary(user)

/obj/machinery/atmos_shield_gen/active
	on = GENERATOR_WANTPOWER
	locked = TRUE

/obj/effect/atmos_shield
	name = ""
	icon = 'icons/obj/smooth_structures/atmosshield.dmi'
	icon_state = "atmosshield-0"
	base_icon_state = "atmosshield"
	density = FALSE
	anchored = TRUE
	can_atmos_pass = ATMOS_PASS_NO
	alpha = 80
	rad_insulation = RAD_LIGHT_INSULATION
	resistance_flags = FIRE_PROOF | FREEZE_PROOF
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_ATMOS_SHIELD
	canSmoothWith = SMOOTH_GROUP_ATMOS_SHIELD
	light_on = TRUE
	light_range = 1.8
	light_power = 2
	light_color = COLOR_ENGINEERING_ORANGE
	/// the atmos shield generator that made us, used to turn it off sometimes
	var/obj/machinery/atmos_shield_gen/owner

/obj/effect/atmos_shield/Initialize(mapload, owner)
	. = ..()
	src.owner = owner
	QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src)
	update_appearance(UPDATE_OVERLAYS)
	air_update_turf(TRUE, TRUE)
	RegisterSignal(loc, COMSIG_TURF_CHANGE, PROC_REF(turf_changed)) // Wont ever be spawned inside something hopefully
	AddElement(/datum/element/give_turf_traits, string_list(list(TRAIT_FIREDOOR_STOP)))

/obj/effect/atmos_shield/block_superconductivity()
	return TRUE

/obj/effect/atmos_shield/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src, alpha = src.alpha)

/obj/effect/atmos_shield/Destroy(force)
	owner = null
	return ..()

/obj/effect/atmos_shield/atom_destruction(damage_flag)
	owner?.turn_off()
	return ..()

/obj/effect/atmos_shield/singularity_pull(atom/singularity, current_size)
	owner?.turn_off()
	qdel(src)

/obj/effect/atmos_shield/singularity_act()
	owner?.turn_off()
	qdel(src)

/obj/effect/atmos_shield/proc/turf_changed(datum/source, path, new_baseturfs, flags, post_change_callback)
	SIGNAL_HANDLER
	if(ispath(path, /turf/closed))
		atom_destruction(ENERGY)

#undef GENERATOR_ACTIVE
#undef GENERATOR_WANTPOWER
#undef GENERATOR_INACTIVE
