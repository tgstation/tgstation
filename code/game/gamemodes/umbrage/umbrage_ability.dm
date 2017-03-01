/datum/action/innate/umbrage
	name = "umbrage ability"
	var/id //The ability's ID, for giving, taking and such
	desc = "This probably shouldn't exist."
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	var/psi_cost = 0
	var/lucidity_cost = 0 //How much lucidity the ability costs to buy; if this is 0, it isn't listed on the catalog
	var/blacklisted = 1 //If the ability can't be gained from the psi web
	var/in_use = FALSE //For channeled/cast-time abilities
	var/datum/umbrage/linked_umbrage //Our linked umbrage datum

/datum/action/innate/umbrage/New()
	START_PROCESSING(SSobj, src)
	..()

/datum/action/innate/umbrage/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/action/innate/umbrage/process()
	UpdateButtonIcon() //This is to constantly check psi

/datum/action/innate/umbrage/Trigger()
	var/successful_activation = 0
	if(!IsAvailable())
		return
	if(!active)
		successful_activation = Activate()
	else
		successful_activation = Deactivate()
	if(successful_activation)
		var/datum/umbrage/U = linked_umbrage
		if(U)
			U.use_psi(psi_cost)

/datum/action/innate/umbrage/IsAvailable()
	if(!linked_umbrage)
		return
	if(!linked_umbrage.has_psi(psi_cost))
		return
	if(in_use)
		return
	return ..()
