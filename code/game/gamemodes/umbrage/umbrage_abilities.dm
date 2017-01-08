/datum/action/innate/umbrage
	name = "umbrage ability"
	desc = "This probably shouldn't exist."
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	var/psi_cost = 0

/datum/action/innate/umbrage/Activate()
	..()
	if(usr.mind.umbrage_psionics)
		usr.mind.umbrage_psionics.use_psi(psi_cost)

/datum/action/innate/umbrage/IsAvailable()
	if(!usr)
		return
	var/datum/umbrage/U = usr.mind.umbrage_psionics
	if(!U)
		return
	if(U.psi < psi_cost)
		usr << "<span class='warning'>You need more psi.</span>"
		return
	return ..()



//Pass: An all-purpose utility ability with a low cost. Morphs the caster's active hand into a tendril with many uses.
/datum/action/innate/umbrage/pass
	name = "Pass"
	desc = "Change your active hand into a tendril with many uses."
	button_icon_state = "umbrage_pass"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	psi_cost = 5
	var/precise = 0 //Accuracy upgrade for mobility

/datum/action/innate/umbrage/pass/Activate()
	var/mob/living/carbon/human/H = usr
	H.visible_message("<span class='warning'>[H]'s arm contorts into tentacles!</span>", "<span class='velvet_bold'>luu...</span>")
	playsound(H, 'sound/items/umbrage_pass_form.ogg', 50, 1)
	var/obj/item/weapon/umbrage_pass/P = new
	P.linked_user = H
	H.put_in_hands(P)
	active = 1
	..()
	return 1

/datum/action/innate/umbrage/pass/Deactivate()
	var/deleted_tendrils = 0
	for(var/obj/item/weapon/umbrage_pass/P in usr)
		qdel(P)
		deleted_tendrils = 1
	if(deleted_tendrils)
		usr.visible_message("<span class='warning'>[usr]'s tentacles twist into an arm!</span>", "<span class='velvet_bold'>...han</span>")
		playsound(usr, 'sound/items/umbrage_pass_fade.ogg', 50, 1)
	active = 0
	..()
	return 1


