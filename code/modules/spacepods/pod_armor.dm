/datum/pod_armor
	var/armor_multiplier = 1 //max_integrity is multiplied by this
	var/name = "civ"
	var/icon_state = "pod_civ"
	var/light_color = null
	var/speed = 1

/datum/pod_armor/New()
	if(!icon_state)
		icon_state = "pod_[name]"

/datum/pod_armor/civ
	name = "civ"
	icon_state = "pod_civ"

/datum/pod_armor/security
	name = "mil"
	armor_multiplier = 1.42
	light_color = "#BBF093"
	icon_state = "pod_mil"
	speed = 1.05

/datum/pod_armor/industrial
	name = "industrial"
	armor_multiplier = 1.32
	light_color = "#CCCC00"
	icon_state = "pod_industrial"

/datum/pod_armor/gold
	name = "gold"
	armor_multiplier = 0.9
	icon_state = "pod_gold"
	speed = 0.8

/datum/pod_armor/syndicate
	name = "synd"
	armor_multiplier = 1.6
	icon_state = "pod_synd"

/datum/pod_armor/black
	name = "black"
	icon_state = "pod_black"