#define SP_LINKED 1
#define SP_READY 2 
#define SP_LAUNCH 3
#define SP_UNLINK 4 
#define SP_UNREADY 5
#define POD_STANDARD 0
#define POD_BLUESPACE 1

/obj/item/supplypod_beacon
	name = "Supply Pod Beacon"
	desc = "A device that can be linked to an Express Supply Console for precision supply pod deliveries. Alt-click to remove link."
	icon = 'icons/obj/device.dmi'
	icon_state = "supplypod_beacon"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/obj/machinery/computer/cargo/express/express_console
	var/linked = FALSE
	var/ready = FALSE
	var/launched = FALSE

/obj/item/supplypod_beacon/proc/update_status(var/consoleStatus)
	switch(consoleStatus)
		if (SP_LINKED)
			linked = TRUE
			playsound(src,'sound/machines/twobeep.ogg',50,0)
		if (SP_READY)
			ready = TRUE
		if (SP_LAUNCH)
			launched = TRUE
			playsound(src,'sound/machines/triple_beep.ogg',50,0)
			playsound(loc,'sound/machines/warning-buzzer.ogg',50,0)
		if (SP_UNLINK)
			linked = FALSE
			playsound(src,'sound/machines/synth_no.ogg',50,0)
		if (SP_UNREADY)
			ready = FALSE
	update_icon()

/obj/item/supplypod_beacon/update_icon()
	cut_overlays()
	if (launched)
		add_overlay("sp_green")
		addtimer(CALLBACK(src, .proc/endLaunch), 33)//wait 3.3 seconds (time it takes for supplypod to land), then update icon
	else if (ready)
		add_overlay("sp_yellow")
	else if (linked)
		add_overlay("sp_orange")

/obj/item/supplypod_beacon/proc/endLaunch()
	launched = FALSE
	update_status()

/obj/item/supplypod_beacon/examine(user)
	..()
	if(!express_console)
		to_chat(user, "<span class='notice'>[src] is not currently linked to a Express Supply console.</span>")

/obj/item/supplypod_beacon/Destroy()
	if(express_console)
		express_console.beacon = null
	return ..()

/obj/item/supplypod_beacon/proc/unlink_console()
	if(express_console)
		express_console.beacon = null
		express_console = null
	update_status(SP_UNLINK)
	update_status(SP_UNREADY) 
	visible_message("<span class='notice'>[name] has been unlinked from [express_console].</span>")

/obj/item/supplypod_beacon/proc/link_console(obj/machinery/computer/cargo/express/C)
	if (C.beacon)//if new console has a beacon, then...
		C.beacon.unlink_console()//unlink the old beacon from new console
	if (express_console)//if this beacon has an express console
		express_console.beacon = null//remove the connection the expressconsole has from beacons
	express_console = C//set the linked console var to the console
	express_console.beacon = src//out with the old in with the news
	update_status(SP_LINKED)
	if (express_console.usingBeacon)
		update_status(SP_READY)
	visible_message("<span class='notice'>[name] linked to [C].</span>")

/obj/item/supplypod_beacon/afterattack(obj/O, mob/user, proximity)
	if(!istype(O) || !proximity)
		return
	if(istype(O, /obj/machinery/computer/cargo/express))
		if (express_console != O)
			link_console(O)

/obj/item/supplypod_beacon/AltClick(mob/user)
	if (!user.canUseTopic(src, !issilicon(user)))
		return
	if (express_console)
		unlink_console()
	else
		visible_message("<span class='notice'>There is no linked console!</span>")

/obj/item/supplypod_beacon/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/pen)) //give a tag that is visible from the linked express console
		var/tag = stripped_input(user, "What would you like the tag to be?")
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(tag)
			name += " ([tag])"
		return
	else	
		return ..()
