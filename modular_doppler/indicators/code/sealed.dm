/obj/vehicle/sealed
	/// Is combat indicator on for this vehicle? Boolean.
	var/combat_indicator_vehicle = FALSE
	/// When is the next time this vehicle will be able to use flick_emote and put the fluff text in chat?
	var/vehicle_next_combat_popup = 0

//Register the signal to the mob and mechs will listen for when CI is toggled, then call the parent proc, then turn on CI if the mob had CI on.
/obj/vehicle/sealed/add_occupant(mob/occupant_entering, control_flags)
	RegisterSignal(occupant_entering, COMSIG_MOB_CI_TOGGLED, PROC_REF(mob_toggled_ci))
	. = ..()
	handle_ci_migration(occupant_entering)

//Unregister the signal then disable CI if the vehicle has no other drivers within it.
/obj/vehicle/sealed/remove_occupant(mob/occupant_exiting)
	UnregisterSignal(occupant_exiting, COMSIG_MOB_CI_TOGGLED)
	. = ..()
	disable_ci(occupant_exiting)
