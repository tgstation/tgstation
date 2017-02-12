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

/obj/screen/ghost/pai
	name = "pAI Candidate"
	icon_state = "pai"

/obj/screen/ghost/pai/Click()
	var/mob/dead/observer/G = usr
	G.register_pai()

/datum/hud/ghost/New(mob/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	..()
	var/mob/dead/observer/G = mymob
	if(!G.client.prefs.ghost_hud)
		mymob.client.screen = null
		return

	var/obj/screen/using

	using = new /obj/screen/ghost/jumptomob()
	using.screen_loc = ui_ghost_jumptomob
	static_inventory += using

	using = new /obj/screen/ghost/orbit()
	using.screen_loc = ui_ghost_orbit
	static_inventory += using

	using = new /obj/screen/ghost/reenter_corpse()
	using.screen_loc = ui_ghost_reenter_corpse
	static_inventory += using

	using = new /obj/screen/ghost/teleport()
	using.screen_loc = ui_ghost_teleport
	static_inventory += using

	using = new /obj/screen/ghost/pai()
	using.screen_loc = ui_ghost_pai
	static_inventory += using


/datum/hud/ghost/show_hud()
	var/mob/dead/observer/G = mymob
	mymob.client.screen = list()
	for(var/thing in plane_masters)
		mymob.client.screen += plane_masters[thing]
	create_parallax()
	if(G.client.prefs.ghost_hud)
		mymob.client.screen += static_inventory


/mob/dead/observer/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/ghost(src, ui_style2icon(client.prefs.UI_style))
