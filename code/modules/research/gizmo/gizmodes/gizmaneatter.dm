
/datum/gizmodes/man_eatter
    guaranteed_active_gizmodes = list(
		/datum/gizpulse/pie_thrower/ordinary,
	)

/datum/gizpulse/man_eatter

    var/who_was_eatten

/datum/gizpulse/man_eatter/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)


/datum/gizpulse/man_eatter/proc/eat_man(atom/movable/holder)
    target = gizmo.find_the_target

    gizmo.launch_meet_hook(target)


/datum/gizpulse/man_eatter/proc/nomnom_man(atom/movable/holder)
    gizmo.shake()
    gizmo.make_some_horrifien_sounds()

    insert_new_gizmo_strange_organ(who_was_eatten)


    gizmo.throw_out_man


/datum/gizpulse/man_eatter/proc/throw_out_man(atom/movable/holder)
    xeno_quenn_throw_out_ability(holder)
