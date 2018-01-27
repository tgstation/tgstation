/datum/action/innate/darkspawn
	name = "darkspawn ability"
	var/id //The ability's ID, for giving, taking and such
	desc = "This probably shouldn't exist."
	icon_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"

	var/psi_cost = 0 //How much psi the ability costs to use
	var/psi_addendum = "" //If applicable, descriptive text shown after the cost
	var/lucidity_price = 0 //How much lucidity the ability costs to buy; if this is 0, it isn't listed on the catalog
	var/blacklisted = FALSE //If the ability can't be gained from the psi web
	var/in_use = FALSE //For channeled/cast-time abilities
	var/datum/antagonist/darkspawn/darkspawn //Linked antag datum for drawing lucidity and psi

/datum/action/innate/darkspawn/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/innate/darkspawn/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/innate/darkspawn/process()
	UpdateButtonIcon() //so as to be consistent with psi costs and situational requirements, keep the button updated

/datum/action/innate/darkspawn/Trigger()
	var/activated = FALSE
	if(!IsAvailable())
		return
	if(!active)
		activated = Activate()
	else
		activated = Deactivate()
	if(darkspawn)
		darkspawn.use_psi(psi_cost * activated)

/datum/action/innate/darkspawn/IsAvailable()
	if(!darkspawn)
		return
	if(!darkspawn.has_psi(psi_cost))
		return
	if(in_use)
		return
	. = ..()

/datum/action/innate/darkspawn/proc/reset()
	in_use = FALSE
