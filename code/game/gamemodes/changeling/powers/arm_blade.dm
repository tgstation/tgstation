/obj/effect/proc_holder/changeling/arm_blade
	name = "Arm Blade"
	desc = "We reform one of our arms into a deadly blade."
	helptext = "Cannot be used while in lesser form."
	chemical_cost = 20
	dna_cost = 1
	genetic_damage = 6
	req_human = 1 //if you need to be human to use this ability


/obj/effect/proc_holder/changeling/arm_blade/try_to_sting(var/mob/user, var/mob/target)
	if(istype(user.l_hand, /obj/item/weapon/melee/arm_blade)) //Not the nicest way to do it, but eh
		del user.l_hand
		user.visible_message("<span class='warning'>With a sickening crunch, [user] reforms his blade into an arm!</span>", "<span class='notice'>We assimilate our blade into our body</span>", "<span class='warning>You hear organic matter ripping and tearing!</span>")
		user.update_inv_l_hand()
		return
	if(istype(user.r_hand, /obj/item/weapon/melee/arm_blade))
		del user.r_hand
		user.visible_message("<span class='warning'>With a sickening crunch, [user] reforms his blade into an arm!</span>", "<span class='notice'>We assimilate our blade into our body</span>", "<span class='warning>You hear organic matter ripping and tearing!</span>")
		user.update_inv_r_hand()
		return
	..(user, target)

/obj/effect/proc_holder/changeling/arm_blade/sting_action(var/mob/user)
	if(!user.drop_item())
		user << "The [user.get_active_hand()] is stuck to your hand, you cannot grow a blade over it!"
		return
	user.put_in_hands(new /obj/item/weapon/melee/arm_blade(user))
	return 1

/obj/item/weapon/melee/arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	flags = ABSTRACT
	w_class = 5.0
	force = 25
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0

/obj/item/weapon/melee/arm_blade/New()
	..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>A grotesque blade forms around [loc.name]\'s arm!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a deadly blade.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")

/obj/item/weapon/melee/arm_blade/dropped(mob/user)
	visible_message("<span class='warning'>With a sickening crunch, [user] reforms his blade into an arm!</span>", "<span class='notice'>We assimilate our blade into our body</span>", "<span class='warning>You hear organic matter ripping and tearing!</span>")
	del src

/obj/item/weapon/melee/arm_blade/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/structure/table))
		var/obj/structure/table/T = target
		T.table_destroy(1, user)

	else if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/C = target
		C.attack_alien(user) //muh copypasta

	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if(!A.requiresID() || A.allowed(user)) //This is to prevent stupid shit like hitting a door with an arm blade, the door opening because you have acces and still getting a "the airlocks motors resist our efforts to force it" message.
			return

		if(A.arePowerSystemsOn() && !(A.stat & NOPOWER))
			user << "<span class='notice'>The airlock's motors resist our efforts to force it.</span>"
			return

		else if(A.locked)
			user << "<span class='notice'>The airlock's bolts prevent it from being forced.</span>"
			return

		else
			//user.say("Heeeeeeeeeerrre's Johnny!")
			user.visible_message("<span class='warning'>[user] forces the door to open with \his [src]!</span>", "<span class='warning'>We force the door to open.</span>", "<span class='warning'>You hear a metal screeching sound.</span>")
			A.open(1)
