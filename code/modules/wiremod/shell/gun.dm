/**
 * # Circuit Gun
 *
 * A gun that lets you fire projectiles to enact circuitry.
 */
/obj/item/gun/energy/wiremod_gun
	name = "circuit gun"
	desc = "A gun that fires projectiles able to control circuitry. It can recharge using power from an attached circuit."
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "setup_gun"
	ammo_type = list(/obj/item/ammo_casing/energy/wiremod_gun)
	cell_type = /obj/item/stock_parts/power_store/cell/emproof/wiremod_gun
	item_flags = NONE
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_on = FALSE
	automatic_charge_overlays = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	gun_flags = NOT_A_REAL_GUN

/obj/item/ammo_casing/energy/wiremod_gun
	projectile_type = /obj/projectile/energy/wiremod_gun
	harmful = FALSE
	select_name = "circuit"
	fire_sound = 'sound/items/weapons/blaster.ogg'

/obj/projectile/energy/wiremod_gun
	name = "scanning beam"
	icon_state = "energy"
	damage = 0
	range = 7

/obj/item/stock_parts/power_store/cell/emproof/wiremod_gun
	maxcharge = 0.1 * STANDARD_CELL_CHARGE

/obj/item/gun/energy/wiremod_gun/Initialize(mapload)
	. = ..()
	var/datum/component/shell/shell = AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/wiremod_gun()
	), SHELL_CAPACITY_MEDIUM)

	RegisterSignal(shell, COMSIG_SHELL_CIRCUIT_ATTACHED, PROC_REF(on_circuit_attached))

/obj/item/circuit_component/wiremod_gun
	display_name = "Gun"
	desc = "Used to receive entities hit by projectiles from a gun."
	/// Called when a projectile hits
	var/datum/port/output/signal
	/// The shooter
	var/datum/port/output/shooter
	/// The entity being shot
	var/datum/port/output/shot

/obj/item/circuit_component/wiremod_gun/Initialize(mapload)
	. = ..()
	shooter = add_output_port("Shooter", PORT_TYPE_ATOM)
	shot = add_output_port("Shot Entity", PORT_TYPE_ATOM)
	signal = add_output_port("Shot", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/wiremod_gun/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_PROJECTILE_ON_HIT, PROC_REF(handle_shot))
	if(istype(shell, /obj/item/gun/energy))
		RegisterSignal(shell, COMSIG_GUN_CHAMBER_PROCESSED, PROC_REF(handle_chamber))

/obj/item/circuit_component/wiremod_gun/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_PROJECTILE_ON_HIT, COMSIG_GUN_CHAMBER_PROCESSED))

/obj/item/gun/energy/wiremod_gun/proc/on_circuit_attached(datum/component/shell/source)
	SIGNAL_HANDLER

	if (istype(source, /datum/component/shell))
		var/datum/component/shell/comp = source
		var/obj/item/integrated_circuit/circuit = comp.attached_circuit
		if (!circuit.cell)
			return
		var/transferred = src.cell.give(min(0.1 * STANDARD_CELL_CHARGE, circuit.cell.charge))
		if (transferred)
			circuit.cell.use(transferred, force=TRUE)

/**
 * Called when the shell item shoots something
 */
/obj/item/circuit_component/wiremod_gun/proc/handle_shot(atom/source, mob/firer, atom/target, angle)
	SIGNAL_HANDLER

	playsound(source, SFX_TERMINAL_TYPE, 25, FALSE)
	shooter.set_output(firer)
	shot.set_output(target)
	signal.set_output(COMPONENT_SIGNAL)

/**
 * Called when the shell item processes a new chamber
 */
/obj/item/circuit_component/wiremod_gun/proc/handle_chamber(atom/source)
	SIGNAL_HANDLER

	if(!parent?.cell)
		return
	var/obj/item/gun/energy/fired_gun = source
	var/transferred = fired_gun.cell.give(min(0.1 * STANDARD_CELL_CHARGE, parent.cell.charge))
	if(transferred)
		parent.cell.use(transferred, force = TRUE)
