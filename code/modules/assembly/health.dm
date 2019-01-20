/obj/item/assembly/health
	name = "health sensor"
	desc = "Used for scanning and monitoring health."
	icon_state = "health"
	materials = list(MAT_METAL=800, MAT_GLASS=200)
	attachable = TRUE
	secured = FALSE

	var/scanning = FALSE
	var/health_scan
	var/alarm_health = HEALTH_THRESHOLD_CRIT

/obj/item/assembly/health/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Use a multitool to swap between \"detect death\" mode and \"detect critical state\" mode.</span>")

/obj/item/assembly/health/activate()
	if(!..())
		return FALSE//Cooldown check
	toggle_scan()
	return TRUE

/obj/item/assembly/health/toggle_secure()
	secured = !secured
	if(secured && scanning)
		START_PROCESSING(SSobj, src)
	else
		scanning = FALSE
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured

/obj/item/assembly/health/multitool_act(mob/living/user, obj/item/I)
	if(alarm_health == HEALTH_THRESHOLD_CRIT)
		alarm_health = HEALTH_THRESHOLD_DEAD
		to_chat(user, "<span class='notice'>You toggle [src] to \"detect death\" mode.</span>")
	else
		alarm_health = HEALTH_THRESHOLD_CRIT
		to_chat(user, "<span class='notice'>You toggle [src] to \"detect critical state\" mode.</span>")
	return TRUE

/obj/item/assembly/health/process()
	if(!scanning || !secured)
		return

	var/atom/A = src
	if(connected && connected.holder)
		A = connected.holder

	for(A, A && !ismob(A), A=A.loc);
	// like get_turf(), but for mobs.
	var/mob/living/M = A

	if(M)
		health_scan = M.health
		if(health_scan <= alarm_health)
			pulse()
			audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*")
			playsound(src, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
			toggle_scan()
		return
	return

/obj/item/assembly/health/proc/toggle_scan()
	if(!secured)
		return 0
	scanning = !scanning
	if(scanning)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	return

/obj/item/assembly/health/ui_interact(mob/user as mob)//TODO: Change this to the wires thingy
	. = ..()
	if(!secured)
		user.show_message("<span class='warning'>The [name] is unsecured!</span>")
		return FALSE
	var/dat = "<TT><B>Health Sensor</B></TT>"
	dat += "<BR><A href='?src=[REF(src)];scanning=1'>[scanning?"On":"Off"]</A>"
	if(scanning && health_scan)
		dat += "<BR>Health: [health_scan]"
	user << browse(dat, "window=hscan")
	onclose(user, "hscan")

/obj/item/assembly/health/Topic(href, href_list)
	..()
	if(!ismob(usr))
		return

	var/mob/user = usr

	if(!user.canUseTopic(src))
		usr << browse(null, "window=hscan")
		onclose(usr, "hscan")
		return

	if(href_list["scanning"])
		toggle_scan()

	if(href_list["close"])
		usr << browse(null, "window=hscan")
		return

	attack_self(user)
	return
