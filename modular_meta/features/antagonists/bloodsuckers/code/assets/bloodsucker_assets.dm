/datum/asset/simple/bloodsucker_icons

/datum/asset/simple/bloodsucker_icons/register()
	for(var/datum/bloodsucker_clan/clans as anything in typesof(/datum/bloodsucker_clan))
		if(!initial(clans.joinable_clan))
			continue
		add_bloodsucker_icon(initial(clans.join_icon), initial(clans.join_icon_state))

	for(var/datum/action/cooldown/bloodsucker/power as anything in subtypesof(/datum/action/cooldown/bloodsucker))
		add_bloodsucker_icon(initial(power.button_icon), initial(power.button_icon_state))

	return ..()

/datum/asset/simple/bloodsucker_icons/proc/add_bloodsucker_icon(bloodsucker_icon, bloodsucker_icon_state)
	assets[SANITIZE_FILENAME("bloodsucker.[bloodsucker_icon_state].png")] = icon(bloodsucker_icon, bloodsucker_icon_state)
