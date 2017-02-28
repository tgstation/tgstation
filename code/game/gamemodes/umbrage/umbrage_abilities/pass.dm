//Equips umbral tendrils with many uses.
/datum/action/innate/umbrage/pass
	name = "Pass"
	id = "pass"
	desc = "Twists an active arm into tendrils with many uses."
	button_icon_state = "umbrage_pass"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	psi_cost = 0
	lucidity_cost = 1
	blacklisted = 0

/datum/action/innate/umbrage/pass/IsAvailable()
	if(!owner.get_empty_held_indexes())
		return
	return ..()

/datum/action/innate/umbrage/pass/Activate()
	owner.visible_message("<span class='warning'>[owner]'s arm contorts into tentacles!</span>", "<span class='velvet bold'>ikna</span><br>\
	<span class='notice'>You transform your arm into umbral tendrils.</span>")
	playsound(owner, 'sound/magic/devour_will_begin.ogg', 50, 1)
	var/obj/item/weapon/umbral_tendrils/T = new
	owner.put_in_hands(T)
	T.linked_umbrage = linked_umbrage
	active = 1
	return TRUE


/datum/action/innate/umbrage/pass/Deactivate()
	owner.visible_message("<span class='warning'>[owner]'s tentacles contort into an arm!</span>", "<span class='velvet bold'>haoo</span><br>\
	<span class='notice'>You reform your arm.</span>")
	for(var/obj/item/weapon/umbral_tendrils/T in owner)
		qdel(T)
	active = 0
	return TRUE
