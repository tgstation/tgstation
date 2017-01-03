/*
	Changeling Mutations! ~By Miauw (ALL OF IT :V)
	Contains:
		Arm Blade
		Space Suit
		Shield
		Armor
*/


//Parent to shields and blades because muh copypasted code.
/obj/effect/proc_holder/changeling/weapon
	name = "Organic Weapon"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at Miauw and/or Perakp"
	chemical_cost = 1000
	dna_cost = -1
	genetic_damage = 1000

	var/silent = FALSE
	var/weapon_type
	var/weapon_name_simple

/obj/effect/proc_holder/changeling/weapon/try_to_sting(mob/user, mob/target)
	for(var/obj/item/I in user.held_items)
		if(check_weapon(user, I))
			return
	..(user, target)

/obj/effect/proc_holder/changeling/weapon/proc/check_weapon(mob/user, obj/item/hand_item)
	if(istype(hand_item, weapon_type))
		user.unEquip(hand_item, 1) //DROPDEL will delete the item
		if(!silent)
			playsound(user, 'sound/effects/blobattack.ogg', 30, 1)
			user.visible_message("<span class='warning'>With a sickening crunch, [user] reforms their [weapon_name_simple] into an arm!</span>", "<span class='notice'>We assimilate the [weapon_name_simple] back into our body.</span>", "<span class='italics>You hear organic matter ripping and tearing!</span>")
		user.update_inv_hands()
		return 1

/obj/effect/proc_holder/changeling/weapon/sting_action(mob/living/user)
	if(!user.drop_item())
		user << "<span class='warning'>The [user.get_active_held_item()] is stuck to your hand, you cannot grow a [weapon_name_simple] over it!</span>"
		return
	var/limb_regen = 0
	if(user.active_hand_index % 2 == 0) //we regen the arm before changing it into the weapon
		limb_regen = user.regenerate_limb("r_arm", 1)
	else
		limb_regen = user.regenerate_limb("l_arm", 1)
	if(limb_regen)
		user.visible_message("<span class='warning'>[user]'s missing arm reforms, making a loud, grotesque sound!</span>", "<span class='userdanger'>Your arm regrows, making a loud, crunchy sound and giving you great pain!</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")
		user.emote("scream")
	var/obj/item/W = new weapon_type(user, silent)
	user.put_in_hands(W)
	if(!silent)
		playsound(user, 'sound/effects/blobattack.ogg', 30, 1)
	return W

/obj/effect/proc_holder/changeling/weapon/on_refund(mob/user)
	for(var/obj/item/I in user.held_items)
		check_weapon(user, I)


//Parent to space suits and armor.
/obj/effect/proc_holder/changeling/suit
	name = "Organic Suit"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at Miauw and/or Perakp"
	chemical_cost = 1000
	dna_cost = -1
	genetic_damage = 1000

	var/helmet_type = /obj/item
	var/suit_type = /obj/item
	var/suit_name_simple = "    "
	var/helmet_name_simple = "     "
	var/recharge_slowdown = 0
	var/blood_on_castoff = 0

/obj/effect/proc_holder/changeling/suit/try_to_sting(mob/user, mob/target)
	if(check_suit(user))
		return
	var/mob/living/carbon/human/H = user
	..(H, target)

