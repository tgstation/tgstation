/*
	Changeling Mutations! ~By Miauw
	Contains:
		Arm Blade
		Space Suit
	TODO:
		Shield
		Armor
*/

/obj/effect/proc_holder/changeling/arm_blade
	name = "Arm Blade"
	desc = "We reform one of our arms into a deadly blade."
	helptext = "Cannot be used while in lesser form."
	chemical_cost = 20
	dna_cost = 1
	genetic_damage = 8
	req_human = 1


/obj/effect/proc_holder/changeling/arm_blade/try_to_sting(var/mob/user, var/mob/target)
	if(istype(user.l_hand, /obj/item/weapon/melee/arm_blade)) //Not the nicest way to do it, but eh
		qdel(user.l_hand)
		user.visible_message("<span class='warning'>With a sickening crunch, [user] reforms his blade into an arm!</span>", "<span class='notice'>We assimilate our blade into our body</span>", "<span class='warning>You hear organic matter ripping and tearing!</span>")
		user.update_inv_l_hand()
		return
	if(istype(user.r_hand, /obj/item/weapon/melee/arm_blade))
		qdel(user.r_hand)
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
	flags = ABSTRACT | NODROP
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
	qdel(src)

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

//Space Suit & Helmet
/obj/effect/proc_holder/changeling/organic_space_suit
	name = "Organic Space Suit"
	desc = "We grow an organic suit to protect ourselves from space exposure."
	helptext = "We must constantly repair our form to make it space-proof, reducing chemical production while we are protected. Retreating the suit damages our genomes. Cannot be used in lesser form."
	chemical_cost = 20
	dna_cost = 1
	genetic_damage = 8
	req_human = 1

/obj/effect/proc_holder/changeling/organic_space_suit/try_to_sting(var/mob/user, var/mob/target)
	var/datum/changeling/changeling = user.mind.changeling
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(changeling.space_suit_active)
		changeling.space_suit_active = 0
		H.visible_message("<span class='warning'>[H] casts off their flesh shell!</span>", "<span class='warning'>We cast off our protective organic shell, temporarily weakening our genomes.</span>", "<span class='warning'>You hear the organic matter ripping and tearing!</span>")
		qdel(H.wear_suit)
		qdel(H.head)
		H.update_inv_wear_suit()
		H.update_inv_head()
		H.update_hair()

		var/turf/simulated/T = get_turf(H)
		if(istype(T))
			T.add_blood(H) //So real blood decals
			playsound(H.loc, 'sound/effects/splat.ogg', 50, 1) //So real sounds
		changeling.geneticdamage += 8 //Casting off a space suit leaves you weak for a few seconds.
		changeling.chem_recharge_slowdown -= 0.5
		return
	..(H, target)

/obj/effect/proc_holder/changeling/organic_space_suit/sting_action(var/mob/living/carbon/human/user)
	if(!user.canUnEquip(user.wear_suit))
		user << "\the [user.wear_suit] is stuck to your body, you cannot grow a space suit over it!"
		return
	if(!user.canUnEquip(user.head))
		user << "\the [user.head] is stuck on your head, you cannot grow a space helmet over it!"
		return
	user.unEquip(user.head)
	user.unEquip(user.wear_suit)
	user.equip_to_slot_if_possible(new /obj/item/clothing/suit/space/changeling(user), slot_wear_suit, 1, 1, 1)
	user.equip_to_slot_if_possible(new /obj/item/clothing/head/helmet/space/changeling(user), slot_head, 1, 1, 1)
	user.visible_message("<span class='warning'>[user]'s flesh rapidly inflates, forming a bloated mass around their body!</span>", "<span class='warning'>We inflate our flesh, creating a spaceproof suit!</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")
	var/datum/changeling/changeling = user.mind.changeling
	changeling.space_suit_active = 1
	changeling.chem_recharge_slowdown +=0.5
	return 1

/obj/item/clothing/suit/space/changeling
	name = "flesh mass"
	icon_state = "lingspacesuit"
	desc = "A huge, bulky mass of pressure and temperature-resistant organic tissue, evolved to facilitate space travel."
	flags = STOPSPRESSUREDMAGE | NODROP //Not THICKMATERIAL because it's organic tissue, so if somebody tries to inject something into it, it still ends up in your blood. (also balance but muh fluff)
	allowed = list(/obj/item/device/flashlight, /obj/item/weapon/tank/emergency_oxygen, /obj/item/weapon/tank/oxygen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0) //No armor at all.

/obj/item/clothing/suit/space/changeling/New()
	processing_objects += src

/obj/item/clothing/suit/space/changeling/dropped()
	qdel(src)

/obj/item/clothing/suit/space/changeling/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.reagents.add_reagent("dexalinp", REAGENTS_METABOLISM)

/obj/item/clothing/head/helmet/space/changeling
	name = "flesh mass"
	icon_state = "lingspacehelmet"
	desc = "A covering of pressure and temperature-resistant organic tissue with a glass-like chitin front."
	flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE | NODROP //Again, no THICKMATERIAL.
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/space/changeling/dropped()
	qdel(src)
