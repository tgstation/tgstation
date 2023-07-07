/datum/action/cooldown/mob_cooldown/charge_apc
	name = "Charge APCs"
	button_icon = 'icons/obj/power.dmi'
	button_icon_state = "apc0"
	desc = "Give off charge to an APC."
	cooldown_time = 5 SECONDS
	///how much charge are we giving off to an APC?
	var/given_charge = 80

/datum/action/cooldown/mob_cooldown/charge_apc/Activate(atom/target_atom)
	if(!istype(target_atom,/obj/machinery/power/apc))
		return
	var/obj/machinery/power/apc/target_apc = target_atom
	if(!target_apc.cell)
		return
	new /obj/effect/particle_effect/sparks(target_apc.loc)
	target_apc.cell.give(given_charge)
	StartCooldown()
	return TRUE