//checks if we already have an organic suit and casts it off.
/obj/effect/proc_holder/changeling/suit/proc/check_suit(mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	if(!ishuman(user) || !changeling)
		return 1
	var/mob/living/carbon/human/H = user
	if(istype(H.wear_suit, suit_type) || istype(H.head, helmet_type))
		H.visible_message("<span class='warning'>[H] casts off their [suit_name_simple]!</span>", "<span class='warning'>We cast off our [suit_name_simple][genetic_damage > 0 ? ", temporarily weakening our genomes." : "."]</span>", "<span class='italics'>You hear the organic matter ripping and tearing!</span>")
		H.unEquip(H.head, TRUE) //The qdel on dropped() takes care of it
		H.unEquip(H.wear_suit, TRUE)
		H.update_inv_wear_suit()
		H.update_inv_head()
		H.update_hair()

		if(blood_on_castoff)
			H.add_splatter_floor()
			playsound(H.loc, 'sound/effects/splat.ogg', 50, 1) //So real sounds

		changeling.geneticdamage += genetic_damage //Casting off a space suit leaves you weak for a few seconds.
		changeling.chem_recharge_slowdown -= recharge_slowdown
		return 1

/obj/effect/proc_holder/changeling/suit/on_refund(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	check_suit(H)

/obj/effect/proc_holder/changeling/suit/sting_action(mob/living/carbon/human/user)
	if(!user.canUnEquip(user.wear_suit))
		user << "\the [user.wear_suit] is stuck to your body, you cannot grow a [suit_name_simple] over it!"
		return
	if(!user.canUnEquip(user.head))
		user << "\the [user.head] is stuck on your head, you cannot grow a [helmet_name_simple] over it!"
		return

	user.unEquip(user.head)
	user.unEquip(user.wear_suit)

	user.equip_to_slot_if_possible(new suit_type(user), slot_wear_suit, 1, 1, 1)
	user.equip_to_slot_if_possible(new helmet_type(user), slot_head, 1, 1, 1)

	var/datum/changeling/changeling = user.mind.changeling
	changeling.chem_recharge_slowdown += recharge_slowdown
	return 1


//fancy headers yo
/***************************************\
|***************ARM BLADE***************|
\***************************************/
/obj/effect/proc_holder/changeling/weapon/arm_blade
	name = "Arm Blade"
	desc = "We reform one of our arms into a deadly blade."
	helptext = "We may retract our armblade in the same manner as we form it. Cannot be used while in lesser form."
	chemical_cost = 20
	dna_cost = 2
	genetic_damage = 10
	req_human = 1
	max_genetic_damage = 20
	weapon_type = /obj/item/weapon/melee/arm_blade
	weapon_name_simple = "blade"

/obj/item/weapon/melee/arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	flags = ABSTRACT | NODROP | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 25
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharpness = IS_SHARP

/obj/item/weapon/melee/arm_blade/New(location,silent)
	..()
	if(ismob(loc) && !silent)
		loc.visible_message("<span class='warning'>A grotesque blade forms around [loc.name]\'s arm!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a deadly blade.</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")

/obj/item/weapon/melee/arm_blade/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/structure/table))
		var/obj/structure/table/T = target
		T.deconstruct(FALSE)

	else if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/C = target
		C.attack_alien(user) //muh copypasta

	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if(!A.requiresID() || A.allowed(user)) //This is to prevent stupid shit like hitting a door with an arm blade, the door opening because you have acces and still getting a "the airlocks motors resist our efforts to force it" message.
			return
		if(A.locked)
			user << "<span class='warning'>The airlock's bolts prevent it from being forced!</span>"
			return

		if(A.hasPower())
			user.visible_message("<span class='warning'>[user] jams [src] into the airlock and starts prying it open!</span>", "<span class='warning'>We start forcing the airlock open.</span>", \
			"<span class='italics'>You hear a metal screeching sound.</span>")
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 100, 1)
			if(!do_after(user, 100, target = A))
				return
		//user.say("Heeeeeeeeeerrre's Johnny!")
		user.visible_message("<span class='warning'>[user] forces the airlock to open with their [src]!</span>", "<span class='warning'>We force the airlock to open.</span>", \
		"<span class='italics'>You hear a metal screeching sound.</span>")
		A.open(2)

/***************************************\
|***********COMBAT TENTACLES*************|
\***************************************/

/obj/effect/proc_holder/changeling/weapon/tentacle
	name = "Tentacle"
	desc = "We ready a tentacle to grab items or victims with."
	helptext = "We can use it once to retrieve a distant item. If used on living creatures, the effect depends on the intent: \
	Help will simply drag them closer, Disarm will grab whatever they're holding instead of them, Grab will put the victim in our hold after catching it, \
	and Harm will stun it, and stab it if we're also holding a sharp weapon. Cannot be used while in lesser form."
	chemical_cost = 10
	dna_cost = 2
	genetic_damage = 5
	req_human = 1
	max_genetic_damage = 10
	weapon_type = /obj/item/weapon/gun/magic/tentacle
	weapon_name_simple = "tentacle"
	silent = TRUE

