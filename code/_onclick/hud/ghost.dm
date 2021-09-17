/obj/screen/ghost
	icon = 'icons/hud/screen_ghost.dmi'

/obj/screen/ghost/MouseEntered(location, control, params)
	. = ..()
	flick(icon_state + "_anim", src)

/obj/screen/ghost/spawners_menu
	name = "Spawners menu"
	icon_state = "spawners"

/obj/screen/ghost/spawners_menu/Click()
	var/mob/dead/observer/observer = usr
	observer.open_spawners_menu()

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

/obj/screen/ghost/mafia
	name = "Mafia Signup"
	icon_state = "mafia"

/obj/screen/ghost/mafia/Click()
	var/mob/dead/observer/G = usr
	G.mafia_signup()

/datum/hud/ghost/New(mob/owner)
	..()
	var/obj/screen/using

	using = new /obj/screen/ghost/spawners_menu()
	using.screen_loc = ui_ghost_spawners_menu
	using.hud = src
	static_inventory += using

	using = new /obj/screen/ghost/orbit()
	using.screen_loc = ui_ghost_orbit
	using.hud = src
	static_inventory += using

	using = new /obj/screen/ghost/reenter_corpse()
	using.screen_loc = ui_ghost_reenter_corpse
	using.hud = src
	static_inventory += using

	using = new /obj/screen/ghost/teleport()
	using.screen_loc = ui_ghost_teleport
	using.hud = src
	static_inventory += using

	using = new /obj/screen/ghost/pai()
	using.screen_loc = ui_ghost_pai
	using.hud = src
	static_inventory += using

	using = new /obj/screen/ghost/mafia()
	using.screen_loc = ui_ghost_mafia
	using.hud = src
	static_inventory += using

	using = new /obj/screen/language_menu
	using.screen_loc = 	ui_ghost_language_menu
	using.icon = ui_style
	using.hud = src
	static_inventory += using

/datum/hud/ghost/show_hud(version = 0, mob/viewmob)
	// don't show this HUD if observing; show the HUD of the observee
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		plane_masters_update()
		return FALSE

	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	if(screenmob.client.prefs.read_preference(/datum/preference/toggle/ghost_hud))
		screenmob.client.screen += static_inventory
	else
		screenmob.client.screen -= static_inventory

//We should only see observed mob alerts.
/datum/hud/ghost/reorganize_alerts(mob/viewmob)
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		return
	. = ..()

