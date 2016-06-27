/datum/objective/devil
	dangerrating = 5

/datum/objective/devil/soulquantity
	explanation_text = "You shouldn't see this text.  Error:DEVIL1"
	var/quantity = 4

/datum/objective/devil/soulquantity/New()
	quantity = pick(6,8)
	explanation_text = "Purchase, and retain control over at least [quantity] souls."

/datum/objective/devil/soulquantity/check_completion()
	var/count = 0
	for(var/S in owner.devilinfo.soulsOwned)
		var/datum/mind/L = S
		if(L.soulOwner != L)
			count++
	return count >= quantity

/datum/objective/devil/soulquality
	explanation_text = "You shouldn't see this text.  Error:DEVIL2"
	var/contractType
	var/quantity

/datum/objective/devil/soulquality/New()
	contractType = pick(CONTRACT_POWER, CONTRACT_WEALTH, CONTRACT_PRESTIGE, CONTRACT_MAGIC, CONTRACT_REVIVE, CONTRACT_KNOWLEDGE/*, CONTRACT_UNWILLING*/)
	var/contractName
	quantity = pick(1,2)
	switch(contractType)
		if(CONTRACT_POWER)
			contractName = "for power"
		if(CONTRACT_WEALTH)
			contractName = "for wealth"
		if(CONTRACT_PRESTIGE)
			contractName = "for prestige"
		if(CONTRACT_MAGIC)
			contractName = "for magic"
		if(CONTRACT_REVIVE)
			contractName = "of revival"
		if(CONTRACT_KNOWLEDGE)
			contractName = "for knowledge"
		//if(CONTRACT_UNWILLING)	//Makes round unfun.
		//	contractName = "against their will"
	explanation_text = "Have mortals sign at least [quantity] contracts [contractName]"

/datum/objective/devil/soulquality/check_completion()
	var/count = 0
	for(var/S in owner.devilinfo.soulsOwned)
		var/datum/mind/L = S
		if(L.soulOwner != L && L.damnation_type == contractType)
			count++
	return count>=quantity

/datum/objective/devil/sintouch
	var/quantity

/datum/objective/devil/sintouch/New()
	quantity = pick(4,5)
	explanation_text = "Ensure at least [quantity] mortals are sintouched."

/datum/objective/devil/sintouch/check_completion()
	return quantity>=ticker.mode.sintouched.len