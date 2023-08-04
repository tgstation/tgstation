/atom/movable/screen/alert/netpod_crowbar
	name = "Forced Entry"
	icon_state = "template"
	desc = "Someone is prying open the netpod door. Find an exit."
	timeout = 10 SECONDS

/atom/movable/screen/alert/netpod_damaged
	name = "Integrity Compromised"
	icon_state = "template"
	desc = "The net pod is damaged. Find an exit."
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

/atom/movable/screen/alert/qserver_threat_deletion
	name = "Queue Deletion"
	icon_state = "template"
	desc = "The server is resetting. Oblivion awaits."
	timeout = 10 SECONDS

/atom/movable/screen/alert/qserver_domain_complete/Click(location, control, params)
	if(..())
		return

	var/mob/living/living_owner = owner
	if(!isliving(living_owner))
		return

	if(tgui_alert(living_owner, "Disconnect safely?", "Server Message", list("Exit", "Remain"), 10 SECONDS) == "Exit")
		SEND_SIGNAL(living_owner.mind, COMSIG_BITRUNNER_SAFE_DISCONNECT)

/datum/status_effect/grouped/embryonic
	id = "embryonic"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/embryonic

/atom/movable/screen/alert/status_effect/embryonic
	name = "Embryonic Stasis"
	icon_state = "netpod_stasis"
	desc = "You feel like you're in a dream."
