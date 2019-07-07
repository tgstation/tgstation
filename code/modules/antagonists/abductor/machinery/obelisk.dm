/obj/machinery/abductor/obelisk
	name = "Alien Obelisk"
	desc = "A mysterious alien obelisk."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "obelisk"
	density = FALSE
	var/next_power = 0

/obj/machinery/abductor/obelisk/Destroy()
	new /obj/item/obelisk_core(drop_location())
	. = ..()

/obj/machinery/abductor/obelisk/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_ABDUCTOR_TRAINING) || HAS_TRAIT(user.mind, TRAIT_ABDUCTOR_TRAINING))
		. += "<span class='notice'>An uplink obelisk, linked to an abductor mothership. It streamlines teleportation, and can broadcast signals from abductor devices."

/obj/machinery/abductor/obelisk/emp_act(power)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	next_power = CLAMP(next_power + 600, world.time + 600, world.time + 3000)

/obj/machinery/abductor/obelisk/proc/sleep_wave()
	if(world.time < next_power)
		return FALSE
	for(var/mob/living/carbon/C in range(7, src))
		if(C.stat == DEAD)
			continue
		if(isabductor(C))
			continue
		to_chat(C, "<span class='warning'>You suddenly feel very sleepy...</span>")
		C.Sleeping(300)
	next_power = world.time + 600
	return TRUE

/obj/machinery/abductor/obelisk/proc/silence()
	if(world.time < next_power)
		return FALSE
	for(var/mob/living/carbon/human/H in range(7, src))
		var/list/all_items = H.GetAllContents()
		for(var/obj/I in all_items)
			if(istype(I, /obj/item/radio))
				var/obj/item/radio/r = I
				r.listening = 0
				if(!istype(I, /obj/item/radio/headset))
					r.broadcasting = 0
	next_power = world.time + 250
	return TRUE

/obj/machinery/abductor/obelisk/proc/communicate(user, message)
	if(!message)
		return
	for(var/mob/living/L in range(7, src))
		if(L.stat == DEAD)
			continue
		to_chat(L, "<span class='italics'>You hear a voice in your head saying: </span><span class='abductor'>[message]</span>")
		log_directed_talk(user, L, message, LOG_SAY, "abductor beacon whisper")

/obj/machinery/abductor/obelisk/proc/disintegrate()
	flick("obelisk_disintegrating", src)
	visible_message("<span class='warning'>[src] starts buzzing loudly while it disintegrates itself!</span>", null, "<span class='warning'>You hear a loud buzz.</span>")
	QDEL_IN(src, 50)

/obj/item/obelisk_core
	name = "obelisk core"
	desc = "The neutralized core of an obelisk. It'd probably be valuable for research."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "obelisk_core"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_ALLOY=2000)
