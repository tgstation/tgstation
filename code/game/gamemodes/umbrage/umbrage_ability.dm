/datum/action/innate/umbrage
	name = "umbrage ability"
	var/id //The ability's ID, for giving, taking and such
	desc = "This probably shouldn't exist."
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	var/psi_cost = 0
	var/lucidity_cost = 0 //How much lucidity the ability costs to buy; if this is 0, it isn't listed on the catalog
	var/blacklisted = 1 //If the ability can't be gained from the psi web
	var/datum/umbrage/linked_umbrage //Our linked umbrage datum

/datum/action/innate/umbrage/Trigger()
	var/successful_activation = 0
	if(!IsAvailable())
		return
	successful_activation = Activate()
	if(successful_activation)
		var/datum/umbrage/U = linked_umbrage
		if(U)
			U.use_psi(psi_cost)

/datum/action/innate/umbrage/IsAvailable()
	var/datum/umbrage/U = linked_umbrage
	if(!U)
		return
	if(U.psi < psi_cost)
		return
	return ..()
