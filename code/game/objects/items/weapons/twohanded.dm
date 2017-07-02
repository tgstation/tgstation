/* Two-handed Weapons
 * Contains:
 * 		Twohanded
 *		Fireaxe
 *		Double-Bladed Energy Swords
 *		Spears
 *		CHAINSAWS
 *		Bone Axe and Spear
 */

/*##################################################################
##################### TWO HANDED WEAPONS BE HERE~ -Agouri :3 ########
####################################################################*/

//Rewrote TwoHanded weapons stuff and put it all here. Just copypasta fireaxe to make new ones ~Carn
//This rewrite means we don't have two variables for EVERY item which are used only by a few weapons.
//It also tidies stuff up elsewhere.




/*
 * Twohanded
 */
/obj/item/weapon/twohanded
	var/wielded = 0
	var/force_unwielded = 0
	var/force_wielded = 0
	var/wieldsound = null
	var/unwieldsound = null

/obj/item/weapon/twohanded/proc/unwield(mob/living/carbon/user, show_message = TRUE)
	if(!wielded || !user)
		return
	wielded = 0
	if(force_unwielded)
		force = force_unwielded
	var/sf = findtext(name," (Wielded)")
	if(sf)
		name = copytext(name,1,sf)
	else //something wrong
		name = "[initial(name)]"
	update_icon()
	if(show_message)
		if(iscyborg(user))
			to_chat(user, "<span class='notice'>You free up your module.</span>")
		else
			to_chat(user, "<span class='notice'>You are now carrying [src] with one hand.</span>")
	if(unwieldsound)
		playsound(loc, unwieldsound, 50, 1)
	var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_held_item()
	if(O && istype(O))
		O.unwield()
	return

/obj/item/weapon/twohanded/proc/wield(mob/living/carbon/user)
	if(wielded)
		return
	if(ismonkey(user))
		to_chat(user, "<span class='warning'>It's too heavy for you to wield fully.</span>")
		return
	if(user.get_inactive_held_item())
		to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
		return
	if(user.get_num_arms() < 2)
		to_chat(user, "<span class='warning'>You don't have enough hands.</span>")
		return
	wielded = 1
	if(force_wielded)
		force = force_wielded
	name = "[name] (Wielded)"
	update_icon()
	if(iscyborg(user))
		to_chat(user, "<span class='notice'>You dedicate your module to [src].</span>")
	else
		to_chat(user, "<span class='notice'>You grab [src] with both hands.</span>")
	if (wieldsound)
		playsound(loc, wieldsound, 50, 1)
	var/obj/item/weapon/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
	O.name = "[name] - offhand"
	O.desc = "Your second grip on [src]."
	O.wielded = TRUE
	user.put_in_inactive_hand(O)
	return

/obj/item/weapon/twohanded/dropped(mob/user)
	..()
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(!wielded)
		return
	if(user)
		var/obj/item/weapon/twohanded/O = user.get_inactive_held_item()
		if(istype(O))
			O.unwield(user, FALSE)
	unwield(user)

/obj/item/weapon/twohanded/update_icon()
	return

/obj/item/weapon/twohanded/attack_self(mob/user)
	..()
	if(wielded) //Trying to unwield it
		unwield(user)
	else //Trying to wield it
		wield(user)

/obj/item/weapon/twohanded/equip_to_best_slot(mob/M)
	if(..())
		if(istype(src, /obj/item/weapon/twohanded/required))
			return // unwield forces twohanded-required items to be dropped.
		unwield(M)
		return

/obj/item/weapon/twohanded/equipped(mob/user, slot)
	..()
	if(!user.is_holding(src) && wielded && !istype(src, /obj/item/weapon/twohanded/required))
		unwield(user)

///////////OFFHAND///////////////
/obj/item/weapon/twohanded/offhand
	name = "offhand"
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	flags = ABSTRACT | NODROP
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/weapon/twohanded/offhand/unwield()
	if(wielded)//Only delete if we're wielded
		wielded = FALSE
		qdel(src)

/obj/item/weapon/twohanded/offhand/wield()
	if(wielded)//Only delete if we're wielded
		wielded = FALSE
		qdel(src)

/obj/item/weapon/twohanded/offhand/attack_self(mob/living/carbon/user)		//You should never be able to do this in standard use of two handed items. This is a backup for lingering offhands.
	var/obj/item/weapon/twohanded/O = user.get_inactive_held_item()
	if (istype(O) && !istype(O, /obj/item/weapon/twohanded/offhand/))		//If you have a proper item in your other hand that the offhand is for, do nothing. This should never happen.
		return
	if (QDELETED(src))
		return
	qdel(src)																//If it's another offhand, or literally anything else, qdel. If I knew how to add logging messages I'd put one here.

