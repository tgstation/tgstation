#define SHOWCASE_CONSTRUCTED 1
#define SHOWCASE_SCREWDRIVERED 2

/*Completely generic structures for use by mappers to create fake objects, i.e. display rooms*/
/obj/structure/showcase
	name = "showcase"
	icon = 'icons/obj/fluff/general.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = TRUE
	anchored = TRUE
	var/deconstruction_state = SHOWCASE_CONSTRUCTED

/obj/structure/showcase/fakeid
	name = "\improper CentCom identification console"
	desc = "You can use this to change ID's."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"

/obj/structure/showcase/fakeid/Initialize(mapload)
	. = ..()
	add_overlay("id")
	add_overlay("id_key")

/obj/structure/showcase/fakesec
	name = "\improper CentCom security records"
	desc = "Used to view and edit personnel's security records."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"

/obj/structure/showcase/fakesec/update_overlays()
	. = ..()
	. += "security"
	. += "security_key"

/obj/structure/showcase/horrific_experiment
	name = "horrific experiment"
	desc = "Some sort of pod filled with blood and viscera. You swear you can see it moving..."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_g" // Please don't delete it and not notice it for months this time.

/obj/structure/showcase/machinery/oldpod
	name = "damaged cryogenic pod"
	desc = "A damaged cryogenic pod long since lost to time, including its former occupant..."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper-open"

/obj/structure/showcase/machinery/oldpod/used
	name = "opened cryogenic pod"
	desc = "A cryogenic pod that has recently discharged its occupant. The pod appears non-functional."

/obj/structure/showcase/machinery/oldpod/used/psyker
	name = "opened mental energizer"
	desc = "A mental energizer that has recently discharged its occupant. The pod appears non-functional."
	icon_state = "psykerpod-open"

/obj/structure/showcase/cyborg/old
	name = "Cyborg Statue"
	desc = "An old, deactivated cyborg. Whilst once actively used to guard against intruders, it now simply intimidates them with its cold, steely gaze."
	icon = 'icons/mob/silicon/robots.dmi'
	icon_state = "robot_old"
	density = FALSE

/obj/structure/showcase/mecha/marauder
	name = "combat mech exhibit"
	desc = "A stand with an empty old Nanotrasen Corporation combat mech bolted to it. It is described as the premier unit used to defend corporate interests and employees."
	icon = 'icons/mob/rideables/mecha.dmi'
	icon_state = "marauder"

/obj/structure/showcase/mecha/ripley
	name = "construction mech exhibit"
	desc = "A stand with a retired construction mech bolted to it. The clamps are rated at 9300PSI. It seems to be falling apart."
	icon = 'icons/mob/rideables/mecha.dmi'
	icon_state = "firefighter"

/obj/structure/showcase/machinery/implanter
	name = "\improper Nanotrasen automated mindshield implanter exhibit"
	desc = "A flimsy model of a standard Nanotrasen automated mindshield implant machine. With secure positioning harnesses and a robotic surgical injector, brain damage and other serious medical anomalies are now up to 60% less likely!"
	icon = 'icons/obj/machines/implant_chair.dmi'
	icon_state = "implantchair"

/obj/structure/showcase/machinery/microwave
	name = "\improper Nanotrasen-brand microwave"
	desc = "The famous Nanotrasen-brand microwave, the multi-purpose cooking appliance every station needs! This one appears to be drawn onto a cardboard box."
	icon = 'icons/obj/machines/microwave.dmi'
	icon_state = "mw_complete"

/obj/structure/showcase/machinery/microwave_engineering
	name = "\improper Nanotrasen Wave(tm) microwave"
	desc = "Just when everyone thought Nanotrasen couldn't improve on their famous microwave, this 2563 model features Wave™! A Nanotrasen exclusive, Wave™ allows your PDA to be charged wirelessly through microwave frequencies. Because nothing says 'future' like charging your PDA while overcooking your leftovers. Nanotrasen Wave™ - Multitasking, redefined."
	icon = 'icons/obj/machines/microwave.dmi'
	icon_state = "engi_mw_complete"

/obj/structure/showcase/machinery/cloning_pod
	name = "cloning pod exhibit"
	desc = "Depicts a prototype from a failed attempt at reliable cloning technology. The technology was scrapped after reports of severe mutations, wiggly ear syndrome and spontaneous tail growth. The date 11.11.2558 is engraved on the base."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"

/obj/structure/showcase/perfect_employee
	name = "'Perfect Man' employee exhibit"
	desc = "A stand with a model of the perfect Nanotrasen Employee bolted to it. Signs indicate it is robustly genetically engineered, as well as being ruthlessly loyal."

/obj/structure/showcase/machinery/tv
	name = "\improper Nanotrasen corporate newsfeed"
	desc = "A slightly battered looking TV. Various Nanotrasen infomercials play on a loop, accompanied by a jaunty tune."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "television"

/obj/structure/showcase/machinery/signal_decrypter
	name = "subsystem signal decrypter"
	desc = "A strange machine that's supposedly used to help pick up and decrypt wave signals."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "processor"

/obj/structure/showcase/wizard
	name = "wizard of yendor showcase"
	desc = "A historical figure of great importance to the wizard federation. He spent his long life learning magic, stealing artifacts, and harassing idiots with swords. May he rest forever, Rodney."
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "nim"

/obj/structure/showcase/machinery/rng
	name = "byond random number generator"
	desc = "A strange machine supposedly from another world. The Wizard Federation has been meddling with it for years."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "processor"

/obj/structure/showcase/katana
	name = "seppuku katana"
	density = 0
	desc = "Welp, only one way to recover your honour."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "katana"

//Deconstructing
//Showcases can be any sprite, so it makes sense that they can't be constructed.
//However if a player wants to move an existing showcase or remove one, this is for that.

/obj/structure/showcase/screwdriver_act(mob/living/user, obj/item/tool)
	if(anchored)
		return FALSE
	if(deconstruction_state == SHOWCASE_SCREWDRIVERED)
		to_chat(user, span_notice("You screw the screws back into the showcase."))
		tool.play_tool_sound(src, 100)
		deconstruction_state = SHOWCASE_CONSTRUCTED
	else if (deconstruction_state == SHOWCASE_CONSTRUCTED)
		to_chat(user, span_notice("You unscrew the screws."))
		tool.play_tool_sound(src, 100)
		deconstruction_state = SHOWCASE_SCREWDRIVERED
	return ITEM_INTERACT_SUCCESS

/obj/structure/showcase/crowbar_act(mob/living/user, obj/item/tool)
	if(!tool.use_tool(src, user, 2 SECONDS, volume=100))
		return
	to_chat(user, span_notice("You start to crowbar the showcase apart..."))
	new /obj/item/stack/sheet/iron(drop_location(), 4)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/showcase/wrench_act(mob/living/user, obj/item/tool)
	if(deconstruction_state != SHOWCASE_CONSTRUCTED)
		return FALSE
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

//Feedback is given in examine because showcases can basically have any sprite assigned to them

/obj/structure/showcase/examine(mob/user)
	. = ..()

	switch(deconstruction_state)
		if(SHOWCASE_CONSTRUCTED)
			. += "It's fully constructed."
		if(SHOWCASE_SCREWDRIVERED)
			. += "It has its screws loosened."
		else
			. += "If you see this, something is wrong."

#undef SHOWCASE_CONSTRUCTED
#undef SHOWCASE_SCREWDRIVERED
