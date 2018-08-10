/obj/item/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("warned", "cautioned", "smashed")

/obj/item/skub
	desc = "It's skub."
	name = "skub"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "skub"
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("skubbed")

/obj/item/suspiciousphone
	name = "suspicious phone"
	desc = "This device raises pink levels to unknown highs."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "suspiciousphone"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("dumped")
	var/dumped = FALSE
	var/announcing = TRUE
	var/calltype = CALLTYPE_NONE
	var/datum/looping_sound/ring/soundloop
	var/mob/bogdannof

/obj/item/suspiciousphone/Initialize()
	. = ..()
	soundloop = new(list(src), FALSE, TRUE)
	GLOB.suspicious_phones += src

obj/item/suspiciousphone/Destroy()
	. = ..()
	QDEL_NULL(soundloop)
	GLOB.suspicious_phones -= src

/obj/item/suspiciousphone/equipped(mob/user, slot)
	. = ..()
	soundloop.output_atoms = list(user)
	soundloop.direct = TRUE

/obj/item/suspiciousphone/dropped(mob/user)
	. = ..()
	soundloop.output_atoms = list(src)
	soundloop.direct = FALSE

/obj/item/suspiciousphone/attack_self(mob/user)
	if(calltype && announcing)
		if(calltype == CALLTYPE_HEBOUGHT)
			SEND_SOUND(user, 'sound/items/he_bought.ogg')
			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, user, "<span class='notice'>Station funds is now [SSshuttle.points] credits.</span>"), 40)
			stop_ring()
			return
		else if(calltype == CALLTYPE_HESOLD)
			SEND_SOUND(user, 'sound/items/he_sold.ogg')
			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, user, "<span class='notice'>Station funds is now [SSshuttle.points] credits.</span>"), 40)
			stop_ring()
			return

	if(dumped)
		to_chat(user, "<span class='warning'>You already activated Protocol CRAB-17.</span>")
		return FALSE

	if(alert(user, "Are you sure you want to crash this market with no survivors?", "Protocol CRAB-17", "Yes", "No") == "Yes")
		if(dumped) //Prevents fuckers from cheesing alert
			return FALSE
		sound_to_playing_players('sound/items/dump_it.ogg', 75)
		addtimer(CALLBACK(src, .proc/crab17), 100)
		dumped = TRUE

/obj/item/suspiciousphone/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Alt-click to toggle auto buy/sell announcements.</span>")

/obj/item/suspiciousphone/AltClick(mob/user)
	. = ..()
	announcing = !announcing
	to_chat(user, "<span class='notice'>Buy/sell auto announcements are now [announcing ? "on" : "off"].</span>")


/obj/item/suspiciousphone/proc/ring(var/calltype)
	soundloop.start()
	src.calltype = calltype
	to_chat(bogdannof, "<span class='notice'>Your phone starts ringing.</span>")
	addtimer(CALLBACK(src, .proc/stop_ring), 80)

/obj/item/suspiciousphone/proc/stop_ring()
	calltype = CALLTYPE_NONE
	to_chat(bogdannof, "<span class='notice'>Your phone starts ringing.</span>")
	soundloop.stop()

/obj/item/suspiciousphone/proc/crab17()
	var/loss = rand(20, 40)
	priority_announce("Protocol CRAB-17 has been activated and our station funds has been lowered by [100 - loss]%.", sender_override = "CRAB-17 Protocol")
	SSshuttle.points *= loss / 100
