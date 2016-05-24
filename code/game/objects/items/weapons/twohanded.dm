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

/obj/item/weapon/twohanded/proc/unwield(mob/living/carbon/user)
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
	if(isrobot(user))
		user << "<span class='notice'>You free up your module.</span>"
	else if(istype(src, /obj/item/weapon/twohanded/required))
		user << "<span class='notice'>You drop \the [name].</span>"
	else
		user << "<span class='notice'>You are now carrying the [name] with one hand.</span>"
	if(unwieldsound)
		playsound(loc, unwieldsound, 50, 1)
	var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand()
	if(O && istype(O))
		O.unwield()
	return

/obj/item/weapon/twohanded/proc/wield(mob/living/carbon/user)
	if(wielded)
		return
	if(istype(user,/mob/living/carbon/monkey) )
		user << "<span class='warning'>It's too heavy for you to wield fully.</span>"
		return
	if(user.get_inactive_hand())
		user << "<span class='warning'>You need your other hand to be empty!</span>"
		return
	if(user.get_num_arms() < 2)
		user << "<span class='warning'>You don't have enough hands.</span>"
		return
	wielded = 1
	if(force_wielded)
		force = force_wielded
	name = "[name] (Wielded)"
	update_icon()
	if(isrobot(user))
		user << "<span class='notice'>You dedicate your module to [name].</span>"
	else
		user << "<span class='notice'>You grab the [name] with both hands.</span>"
	if (wieldsound)
		playsound(loc, wieldsound, 50, 1)
	var/obj/item/weapon/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
	O.name = "[name] - offhand"
	O.desc = "Your second grip on the [name]"
	user.put_in_inactive_hand(O)
	return

/obj/item/weapon/twohanded/mob_can_equip(mob/M, slot)
	//Cannot equip wielded items.
	if(wielded)
		M << "<span class='warning'>Unwield the [name] first!</span>"
		return 0
	return ..()

/obj/item/weapon/twohanded/dropped(mob/user)
	..()
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(user)
		var/obj/item/weapon/twohanded/O = user.get_inactive_hand()
		if(istype(O))
			O.unwield(user)
	return	unwield(user)

/obj/item/weapon/twohanded/update_icon()
	return

/obj/item/weapon/twohanded/attack_self(mob/user)
	..()
	if(wielded) //Trying to unwield it
		unwield(user)
	else //Trying to wield it
		wield(user)

///////////OFFHAND///////////////
/obj/item/weapon/twohanded/offhand
	name = "offhand"
	icon_state = "offhand"
	w_class = 5
	flags = ABSTRACT

/obj/item/weapon/twohanded/offhand/unwield()
	qdel(src)

/obj/item/weapon/twohanded/offhand/wield()
	qdel(src)

///////////Two hand required objects///////////////
//This is for objects that require two hands to even pick up
/obj/item/weapon/twohanded/required/
	w_class = 5

/obj/item/weapon/twohanded/required/attack_self()
	return

/obj/item/weapon/twohanded/required/mob_can_equip(mob/M, slot)
	if(wielded)
		M << "<span class='warning'>\The [src] is too cumbersome to carry with anything but your hands!</span>"
		return 0
	return ..()

/obj/item/weapon/twohanded/required/attack_hand(mob/user)//Can't even pick it up without both hands empty
	var/obj/item/weapon/twohanded/required/H = user.get_inactive_hand()
	if(get_dist(src,user) > 1)
		return 0
	if(H != null)
		user << "<span class='notice'>\The [src] is too cumbersome to carry in one hand!</span>"
		return
	wield(user)
	..()


/obj/item/weapon/twohanded/

/*
 * Fireaxe
 */
/obj/item/weapon/twohanded/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	w_class = 4
	slot_flags = SLOT_BACK
	force_unwielded = 5
	force_wielded = 24 // Was 18, Buffed - RobRichards/RR
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP

/obj/item/weapon/twohanded/fireaxe/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "fireaxe[wielded]"
	return

/obj/item/weapon/twohanded/fireaxe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] axes \himself from head to toe! It looks like \he's trying to commit suicide..</span>")
	return (BRUTELOSS)

/obj/item/weapon/twohanded/fireaxe/afterattack(atom/A as mob|obj|turf|area, mob/user, proximity)
	if(!proximity) return
	if(wielded) //destroys windows and grilles in one hit
		if(istype(A,/obj/structure/window))
			var/obj/structure/window/W = A
			W.shatter()
		else if(istype(A,/obj/structure/grille))
			var/obj/structure/grille/G = A
			G.take_damage(16)


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
	w_class = 2
	force_unwielded = 3
	force_wielded = 34
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	hitsound = "swing_hit"
	armour_penetration = 35
	origin_tech = "magnets=4;syndicate=5"
	item_color = "green"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 75
	var/hacked = 0

/obj/item/weapon/twohanded/dualsaber/New()
	item_color = pick("red", "blue", "green", "purple")

/obj/item/weapon/twohanded/dualsaber/update_icon()
	if(wielded)
		icon_state = "dualsaber[item_color][wielded]"
	else
		icon_state = "dualsaber0"
	clean_blood()//blood overlays get weird otherwise, because the sprite changes.
	return

/obj/item/weapon/twohanded/dualsaber/attack(mob/target, mob/living/carbon/human/user)
	..()
	if(user.disabilities & CLUMSY && (wielded) && prob(40))
		impale(user)
		return
	if((wielded) && prob(50))
		spawn(0)
			for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
				user.dir = i
				if(i == 8)
					user.emote("flip")
				sleep(1)

