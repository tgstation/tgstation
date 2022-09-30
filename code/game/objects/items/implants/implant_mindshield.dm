/obj/item/implant/mindshield
	name = "mindshield implant"
	desc = "Protects against brainwashing."
	activated = FALSE

/obj/item/implant/mindshield/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Management Implant<BR>
				<b>Life:</b> Ten years.<BR>
				<b>Important Notes:</b> Personnel injected with this device are much more resistant to brainwashing.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that protects the host's mental functions from manipulation.<BR>
				<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
				<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat


/obj/item/implant/mindshield/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(target.mind)
		if((SEND_SIGNAL(target.mind, COMSIG_PRE_MINDSHIELD_IMPLANT, user) & COMPONENT_MINDSHIELD_RESISTED) || target.mind.unconvertable)
			if(!silent)
				target.visible_message(span_warning("[target] seems to resist the implant!"), span_warning("You feel something interfering with your mental conditioning, but you resist it!"))
			removed(target, TRUE)
			qdel(src)
			return TRUE
		if(SEND_SIGNAL(target.mind, COMSIG_MINDSHIELD_IMPLANTED, user) & COMPONENT_MINDSHIELD_DECONVERTED)
			if(prob(1) || SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
				target.say("I'm out! I quit! Whose kidneys are these?", forced = "They're out! They quit! Whose kidneys do they have?")

	ADD_TRAIT(target, TRAIT_MINDSHIELD, IMPLANT_TRAIT)
	target.sec_hud_set_implants()
	if(!silent)
		to_chat(target, span_notice("You feel a sense of peace and security. You are now protected from brainwashing."))
	return TRUE

/obj/item/implant/mindshield/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(isliving(target))
		var/mob/living/L = target
		REMOVE_TRAIT(L, TRAIT_MINDSHIELD, IMPLANT_TRAIT)
		L.sec_hud_set_implants()
	if(target.stat != DEAD && !silent)
		to_chat(target, span_boldnotice("Your mind suddenly feels terribly vulnerable. You are no longer safe from brainwashing."))
	return TRUE

/obj/item/implanter/mindshield
	name = "implanter (mindshield)"
	imp_type = /obj/item/implant/mindshield

/obj/item/implantcase/mindshield
	name = "implant case - 'Mindshield'"
	desc = "A glass case containing a mindshield implant."
	imp_type = /obj/item/implant/mindshield