///////////Two hand required objects///////////////
//This is for objects that require two hands to even pick up
/obj/item/weapon/twohanded/required
	w_class = WEIGHT_CLASS_HUGE

/obj/item/weapon/twohanded/required/attack_self()
	return

/obj/item/weapon/twohanded/required/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	if(wielded && !slot_flags)
		to_chat(M, "<span class='warning'>[src] is too cumbersome to carry with anything but your hands!</span>")
		return 0
	return ..()

/obj/item/weapon/twohanded/required/attack_hand(mob/user)//Can't even pick it up without both hands empty
	var/obj/item/weapon/twohanded/required/H = user.get_inactive_held_item()
	if(get_dist(src,user) > 1)
		return
	if(H != null)
		to_chat(user, "<span class='notice'>[src] is too cumbersome to carry in one hand!</span>")
		return
	if(src.loc != user)
		wield(user)
	..()

/obj/item/weapon/twohanded/required/equipped(mob/user, slot)
	..()
	var/slotbit = slotdefine2slotbit(slot)
	if(slot_flags & slotbit)
		var/datum/O = user.is_holding_item_of_type(/obj/item/weapon/twohanded/offhand)
		if(!O || QDELETED(O))
			return
		qdel(O)
		return
	if(slot == slot_hands)
		wield(user)
	else
		unwield(user)

/obj/item/weapon/twohanded/required/wield(mob/living/carbon/user)
	..()
	if(!wielded)
		user.dropItemToGround(src)

/obj/item/weapon/twohanded/required/unwield(mob/living/carbon/user, show_message = TRUE)
	if(show_message)
		to_chat(user, "<span class='notice'>You drop [src].</span>")
	..(user, FALSE)
	user.dropItemToGround(src)

/*
 * Fireaxe
 */
/obj/item/weapon/twohanded/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 5
	force_wielded = 24
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP
	obj_integrity = 200
	max_integrity = 200
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 30)
	resistance_flags = FIRE_PROOF

/obj/item/weapon/twohanded/fireaxe/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "fireaxe[wielded]"
	return

/obj/item/weapon/twohanded/fireaxe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] axes [user.p_them()]self from head to toe! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/weapon/twohanded/fireaxe/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(wielded) //destroys windows and grilles in one hit
		if(istype(A,/obj/structure/window))
			var/obj/structure/window/W = A
			W.take_damage(200, BRUTE, "melee", 0)
		else if(istype(A,/obj/structure/grille))
			var/obj/structure/grille/G = A
			G.take_damage(40, BRUTE, "melee", 0)


/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/weapon/twohanded/dualsaber
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY
	force_unwielded = 3
	force_wielded = 34
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	hitsound = "swing_hit"
	armour_penetration = 35
	origin_tech = "magnets=4;syndicate=5"
	item_color = "green"
	light_color = "#00ff00"//green
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 75
	obj_integrity = 200
	max_integrity = 200
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF
	var/hacked = 0
	var/brightness_on = 6 //TWICE AS BRIGHT AS A REGULAR ESWORD
	var/list/possible_colors = list("red", "blue", "green", "purple")

/obj/item/weapon/twohanded/dualsaber/Initialize()
	. = ..()
	if(LAZYLEN(possible_colors))
		item_color = pick(possible_colors)
		switch(item_color)
			if("red")
				light_color = LIGHT_COLOR_RED
			if("green")
				light_color = LIGHT_COLOR_GREEN
			if("blue")
				light_color = LIGHT_COLOR_LIGHT_CYAN
			if("purple")
				light_color = LIGHT_COLOR_LAVENDER

/obj/item/weapon/twohanded/dualsaber/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/weapon/twohanded/dualsaber/update_icon()
	if(wielded)
		icon_state = "dualsaber[item_color][wielded]"
	else
		icon_state = "dualsaber0"
	clean_blood()//blood overlays get weird otherwise, because the sprite changes.

/obj/item/weapon/twohanded/dualsaber/attack(mob/target, mob/living/carbon/human/user)
	if(user.has_dna())
		if(user.dna.check_mutation(HULK))
			to_chat(user, "<span class='warning'>You grip the blade too hard and accidentally close it!</span>")
			unwield()
			return
	..()
	if(user.disabilities & CLUMSY && (wielded) && prob(40))
		impale(user)
		return
	if((wielded) && prob(50))
		INVOKE_ASYNC(src, .proc/jedi_spin, user)

