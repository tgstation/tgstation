/obj/item/weapon/implant/explosive
	name = "microbomb implant"
	desc = "And boom goes the weasel."
	icon_state = "explosive"
	origin_tech = "materials=2;combat=3;biotech=4;syndicate=4"
	actions_types = list(/datum/action/item_action/explosive_implant)
	// Explosive implant action is always availible.
	var/weak = 2
	var/medium = 0.8
	var/heavy = 0.4
	var/delay = 7
	var/popup = FALSE // is the DOUWANNABLOWUP window open?
	var/active = FALSE

/obj/item/weapon/implant/explosive/get_data()
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

/obj/item/weapon/implant/explosive/trigger(emote, mob/source)
	if(emote == "deathgasp")
		activate("death")

/obj/item/weapon/implant/explosive/activate(cause)
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
	var/area/A = get_area(boomturf)
	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [A.name] [ADMIN_JMP(boomturf)].")
//If the delay is short, just blow up already jeez
	if(delay <= 7)
		explosion(src,heavy,medium,weak,weak, flame_range = weak)
		if(imp_in)
			imp_in.gib(1)
		qdel(src)
		return
	timed_explosion()

/obj/item/weapon/implant/explosive/implant(mob/living/target)
	for(var/X in target.implants)
		if(istype(X, type))
			var/obj/item/weapon/implant/explosive/imp_e = X
			imp_e.heavy += heavy
			imp_e.medium += medium
			imp_e.weak += weak
			imp_e.delay += delay
			qdel(src)
			return 1

	return ..()

/obj/item/weapon/implant/explosive/proc/timed_explosion()
	imp_in.visible_message("<span class='warning'>[imp_in] starts beeping ominously!</span>")
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(delay*0.25)
	if(imp_in && !imp_in.stat)
		imp_in.visible_message("<span class='warning'>[imp_in] doubles over in pain!</span>")
		imp_in.Knockdown(140)
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(delay*0.25)
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(delay*0.25)
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(delay*0.25)
	explosion(src,heavy,medium,weak,weak, flame_range = weak)
	if(imp_in)
		imp_in.gib(1)
	qdel(src)

/obj/item/weapon/implant/explosive/macro
	name = "macrobomb implant"
	desc = "And boom goes the weasel. And everything else nearby."
	icon_state = "explosive"
	origin_tech = "materials=3;combat=5;biotech=4;syndicate=5"
	weak = 16
	medium = 8
	heavy = 4
	delay = 70

/obj/item/weapon/implant/explosive/macro/implant(mob/living/target)
	for(var/X in target.implants)
		if(istype(X, type))
			return 0

	for(var/Y in target.implants)
		if(istype(Y, /obj/item/weapon/implant/explosive))
			var/obj/item/weapon/implant/explosive/imp_e = Y
			heavy += imp_e.heavy
			medium += imp_e.medium
			weak += imp_e.weak
			delay += imp_e.delay
			qdel(imp_e)
			break

	return ..()


/obj/item/weapon/implanter/explosive
	name = "implanter (explosive)"
	imp_type = /obj/item/weapon/implant/explosive

/obj/item/weapon/implantcase/explosive
	name = "implant case - 'Explosive'"
	desc = "A glass case containing an explosive implant."
	imp_type = /obj/item/weapon/implant/explosive
