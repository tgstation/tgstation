/obj/item/implant/explosive
	name = "microbomb implant"
	desc = "And boom goes the weasel."
	icon_state = "explosive"
	actions_types = list(/datum/action/item_action/explosive_implant)
	// Explosive implant action is always available.
	var/weak = 2
	var/medium = 0.8
	var/heavy = 0.4
	var/delay = 7
	var/popup = FALSE // is the DOUWANNABLOWUP window open?
	var/active = FALSE

/obj/item/implant/explosive/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	// There may be other signals that want to handle mob's death
	// and the process of activating destroys the body, so let the other
	// signal handlers at least finish. Also, the "delayed explosion"
	// uses sleeps, which is bad for signal handlers to do.
	INVOKE_ASYNC(src, .proc/activate, "death")

/obj/item/implant/explosive/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp RX-78 Employee Management Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Explodes<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR>
				<b>Special Features:</b> Explodes<BR>
				"}
	return dat

/obj/item/implant/explosive/activate(cause)
	. = ..()
	if(!cause || !imp_in || active)
		return 0
	if(cause == "action_button" && !popup)
		popup = TRUE
		var/response = alert(imp_in, "Are you sure you want to activate your [name]? This will cause you to explode!", "[name] Confirmation", "Yes", "No")
		popup = FALSE
		if(response == "No")
			return 0
	heavy = round(heavy)
	medium = round(medium)
	weak = round(weak)
	to_chat(imp_in, "<span class='notice'>You activate your [name].</span>")
	active = TRUE
	var/turf/boomturf = get_turf(imp_in)
	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [ADMIN_VERBOSEJMP(boomturf)], with cause of [cause].")
//If the delay is short, just blow up already jeez
	if(delay <= 7)
		explosion(src,heavy,medium,weak,weak, flame_range = weak)
		if(imp_in)
			imp_in.gib(1)
		qdel(src)
		return
	timed_explosion()

/obj/item/implant/explosive/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	for(var/X in target.implants)
		if(istype(X, /obj/item/implant/explosive)) //we don't use our own type here, because macrobombs inherit this proc and need to be able to upgrade microbombs
			var/obj/item/implant/explosive/imp_e = X
			imp_e.heavy += heavy
			imp_e.medium += medium
			imp_e.weak += weak
			imp_e.delay += delay
			qdel(src)
			return TRUE

	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, .proc/on_death)

/obj/item/implant/explosive/proc/timed_explosion()
	imp_in.visible_message("<span class='warning'>[imp_in] starts beeping ominously!</span>")
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay*0.25)
	if(imp_in && !imp_in.stat)
		imp_in.visible_message("<span class='warning'>[imp_in] doubles over in pain!</span>")
		imp_in.Paralyze(140)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay*0.25)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay*0.25)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay*0.25)
	explosion(src,heavy,medium,weak,weak, flame_range = weak)
	if(imp_in)
		imp_in.gib(1)
	qdel(src)

/obj/item/implant/explosive/macro
	name = "macrobomb implant"
	desc = "And boom goes the weasel. And everything else nearby."
	icon_state = "explosive"
	weak = 20 //the strength and delay of 10 microbombs
	medium = 8
	heavy = 4
	delay = 70

/obj/item/implanter/explosive
	name = "implanter (microbomb)"
	imp_type = /obj/item/implant/explosive

/obj/item/implantcase/explosive
	name = "implant case - 'Explosive'"
	desc = "A glass case containing an explosive implant."
	imp_type = /obj/item/implant/explosive

/obj/item/implanter/explosive_macro
	name = "implanter (macrobomb)"
	imp_type = /obj/item/implant/explosive/macro