/obj/item/weapon/gun/magic/tentacle
	name = "tentacle"
	desc = "A fleshy tentacle that can stretch out and grab things or people."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "tentacle"
	item_state = null
	flags = ABSTRACT | NODROP | DROPDEL | NOBLUDGEON
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = /obj/item/ammo_casing/magic/tentacle
	fire_sound = 'sound/effects/splat.ogg'
	force = 0
	max_charges = 1
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0

/obj/item/weapon/gun/magic/tentacle/New(location,silent)
	..()
	if(ismob(loc))
		if(!silent)
			loc.visible_message("<span class='warning'>[loc.name]\'s arm starts stretching inhumanly!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a tentacle.</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")
		else
			loc << "<span class='notice'>You prepare to extend a tentacle.</span>"


/obj/item/weapon/gun/magic/tentacle/shoot_with_empty_chamber(mob/living/user as mob|obj)
	user << "<span class='warning'>The [name] is not ready yet.<span>"

/obj/item/ammo_casing/magic/tentacle
	name = "tentacle"
	desc = "a tentacle."
	projectile_type = /obj/item/projectile/tentacle
	caliber = "tentacle"
	icon_state = "tentacle_end"
	firing_effect_type = null
	var/obj/item/weapon/gun/magic/tentacle/gun //the item that shot it

/obj/item/ammo_casing/magic/tentacle/New(obj/item/weapon/gun/magic/tentacle/tentacle_gun)
	gun = tentacle_gun
	..()

/obj/item/ammo_casing/magic/tentacle/Destroy(obj/item/weapon/gun/magic/tentacle/tentacle_gun)
	gun = null
	..()

/obj/item/projectile/tentacle
	name = "tentacle"
	icon_state = "tentacle_end"
	pass_flags = PASSTABLE
	damage = 0
	damage_type = BRUTE
	range = 8
	hitsound = 'sound/weapons/thudswoosh.ogg'
	var/chain
	var/obj/item/ammo_casing/magic/tentacle/source //the item that shot it

/obj/item/projectile/tentacle/New(obj/item/ammo_casing/magic/tentacle/tentacle_casing)
	source = tentacle_casing
	..()

/obj/item/projectile/tentacle/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "tentacle", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1)
	..()

/obj/item/projectile/tentacle/proc/reset_throw(mob/living/carbon/human/H)
	if(H.in_throw_mode)
		H.throw_mode_off() //Don't annoy the changeling if he doesn't catch the item

/obj/item/projectile/tentacle/proc/tentacle_grab(mob/living/carbon/human/H, mob/living/carbon/C)
	if(H.Adjacent(C))
		C.grabbedby(H)
		C.grippedby(H) //instant aggro grab

/obj/item/projectile/tentacle/proc/tentacle_stab(mob/living/carbon/human/H, mob/living/carbon/C)
	if(H.Adjacent(C))
		for(var/obj/item/I in H.held_items)
			if(I.is_sharp())
				C.visible_message("<span class='danger'>[H] impales [C] with [H.p_their()] [I.name]!</span>", "<span class='userdanger'>[H] impales you with [H.p_their()] [I.name]!</span>")
				C.apply_damage(I.force*2, BRUTE, "chest")
				H.do_item_attack_animation(C, used_item = I)
				H.add_mob_blood(C)
				playsound(get_turf(H),I.hitsound,75,1)
				C.Weaken(4)
				return

