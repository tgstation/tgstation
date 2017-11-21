
// Do I have a stake in my heart?
/mob/living/proc/AmStaked()
	var/obj/item/bodypart/BP = get_bodypart("chest")
	if (!BP)
		return 0
	for(var/obj/item/I in BP.embedded_objects)
		if (istype(I,/obj/item/stake/))
			return 1
	return 0


///obj/item/weapon/melee/stake
/obj/item/stake/
	name = "wooden stake"
	desc = "A simple wooden stake carved to a sharp point."
	icon = 'icons/Fulpstation/fulpitems.dmi'
	icon_state = "wood" // Inventory Icon
	item_state = "wood" // In-hand Icon
	lefthand_file = 'icons/Fulpstation/fulpitems_hold_left.dmi' // File for in-hand icon
	righthand_file = 'icons/Fulpstation/fulpitems_hold_right.dmi'
	origin_tech = "biotech=1;combat=1"
	attack_verb = list("staked")
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL

	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 6
	throwforce = 10
	embed_chance = 25 // Look up "is_pointed" to see where we set stakes able to do this.
	embedded_fall_chance = 0.5 // Chance it will fall out.
	obj_integrity = 30
	max_integrity = 30
	//embedded_fall_pain_multiplier

	var/staketime = 120		// Time it takes to embed the stake into someone's chest.




/obj/item/stake/basic
	name = "wooden stake"
	// This exists so Hardened/Silver Stake can't have a welding torch used on them.


/obj/item/stake/basic/attackby(obj/item/W, mob/user, params)
	if (istype(W, /obj/item/weldingtool))
		//if (amWelded)
		//	to_chat(user, "<span class='warning'>This stake has already been treated with fire.</span>")
		//	return
		//amWelded = TRUE
		// Weld it
		var/obj/item/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			user.visible_message("[user.name] scorched the pointy end of [src] with the welding tool.", \
						 "<span class='notice'>You scorch the pointy end of [src] with the welding tool.</span>", \
						 "<span class='italics'>You hear welding.</span>")
		// 8 Second Timer
		if (!do_mob(user, src, 80))
			return

		// Create the Stake
		qdel(src)
		var/obj/item/stake/hardened/new_item = new(usr.loc)
		user.put_in_hands(new_item)

	else
		return ..()



/obj/item/stake/afterattack(atom/target, mob/user, proximity)
	//to_chat(world, "<span class='notice'>DEBUG: Staking </span>")
	// Invalid Target, or not targetting chest with HARM intent?
	if (!iscarbon(target) || check_zone(user.zone_selected) != "chest" || user.a_intent != INTENT_HARM)
		return
	var/mob/living/carbon/C = target
	// Needs to be Down/Slipped in some way to Stake. Taken from update_canmove() in mob.dm
	if (!C.can_be_staked())
		return
	// Make Attempt...
	to_chat(user, "<span class='notice'>You put all your weight into embedding the stake into [target]'s chest...</span>")
	playsound(user, 'sound/magic/Demon_consume.ogg', 50, 1)
	if (!do_mob(user, C, staketime, 0, 1, extra_checks=CALLBACK(C, /mob/living/carbon/proc/can_be_staked))) // user / target / time / uninterruptable / show progress bar / extra checks
		return
	// Oops! Can't.
	if(C.dna && (PIERCEIMMUNE in C.dna.species.species_traits))
		to_chat(user, "<span class='danger'>[target]'s chest resists the stake. It won't go in.</span>")
		return

	// Drop & Embed Stake
	user.visible_message("<span class='danger'>[user.name] drives the [src] into [target]'s chest!</span>", \
			 "<span class='danger'>You drive the [src] into [target]'s chest!</span>")
	playsound(get_turf(target), 'sound/effects/splat.ogg', 40, 1)

	user.dropItemToGround(src, TRUE) //user.drop_item() // "drop item" doesn't seem to exist anymore. New proc is user.dropItemToGround() but it doesn't seem like it's needed now?

	var/obj/item/bodypart/B = C.get_bodypart("chest")  // This was all taken from hitby() in human_defense.dm
	B.embedded_objects |= src
	add_mob_blood(target)//Place blood on the stake
	loc = C // Put INSIDE the character
	B.receive_damage(w_class * embedded_impact_pain_multiplier)

	if (C.mind)
		var/datum/antagonist/bloodsucker/bloodsucker = C.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if (bloodsucker)
			// If DEAD or TORPID...kill vamp!
			if (C.stat == DEAD || C.status_flags & FAKEDEATH) // NOTE: This is the ONLY time a staked Torpid vamp dies.
				bloodsucker.FinalDeath()
				return
			else
				to_chat(target, "<span class='userdanger'>You have been staked! Your powers are useless, your death forever, while it remains in place.</span>")


