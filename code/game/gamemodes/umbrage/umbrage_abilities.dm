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



//Devour Will: After a charge-up, creates a dark bead in the user's hand.
//The bead only lasts for one second, but if used to attack someone, they will be knocked out and put into a state of catatonia.
//Only those in this state can be made into veils.
//Additionally, every successful Devour Will increases maximum psi by 10 and fully restores it.
/datum/action/innate/umbrage/devour_will
	name = "Devour Will"
	desc = "Bring a human to death's door in order to fill and expand your psi. Victims must be in the catatonia induced by this before made veils."
	button_icon_state = "umbrage_devour_will"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS

/datum/action/innate/umbrage/devour_will/Activate()
	usr.visible_message("<span class='warning'>[usr]'s hand begins to glow violet!</span>", "<span class='velvet_bold'>koq...</span>")
	playsound(usr, 'sound/magic/devour_will_begin.ogg', 50, 0)
	if(!do_after(usr, 30, target = usr))
		return
	usr.visible_message("<span class='warning'>A dark orb forms in [usr]'s hand!</span>", "<span class='velvet_bold'>...iez...</span>")
	var/obj/item/weapon/umbrage_dark_bead/U = new
	usr.put_in_hands(U)
	return 1



//Veil Mind: Turns nearby unconscious humans afflicted by near-death catatonia into veils.
/datum/action/innate/umbrage/veil_mind
	name = "Veil Mind"
	desc = "Enslaves adjacent targets affected by Devour Mind. Also causes mild disorientation and hallucination in all hearers."
	button_icon_state = "umbrage_veil_mind"
	check_flags = AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	psi_cost = 20

/datum/action/innate/umbrage/veil_mind/Activate()
	usr.visible_message("<span class='warning'>[usr]'s sigils suddenly flare as they take a deep breath...</span>", "<span class='velvet_bold'>oxiep...</span>")
	playsound(usr, 'sound/magic/veil_gasp.ogg', 50, 0)
	if(!do_after(usr, 10, target = usr))
		return
	usr.visible_message("<span class='boldwarning'>[usr] lets out a horrific scream!</span>", "<span class='velvet_bold'>...ueahz</span>")
	playsound(usr, 'sound/magic/veil_scream.ogg', 100, 0)
	for(var/mob/living/L in view(7, usr))
		if(L == usr)
			continue
		if(L.flags & FAKEDEATH)
			L << "<span class='velvet_large'><b>UQ NA IEJ JSS.</b></span>"
		else
			if(L.ear_deaf)
				L << "<span class='warning'>...but you can't hear it!</span>" //Lucky lucky
				return
			L.confused += 3
			L.dir = pick(cardinal)
	..()
	return 1
