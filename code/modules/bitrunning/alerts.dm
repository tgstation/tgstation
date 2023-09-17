/atom/movable/screen/alert/bitrunning
	name = "Generic Bitrunning Alert"
	icon_state = "template"
	timeout = 10 SECONDS

/atom/movable/screen/alert/bitrunning/netpod_crowbar
	name = "Forced Entry"
	desc = "Someone is prying open the netpod door. Find an exit."

/atom/movable/screen/alert/bitrunning/netpod_damaged
	name = "Integrity Compromised"
	desc = "The netpod is damaged. Find an exit."

/atom/movable/screen/alert/bitrunning/qserver_shutting_down
	name = "Domain Rebooting"
	desc = "The domain is rebooting. Find an exit."

/atom/movable/screen/alert/bitrunning/qserver_threat_deletion
	name = "Queue Deletion"
	desc = "The server is resetting. Oblivion awaits."

/atom/movable/screen/alert/bitrunning/qserver_threat_spawned
	name = "Threat Detected"
	desc = "Data stream abnormalities present."

/atom/movable/screen/alert/bitrunning/qserver_domain_complete
	name = "Domain Completed"
	desc = "The domain is completed. Activate to exit."
	timeout = 20 SECONDS

/atom/movable/screen/alert/bitrunning/qserver_domain_complete/Click(location, control, params)
	if(..())
		return

	var/mob/living/living_owner = owner
	if(!isliving(living_owner))
		return

	if(tgui_alert(living_owner, "Disconnect safely?", "Server Message", list("Exit", "Remain"), 10 SECONDS) == "Exit")
		SEND_SIGNAL(living_owner, COMSIG_BITRUNNER_SAFE_DISCONNECT)
