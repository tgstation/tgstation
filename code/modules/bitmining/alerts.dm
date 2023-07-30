/atom/movable/screen/alert/netpod_crowbar
	name = "Forced Entry"
	icon_state = "template"
	desc = "Someone is prying open the netpod door. Find an exit."
	timeout = 10 SECONDS

/atom/movable/screen/alert/qserver_shutting_down
	name = "Domain Rebooting"
	icon_state = "template"
	desc = "The domain is rebooting. Find an exit."
	timeout = 10 SECONDS

/atom/movable/screen/alert/qserver_domain_complete
	name = "Domain Completed"
	icon_state = "template"
	desc = "The domain is completed. Activate to exit."
	timeout = 20 SECONDS

/atom/movable/screen/alert/qserver_domain_complete/Click(location, control, params)
	if(..())
		return

	var/mob/living/living_owner = owner
	if(!isliving(living_owner))
		return

	if(tgui_alert(living_owner, "You may choose to exit safely or remain indefinitely.", "Disconnect", list("Exit", "Remain"), 10 SECONDS) == "Exit")
		SEND_SIGNAL(living_owner.mind, COMSIG_BITMINING_SAFE_DISCONNECT)
