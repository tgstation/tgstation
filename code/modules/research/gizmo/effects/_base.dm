/// Runs the functionality for the interaction.
/datum/gizmo_effect
    /// If TRUE, put the gizmo combination into cooldown upon use
    var/affect_timer = TRUE

/datum/gizmo_effect/proc/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
    return
