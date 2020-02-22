/obj/item/card/emag/budget
	desc = "It's a card with a magnetic strip attached to some circuitry. This one appears to be a crude knockoff with a digital counter on closer inspection."
	name = "budget cryptographic sequencer"
	var/charges = 2
	var/cooldown = 300 //300 deciseconds
	var/timestamp

/obj/item/card/emag/budget/Initialize()
	. = ..()
	maptext = "[charges]"


/obj/item/card/emag/budget/afterattack(atom/target, mob/user, proximity)
	if(!charges)
		to_chat(user, "<span class='warning'>[src] is out of charges and needs [((timestamp + cooldown) - world.time) / 10] more seconds to recharge!</span>")
		return

	if(check_emag_status(target)) //Check whether it's already emagged; if so, no need to progress.
		return

	. = ..()

	if(!check_emag_status(target))
		return

	charges = max(charges - 1, 0)
	maptext = "[charges]"
	timestamp = world.time
	to_chat(user, "<span class='warning'>[src] has expended a charge and has [charges] charges remaining. It will regain a charge in [((timestamp + cooldown) - world.time) / 10] seconds.</span>")
	addtimer(CALLBACK(src, .proc/recharge), cooldown) //recharge proc

/obj/item/card/emag/budget/proc/recharge()
	charges = min(charges + 1, 2)
	maptext = "[charges]"
	playsound(loc, SEC_BODY_CAM_SOUND, get_clamped_volume(), TRUE, -1)

/obj/item/card/emag/budget/proc/check_emag_status(atom/A)
	if(!A)
		return FALSE

	if(istype(A, /obj))
		var/obj/O = A
		if(O.obj_flags & EMAGGED)
			return TRUE

	if(istype(A, /mob/living/simple_animal/bot))
		var/mob/living/simple_animal/bot/B = A
		if(!B.emagged)
			return TRUE

	if(istype(A, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = A
		if(!R.emagged)
			return TRUE

	return FALSE