/obj/item/projectile/tentacle/on_hit(atom/target, blocked = 0)
	var/mob/living/carbon/human/H = firer
	H.unEquip(source.gun,1) //Unequip thus delete the tentacle on hit
	if(blocked >= 100)
		return 0
	if(istype(target, /obj/item))
		var/obj/item/I = target
		if(!I.anchored)
			firer << "<span class='notice'>You pull [I] towards yourself.</span>"
			H.throw_mode_on()
			I.throw_at(H, 10, 2)
			. = 1

	else if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored && !L.throwing)//avoid double hits
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				switch(firer.a_intent)
					if(INTENT_HELP)
						C.visible_message("<span class='danger'>[L] is pulled by [H]'s tentacle!</span>","<span class='userdanger'>A tentacle grabs you and pulls you towards [H]!</span>")
						C.throw_at(get_step_towards(H,C), 8, 2)
						return 1

					if(INTENT_DISARM)
						var/obj/item/I = C.get_active_held_item()
						if(I)
							if(C.drop_item())
								C.visible_message("<span class='danger'>[I] is yanked off of [C]'s hand by [src]!</span>","<span class='userdanger'>A tentacle pulls [I] away from you!</span>")
								on_hit(I) //grab the item as if you had hit it directly with the tentacle
								return 1
							else
								firer << "<span class='danger'>You can't seem to pry [I] off of [C]'s hands!<span>"
								return 0
						else
							firer << "<span class='danger'>[C] has nothing in hand to disarm!<span>"
							return 0

					if(INTENT_GRAB)
						C.visible_message("<span class='danger'>[L] is grabbed by [H]'s tentacle!</span>","<span class='userdanger'>A tentacle grabs you and pulls you towards [H]!</span>")
						C.throw_at(get_step_towards(H,C), 8, 2, callback=CALLBACK(src, .proc/tentacle_grab, H, C))
						return 1

					if(INTENT_HARM)
						C.visible_message("<span class='danger'>[L] is thrown towards [H] by a tentacle!</span>","<span class='userdanger'>A tentacle grabs you and throws you towards [H]!</span>")
						C.Weaken(3)
						C.throw_at(get_step_towards(H,C), 8, 2, callback=CALLBACK(src, .proc/tentacle_stab, H, C))
						return 1
			else
				L.visible_message("<span class='danger'>[L] is pulled by [H]'s tentacle!</span>","<span class='userdanger'>A tentacle grabs you and pulls you towards [H]!</span>")
				L.throw_at(get_step_towards(H,L), 8, 2)
				. = 1

/obj/item/projectile/tentacle/Destroy()
	qdel(chain)
	source = null
	return ..()


/***************************************\
|****************SHIELD*****************|
\***************************************/
/obj/effect/proc_holder/changeling/weapon/shield
	name = "Organic Shield"
	desc = "We reform one of our arms into a hard shield."
	helptext = "Organic tissue cannot resist damage forever; the shield will break after it is hit too much. The more genomes we absorb, the stronger it is. Cannot be used while in lesser form."
	chemical_cost = 20
	dna_cost = 1
	genetic_damage = 12
	req_human = 1
	max_genetic_damage = 20

	weapon_type = /obj/item/weapon/shield/changeling
	weapon_name_simple = "shield"

/obj/effect/proc_holder/changeling/weapon/shield/sting_action(mob/user)
	var/datum/changeling/changeling = user.mind.changeling //So we can read the absorbedcount.
	if(!changeling)
		return

	var/obj/item/weapon/shield/changeling/S = ..(user)
	S.remaining_uses = round(changeling.absorbedcount * 3)
	return 1

/obj/item/weapon/shield/changeling
	name = "shield-like mass"
	desc = "A mass of tough, boney tissue. You can still see the fingers as a twisted pattern in the shield."
	flags = ABSTRACT | NODROP | DROPDEL
	icon = 'icons/obj/weapons.dmi'
	icon_state = "ling_shield"
	block_chance = 50

	var/remaining_uses //Set by the changeling ability.

/obj/item/weapon/shield/changeling/New()
	..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>The end of [loc.name]\'s hand inflates rapidly, forming a huge shield-like mass!</span>", "<span class='warning'>We inflate our hand into a strong shield.</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")

/obj/item/weapon/shield/changeling/hit_reaction()
	if(remaining_uses < 1)
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.visible_message("<span class='warning'>With a sickening crunch, [H] reforms his shield into an arm!</span>", "<span class='notice'>We assimilate our shield into our body</span>", "<span class='italics>You hear organic matter ripping and tearing!</span>")
			H.unEquip(src, 1)
		qdel(src)
		return 0
	else
		remaining_uses--
		return ..()


