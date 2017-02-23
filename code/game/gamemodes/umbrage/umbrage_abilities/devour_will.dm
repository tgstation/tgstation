//After a brief charge-up, equips a temporary dark bead that can be used on a human to knock them out and drain their will, making them vulnerable to conversion.
/datum/action/innate/umbrage/devour_will
	name = "Devour Will"
	id = "devour_will"
	desc = "Creates a dark bead that can be used on a human to fully recharge psi and knock them out."
	button_icon_state = "umbrage_devour_will"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	psi_cost = 20
	lucidity_cost = 0 //Baseline
	blacklisted = 1
	var/list/victims = list() //A list of people we've used the bead on recently; we can't drain them again so soon

/datum/action/innate/umbrage/devour_will/IsAvailable()
	if(!owner || !owner.get_empty_held_indexes())
		return
	return ..()

/datum/action/innate/umbrage/devour_will/Activate()
	owner.visible_message("<span class='warning'>[owner]'s hand begins to shimmer...</span>", "<span class='velvet bold'>pwga...</span><br>\
	<span owner='notice'>You begin forming a dark bead...</span>")
	playsound(owner, 'sound/magic/devour_will_begin.ogg', 50, 1)
	if(!do_after(owner, 10, target = owner))
		return
	owner.visible_message("<span class='warning'>A glowing black orb appears in [owner]'s hand!</span>", "<span class='velvet bold'>...iejz</span><br>\
	<span class='notice'>You form a dark bead in your hand.</span>")
	playsound(owner, 'sound/magic/devour_will_form.ogg', 50, 1)
	var/obj/item/weapon/dark_bead/B = new
	owner.put_in_hands(B)
	B.linked_ability = src
	return TRUE
