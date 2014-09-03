/*
FREEFORM 2: ELECTRIC BOOGALOO

By N3X15
*/

/obj/item/weapon/aiModule/freeform // Slightly more dynamic freeform module -- TLE
	modname = "Freeform"
	origin_tech = "programming=4;materials=4"
	var/priority=1 // Use LAW_* for forcing to that lawtype.
	var/allowed_priority_min=15 // Or 0 for no lower limit.
	var/allowed_priority_max=50 // Or 0 for no upper limit.

/obj/item/weapon/aiModule/freeform/updateLaw()
	desc = "\A '[name]' [modtype]: "
	if(priority>0 && priority>allowed_priority_min)
		desc+="([priority]) "
	if(!law)
		desc += "<No law set>"
	else
		desc += "'[law]'"
	return


/obj/item/weapon/aiModule/freeform/copy()
	var/obj/item/weapon/aiModule/freeform/clone = ..()
	clone.law=law
	clone.priority=priority
	return clone

/obj/item/weapon/aiModule/freeform/attack_self(var/mob/user as mob)
	..()
	if(priority>0)
		var/lawpos = allowed_priority_min
		while(1)
			lawpos = input("Please enter the priority for your new law. Can only write to law sectors [allowed_priority_min] - [allowed_priority_max].", "Law Priority (15+)", lawpos) as num
			if(allowed_priority_min > 0 && lawpos < allowed_priority_min)
				user << "\red Desired law sector is too low."
				continue
			if(allowed_priority_max > 0 && lawpos > allowed_priority_max)
				user << "\red Desired law sector is too high."
				continue
			priority=lawpos
			user << "\blue Target law sector set to [priority]."
			break

	law = copytext(sanitize(input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", law)),1,MAX_MESSAGE_LEN)
	updateLaw()

/obj/item/weapon/aiModule/freeform/upload(var/datum/ai_laws/laws, var/atom/target=null, var/mob/sender=null, var/notify_target=0)
	..()
	//target << law
	if((!priority || priority < allowed_priority_min) && !(priority == LAW_IONIC || priority == LAW_INHERENT || priority == LAW_ZERO))
		priority = allowed_priority_min
	laws.add_law(priority, law)
	lawchanges.Add("The law was '[law]'")
	log_game("[fmtSubject(sender)] added law \"[law]\" to [fmtSubject(target)]")
	return 1

/obj/item/weapon/aiModule/freeform/validate(var/datum/ai_laws/laws, var/atom/subject=null, var/mob/sender=null)
	if(!law)
		if(sender)
			sender << "No law detected on module, please create one."
		return 0
	return ..()

/////////////////////////////////////
// Core Freeform

/obj/item/weapon/aiModule/freeform/core
	modtype = "Core AI Module"
	origin_tech = "programming=3;materials=6"

	priority = LAW_INHERENT

/////////////////////////////////////
// Hacked Freeform

/obj/item/weapon/aiModule/freeform/syndicate
	modtype = "Hacked AI Module"
	origin_tech = "programming=3;materials=6;syndicate=7"

	priority = LAW_IONIC
	modflags = HIDE_SENDER