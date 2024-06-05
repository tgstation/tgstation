/datum/ip_info
	var/is_loaded = FALSE
	var/is_whitelisted = FALSE

	var/ip
	var/ip_as
	var/ip_mobile
	var/ip_proxy
	var/ip_hosting

/client
	var/datum/ip_info/ip_info = new

/client/proc/Overwatch_ASN_panel()
	set category = "Server"
	set name = "Overwatch ASN Panel"

	if(!SSdbcore.Connect())
		to_chat(usr, span_warning("Failed to establish database connection"))
		return

	if(!check_rights(R_SERVER))
		return

	new /datum/overwatch_asn_panel(src)


/client/proc/Overwatch_WhitelistPanel()
	set category = "Server"
	set name = "Overwatch WL Panel"

	if(!SSdbcore.Connect())
		to_chat(usr, span_warning("Failed to establish database connection"))
		return

	if(!check_rights(R_BAN))
		return

	new /datum/overwatch_wl_panel(src)

