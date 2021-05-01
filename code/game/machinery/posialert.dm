//POSITRONIC ALERT CONSOLE
//Allows a ghost to click on it, giving an alert and playing a 'ping' noise to remind scatterbrained roboticists that posibrains are a thing
/obj/machinery/posialert
	name = "automated positronic alert console"
	desc = "A console that will ping when a positronic personality is available for download."
	icon = 'icons/obj/machines/terminals.dmi'
	icon_state = "posialert"
	var/inuse = FALSE

/obj/machinery/posialert/attack_ghost(mob/user)
	. = ..()
	if(inuse)
		return
	inuse = TRUE
	flick("posialertflash", src)
	say("There are positronic personalities available.")
	playsound(loc, 'sound/machines/ping.ogg', 50)
	addtimer(CALLBACK(src, /obj/machinery/posialert.proc/liftcooldown), 30 SECONDS)

/obj/machinery/posialert/proc/liftcooldown()
	inuse = FALSE
