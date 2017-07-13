/*
	Items, Structures, Machines
*/


//
// Items
//

/obj/item/weapon/holo
	damtype = STAMINA

/obj/item/weapon/holo/esword
	name = "holographic energy sword"
	desc = "May the force be with you. Sorta"
	icon_state = "sword0"
	force = 3.0
	throw_speed = 2
	throw_range = 5
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	hitsound = "swing_hit"
	armour_penetration = 50
	var/active = 0

/obj/item/weapon/holo/esword/green/New()
	..()
	item_color = "green"


/obj/item/weapon/holo/esword/red/New()
	..()
	item_color = "red"

/obj/item/weapon/holo/esword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/weapon/holo/esword/attack(target as mob, mob/user as mob)
	..()

/obj/item/weapon/holo/esword/New()
	item_color = pick("red","blue","green","purple")
	..()

/obj/item/weapon/holo/esword/attack_self(mob/living/user as mob)
	active = !active
	if (active)
		force = 30
		icon_state = "sword[item_color]"
		w_class = WEIGHT_CLASS_BULKY
		hitsound = 'sound/weapons/blade1.ogg'
		playsound(user, 'sound/weapons/saberon.ogg', 20, 1)
		to_chat(user, "<span class='warning'>[src] is now active.</span>")
	else
		force = 3
		icon_state = "sword0"
		w_class = WEIGHT_CLASS_SMALL
		hitsound = "swing_hit"
		playsound(user, 'sound/weapons/saberoff.ogg', 20, 1)
		to_chat(user, "<span class='warning'>[src] can now be concealed.</span>")
	return

//BASKETBALL OBJECTS

/obj/item/toy/beach_ball/holoball
	name = "basketball"
	icon = 'icons/obj/items.dmi'
	icon_state = "basketball"
	item_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets

/obj/item/toy/beach_ball/holoball/dodgeball
	name = "dodgeball"
	icon_state = "dodgeball"
	item_state = "dodgeball"
	desc = "Used for playing the most violent and degrading of childhood games."

/obj/item/toy/beach_ball/holoball/dodgeball/throw_impact(atom/hit_atom)
	..()
	if((ishuman(hit_atom)))
		var/mob/living/carbon/M = hit_atom
		playsound(src, 'sound/items/dodgeball.ogg', 50, 1)
		M.apply_damage(10, STAMINA)
		if(prob(5))
			M.Knockdown(60)
			visible_message("<span class='danger'>[M] is knocked right off [M.p_their()] feet!</span>")

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

/obj/structure/holohoop/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(get_dist(src,user)<2)
		if(user.drop_item(src))
			visible_message("<span class='warning'> [user] dunks [W] into \the [src]!</span>")

/obj/structure/holohoop/attack_hand(mob/user)
	if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return
		L.loc = src.loc
		L.Knockdown(100)
		visible_message("<span class='danger'>[user] dunks [L] into \the [src]!</span>")
		user.stop_pulling()
	else
		..()

/obj/structure/holohoop/CanPass(atom/movable/mover, turf/target)
	if (isitem(mover) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/projectile))
			return
		if(prob(50))
			I.forceMove(get_turf(src))
			visible_message("<span class='warning'>Swish! [I] lands in [src].</span>")
		else
			visible_message("<span class='danger'>[I] bounces off of [src]'s rim!</span>")
		return 0
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

	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

/obj/machinery/readybutton/attack_ai(mob/user as mob)
	to_chat(user, "The station AI is not to interact with these devices")
	return

/obj/machinery/readybutton/attack_paw(mob/user as mob)
	to_chat(user, "<span class='warning'>You are too primitive to use this device!</span>")
	return

/obj/machinery/readybutton/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	to_chat(user, "The device is a solid button, there's nothing you can do with it!")

/obj/machinery/readybutton/attack_hand(mob/user as mob)
	if(user.stat || stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>This device is not powered!</span>")
		return

	currentarea = get_area(src.loc)
	if(!currentarea)
		qdel(src)

	if(eventstarted)
		to_chat(usr, "<span class='warning'>The event has already begun!</span>")
		return

	ready = !ready

	update_icon()

	var/numbuttons = 0
	var/numready = 0
	for(var/obj/machinery/readybutton/button in currentarea)
		numbuttons++
		if (button.ready)
			numready++

	if(numbuttons == numready)
		begin_event()

/obj/machinery/readybutton/update_icon()
	if(ready)
		icon_state = "auth_on"
	else
		icon_state = "auth_off"

/obj/machinery/readybutton/proc/begin_event()

	eventstarted = TRUE

	for(var/obj/structure/window/W in currentarea)
		if(W.flags&NODECONSTRUCT) // Just in case: only holo-windows
			qdel(W)

	for(var/mob/M in currentarea)
		to_chat(M, "FIGHT!")

/obj/machinery/conveyor/holodeck

/obj/machinery/conveyor/holodeck/attackby(obj/item/I, mob/user, params)
	if(user.drop_item())
		I.loc = src.loc
	else
		return ..()

/obj/item/weapon/paper/trek_diploma
	name = "paper - Starfleet Academy Diploma"
	info = {"<h2>Starfleet Academy</h2></br><p>Official Diploma</p></br>"}
