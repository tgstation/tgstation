/* Two-handed Weapons
 * Contains:
 * 		Twohanded
 *		Fireaxe
 *		Double-Bladed Energy Swords
 *		Spears
 *		CHAINSAWS
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

/obj/item/weapon/twohanded/offhand/hit_reaction()//if the actual twohanded weapon is a shield, we count as a shield too!
	var/mob/user = loc
	if(!istype(user))
		return 0
	var/obj/item/I = user.get_active_hand()
	if(I == src)
		I = user.get_inactive_hand()
	if(!I)
		return 0
	return I.hit_reaction()

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
			W.spawnfragments() // this will qdel and spawn shards
		else if(istype(A,/obj/structure/grille))
			var/obj/structure/grille/G = A
			G.health = -6
			G.destroyed += prob(25) // If this is set, healthcheck will completely remove the grille
			G.healthcheck()


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
	armour_penetration = 75
	origin_tech = "magnets=3;syndicate=4"
	item_color = "green"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 50
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
	..()
	if(istype(W, /obj/item/device/multitool))
		if(hacked == 0)
			hacked = 1
			user << "<span class='warning'>2XRNBW_ENGAGE</span>"
			item_color = "rainbow"
			update_icon()
		else
			user << "<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>"


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
	if(istype(AM, /turf/simulated/floor)) //So you can actually melee with it
		return
	if(istype(AM, /turf/space)) //So you can actually melee with it
		return
	if(explosive && wielded)
		user.say("[war_cry]")
		explosive.loc = AM
		explosive.prime()
		qdel(src)

 //THIS MIGHT BE UNBALANCED SO I DUNNO
/obj/item/weapon/twohanded/spear/throw_impact(atom/target)
	. = ..()
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

//Placeholder C4 "grenade" for use on this spear
/obj/item/weapon/grenade/C4
	name = "C-4"
	desc = "A brick of C-4."

/obj/item/weapon/grenade/C4/prime()
	update_mob()
	explosion(src.loc,-1,1,3)
	qdel(src)

/obj/item/weapon/twohanded/spear/CheckParts()
	if(explosive)
		explosive.loc = get_turf(src.loc)
		explosive = null
	var/obj/item/weapon/grenade/G = locate() in contents
	if(G)
		explosive = G
		name = "explosive lance"
		desc = "A makeshift spear with [G] attached to it. Alt+click on the spear to set your war cry!"
		return
	var/obj/item/weapon/c4/C4 = locate() in contents
	if(C4)
		var /obj/item/weapon/grenade/C4/C42 = new /obj/item/weapon/grenade/C4(src)
		qdel(C4)
		explosive = C42
		desc = "A makeshift spear with [C42] attached to it. Alt+click on the spear to set your war cry!"
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
	origin_tech = "materials=2;engineering=2;combat=2"
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
