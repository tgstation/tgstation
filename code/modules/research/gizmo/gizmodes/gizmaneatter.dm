// gizmo mode about
// when activation, its launching the meet hook(like traitor chef) into the most close target
// then victim is drastically pulled into the gizmo, Gizmo eats the poor spessman(like bileworms)
// When victim was got into Gizmo, the Victim got into some kinda of the room
// Victim can go around and eventually go out
// When Victim is trying to get out, Gizmo will threw him out like a Xeno Queen, but with no acid, maybe with machine oil? Its machine afterwards!
/datum/gizmodes/man_eatter
    guaranteed_active_gizmodes = list(
		/datum/gizpulse/man_eatter/gizmo_insideness,
        /datum/gizpulse/man_eatter/gizmo_dungeon,
	)

/datum/gizpulse/man_eatter

    var/mob/living/who_was_eatten

	var/mob/living/carbon/gizmo_flesh

	// Gizmo hook
	var/obj/projectile/hook/gizmo_hook

	var/angle_of_target

/datum/gizpulse/man_eatter/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/obj/item/organ/stomach/alien/gizmo_stomach = new()
	gizmo_flesh.Insert(gizmo_stomach, special = True)


/datum/gizpulse/man_eatter/proc/eat_man(atom/movable/holder)
    target = gizmo.find_the_target

    // launch meet hook like traitor chef from gizmo
    // to choosen target


	targe.count_angle()

	gizmo_hook.fire(angle_of_target)


/datum/gizpulse/man_eatter/proc/nomnom_man(atom/movable/holder)
    // shake the gizmo like its like doing something with body
    gizmo.shake()
    // sound for more drasticall effect
    gizmo.make_some_horrifien_sounds()

    // Sending the hooked spessman into the... Gizmo room
    Gizmo.put_victim_inside(who_was_eatten)

    // sending the man into... Gizmo?
    SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_GIZMO_INSIDNESS)

    // threw out victim
    gizmo.throw_out_man(who_was_eatten)


/datum/gizpulse/man_eatter/proc/throw_out_man(atom/movable/holder)
    // that xeno quen ability to threw out the eatten with special... sound; and acid, but acid can changed to like smth
    xeno_quenn_throw_out_ability(holder)
