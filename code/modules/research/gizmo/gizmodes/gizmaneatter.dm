// gizmo mode about
// when activation, its launching the meet hook(like traitor chef) into the most close target
// then victim is drastically pulled into the gizmo, Gizmo eats the poor spessman(like bileworms)
// When victim was got into Gizmo, Gizmo is shaking and producing horryfull sounds
// And like.. do something with victim... like changing the organ, for first pulse, but can like, make people bald, or even heal them?
// After some time, its doing the same, what xeno queen do, its threw out the victim out of the itself, with same sound, and mb without acid
/datum/gizmodes/man_eatter
    guaranteed_active_gizmodes = list(
		/datum/gizpulse/pie_thrower/ordinary,
	)

/datum/gizpulse/man_eatter

    var/who_was_eatten

/datum/gizpulse/man_eatter/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)


/datum/gizpulse/man_eatter/proc/eat_man(atom/movable/holder)
    target = gizmo.find_the_target

    // launch meet hook like traitor chef from gizmo
    // to choosen target
    gizmo.launch_meet_hook(target)


/datum/gizpulse/man_eatter/proc/nomnom_man(atom/movable/holder)
    // shake the gizmo like its like doing something with body
    gizmo.shake()
    // sound for more drasticall effect
    gizmo.make_some_horrifien_sounds()

    // inserting new random organ
    insert_new_gizmo_strange_organ(who_was_eatten)

    // threw out victim
    gizmo.throw_out_man(who_was_eatten)


/datum/gizpulse/man_eatter/proc/throw_out_man(atom/movable/holder)
    // that xeno quen ability to threw out the eatten with special... sound; and acid, but acid can changed to like smth
    xeno_quenn_throw_out_ability(holder)