/obj/item/weapon/twohanded/dualsaber/proc/jedi_spin(mob/living/user)
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		user.setDir(i)
		if(i == WEST)
			user.emote("flip")
		sleep(1)

/obj/item/weapon/twohanded/dualsaber/proc/impale(mob/living/user)
	to_chat(user, "<span class='warning'>You twirl around a bit before losing your balance and impaling yourself on [src].</span>")
	if (force_wielded)
		user.take_bodypart_damage(20,25)
	else
		user.adjustStaminaLoss(25)

/obj/item/weapon/twohanded/dualsaber/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance)
	if(wielded)
		return ..()
	return 0

/obj/item/weapon/twohanded/dualsaber/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)  //In case thats just so happens that it is still activated on the groud, prevents hulk from picking it up
	if(wielded)
		to_chat(user, "<span class='warning'>You can't pick up such dangerous item with your meaty hands without losing fingers, better not to!</span>")
		return 1

/obj/item/weapon/twohanded/dualsaber/wield(mob/living/carbon/M) //Specific wield () hulk checks due to reflection chance for balance issues and switches hitsounds.
	if(M.has_dna())
		if(M.dna.check_mutation(HULK))
			to_chat(M, "<span class='warning'>You lack the grace to wield this!</span>")
			return
	..()
	if(wielded)
		sharpness = IS_SHARP
		w_class = w_class_on
		hitsound = 'sound/weapons/blade1.ogg'
		START_PROCESSING(SSobj, src)
		set_light(brightness_on)

/obj/item/weapon/twohanded/dualsaber/unwield() //Specific unwield () to switch hitsounds.
	sharpness = initial(sharpness)
	w_class = initial(w_class)
	..()
	hitsound = "swing_hit"
	STOP_PROCESSING(SSobj, src)
	set_light(0)

/obj/item/weapon/twohanded/dualsaber/process()
	if(wielded)
		if(hacked)
			light_color = pick(LIGHT_COLOR_RED, LIGHT_COLOR_GREEN, LIGHT_COLOR_LIGHT_CYAN, LIGHT_COLOR_LAVENDER)
		open_flame()
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/weapon/twohanded/dualsaber/IsReflect()
	if(wielded)
		return 1

/obj/item/weapon/twohanded/dualsaber/ignition_effect(atom/A, mob/user)
	// same as /obj/item/weapon/melee/energy, mostly
	if(!wielded)
		return ""
	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask == src)
			in_mouth = ", barely missing their nose"
	. = "<span class='warning'>[user] swings [user.p_their()] [src][in_mouth]. [user.p_they()] light[user.p_s()] [A] in the process.</span>"
	playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	add_fingerprint(user)
	// Light your candles while spinning around the room
	INVOKE_ASYNC(src, .proc/jedi_spin, user)

/obj/item/weapon/twohanded/dualsaber/green
	possible_colors = list("green")

/obj/item/weapon/twohanded/dualsaber/red
	possible_colors = list("red")

/obj/item/weapon/twohanded/dualsaber/blue
	possible_colors = list("blue")

/obj/item/weapon/twohanded/dualsaber/purple
	possible_colors = list("purple")

/obj/item/weapon/twohanded/dualsaber/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		if(hacked == 0)
			hacked = 1
			to_chat(user, "<span class='warning'>2XRNBW_ENGAGE</span>")
			item_color = "rainbow"
			update_icon()
		else
			to_chat(user, "<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")
	else
		return ..()

//spears
/obj/item/weapon/twohanded/spear
	icon_state = "spearglass0"
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 10
	force_wielded = 18
	throwforce = 20
	throw_speed = 4
	embedded_impact_pain_multiplier = 3
	armour_penetration = 10
	materials = list(MAT_METAL=1150, MAT_GLASS=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharpness = IS_SHARP
	obj_integrity = 200
	max_integrity = 200
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 30)
	var/obj/item/weapon/grenade/explosive = null
	var/war_cry = "AAAAARGH!!!"

/obj/item/weapon/twohanded/spear/update_icon()
	if(explosive)
		icon_state = "spearbomb[wielded]"
	else
		icon_state = "spearglass[wielded]"

