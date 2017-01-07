/datum/action/innate/umbrage
	name = "umbrage adction"
	desc = "This probably shouldn't exist."
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	var/mana_cost = 0

/datum/action/innate/umbrage/Activate()
	..()
	if(usr.mind.umbrage_psionics)
		usr.mind.umbrage_psionics.use_mana(mana_cost)

/datum/action/innate/umbrage/IsAvailable()
	if(!usr)
		return
	var/datum/umbrage/U = usr.mind.umbrage_psionics
	if(!U)
		return
	if(U.mana < mana_cost)
		usr << "<span class='warning'>Your mind is too weak! Restore your mana first!</span>"
		return
	return ..()

//Mindlink: Basic hive mind. Umbrages can communicate silently to their allies on the same z.
/datum/action/innate/umbrage/umbrage_comms
	name = "Mindlink"
	desc = "Silently speak to your allies on the same z-level."
	button_icon_state = "umbrage_mindlink"
	check_flags = AB_CHECK_CONSCIOUS
	mana_cost = 10

/datum/action/innate/umbrage/umbrage_comms/Activate()
	var/message = stripped_input(usr, "Enter a message to tell your nearby allies.", "Mindlink", "")
	if(!message || !IsAvailable())
		return
	var/processed_message
	if(is_umbrage(usr.mind))
		if(!is_umbrage_progenitor(usr.mind))
			processed_message = "<span class='velvet'><b>\[Mindlink\] Umbrage [usr.real_name]:</b> \"[message]\"</span>"
		else
			processed_message = "<font size=3><span class='velvet'><b>\[Mindlink\] Progenitor [usr.real_name]:</b> \"[message]\"</span></font>" //Progenitors get big spooky text
	else if(is_veil(usr.mind))
		processed_message = "<span class='velvet'><b>\[Mindlink\] [usr.real_name]:</b> \"[message]\""
	else
		return 0 //How are you doing this in the first place?
	usr << "<span class='velvet_bold'>saa'teo</span>"
	for(var/V in ticker.mode.umbrages_and_veils)
		var/datum/mind/M = V
		if(M.current.z != usr.z)
			if(prob(10))
				M.current << "<span class='warning'>Your mindlink trembles with words, but you're too far away to make it out...</span>"
			continue
		else
			M.current << processed_message
	for(var/mob/M in dead_mob_list)
		M << processed_message
	..()
	return 1

//Pass: An all-purpose utility ability on a short cooldown. Morphs the caster's active hand into a tendril with many uses.
/datum/action/innate/umbrage/umbrage_pass
	name = "Pass"
	desc = "Change your active hand into a tendril with many uses."
	button_icon_state = "umbrage_pass"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	mana_cost = 5
	var/precise = 0 //Accuracy upgrade for mobility

/datum/action/innate/umbrage/umbrage_pass/Activate()
	var/mob/living/carbon/human/H = usr
	H.visible_message("<span class='warning'>[H]'s arm contorts into tentacles!</span>", "<span class='velvet_bold'>luu...</span>")
	playsound(H, 'sound/items/umbrage_pass_form.ogg', 50, 1)
	var/obj/item/weapon/umbrage_pass/P = new
	P.precise = precise
	P.linked_user = H
	H.put_in_hands(P)
	active = 1

/datum/action/innate/umbrage/umbrage_pass/Deactivate()
	var/deleted_tendrils = 0
	for(var/obj/item/weapon/umbrage_pass/P in usr)
		P.use_mana(UMBRAGE_PASS_COST_DISMISS)
		qdel(P)
		deleted_tendrils = 1
	if(deleted_tendrils)
		usr.visible_message("<span class='warning'>[usr]'s tentacles twist into an arm!</span>", "<span class='velvet_bold'>...han</span>")
		playsound(usr, 'sound/items/umbrage_pass_fade.ogg', 50, 1)
	active = 0
	..()

/obj/item/weapon/umbrage_pass
	name = "shadowy tendrils"
	desc = "A cluster of black tendrils emitting plumes of smoke."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "umbrage_pass"
	item_state = "umbrage_pass"
	flags = NODROP | CONDUCT
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF
	w_class = 5
	var/mob/living/carbon/human/linked_user
