/obj/item/announcer
	name = "bootleg announcer"
	desc = "Fake an announcement from Centcom! Note that it's unlikely they will back up your story if asked."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	item_state = "walkietalkie"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	var/unlimited = FALSE
	var/autoapprove = FALSE // admin only plox
	var/approval_window = 1200 // 2 minutes to approve admins plz

	var/compose_warning = "Compose your spoof announcement. Be warned that automatic algoritms verify incoming announcements, so something that's too crazy won't get broadcast."

	var/proposed_message = ""
	var/proposed_stealth = FALSE

	var/verification_timer = FALSE

/obj/item/announcer/Destroy()
	deltimer(verification_timer)
	. = ..()

/obj/item/announcer/attack_self(mob/user)
	if(verification_timer)
		user << "<span class='warning'>[src] is still processing the last message. Please wait...</span>"
		return

	var/input = stripped_multiline_input(user, compose_warning, "Announcer Message", proposed_message) as message|null
	if(!input || QDELETED(src) || QDELETED(user))
		return

	proposed_message = input

	var/stealth_level = alert(user, "Do you want to announce the contents of the report to the crew?", "Announce", "Yes", "No")

	proposed_stealth = stealth_level == "No" ? TRUE : FALSE

	if(autoapprove)
		accept_message(user)
		return

	user << "<span class='notice'>[src] chirps to itself while it verifies that the communication algorithms will accept this message.</span>"

	verification_timer = addtimer(CALLBACK(src, .proc/reject_message), approval_window, TIMER_STOPPABLE)

	admins << "<span class='adminnotice'><b><font color=orange>SPOOFED COMMAND MESSAGE:</font></b> [ADMIN_LOOKUP(user)] proposes to send [proposed_stealth ? "a classified message" : "a global message"]: <span class='italics'>[proposed_message]</span>. Will autoreject in [approval_window / 10] seconds. (<A HREF='?_src_=holder;spoof_message=\ref[src];response=[SPOOFER_ACCEPT]'>ACCEPT</a>) (<A HREF='?_src_=holder;spoof_message=\ref[src];response=[SPOOFER_REJECT]'>REJECT</a>) (<A HREF='?_src_=holder;spoof_message=\ref[src];response=[SPOOFER_DESTROY]'>DESTROY DEVICE</a>)</span>"

/obj/item/announcer/proc/pop()
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(4, 4, src)
	sparks.attach(src)
	sparks.start()
	visible_message("<span class='warning'>[src] dissolves into sparks!</span>")
	qdel(src)

/obj/item/announcer/proc/reject_message()
	audible_message("<span class='warning'>[src] buzzes.</span>")
	playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)

	deltimer(verification_timer)
	verification_timer = null

/obj/item/announcer/proc/accept_message(mob/user)
	audible_message("<span class='notice'>[src] chimes.</span>")
	playsound(get_turf(src), 'sound/machines/chime.ogg', 50, 0)

	sleep(30) // let the sound play

	verification_timer = null
	deltimer(verification_timer)

	create_command_report(user, proposed_message, proposed_stealth)
	proposed_message = ""
	proposed_stealth = FALSE
	if(!unlimited)
		pop()

/obj/item/announcer/unlimited
	name = "official announcer"
	desc = "Send an official announcement from Centcom. Since you're holding this, you MUST be a Centcom employee, so it has unlimited uses."
	icon_state = "gangtool-white"
	unlimited = TRUE
	autoapprove = TRUE
	compose_warning = "Please enter anything you want. Anything. Serious."


/proc/create_command_report(mob/user, message, stealth)
	if(!stealth)
		priority_announce(message, null, 'sound/AI/commandreport.ogg')
	else
		priority_announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", 'sound/AI/commandreport.ogg')

	print_command_report(message,"[stealth ? "Classified " : ""][command_name()] Update")
	log_admin("[key_name(user)] has created a command report: [message]")
	message_admins("[key_name_admin(user)] has created a command report")
	return TRUE