/obj/item/weapon/twohanded/dualsaber/proc/impale(mob/living/user)
	user << "<span class='warning'>You twirl around a bit before losing your balance and impaling yourself on \the [src].</span>"
	if (force_wielded)
		user.take_organ_damage(20,25)
	else
		user.adjustStaminaLoss(25)

/obj/item/weapon/twohanded/dualsaber/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance)
	if(wielded)
		return ..()
	return 0

/obj/item/weapon/twohanded/dualsaber/attack_hulk(mob/living/carbon/human/user)  //In case thats just so happens that it is still activated on the groud, prevents hulk from picking it up
	if(wielded)
		user << "<span class='warning'>You can't pick up such dangerous item with your meaty hands without losing fingers, better not to!</span>"
		return 1

/obj/item/weapon/twohanded/dualsaber/wield(mob/living/carbon/M) //Specific wield () hulk checks due to reflection chance for balance issues and switches hitsounds.
	if(M.has_dna())
		if(M.dna.check_mutation(HULK))
			M << "<span class='warning'>You lack the grace to wield this!</span>"
			return
	..()
	hitsound = 'sound/weapons/blade1.ogg'

/obj/item/weapon/twohanded/dualsaber/unwield() //Specific unwield () to switch hitsounds.
	..()
	hitsound = "swing_hit"

/obj/item/weapon/twohanded/dualsaber/IsReflect()
	if(wielded)
		return 1

/obj/item/weapon/twohanded/dualsaber/green/New()
	item_color = "green"

/obj/item/weapon/twohanded/dualsaber/red/New()
	item_color = "red"

/obj/item/weapon/twohanded/dualsaber/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		if(hacked == 0)
			hacked = 1
			user << "<span class='warning'>2XRNBW_ENGAGE</span>"
			item_color = "rainbow"
			update_icon()
		else
			user << "<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>"
	else
		return ..()

//spears
/obj/item/weapon/twohanded/spear
	icon_state = "spearglass0"
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	w_class = 4
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
	if(istype(AM, /turf/open)) //So you can actually melee with it
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
	..()
	if(explosive)
		explosive.loc = get_turf(src.loc)
		explosive = null
	var/obj/item/weapon/grenade/G = locate() in contents
	if(G)
		explosive = G
		name = "explosive lance"
		desc = "A makeshift spear with [G] attached to it. Alt+click on the spear to set your war cry!"
		return
	update_icon()

// CHAINSAW
/obj/item/weapon/twohanded/required/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon_state = "chainsaw_off"
	flags = CONDUCT
	force = 13
	w_class = 5
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
	user << "As you pull the starting cord dangling from \the [src], [on ? "it begins to whirr." : "the chain stops moving."]"
	force = on ? 21 : 13
	throwforce = on ? 21 : 13
	icon_state = "chainsaw_[on ? "on" : "off"]"

	if(hitsound == "swing_hit")
		hitsound = 'sound/weapons/chainsawhit.ogg'
	else
		hitsound = "swing_hit"

	if(src == user.get_active_hand()) //update inhands
		user.update_inv_l_hand()
		user.update_inv_r_hand()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/weapon/twohanded/required/chainsaw/get_dismemberment_chance()
	if(wielded)
		. = ..()

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
	if(istype(AM, /mob/living))
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
	w_class = 4
	force_unwielded = 7
	force_wielded = 15
	attack_verb = list("attacked", "impaled", "pierced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP

/obj/item/weapon/twohanded/pitchfork/demonic
	name = "demonic pitchfork"
	desc = "A red pitchfork, it looks like the work of the devil."
	force = 19
	throwforce = 24
	force_unwielded = 19
	force_wielded = 25

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

/obj/item/weapon/twohanded/pitchfork/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "pitchfork[wielded]"

/obj/item/weapon/twohanded/pitchfork/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] impales \himself in \his abdomen with [src]! It looks like \he's trying to commit suicide..</span>")
	return (BRUTELOSS)

/obj/item/weapon/twohanded/pitchfork/demonic/pickup(mob/user)
	if(istype(user, /mob/living))
		var/mob/living/U = user
		if(!U.mind.devilinfo)
			U.visible_message("<span class='warning'>As [U] picks [src] up, [U]'s arms briefly catch fire.</span>", \
				"<span class='warning'>\"As you pick up the [src] your arms ignite, reminding you of all your past sins.\"</span>")
			if(ishuman(U))
				var/mob/living/carbon/human/H = U
				H.apply_damage(rand(force/2, force), BURN, pick("l_arm", "r_arm"))
			else
				U.adjustFireLoss(rand(force/2,force))

/obj/item/weapon/twohanded/pitchfork/demonic/attack(mob/target, mob/living/carbon/human/user)
	if(!user.mind.devilinfo)
		user << "<span class ='warning'>The [src] burns in your hands.</span>"
		user.apply_damage(rand(force/2, force), BURN, pick("l_arm", "r_arm"))
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
	w_class = 4
	slot_flags = SLOT_BACK
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/twohanded/vibro_weapon/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	if(wielded)
		final_block_chance *= 2
	if(wielded || attack_type != PROJECTILE_ATTACK)
		if(prob(final_block_chance))
			if(attack_type == PROJECTILE_ATTACK)
				owner.visible_message("<span class='danger'>[owner] deflects [attack_text] with [src]!</span>")
				playsound(src, pick("sound/weapons/bulletflyby.ogg","sound/weapons/bulletflyby2.ogg","sound/weapons/bulletflyby3.ogg"), 75, 1)
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
	w_class = 4
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
