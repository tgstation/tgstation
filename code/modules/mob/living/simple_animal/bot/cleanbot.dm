//Cleanbot
/mob/living/simple_animal/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "cleanbot0"
	density = 0
	anchored = 0
	health = 25
	maxHealth = 25
	radio_key = /obj/item/device/encryptionkey/headset_service
	radio_channel = "Service" //Service
	bot_type = CLEAN_BOT
	model = "Cleanbot"
	bot_core_type = /obj/machinery/bot_core/cleanbot
	window_id = "autoclean"
	window_name = "Automatic Station Cleaner v1.2"
	pass_flags = PASSMOB
	var/datum/goap_agent/cleanbot/goap_ai

/mob/living/simple_animal/bot/cleanbot/Initialize()
	. = ..()
	icon_state = "cleanbot[on]"

	var/datum/job/janitor/J = new/datum/job/janitor
	access_card.access += J.get_access()
	prev_access = access_card.access
	goap_ai = new()
	goap_ai.agent = src
	goap_ai.given_pathfind_access = access_card

/mob/living/simple_animal/bot/cleanbot/emag_act(mob/user)
	var/last_emagged = emagged
	..()
	if(last_emagged != 2)
		goap_ai.our_actions += new /datum/goap_action/cleanbot/foam()
		goap_ai.our_actions += new /datum/goap_action/cleanbot/clean_faces()
/mob/living/simple_animal/bot/cleanbot/turn_on()
	..()
	icon_state = "cleanbot[on]"
	bot_core.updateUsrDialog()

/mob/living/simple_animal/bot/cleanbot/turn_off()
	..()
	icon_state = "cleanbot[on]"
	bot_core.updateUsrDialog()

/mob/living/simple_animal/bot/cleanbot/set_custom_texts()
	text_hack = "You corrupt [name]'s cleaning software."
	text_dehack = "[name]'s software has been reset!"
	text_dehack_fail = "[name] does not seem to respond to your repair code!"

/mob/living/simple_animal/bot/cleanbot/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(bot_core.allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] \the [src] behaviour controls.</span>")
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='notice'>\The [src] doesn't seem to respect your authority.</span>")
	else
		return ..()

/mob/living/simple_animal/bot/cleanbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, "<span class='danger'>[src] buzzes and beeps.</span>")

/mob/living/simple_animal/bot/cleanbot/handle_automated_action()
	if(!..())
		return

	if(prob(5))
		audible_message("[src] makes an excited beeping booping sound!")


/mob/living/simple_animal/bot/cleanbot/explode()
	on = 0
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/reagent_containers/glass/bucket(Tsec)

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if(prob(50))
		new /obj/item/bodypart/l_arm/robot(Tsec)

	do_sparks(3, TRUE, src)
	..()

/obj/machinery/bot_core/cleanbot
	req_one_access = list(GLOB.access_janitor, GLOB.access_robotics)


/mob/living/simple_animal/bot/cleanbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
Status: <A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A><BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"})
	return dat