// Can this target be staked? If someone stands up before this is complete, it fails. Best used on someone stationary.
/mob/living/carbon/proc/can_be_staked()
	return IsKnockdown() || IsUnconscious() || (stat && (stat != SOFT_CRIT || pulledby)) || (status_flags & FAKEDEATH) || resting || IsStun() || IsFrozen() || (pulledby && pulledby.grab_state >= GRAB_NECK)






/obj/item/stack/sheet/mineral/wood/attackby(obj/item/W, mob/user, params) // NOTE: sheet_types.dm is where the WOOD stack lives. Maybe move this over there.
	// Taken from /obj/item/stack/rods/attackby in [rods.dm]
	if (W.is_sharp())
		user.visible_message("[user] begins whittling [src] into a pointy object.", \
				 "<span class='notice'>You begin whittling [src] into a sharp point at one end.</span>", \
				 "<span class='italics'>You hear wood carving.</span>")
		// 8 Second Timer
		if (!do_mob(user, src, 80))
			return
		// Make Stake
		var/obj/item/stake/basic/new_item = new(usr.loc)
		user.visible_message("[user] finishes carving a stake out of [src].", \
				 "<span class='notice'>You finish carving a stake out of [src].</span>")
		// Prepare to Put in Hands (if holding wood)
		var/obj/item/stack/sheet/mineral/wood/thisStack = src
		var/replace = (user.get_inactive_held_item()==thisStack)
		// Use Wood
		thisStack.use(1)
		// If stack depleted, put item in that hand (if it had one)
		if (!thisStack && replace)
			user.put_in_hands(new_item)


/obj/item/stake/hardened
	// Created by welding and acid-treating a simple stake.
	name = "hardened stake"
	desc = "A hardened wooden stake carved to a sharp point and scorched at the end."
	icon_state = "hardened" // Inventory Icon
	force = 8
	throwforce = 12
	armour_penetration = 10
	embed_chance = 50
	embedded_fall_chance = 0 // Chance it will fall out.
	obj_integrity = 120
	max_integrity = 120

	staketime = 80

/obj/item/stake/hardened/silver
	name = "silver stake"
	desc = "Polished and sharp at the end. For when some mofo is always trying to iceskate uphill."
	icon_state = "silver" // Inventory Icon
	item_state = "silver" // In-hand Icon
	origin_tech = "materials=1;combat=1;"
	siemens_coefficient = 1 //flags = CONDUCT // var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	force = 9
	armour_penetration = 25
	embed_chance = 55
	obj_integrity = 300
	max_integrity = 300

	staketime = 60

// Convert back to Silver
/obj/item/stake/hardened/silver/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			var/obj/item/stack/sheet/mineral/silver/newsheet = new (user.loc)
			for(var/obj/item/stack/sheet/mineral/silver/S in user.loc)
				if(S == newsheet)
					continue
				if(S.amount >= S.max_amount)
					continue
				S.attackby(newsheet, user)
			to_chat(user, "<span class='notice'>You melt down the stake and add it to the stack. It now contains [newsheet.amount] sheet\s.</span>")
			qdel(src)
	else
		return ..()


