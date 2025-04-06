/atom/movable/screen/alert/bitrunning
	name = "Generic Bitrunning Alert"
	icon_state = "template"
	timeout = 10 SECONDS

/atom/movable/screen/alert/bitrunning/qserver_domain_complete
	name = "Domain Completed"
	desc = "The domain is completed. Activate to exit."
	timeout = 20 SECONDS
	clickable_glow = TRUE

/atom/movable/screen/alert/bitrunning/qserver_domain_complete/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/mob/living/living_owner = owner
	if(!isliving(living_owner))
		return

	if(tgui_alert(living_owner, "Disconnect safely?", "Server Message", list("Exit", "Remain"), 10 SECONDS) == "Exit")
		SEND_SIGNAL(living_owner, COMSIG_BITRUNNER_ALERT_SEVER)

