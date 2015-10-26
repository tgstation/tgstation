//TODO: add sec/med huds to ghosts
//TODO: pop-up buttons for cloning,defib,drones,holoparasites,slimes,etcetc
/obj/screen/ghost
	icon = 'icons/mob/screen_ghost.dmi'

/obj/screen/ghost/jumptomob
	name = "Jump to mob"
	icon_state = "jumptomob"

/obj/screen/ghost/jumptomob/Click()
	var/mob/dead/observer/G = usr
	G.jumptomob()

/obj/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"

/obj/screen/ghost/orbit/Click()
	var/mob/dead/observer/G = usr
	G.follow()

/obj/screen/ghost/reenter_corpse
	name = "Reenter corpse"
	icon_state = "reenter_corpse"

/obj/screen/ghost/reenter_corpse/Click()
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/obj/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"

/obj/screen/ghost/teleport/Click()
	var/mob/dead/observer/G = usr
	G.dead_tele()

/obj/screen/ghost/toggle_darkness
	name = "Toggle Darkness"
	icon_state = "toggle_darkness"

/obj/screen/ghost/toggle_darkness/Click()
	var/mob/dead/observer/G = usr
	G.toggle_darkness()

/obj/screen/ghost/toggle_ghostsee
	name = "Toggle Ghost Vision"
	icon_state = "toggle_ghostsee"

/obj/screen/ghost/toggle_ghostsee/Click()
	var/mob/dead/observer/G = usr
	G.toggle_ghostsee()

/obj/screen/ghost/toggle_inquisition
	name = "Toggle Inquisitiveness"
	icon_state = "toggle_inquisition"

/obj/screen/ghost/toggle_inquisition/Click()
	var/mob/dead/observer/G = usr
	G.toggle_inquisition()

/obj/screen/ghost/view_manifest
	name = "View Manifest"
	icon_state = "view_manifest"

/obj/screen/ghost/view_manifest/Click()
	var/mob/dead/observer/G = usr
	G.view_manifest()

/datum/hud/proc/ghost_hud()
	adding = list()

	var/obj/screen/using

	using = new /obj/screen/ghost/jumptomob()
	using.screen_loc = ui_ghost_jumptomob
	adding += using

	using = new /obj/screen/ghost/orbit()
	using.screen_loc = ui_ghost_orbit
	adding += using

	using = new /obj/screen/ghost/reenter_corpse()
	using.screen_loc = ui_ghost_reenter_corpse
	adding += using

	using = new /obj/screen/ghost/teleport()
	using.screen_loc = ui_ghost_teleport
	adding += using

	using = new /obj/screen/ghost/toggle_darkness()
	using.screen_loc = ui_ghost_toggle_darkness
	adding += using

	using = new /obj/screen/ghost/toggle_ghostsee()
	using.screen_loc = ui_ghost_toggle_ghostsee
	adding += using

	using = new /obj/screen/ghost/toggle_inquisition()
	using.screen_loc = ui_ghost_toggle_inquisition
	adding += using

	using = new /obj/screen/ghost/view_manifest()
	using.screen_loc = ui_ghost_view_manifest
	adding += using

	mymob.client.screen += adding
	return