/obj/item/weapon/twohanded/spear/afterattack(atom/movable/AM, mob/user, proximity)
	if(!proximity)
		return
	if(isopenturf(AM)) //So you can actually melee with it
		return
	if(explosive && wielded)
		user.say("[war_cry]")
		explosive.loc = AM
		explosive.prime()
		qdel(src)

 //THIS MIGHT BE UNBALANCED SO I DUNNO // it totally is.
/obj/item/weapon/twohanded/spear/throw_impact(atom/target)
	. = ..()
	if(!.) //not caught
		if(explosive)
			explosive.prime()
			qdel(src)

/obj/item/weapon/twohanded/spear/AltClick()
	..()
	if(!explosive)
		return
	if(ismob(loc))
		var/mob/M = loc
		var/input = stripped_input(M,"What do you want your war cry to be? You will shout it when you hit someone in melee.", ,"", 50)
		if(input)
			src.war_cry = input

/obj/item/weapon/twohanded/spear/CheckParts(list/parts_list)
	var/obj/item/weapon/twohanded/spear/S = locate() in parts_list
	if(S)
		if(S.explosive)
			S.explosive.forceMove(get_turf(src))
			S.explosive = null
		parts_list -= S
		qdel(S)
	..()
	var/obj/item/weapon/grenade/G = locate() in contents
	if(G)
		explosive = G
		name = "explosive lance"
		desc = "A makeshift spear with [G] attached to it. Alt+click on the spear to set your war cry!"
	update_icon()

// CHAINSAW
/obj/item/weapon/twohanded/required/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon_state = "chainsaw_off"
	flags = CONDUCT
	force = 13
	var/force_on = 21
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	materials = list(MAT_METAL=13000)
	origin_tech = "materials=3;engineering=4;combat=2"
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = "swing_hit"
	sharpness = IS_SHARP
	actions_types = list(/datum/action/item_action/startchainsaw)
	var/on = 0

/obj/item/weapon/twohanded/required/chainsaw/attack_self(mob/user)
	on = !on
	to_chat(user, "As you pull the starting cord dangling from [src], [on ? "it begins to whirr." : "the chain stops moving."]")
	force = on ? force_on : initial(force)
	throwforce = on ? force_on : initial(force)
	icon_state = "chainsaw_[on ? "on" : "off"]"

	if(hitsound == "swing_hit")
		hitsound = 'sound/weapons/chainsawhit.ogg'
	else
		hitsound = "swing_hit"

	if(src == user.get_active_held_item()) //update inhands
		user.update_inv_hands()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/weapon/twohanded/required/chainsaw/get_dismemberment_chance()
	if(wielded)
		. = ..()

/obj/item/weapon/twohanded/required/chainsaw/doomslayer
	name = "THE GREAT COMMUNICATOR"
	desc = "<span class='warning'>VRRRRRRR!!!</span>"
	armour_penetration = 100
	force_on = 30

/obj/item/weapon/twohanded/required/chainsaw/doomslayer/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message("<span class='danger'>Ranged attacks just make [owner] angrier!</span>")
		playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
		return 1
	return 0

//GREY TIDE
/obj/item/weapon/twohanded/spear/grey_tide
	icon_state = "spearglass0"
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Nanotrasen military forces."
	force_unwielded = 15
	force_wielded = 25
	throwforce = 20
	throw_speed = 4
	attack_verb = list("gored")

/obj/item/weapon/twohanded/spear/grey_tide/afterattack(atom/movable/AM, mob/living/user, proximity)
	..()
	if(!proximity)
		return
	user.faction |= "greytide(\ref[user])"
	if(isliving(AM))
		var/mob/living/L = AM
		if(istype (L, /mob/living/simple_animal/hostile/illusion))
			return
		if(!L.stat && prob(50))
			var/mob/living/simple_animal/hostile/illusion/M = new(user.loc)
			M.faction = user.faction.Copy()
			M.Copy_Parent(user, 100, user.health/2.5, 12, 30)
			M.GiveTarget(L)

/obj/item/weapon/twohanded/pitchfork
	icon_state = "pitchfork0"
	name = "pitchfork"
	desc = "A simple tool used for moving hay."
	force = 7
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	force_unwielded = 7
	force_wielded = 15
	attack_verb = list("attacked", "impaled", "pierced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP
	obj_integrity = 200
	max_integrity = 200
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 30)
	resistance_flags = FIRE_PROOF

/obj/item/weapon/twohanded/pitchfork/demonic
	name = "demonic pitchfork"
	desc = "A red pitchfork, it looks like the work of the devil."
	force = 19
	throwforce = 24
	force_unwielded = 19
	force_wielded = 25

