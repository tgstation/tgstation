/datum/action/innate/darkspawn
	name = "darkspawn ability"
	var/id //The ability's ID, for giving, taking and such
	desc = "This probably shouldn't exist."
	icon_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"

	var/psi_cost = 0 //How much psi the ability costs to use
	var/lucidity_price = 0 //How much lucidity the ability costs to buy; if this is 0, it isn't listed on the catalog
	var/blacklisted = FALSE //If the ability can't be gained from the psi web
	var/in_use = FALSE //For channeled/cast-time abilities
	var/datum/antagonist/darkspawn/darkspawn //Linked antag datum for drawing lucidity and psi

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


/datum/action/innate/darkspawn/test_ability
	name = "Test Ability"
	id = "test_ability"
	desc = "This is a test ability. Costs 20 Psi."
	lucidity_price = 1
	psi_cost = 20

/datum/action/innate/darkspawn/test_ability/Activate()
	to_chat(owner, "<span class='velvet'>Nice, you used an ability!</span>")
	return TRUE
