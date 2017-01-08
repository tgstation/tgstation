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


