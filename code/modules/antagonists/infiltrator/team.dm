/datum/team/infiltrator
	name = "syndicate infiltration unit"
	member_name = "syndicate infiltrator"

/datum/team/infiltrator/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>Syndicate Infiltrators</span>"

	var/text = "<br><span class='header'>The syndicate infiltrators were:</span>"
	var/purchases = ""
	var/TC_uses = 0
	for(var/I in members)
		var/datum/mind/syndicate = I
		var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[syndicate.key]
		if(H)
			TC_uses += H.total_spent
			purchases += H.generate_render(show_key = FALSE)
	text += printplayerlist(members)
	text += "<br>"
	text += "(Syndicates used [TC_uses] TC) [purchases]"

	parts += text

/datum/team/infiltrator/is_gamemode_hero()
	return SSticker.mode.name == "infiltration"

/datum/team/infiltrator/proc/update_objectives()