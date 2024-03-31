/* PROC TO MANAGE LEVELLING UP THIS WAY */
/datum/antagonist/bloodsucker/proc/ForcedRankUp() //I hate this.
	set waitfor = FALSE
	if(!owner || !owner.current)
		return
	bloodsucker_level_unspent ++
	// Spend Rank Immediately?
	if(istype(owner.current.loc, /obj/structure/closet/crate/coffin)) //Hacky workaround.
		SpendRank()
	else
		to_chat(owner, span_notice("You have forced your powers to further through the power of blood; Sleep within your lair to claim your boon."))
		if(bloodsucker_level_unspent >= 2)
			to_chat(owner, span_notice("Bloodsucker Tip: If you cannot find or steal a coffin to use, you can build one from wooden planks."))

/datum/action/cooldown/bloodsucker/levelup
	name = "Forced Evolution"
	desc = "Spend the lovely sanguine running through your veins; aging you at an accelerated rate."
	button_icon_state = "power_feed"
	var/total_uses = 1
	bloodcost = 50
	cooldown_time = 50
	power_flags = BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_WHILE_STAKED|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|BLOODSUCKER_DEFAULT_POWER

/datum/action/cooldown/bloodsucker/levelup/ActivatePower()
	if(total_uses >= 10)
		to_chat(owner, span_bolddanger("The power of blood simply isn't enough to advance further... Age must suffice, from now on."))
		return
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(istype(bloodsuckerdatum))
		bloodsuckerdatum.ForcedRankUp()	// Rank up! Must still be in a coffin to level!
	total_uses++
	bloodcost = total_uses * 20 //By default, it's 50 blood, then 100, etc etc.
	if(total_uses == 4)
		to_chat(owner, span_revenbignotice("With the next use; you can't help but feel your true nature will become visible to all that gaze upon your visage! OOC: This will costitute a breach of the Masquerade and show you're a vampire!"))
	if(total_uses == 5) //you're fucked.
		bloodsuckerdatum.owner.current.remove_traits(TRAIT_DISFIGURED, BLOODSUCKER_TRAIT) //Disfigures them.
		bloodsuckerdatum.break_masquerade() //Killing people to get this far should break the masquerade.
		to_chat(owner, span_danger("You've broken the Masquerade, and revealed yourself for the blood-theiving, murdering parasite you are! Vampires and Crew will attempt to hunt you... But isn't that what you want? Fresh blood for your fangs..."))
		for(var/datum/action/cooldown/bloodsucker/power as anything in bloodsuckerdatum.powers)
			if(istype(power, /datum/action/cooldown/bloodsucker/masquerade) || istype(power, /datum/action/cooldown/bloodsucker/veil))
				bloodsuckerdatum.RemovePower(power)