/***************************************\
|*********SPACE SUIT + HELMET***********|
\***************************************/
/obj/effect/proc_holder/changeling/suit/organic_space_suit
	name = "Organic Space Suit"
	desc = "We grow an organic suit to protect ourselves from space exposure."
	helptext = "We must constantly repair our form to make it space-proof, reducing chemical production while we are protected. Retreating the suit damages our genomes. Cannot be used in lesser form."
	chemical_cost = 20
	dna_cost = 2
	genetic_damage = 8
	req_human = 1
	max_genetic_damage = 20

	suit_type = /obj/item/clothing/suit/space/changeling
	helmet_type = /obj/item/clothing/head/helmet/space/changeling
	suit_name_simple = "flesh shell"
	helmet_name_simple = "space helmet"
	recharge_slowdown = 0.5
	blood_on_castoff = 1

/obj/item/clothing/suit/space/changeling
	name = "flesh mass"
	icon_state = "lingspacesuit"
	desc = "A huge, bulky mass of pressure and temperature-resistant organic tissue, evolved to facilitate space travel."
	flags = STOPSPRESSUREDMAGE | NODROP | DROPDEL //Not THICKMATERIAL because it's organic tissue, so if somebody tries to inject something into it, it still ends up in your blood. (also balance but muh fluff)
	allowed = list(/obj/item/device/flashlight, /obj/item/weapon/tank/internals/emergency_oxygen, /obj/item/weapon/tank/internals/oxygen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0, fire = 90, acid = 90) //No armor at all.

/obj/item/clothing/suit/space/changeling/New()
	..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>[loc.name]\'s flesh rapidly inflates, forming a bloated mass around their body!</span>", "<span class='warning'>We inflate our flesh, creating a spaceproof suit!</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/changeling/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.reagents.add_reagent("salbutamol", REAGENTS_METABOLISM)

/obj/item/clothing/head/helmet/space/changeling
	name = "flesh mass"
	icon_state = "lingspacehelmet"
	desc = "A covering of pressure and temperature-resistant organic tissue with a glass-like chitin front."
	flags = STOPSPRESSUREDMAGE | NODROP | DROPDEL //Again, no THICKMATERIAL.
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0, fire = 90, acid = 90)
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/***************************************\
|*****************ARMOR*****************|
\***************************************/
/obj/effect/proc_holder/changeling/suit/armor
	name = "Chitinous Armor"
	desc = "We turn our skin into tough chitin to protect us from damage."
	helptext = "Upkeep of the armor requires a low expenditure of chemicals. The armor is strong against brute force, but does not provide much protection from lasers. Retreating the armor damages our genomes. Cannot be used in lesser form."
	chemical_cost = 20
	dna_cost = 1
	genetic_damage = 11
	req_human = 1
	max_genetic_damage = 20
	recharge_slowdown = 0.25

	suit_type = /obj/item/clothing/suit/armor/changeling
	helmet_type = /obj/item/clothing/head/helmet/changeling
	suit_name_simple = "armor"
	helmet_name_simple = "helmet"

/obj/item/clothing/suit/armor/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin."
	icon_state = "lingarmor"
	flags = NODROP | DROPDEL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 20, bomb = 10, bio = 4, rad = 0, fire = 90, acid = 90)
	flags_inv = HIDEJUMPSUIT
	cold_protection = 0
	heat_protection = 0

/obj/item/clothing/suit/armor/changeling/New()
	..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>[loc.name]\'s flesh turns black, quickly transforming into a hard, chitinous mass!</span>", "<span class='warning'>We harden our flesh, creating a suit of armor!</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")

/obj/item/clothing/head/helmet/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin with transparent chitin in front."
	icon_state = "lingarmorhelmet"
	flags = NODROP | DROPDEL
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 20, bomb = 10, bio = 4, rad = 0, fire = 90, acid = 90)
	flags_inv = HIDEEARS|HIDEHAIR|HIDEEYES|HIDEFACIALHAIR|HIDEFACE
