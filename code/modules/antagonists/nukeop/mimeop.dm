
/datum/antagonist/nukeop/mimeop
	name = "Mime Operative"
	roundend_category = "mime operatives"
	antagpanel_category = "MimeOp"
	nukeop_outfit = /datum/outfit/syndicate/mimeop

/datum/antagonist/nukeop/leader/mimeop
	name = "Mime Operative Leader"
	roundend_category = "mime operatives"
	antagpanel_category = "MimeOp"
	nukeop_outfit = /datum/outfit/syndicate/mimeop/leader

/datum/antagonist/nukeop/leader/mimeop/give_alias()
	title = pick("Silent Shojin", "Wallweaver", "Mime Master", "Wordbearer")
	if(nuke_team && nuke_team.syndicate_name)
		owner.current.real_name = "[nuke_team.syndicate_name] [title]"
	else
		owner.current.real_name = "Syndicate [title]"

/datum/antagonist/nukeop/mimeop/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = "Mime Operative"
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has mime op'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has mime op'ed [key_name(new_owner)].")
