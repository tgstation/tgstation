/*
	Items, Structures, Machines
*/


//
// Items
//

/obj/item/holo
	damtype = STAMINA

/obj/item/holo/esword
	name = "holographic energy sword"
	desc = "May the force be with you. Sorta."
	icon = 'icons/obj/transforming_energy.dmi'
	icon_state = "sword0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 3.0
	throw_speed = 2
	throw_range = 5
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	hitsound = "swing_hit"
	armour_penetration = 50
	var/active = 0
	var/saber_color

/obj/item/holo/esword/green/Initialize()
	. = ..()
	saber_color = "green"

/obj/item/holo/esword/red/Initialize()
	. = ..()
	saber_color = "red"

/obj/item/holo/esword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/holo/esword/attack(target, mob/user)
	..()

/obj/item/holo/esword/Initialize()
	. = ..()
	saber_color = pick("red","blue","green","purple")

/obj/item/holo/esword/attack_self(mob/living/user)
	active = !active
	if (active)
		force = 30
		icon_state = "sword[saber_color]"
		w_class = WEIGHT_CLASS_BULKY
		hitsound = 'sound/weapons/blade1.ogg'
		playsound(user, 'sound/weapons/saberon.ogg', 20, TRUE)
		to_chat(user, span_notice("[src] is now active."))
	else
		force = 3
		icon_state = "sword0"
		w_class = WEIGHT_CLASS_SMALL
		hitsound = "swing_hit"
		playsound(user, 'sound/weapons/saberoff.ogg', 20, TRUE)
		to_chat(user, span_notice("[src] can now be concealed."))
	return

//BASKETBALL OBJECTS

/obj/item/toy/beach_ball/holoball
	name = "basketball"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "basketball"
	inhand_icon_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets

/obj/item/toy/beach_ball/holoball/dodgeball
	name = "dodgeball"
	icon_state = "dodgeball"
	inhand_icon_state = "dodgeball"
	desc = "Used for playing the most violent and degrading of childhood games."

/obj/item/toy/beach_ball/holoball/dodgeball/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if((ishuman(hit_atom)))
		var/mob/living/carbon/M = hit_atom
		playsound(src, 'sound/items/dodgeball.ogg', 50, TRUE)
		M.apply_damage(10, STAMINA)
		if(prob(5))
			M.Paralyze(60)
			visible_message(span_danger("[M] is knocked right off [M.p_their()] feet!"))

//
// Structures
//

/obj/structure/holohoop
	name = "basketball hoop"
	desc = "Boom, shakalaka!"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "hoop"
	anchored = TRUE
	density = TRUE

/obj/structure/holohoop/attackby(obj/item/W, mob/user, params)
	if(get_dist(src,user)<2)
		if(user.transferItemToLoc(W, drop_location()))
			visible_message(span_warning("[user] dunks [W] into \the [src]!"))

/obj/structure/holohoop/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user.pulling && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, span_warning("You need a better grip to do that!"))
			return
		L.forceMove(loc)
		L.Paralyze(100)
		visible_message(span_danger("[user] dunks [L] into \the [src]!"))
		user.stop_pulling()
	else
		..()

/obj/structure/holohoop/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if (isitem(AM) && !istype(AM,/obj/projectile))
		if(prob(50))
			AM.forceMove(get_turf(src))
			visible_message(span_warning("Swish! [AM] lands in [src]."))
			return
		else
			visible_message(span_danger("[AM] bounces off of [src]'s rim!"))
			return ..()
	else
		return ..()



//
// Machines
//

/obj/machinery/readybutton
	name = "ready declaration device"
	desc = "This device is used to declare ready. If all devices in an area are ready, the event will begin!"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	var/ready = 0
	var/area/currentarea = null
	var/eventstarted = FALSE

	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = AREA_USAGE_ENVIRON

/obj/machinery/readybutton/attack_ai(mob/user)
	to_chat(user, span_warning("The station AI is not to interact with these devices!"))
	return

/obj/machinery/readybutton/attack_paw(mob/user, list/modifiers)
	to_chat(user, span_warning("You are too primitive to use this device!"))
	return

/obj/machinery/readybutton/attackby(obj/item/W, mob/user, params)
	to_chat(user, span_warning("The device is a solid button, there's nothing you can do with it!"))

/obj/machinery/readybutton/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user.stat || machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_warning("This device is not powered!"))
		return

	currentarea = get_area(src.loc)
	if(!currentarea)
		qdel(src)

	if(eventstarted)
		to_chat(usr, span_warning("The event has already begun!"))
		return

	ready = !ready

	update_appearance()

	var/numbuttons = 0
	var/numready = 0
	for(var/obj/machinery/readybutton/button in currentarea)
		numbuttons++
		if (button.ready)
			numready++

	if(numbuttons == numready)
		begin_event()

/obj/machinery/readybutton/update_icon_state()
	icon_state = "auth_[ready ? "on" : "off"]"
	return ..()

/obj/machinery/readybutton/proc/begin_event()

	eventstarted = TRUE

	for(var/obj/structure/window/W in currentarea)
		if(W.flags_1&NODECONSTRUCT_1) // Just in case: only holo-windows
			qdel(W)

	for(var/mob/M in currentarea)
		to_chat(M, span_userdanger("FIGHT!"))

/obj/machinery/conveyor/holodeck

/obj/machinery/conveyor/holodeck/attackby(obj/item/I, mob/user, params)
	if(!user.transferItemToLoc(I, drop_location()))
		return ..()

/obj/item/paper/fluff/holodeck/trek_diploma
	name = "paper - Starfleet Academy Diploma"
	info = {"<h2>Starfleet Academy</h2></br><p>Official Diploma</p></br>"}

/obj/item/paper/fluff/holodeck/disclaimer
	name = "Holodeck Disclaimer"
	info = "Bruises sustained in the holodeck can be healed simply by sleeping."

/obj/vehicle/ridden/scooter/skateboard/pro/holodeck
	name = "holographic skateboard"
	desc = "A holographic copy of the EightO brand professional skateboard."
	instability = 6

/obj/vehicle/ridden/scooter/skateboard/pro/holodeck/pick_up_board() //picking up normal skateboards spawned in the holodeck gets rid of the holo flag, now you cant pick them up.
	return
