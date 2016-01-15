/obj/screen/ghost
	icon = 'icons/mob/screen_ghost.dmi'

/obj/screen/ghost/MouseEntered()
	flick(icon_state + "_anim", src)

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

/datum/hud/proc/ghost_hud()
	var/mob/dead/observer/G = mymob
	if(!G.client.prefs.ghost_hud)
		mymob.client.screen -= adding
		return

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

	mymob.client.screen += adding
	return
