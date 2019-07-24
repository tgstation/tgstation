/obj/screen/infection/InfectionSporeHelp
	icon_state = "help_hud"
	name = "Infection Help"
	desc = "Help on playing the infection!"

/obj/screen/infection/InfectionSporeHelp/Click()
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/I = usr
	I.infection_help()

/obj/screen/infection/Refund
	icon_state = "revert_hud"
	name = "Revert Evolutions"
	desc = "Refund all currently purchased traits. Refunds half the points you've spent, but refunds all of them if the infectious core has not landed."

/obj/screen/infection/Refund/Click()
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/I = usr
	I.refund_upgrades()

/obj/screen/infection/EvolveSpore
	icon_state = "upgrade_hud"
	name = "Evolution"
	desc = "Purchase traits that make you stronger."

/obj/screen/infection/EvolveSpore/Click()
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/I = usr
	I.evolve_menu()

/obj/screen/infection/Respawn
	icon_state = "core_hud"
	name = "Respawn"
	desc = "Lets you come back from the dead once you have finished reforming."

/obj/screen/infection/Respawn/Click()
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/I = usr
	I.do_spawn()

/datum/hud/infection_spore/New(mob/owner)
	..()
	var/obj/screen/using

	infectionpwrdisplay = new /obj/screen()
	infectionpwrdisplay.name = "infection power"
	infectionpwrdisplay.icon_state = "block"
	infectionpwrdisplay.screen_loc = ui_health
	infectionpwrdisplay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	infectionpwrdisplay.layer = ABOVE_HUD_LAYER
	infectionpwrdisplay.plane = ABOVE_HUD_PLANE
	infodisplay += infectionpwrdisplay

	healths = new /obj/screen/healths/blob()
	infodisplay += healths

	using = new /obj/screen/infection/InfectionSporeHelp()
	using.screen_loc = ui_back
	static_inventory += using

	using = new /obj/screen/infection/Refund()
	using.screen_loc = ui_hand_position(2)
	static_inventory += using

	using = new /obj/screen/infection/EvolveSpore()
	using.screen_loc = ui_hand_position(1)
	static_inventory += using

	using = new /obj/screen/infection/Respawn()
	using.screen_loc = ui_storage1
	static_inventory += using
