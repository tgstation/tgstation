/obj/screen/infection/InfectionSporeHelp
	icon_state = "ui_help"
	name = "Infection Help"
	desc = "Help on playing the infection!"

/obj/screen/infection/InfectionSporeHelp/Click()
	var/mob/living/simple_animal/hostile/infection/infectionspore/I = usr
	I.infection_help()

/obj/screen/infection/EvolveSpore
	icon_state = "ui_swap"
	name = "Evolution"
	desc = "Purchase traits that make you stronger."

/obj/screen/infection/EvolveSpore/Click()
	var/mob/living/simple_animal/hostile/infection/infectionspore/I = usr
	I.evolve_menu()

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
	using.screen_loc = ui_hand_position(2)
	static_inventory += using

	using = new /obj/screen/infection/EvolveSpore()
	using.screen_loc = ui_hand_position(1)
	static_inventory += using