/obj/item/weapon/twohanded/pitchfork/demonic/Initialize()
	set_light(3,6,LIGHT_COLOR_RED)

/obj/item/weapon/twohanded/pitchfork/demonic/greater
	force = 24
	throwforce = 50
	force_unwielded = 24
	force_wielded = 34

/obj/item/weapon/twohanded/pitchfork/demonic/ascended
	force = 100
	throwforce = 100
	force_unwielded = 100
	force_wielded = 500000 // Kills you DEAD.

/obj/item/weapon/twohanded/pitchfork/update_icon()
	icon_state = "pitchfork[wielded]"

/obj/item/weapon/twohanded/pitchfork/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] impales [user.p_them()]self in [user.p_their()] abdomen with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/weapon/twohanded/pitchfork/demonic/pickup(mob/living/user)
	if(isliving(user) && user.mind && user.owns_soul() && !is_devil(user))
		var/mob/living/U = user
		U.visible_message("<span class='warning'>As [U] picks [src] up, [U]'s arms briefly catch fire.</span>", \
			"<span class='warning'>\"As you pick up [src] your arms ignite, reminding you of all your past sins.\"</span>")
		if(ishuman(U))
			var/mob/living/carbon/human/H = U
			H.apply_damage(rand(force/2, force), BURN, pick("l_arm", "r_arm"))
		else
			U.adjustFireLoss(rand(force/2,force))

/obj/item/weapon/twohanded/pitchfork/demonic/attack(mob/target, mob/living/carbon/human/user)
	if(user.mind && user.owns_soul() && !is_devil(user))
		to_chat(user, "<span class ='warning'>[src] burns in your hands.</span>")
		user.apply_damage(rand(force/2, force), BURN, pick("l_arm", "r_arm"))
	..()

/obj/item/weapon/twohanded/pitchfork/demonic/ascended/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !wielded)
		return
	if(istype(target, /turf/closed/wall))
		var/turf/closed/wall/W = target
		user.visible_message("<span class='danger'>[user] blasts \the [target] with \the [src]!</span>")
		playsound(target, 'sound/magic/disintegrate.ogg', 100, 1)
		W.break_wall()
		return 1
	..()

//HF blade

/obj/item/weapon/twohanded/vibro_weapon
	icon_state = "hfrequency0"
	name = "vibro sword"
	desc = "A potent weapon capable of cutting through nearly anything. Wielding it in two hands will allow you to deflect gunfire."
	force_unwielded = 20
	force_wielded = 40
	armour_penetration = 100
	block_chance = 40
	throwforce = 20
	throw_speed = 4
	sharpness = IS_SHARP
	attack_verb = list("cut", "sliced", "diced")
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/twohanded/vibro_weapon/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	if(wielded)
		final_block_chance *= 2
	if(wielded || attack_type != PROJECTILE_ATTACK)
		if(prob(final_block_chance))
			if(attack_type == PROJECTILE_ATTACK)
				owner.visible_message("<span class='danger'>[owner] deflects [attack_text] with [src]!</span>")
				playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
				return 1
			else
				owner.visible_message("<span class='danger'>[owner] parries [attack_text] with [src]!</span>")
				return 1
	return 0

/obj/item/weapon/twohanded/vibro_weapon/update_icon()
	icon_state = "hfrequency[wielded]"

/*
 * Bone Axe
 */
/obj/item/weapon/twohanded/fireaxe/boneaxe  // Blatant imitation of the fireaxe, but made out of bone.
	icon_state = "bone_axe0"
	name = "bone axe"
	desc = "A large, vicious axe crafted out of several sharpened bone plates and crudely tied together. Made of monsters, by killing monsters, for killing monsters."
	force_wielded = 23

/obj/item/weapon/twohanded/fireaxe/boneaxe/update_icon()
	icon_state = "bone_axe[wielded]"

/*
 * Bone Spear
 */
/obj/item/weapon/twohanded/bonespear	//Blatant imitation of spear, but made out of bone. Not valid for explosive modification.
	icon_state = "bone_spear0"
	name = "bone spear"
	desc = "A haphazardly-constructed yet still deadly weapon. The pinnacle of modern technology."
	force = 11
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 11
	force_wielded = 20					//I have no idea how to balance
	throwforce = 22
	throw_speed = 4
	embedded_impact_pain_multiplier = 3
	armour_penetration = 15				//Enhanced armor piercing
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharpness = IS_SHARP

/obj/item/weapon/twohanded/bonespear/update_icon()
	icon_state = "bone_spear[wielded]"