// Look up recipes.dm OR pneumaticCannon.dm
/datum/crafting_recipe/silver_stake
	name = "Silver Stake"
	result = /obj/item/stake/hardened/silver
	tools = list(/obj/item/weldingtool)
	reqs = list(/obj/item/stack/sheet/mineral/silver = 2,
				/obj/item/stake/hardened = 1)
				///obj/item/stack/packageWrap = 8,
				///obj/item/pipe = 2)
	time = 80
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//   BLOOD BAGS! Add ability to drank em




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






/obj/structure/closet/coffin/bloodsucker // closet.dmi, closets.dm, and job_closets.dm
	name = "Black Coffin"
	desc = "For those departed who are not so dear."
	icon_state = "coffin"
	icon = 'icons/Fulpstation/fulpobjects.dmi'
	var/mob/living/carbon/creator	// Who made me? Locks when they sleep inside, unlocks when they are awake. Assigned when using Blood on this during construction.
	can_weld_shut = FALSE
	resistance_flags = 0			// Start off with no bonuses.
	open_sound = 'sound/machines/door_open.ogg'
	close_sound = 'sound/machines/door_close.ogg'

	// Locks when going into Torpor inside it (NOTE: give warning if you sleep in your OWN coffin.

/obj/structure/closet/coffin/bloodsucker/proc/ClaimCoffin(mob/living/carbon/claimant)
	// We're a Vampire Coffin? Why didn't you say so!
	anchored = 1					// No moving this
	resistance_flags = FIRE_PROOF	// Vamp coffins are fireproof.
	// Make it BLOODY!
	icon_state = "coffin_bloody"
	icon_door = "coffin"
	icon_door_override = TRUE // Have door use icon_door to pick out its art. This way we can swap to a bloody coffin without redundant door art.
	update_icon()
	creator = claimant
	to_chat(claimant, "<span class='notice'>You have claimed the [src] for your own.</span>")

/obj/structure/closet/coffin/
	can_weld_shut = FALSE
	breakout_time = 600

/obj/structure/closet/coffin/bloodsucker/can_open(mob/living/user)
	// You cannot lock in/out a coffin's owner. SORRY.
	if (locked)
		if(user == creator)
			if (welded)
				welded = FALSE
				update_icon()
			to_chat(user, "<span class='notice'>You flip a secret latch and unlock the [src].</span>")
			locked = FALSE
			return 1
		else
			playsound(get_turf(src), 'sound/machines/door_locked.ogg', 20, 1)
			to_chat(user, "<span class='notice'>The [src] is locked tight from the inside.</span>")
	return ..()

/obj/structure/closet/coffin/bloodsucker/close(mob/living/user)
	if (!..())
		return 0
	// Creator inside Coffin? Lock it (no matter who closed us)
	to_chat(user, "<span class='userdanger'>DEBUG: close() [user] / [src] / [creator] / [creator in src]. </span>")
	if (creator && creator in src && creator.stat == CONSCIOUS)
		if (!broken)
			locked = TRUE
			to_chat(creator, "<span class='notice'>You flip a secret latch and lock yourself inside the [src].</span>")
		else
			to_chat(creator, "<span class='notice'>The secret latch to lock the [src] from the inside is broken. You set it back into place...</span>")
			if (do_mob(creator, src, 50))//sleep(10)
				to_chat(creator, "<span class='notice'>You fix the mechanism.</span>")
				broken = FALSE
				locked = TRUE
		// Play Sound: locktoggle.ogg  ?
	return 1

/obj/structure/closet/coffin/bloodsucker/attackby(obj/item/W, mob/user, params)
	// You cannot weld or deconstruct an owned coffin. STILL NOT SORRY.
	if (creator != null && user != creator)
		if(opened)
			if(istype(W, cutting_tool))
				to_chat(user, "<span class='notice'>This is a much more complex mechanical structure than you thought. You don't know where to begin cutting the [src].</span>")
				return
	..()




/obj/structure/bloodaltar
	name = "Bloody Altar"

/obj/structure/statue/bloodstatue
	name = "Bloody Countenance"
