#define CPU_INTERACTABLE(user) (cpu && !HAS_TRAIT_FROM(src, TRAIT_MODPC_INTERACTING_WITH_FRAME, REF(user)))

// Modular Computer - A machinery that is mostly just a host to the Modular Computer item.
/obj/machinery/modular_computer
	name = "modular computer"
	desc = "You shouldn't see this. If you do, report it." //they should be examining the processor instead
	icon = 'icons/obj/machines/modular_console.dmi'
	icon_state = "console"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.025
	density = TRUE
	max_integrity = 300
	integrity_failure = 0.5

	///A flag that describes this device type
	var/hardware_flag = PROGRAM_CONSOLE
	/// Amount of programs that can be ran at once
	var/max_idle_programs = 4


	///Icon state when the computer is turned off.
	var/icon_state_unpowered = "console-off"
	///Icon state when the computer is turned on.
	var/icon_state_powered = "console"
	///Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/screen_icon_state_menu = "menu"
	///Icon state overlay when the computer is powered, but not 'switched on'.
	var/screen_icon_screensaver = "standby"
	///Amount of steel sheets refunded when disassembling an empty frame of this computer.
	var/steel_sheet_cost = 10
	///Light luminosity when turned on
	var/light_strength = 2
	///Power usage when the computer is open (screen is active) and can be interacted with.
	var/base_active_power_usage = 500
	///Power usage when the computer is idle and screen is off (currently only applies to laptops)
	var/base_idle_power_usage = 100

	///CPU that handles most logic while this type only handles power and other specific things.
	var/obj/item/modular_computer/processor/cpu

/obj/machinery/modular_computer/Initialize(mapload)
	. = ..()
	cpu = new(src)
	cpu.screen_on = TRUE
	cpu.add_shell_component(SHELL_CAPACITY_LARGE, SHELL_FLAG_USB_PORT)
	update_appearance()
	register_context()

/obj/machinery/modular_computer/Destroy()
	QDEL_NULL(cpu)
	return ..()

/obj/machinery/modular_computer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Toggle processor interaction"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/modular_computer/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(HAS_TRAIT_FROM(src, TRAIT_MODPC_INTERACTING_WITH_FRAME, REF(user)))
		REMOVE_TRAIT(src, TRAIT_MODPC_INTERACTING_WITH_FRAME, REF(user))
		balloon_alert(user, "now interacting with computer")
	else
		ADD_TRAIT(src, TRAIT_MODPC_INTERACTING_WITH_FRAME, REF(user))
		balloon_alert(user, "now interacting with frame")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/modular_computer/examine(mob/user)
	. = cpu?.examine(user) || ..()
	. += span_info("You can toggle interaction between computer and its machinery frame with [EXAMINE_HINT("Right-Click")] while empty-handed.")
	var/frame_or_pc = HAS_TRAIT_FROM(src, TRAIT_MODPC_INTERACTING_WITH_FRAME, REF(user)) ? "frame" : "computer"
	. += span_info("Currently interacting with [EXAMINE_HINT(frame_or_pc)].")

/obj/machinery/modular_computer/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	cpu?.attack_ghost(user)

/obj/machinery/modular_computer/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(!cpu)
		balloon_alert(user, "turn it on first!")
		return FALSE
	return cpu.emag_act(user)

/obj/machinery/modular_computer/update_appearance(updates)
	. = ..()
	set_light(cpu?.enabled ? light_strength : 0)

/obj/machinery/modular_computer/update_icon_state()
	if(!cpu || !cpu.enabled || (machine_stat & NOPOWER))
		icon_state = icon_state_unpowered
	else
		icon_state = icon_state_powered
	return ..()

/obj/machinery/modular_computer/update_overlays()
	. = ..()
	if(!cpu)
		return .

	if(cpu.enabled)
		. += cpu.active_program?.program_open_overlay || screen_icon_state_menu
	else if(!(machine_stat & NOPOWER))
		. += screen_icon_screensaver

	if(cpu.get_integrity() <= cpu.integrity_failure * cpu.max_integrity)
		. += "bsod"
		. += "broken"
	return .

/// Eats the "source" arg because update_icon actually expects args now.
/obj/machinery/modular_computer/proc/relay_icon_update(datum/source, updates, updated)
	SIGNAL_HANDLER
	return update_icon(updates)

/obj/machinery/modular_computer/click_alt(mob/user)
	if(CPU_INTERACTABLE(user) || !can_interact(user))
		return NONE
	cpu.click_alt(user)
	return CLICK_ACTION_SUCCESS

//ATTACK HAND IGNORING PARENT RETURN VALUE
// On-click handling. Turns on the computer if it's off and opens the GUI.
/obj/machinery/modular_computer/interact(mob/user)
	return CPU_INTERACTABLE(user) ? cpu.interact(user) : ..()

// Modular computers can have battery in them, we handle power in previous proc, so prevent this from messing it up for us.
/obj/machinery/modular_computer/power_change()
	if(cpu?.use_energy()) // If it still has a power source, PC wouldn't go offline.
		set_machine_stat(machine_stat & ~NOPOWER)
		update_appearance()
		return
	return ..()

///Try to recharge our internal cell if it isn't fully charged.
/obj/machinery/modular_computer/process(seconds_per_tick)
	var/obj/item/stock_parts/cell/cell = get_cell()
	if(isnull(cell) || cell.percent() >= 100)
		return
	charge_cell(idle_power_usage * seconds_per_tick, cell)

/obj/machinery/modular_computer/get_cell()
	return cpu?.internal_cell

/obj/machinery/modular_computer/screwdriver_act(mob/user, obj/item/tool)
	return CPU_INTERACTABLE(user) ? cpu.screwdriver_act(user, tool) : ..()

/obj/machinery/modular_computer/wrench_act_secondary(mob/user, obj/item/tool)
	return CPU_INTERACTABLE(user) ? cpu.wrench_act_secondary(user, tool) : ..()

/obj/machinery/modular_computer/welder_act(mob/user, obj/item/tool)
	return CPU_INTERACTABLE(user) ? cpu.welder_act(user, tool) : ..()

/obj/machinery/modular_computer/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	return (CPU_INTERACTABLE(user) && !user.combat_mode) ? cpu.item_interaction(user, tool, modifiers) : ..()

/obj/machinery/modular_computer/attacked_by(obj/item/attacking_item, mob/living/user)
	return CPU_INTERACTABLE(user) ? cpu.attacked_by(attacking_item, user) : ..()

// Stronger explosions cause serious damage to internal components
// Minor explosions are mostly mitigitated by casing.
/obj/machinery/modular_computer/ex_act(severity)
	if(!cpu)
		return ..()

	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += cpu
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += cpu
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += cpu
	return ..()

// EMPs are similar to explosions, but don't cause physical damage to the casing. Instead they screw up the components
/obj/machinery/modular_computer/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	if(cpu)
		cpu.emp_act(severity)

// "Stun" weapons can cause minor damage to components (short-circuits?)
// "Burn" damage is equally strong against internal components and exterior casing
// "Brute" damage mostly damages the casing.
/obj/machinery/modular_computer/bullet_act(obj/projectile/Proj)
	return cpu?.bullet_act(Proj) || ..()

#undef CPU_INTERACTABLE
