#define MAX_TABLE_MESSES 8 // how many things can we knock off a table at once?

/**
  *#tackle.dm
  *
  * For when you want to throw a person at something and have fun stuff happen
  *
  * This component is made for carbon mobs (really, humans), and allows its parent to throw themselves and perform tackles. This is done by enabling throw mode, then clicking on your
  *	  intended target with an empty hand. You will then launch toward your target. If you hit a carbon, you'll roll to see how hard you hit them. If you hit a solid non-mob, you'll
  *	  roll to see how badly you just messed yourself up. If, along your journey, you hit a table, you'll slam onto it and send up to MAX_TABLE_MESSES (8) /obj/items on the table flying,
  *	  and take a bit of extra damage and stun for each thing launched.
  *
  * There are 2 """skill rolls""" involved here, which are handled and explained in sack() and rollTackle() (for roll 1, carbons), and splat() (for roll 2, walls and solid objects)
*/
/datum/component/tackler
	dupe_mode = COMPONENT_DUPE_UNIQUE

	///If we're currently tackling or are on cooldown. Actually, shit, if I use this to handle cooldowns, then getting thrown by something while on cooldown will count as a tackle..... whatever, i'll fix that next commit
	var/tackling = TRUE
	///How much stamina it takes to launch a tackle
	var/stamina_cost
	///Launching a tackle calls Knockdown on you for this long, so this is your cooldown. Once you stand back up, you can tackle again.
	var/base_knockdown
	///Your max range for how far you can tackle.
	var/range
	///How fast you sail through the air. Standard tackles are 1 speed, but gloves that throw you faster come at a cost: higher speeds make it more likely you'll be badly injured if you fly into a non-mob obstacle.
	var/speed
	///A flat modifier to your roll against your target, as described in [rollTackle()][/datum/component/tackler/proc/rollTackle]. Slightly misleading, skills aren't relevant here, this is a matter of what type of gloves (or whatever) is granting you the ability to tackle.
	var/skill_mod
	///Some gloves, generally ones that increase mobility, may have a minimum distance to fly. Rocket gloves are especially dangerous with this, be sure you'll hit your target or have a clear background if you miss, or else!
	var/min_distance
	///The throwdatum we're currently dealing with, if we need it
	var/datum/thrownthing/tackle

/datum/component/tackler/Initialize(stamina_cost = 25, base_knockdown = 1 SECONDS, range = 4, speed = 1, skill_mod = 0, min_distance = min_distance)
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	src.stamina_cost = stamina_cost
	src.base_knockdown = base_knockdown
	src.range = range
	src.speed = speed
	src.skill_mod = skill_mod
	src.min_distance = min_distance

	var/mob/P = parent
	to_chat(P, "<span class='notice'>You are now able to launch tackles! You can do so by activating throw intent, and clicking on your target with an empty hand.</span>")

	addtimer(CALLBACK(src, .proc/resetTackle), base_knockdown, TIMER_STOPPABLE)

/datum/component/tackler/Destroy()
	var/mob/P = parent
	to_chat(P, "<span class='notice'>You can no longer tackle.</span>")
	..()

/datum/component/tackler/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLICKON, .proc/checkTackle)
	RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, .proc/sack)
	RegisterSignal(parent, COMSIG_MOVABLE_POST_THROW, .proc/registerTackle)
	RegisterSignal(parent, COMSIG_MOVABLE_Z_FALL_IMPACT, .proc/splatGround)
	RegisterSignal(parent, COMSIG_MOVABLE_Z_FALL_SKIPFALL, .proc/checkSkipFall)

/datum/component/tackler/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_CLICKON, COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_Z_FALL_IMPACT, COMSIG_MOVABLE_Z_FALL_SKIPFALL))

///Store the thrownthing datum for later use
/datum/component/tackler/proc/registerTackle(mob/living/carbon/user, datum/thrownthing/TT)
	tackle = TT

///See if we can tackle or not. If we can, leap!
/datum/component/tackler/proc/checkTackle(mob/living/carbon/user, atom/A, params)
	if(!user.in_throw_mode || user.get_active_held_item() || user.pulling || user.buckling)
		return

	if(HAS_TRAIT(user, TRAIT_HULK))
		to_chat(user, "<span class='warning'>You're too angry to remember how to tackle!</span>")
		return

	if(user.restrained())
		to_chat(user, "<span class='warning'>You need free use of your hands to tackle!</span>")
		return

	if(!(user.mobility_flags & MOBILITY_STAND))
		to_chat(user, "<span class='warning'>You must be standing to tackle!</span>")
		return

	if(tackling)
		to_chat(user, "<span class='warning'>You're not ready to tackle!</span>")
		return

	if(user.has_movespeed_modifier(MOVESPEED_ID_SHOVE)) // can't tackle if you just got shoved
		to_chat(user, "<span class='warning'>You're too off balance to tackle!</span>")
		return

	user.face_atom(A)

	var/list/modifiers = params2list(params)
	if(modifiers["alt"] || modifiers["shift"] || modifiers["ctrl"] || modifiers["middle"])
		return

	tackling = TRUE
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/checkObstacle)
	playsound(user, 'sound/weapons/thudswoosh.ogg', 40, TRUE, -1)

	if(can_see(user, A, 7))
		user.visible_message("<span class='warning'>[user] leaps at [A]!</span>", "<span class='danger'>You leap at [A]!</span>")
	else
		user.visible_message("<span class='warning'>[user] leaps!</span>", "<span class='danger'>You leap!</span>")

	if(get_dist(user, A) < min_distance)
		A = get_ranged_target_turf(user, get_dir(user, A), min_distance) //TODO: this only works in cardinals/diagonals, make it work with in-betweens too!

	user.Knockdown(base_knockdown, TRUE, TRUE)
	user.adjustStaminaLoss(stamina_cost)
	user.throw_at(A, range, speed, user, FALSE)
	addtimer(CALLBACK(src, .proc/resetTackle), base_knockdown, TIMER_STOPPABLE)
	return(COMSIG_MOB_CANCEL_CLICKON)

/**
 * sack()
 *
 * sack() is called when you actually smack into something, assuming we're mid-tackle. First it deals with smacking into non-carbons, in two cases:
 * * If it's a non-carbon mob, we don't care, get out of here and do normal thrown-into-mob stuff
 * * Else, if it's something dense (walls, machinery, structures, most things other than the floor), go to splat() and get ready for some high grade shit
 *
 * If it's a carbon we hit, we'll call rollTackle() which rolls a die and calculates modifiers for both the tackler and target, then gives us a number. Negatives favor the target, while positives favor the tackler.
 * Check [rollTackle()][/datum/component/tackler/proc/rollTackle] for a more thorough explanation on the modifiers at play.
 *
 * Then, we figure out what effect we want, and we get to work! Note that with standard gripper gloves and no modifiers, the range of rolls is (-3, 3). The results are as follows, based on what we rolled:
 * * -inf to -5: Seriously botched tackle, tackler suffers a concussion, brute damage, and a 3 second paralyze, target suffers nothing
 * * -4 to -2: weak tackle, tackler gets 3 second knockdown, target gets shove slowdown but is otherwise fine
 * * -1 to 0: decent tackle, tackler gets up a bit quicker than the target
 * * 1: solid tackle, tackler has more of an advantage getting up quicker
 * * 2 to 4: expert tackle, tackler has sizeable advantage and lands on their feet with a free passive grab
 * * 5 to inf: MONSTER tackle, tackler gets up immediately and gets a free aggressive grab, target takes sizeable stamina damage from the hit and is paralyzed for one and a half seconds and knocked down for three seconds
 *
 * Finally, we return a bitflag to [COMSIG_MOVABLE_IMPACT] that forces the hitpush to false so that we don't knock them away.
*/
/datum/component/tackler/proc/sack(mob/living/carbon/user, atom/hit, levels_fell=0)
	if(!tackling || !tackle)
		return

	if(levels_fell)
		var/mob/living/L = hit
		user.visible_message("<span class='danger'>[user] slams into [L] from above!</span>", "<span class='danger'>You slam into [L] from above!</span>", list(L))
		to_chat(L, "<span class='danger'>[user] slams into you from above!</span>")

	if(!iscarbon(hit))
		if(hit.density)
			return splat(user, hit)
		return

	var/mob/living/carbon/target = hit
	var/mob/living/carbon/human/T = target
	var/mob/living/carbon/human/S = user

	var/roll = rollTackle(target, levels_fell)
	tackling = FALSE
	tackle.gentle = TRUE

	log_combat(user, target, "has tackled (roll: [roll])")

	switch(roll)
		if(-INFINITY to -5)
			user.visible_message("<span class='danger'>[user] botches [user.p_their()] tackle and slams [user.p_their()] head into [target], knocking [user.p_them()]self silly!</span>", "<span class='userdanger'>You botch your tackle and slam your head into [target], knocking yourself silly!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] botches [user.p_their()] tackle and slams [user.p_their()] head into you, knocking [user.p_them()]self silly!</span>")

			user.Paralyze(30)
			var/obj/item/bodypart/head/hed = user.get_bodypart(BODY_ZONE_HEAD)
			if(hed)
				hed.receive_damage(brute=20, updating_health=TRUE)
			user.gain_trauma(/datum/brain_trauma/mild/concussion)

		if(-4 to -2) // glancing blow at best
			user.visible_message("<span class='warning'>[user] lands a weak tackle on [target], briefly knocking [target.p_them()] off-balance!</span>", "<span class='userdanger'>You land a weak tackle on [target], briefly knocking [target.p_them()] off-balance!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] lands a weak tackle on you, briefly knocking you off-balance!</span>")

			user.Knockdown(30)
			if(ishuman(target) && !T.has_movespeed_modifier(MOVESPEED_ID_SHOVE))
				T.add_movespeed_modifier(MOVESPEED_ID_SHOVE, multiplicative_slowdown = SHOVE_SLOWDOWN_STRENGTH) // maybe define a slightly more severe/longer slowdown for this
				addtimer(CALLBACK(T, /mob/living/carbon/human/proc/clear_shove_slowdown), SHOVE_SLOWDOWN_LENGTH)

		if(-1 to 0) // decent hit, both parties are about equally inconvenienced
			user.visible_message("<span class='warning'>[user] lands a passable tackle on [target], sending them both tumbling!</span>", "<span class='userdanger'>You land a passable tackle on [target], sending you both tumbling!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] lands a passable tackle on you, sending you both tumbling!</span>")

			target.adjustStaminaLoss(stamina_cost)
			target.Paralyze(5)
			user.Knockdown(20)
			target.Knockdown(25)

		if(1 to 2) // solid hit, tackler has a slight advantage
			user.visible_message("<span class='warning'>[user] lands a solid tackle on [target], knocking them both down hard!</span>", "<span class='userdanger'>You land a solid tackle on [target], knocking you both down hard!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] lands a solid tackle on you, knocking you both down hard!</span>")

			target.adjustStaminaLoss(30)
			target.Paralyze(5)
			user.Knockdown(10)
			target.Knockdown(20)

		if(3 to 4) // really good hit, the target is definitely worse off here. Without positive modifiers, this is as good a tackle as you can land
			user.visible_message("<span class='warning'>[user] lands an expert tackle on [target], knocking [target.p_them()] down hard while landing on [user.p_their()] feet with a passive grip!</span>", "<span class='userdanger'>You land an expert tackle on [target], knocking [target.p_them()] down hard while landing on your feet with a passive grip!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] lands an expert tackle on you, knocking you down hard and maintaining a passive grab!</span>")

			user.SetKnockdown(0)
			user.forceMove(get_turf(target))
			target.adjustStaminaLoss(40)
			target.Paralyze(5)
			target.Knockdown(30)
			if(ishuman(target) && ishuman(user))
				S.dna.species.grab(S, T)
				S.setGrabState(GRAB_PASSIVE)

		if(5 to INFINITY) // absolutely BODIED
			user.visible_message("<span class='warning'>[user] lands a monster tackle on [target], knocking [target.p_them()] senseless and applying an aggressive pin!</span>", "<span class='userdanger'>You land a monster tackle on [target], knocking [target.p_them()] senseless and applying an aggressive pin!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] lands a monster tackle on you, knocking you senseless and aggressively pinning you!</span>")

			user.SetKnockdown(0)
			user.forceMove(get_turf(target))
			target.adjustStaminaLoss(40)
			target.Paralyze(5)
			target.Knockdown(30)
			if(ishuman(target) && ishuman(user))
				S.dna.species.grab(S, T)
				S.setGrabState(GRAB_AGGRESSIVE)


	return COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH

/**
  * rollTackle()
  *
  * This handles all of the modifiers for the actual carbon-on-carbon tackling, and gets its own proc because of how many there are (with plenty more in mind!)
  *
  * The base roll is between (-3, 3), with negative numbers favoring the target, and positive numbers favoring the tackler. The target and the tackler are both assessed for
  *	how easy they are to knock over, with clumsiness and dwarfiness being strong maluses for each, and gigantism giving a bonus for each. These numbers and ideas
  *	are absolutely subject to change.

  * In addition, after subtracting the defender's mod and adding the attacker's mod to the roll, the component's base (skill) mod is added as well. Some sources of tackles
  *	are better at taking people down, like the bruiser and rocket gloves, while the dolphin gloves have a malus in exchange for better mobility.
*/
/datum/component/tackler/proc/rollTackle(mob/living/carbon/target, levels_fell)
	var/defense_mod = 0
	var/attack_mod = 0

	// DE-FENSE
	if(target.drunkenness > 60) // drunks are easier to knock off balance
		defense_mod -= 3
	else if(target.drunkenness > 30)
		defense_mod -= 1
	if(HAS_TRAIT(target, TRAIT_CLUMSY))
		defense_mod -= 2
	if(HAS_TRAIT(target, TRAIT_FAT)) // chonkers are harder to knock over
		defense_mod += 1
	if(HAS_TRAIT(target, TRAIT_GRABWEAKNESS))
		defense_mod -= 2
	if(HAS_TRAIT(target, TRAIT_DWARF))
		defense_mod -= 2
	if(HAS_TRAIT(target, TRAIT_GIANT))
		defense_mod += 2

	if(ishuman(target))
		var/mob/living/carbon/human/T = target
		var/suit_slot = T.get_item_by_slot(ITEM_SLOT_OCLOTHING)

		if(isnull(T.wear_suit) && isnull(T.w_uniform)) // who honestly puts all of their effort into tackling a naked guy?
			defense_mod += 2
		if(suit_slot && (istype(suit_slot,/obj/item/clothing/suit/space/hardsuit)))
			defense_mod += 1
		if(T.is_shove_knockdown_blocked()) // riot armor and such
			defense_mod += 5
		if(T.is_holding_item_of_type(/obj/item/shield))
			defense_mod += 2

		if(islizard(T))
			if(!T.getorganslot(ORGAN_SLOT_TAIL)) // lizards without tails are off-balance
				defense_mod -= 1
			else if(T.dna.species.is_wagging_tail()) // lizard tail wagging is robust and can swat away assailants!
				defense_mod += 1

	// OF-FENSE
	if(levels_fell)
		attack_mod += 3 * levels_fell

	var/mob/living/carbon/sacker = parent

	if(sacker.drunkenness > 60) // you're far too drunk to hold back!
		attack_mod += 1
	else if(sacker.drunkenness > 30) // if you're only a bit drunk though, you're just sloppy
		attack_mod -= 1
	if(HAS_TRAIT(sacker, TRAIT_CLUMSY))
		attack_mod -= 2
	if(HAS_TRAIT(sacker, TRAIT_DWARF))
		attack_mod -= 2
	if(HAS_TRAIT(sacker, TRAIT_GIANT))
		attack_mod += 2

	if(ishuman(target))
		var/mob/living/carbon/human/S = sacker

		var/suit_slot = S.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(suit_slot && (istype(suit_slot,/obj/item/clothing/suit/armor/riot))) // tackling in riot armor is more effective, but tiring
			attack_mod += 2
			sacker.adjustStaminaLoss(20)

	var/r = rand(-3, 3) - defense_mod + attack_mod + skill_mod
	return r


/**
  * splat()
  *
  * This is where we handle diving into dense atoms, generally with effects ranging from bad to REALLY bad. This works as a percentile roll that is modified in two steps as detailed below. The higher
  *	the roll, the more severe the result.
  *
  * Mod 1: Speed
  *	* Base tackle speed is 1, which is what normal gripper gloves use. For other sources with higher speed tackles, like dolphin and ESPECIALLY rocket gloves, we obey Newton's laws and hit things harder.
  *	* For every unit of speed above 1, move the lower bound of the roll up by 15. Unlike Mod 2, this only serves to raise the lower bound, so it can't be directly counteracted by anything you can control.
  *
  * Mod 2: Misc
  *	-Flat modifiers, these take whatever you rolled and add/subtract to it, with the end result capped between the minimum from Mod 1 and 100. Note that since we can't roll higher than 100 to start with,
  *		wearing a helmet should be enough to remove any chance of permanently paralyzing yourself and dramatically lessen knocking yourself unconscious, even with rocket gloves. Will expand on maybe
  *	* Wearing a helmet: -6
  *	* Wearing riot armor: -6
  *	* Clumsy: +6
  *
  * Effects: Below are the outcomes based off your roll, in order of increasing severity
  *	* 1-63: Knocked down for a few seconds and a bit of brute and stamina damage
  *	* 64-83: Knocked silly, gain some confusion as well as the above
  *	* 84-93: Cranial trauma, get a concussion and more confusion, plus more damage
  *	* 94-98: Knocked unconscious, significant chance to get a random mild brain trauma, as well as a fair amount of damage
  *	* 99-100: Break your spinal cord, get paralyzed, take a bunch of damage too. Very unlucky!
*/
/datum/component/tackler/proc/splat(mob/living/carbon/user, atom/hit)
	if(istype(hit, /obj/machinery/vending)) // before we do anything else-
		log_combat(user, hit, "has tackled (vendor)")
		var/obj/machinery/vending/darth_vendor = hit
		darth_vendor.tilt(user, TRUE)
		return
	else if(istype(hit, /obj/structure/window))
		var/obj/structure/window/W = hit
		splatWindow(user, W)
		if(QDELETED(W))
			return COMPONENT_MOVABLE_IMPACT_NEVERMIND
		return

	var/oopsie_mod = 0
	var/danger_zone = (speed - 1) * 15 // for every extra speed we have over 1, take away 15 of the safest chance
	danger_zone = max(min(danger_zone, 100), 1)

	if(ishuman(user))
		var/mob/living/carbon/human/S = user
		var/head_slot = S.get_item_by_slot(ITEM_SLOT_HEAD)
		var/suit_slot = S.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(head_slot && (istype(head_slot,/obj/item/clothing/head/helmet) || istype(head_slot,/obj/item/clothing/head/hardhat)))
			oopsie_mod -= 6
		if(suit_slot && (istype(suit_slot,/obj/item/clothing/suit/armor/riot)))
			oopsie_mod -= 6

	if(HAS_TRAIT(user, TRAIT_CLUMSY))
		oopsie_mod += 6 //honk!

	var/oopsie = rand(danger_zone, 100)
	if(oopsie >= 94 && oopsie_mod < 0) // good job avoiding getting paralyzed! gold star!
		to_chat(user, "<span class='usernotice'>You're really glad you're wearing protection!</span>")
	oopsie += oopsie_mod

	log_combat(user, hit, "has tackled (obstacle) (roll: [oopsie])")

	switch(oopsie)
		if(99 to INFINITY)
			// can you imagine standing around minding your own business when all of the sudden some guy fucking launches himself into a wall at full speed and irreparably paralyzes himself?
			user.visible_message("<span class='danger'>[user] slams face-first into [hit] at an awkward angle, severing [user.p_their()] spinal column with a sickening crack! Holy shit!</span>", "<span class='userdanger'>You slam face-first into [hit] at an awkward angle, severing your spinal column with a sickening crack! Holy shit!</span>")
			user.adjustStaminaLoss(30)
			user.adjustBruteLoss(30)
			playsound(user, 'sound/effects/blobattack.ogg', 60, TRUE)
			playsound(user, 'sound/effects/splat.ogg', 70, TRUE)
			user.emote("scream")
			user.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic) // oopsie indeed!
			shake_camera(user, 7, 7)
			user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash)
			user.clear_fullscreen("flash", 4.5)

		if(94 to 98)
			user.visible_message("<span class='danger'>[user] slams face-first into [hit] with a concerning squish, immediately going limp!</span>", "<span class='userdanger'>You slam face-first into [hit], and immediately lose consciousness!</span>")
			user.adjustStaminaLoss(30)
			user.adjustBruteLoss(30)
			user.Unconscious(100)
			user.gain_trauma_type(BRAIN_TRAUMA_MILD)
			user.playsound_local(get_turf(user), 'sound/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)
			shake_camera(user, 6, 6)
			user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash)
			user.clear_fullscreen("flash", 3.5)

		if(84 to 93)
			user.visible_message("<span class='danger'>[user] slams head-first into [hit], suffering major cranial trauma!</span>", "<span class='userdanger'>You slam head-first into [hit], and the world explodes around you!</span>")
			user.adjustStaminaLoss(30)
			user.adjustBruteLoss(30)
			user.confused += 15
			if(prob(80))
				user.gain_trauma(/datum/brain_trauma/mild/concussion)
			user.playsound_local(get_turf(user), 'sound/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)
			user.Knockdown(40)
			shake_camera(user, 5, 5)
			user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash)
			user.clear_fullscreen("flash", 2.5)

		if(64 to 83)
			user.visible_message("<span class='danger'>[user] slams hard into [hit], knocking [user.p_them()] senseless!</span>", "<span class='userdanger'>You slam hard into [hit], knocking yourself senseless!</span>")
			user.adjustStaminaLoss(30)
			user.adjustBruteLoss(10)
			user.confused += 10
			user.Knockdown(30)
			shake_camera(user, 3, 4)

		if(1 to 63)
			user.visible_message("<span class='danger'>[user] slams into [hit]!</span>", "<span class='userdanger'>You slam into [hit]!</span>")
			user.adjustStaminaLoss(20)
			user.adjustBruteLoss(10)
			user.Knockdown(30)
			shake_camera(user, 2, 2)

	playsound(user, 'sound/weapons/smash.ogg', 70, TRUE)


/datum/component/tackler/proc/resetTackle()
	tackling = FALSE
	QDEL_NULL(tackle)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

///A special case for splatting for handling windows
/datum/component/tackler/proc/splatWindow(mob/living/carbon/user, obj/structure/window/W)
	log_combat(user, W, "has tackled (window)")
	playsound(user, "sound/effects/Glasshit.ogg", 140, TRUE)

	if(W.type in list(/obj/structure/window, /obj/structure/window/fulltile, /obj/structure/window/unanchored, /obj/structure/window/fulltile/unanchored)) // boring unreinforced windows
		for(var/i = 0, i < speed, i++)
			var/obj/item/shard/shard = new /obj/item/shard(get_turf(user))
			shard.embedding = list(embed_chance = 100, ignore_throwspeed_threshold = TRUE, impact_pain_mult=3, pain_chance=5)
			shard.AddElement(/datum/element/embed, shard.embedding)
			user.hitby(shard, skipcatch = TRUE, hitpush = FALSE)
			shard.embedding = list()
			shard.AddElement(/datum/element/embed, shard.embedding)
		W.obj_destruction()
		user.adjustStaminaLoss(10 * speed)
		user.Paralyze(30)
		user.visible_message("<span class='danger'>[user] slams into [W] and shatters it, shredding [user.p_them()]self with glass!</span>", "<span class='userdanger'>You slam into [W] and shatter it, shredding yourself with glass!</span>")

	else
		user.visible_message("<span class='danger'>[user] slams into [W] like a bug, then slowly slides off it!</span>", "<span class='userdanger'>You slam into [W] like a bug, then slowly slide off it!</span>")
		user.Paralyze(10)
		user.Knockdown(30)
		W.take_damage(20 * speed)
		user.adjustStaminaLoss(10 * speed)
		user.adjustBruteLoss(5 * speed)

/datum/component/tackler/proc/delayedSmash(obj/structure/window/W)
	if(W)
		W.obj_destruction()
		playsound(W, "shatter", 70, TRUE)

///Check to see if we hit a table, and if so, make a big mess!
/datum/component/tackler/proc/checkObstacle(mob/living/carbon/owner)
	if(!tackling)
		return

	var/turf/T = get_turf(owner)
	var/obj/structure/table/kevved = locate(/obj/structure/table) in T.contents
	if(!kevved)
		return

	var/list/messes = list()

	// we split the mess-making into two parts (check what we're gonna send flying, intermission for dealing with the tackler, then actually send stuff flying) for the benefit of making sure the face-slam text
	// comes before the list of stuff that goes flying, but can still adjust text + damage to how much of a mess it made
	for(var/obj/item/I in T.contents)
		if(!I.anchored)
			messes += I
			if(messes.len >= MAX_TABLE_MESSES)
				break

	/// for telling HOW big of a mess we just made
	var/HOW_big_of_a_miss_did_we_just_make = ""
	if(messes.len)
		if(messes.len < MAX_TABLE_MESSES / 4)
			HOW_big_of_a_miss_did_we_just_make = ", making a mess"
		else if(messes.len < MAX_TABLE_MESSES / 2)
			HOW_big_of_a_miss_did_we_just_make = ", making a big mess"
		else if(messes.len < MAX_TABLE_MESSES)
			HOW_big_of_a_miss_did_we_just_make = ", making a giant mess"
		else
			HOW_big_of_a_miss_did_we_just_make = ", making a ginormous mess!" // an extra exclamation point!! for emphasis!!!

	owner.visible_message("<span class='danger'>[owner] trips over [kevved] and slams into it face-first[HOW_big_of_a_miss_did_we_just_make]!</span>", "<span class='userdanger'>You trip over [kevved] and slam into it face-first[HOW_big_of_a_miss_did_we_just_make]!</span>")
	owner.adjustStaminaLoss(20 + messes.len * 2)
	owner.adjustBruteLoss(10 + messes.len)
	owner.Paralyze(5 * messes.len) // half a second of paralyze for each thing you knock around
	owner.Knockdown(20 + 5 * messes.len) // 2 seconds of knockdown after the paralyze

	for(var/obj/item/I in messes)
		var/dist = rand(1, 3)
		var/sp = 2
		if(prob(25 * (src.speed - 1))) // if our tackle speed is higher than 1, with chance (speed - 1 * 25%), throw the thing at our tackle speed + 1
			sp = speed + 1
		I.throw_at(get_ranged_target_turf(I, pick(GLOB.alldirs), range = dist), range = dist, speed = sp)
		I.visible_message("<span class='danger'>[I] goes flying[sp > 3 ? " dangerously fast" : ""]!</span>") // standard embed speed

	playsound(owner, 'sound/weapons/smash.ogg', 70, TRUE)
	tackle.finalize(hit=TRUE)
	resetTackle()


/**
  * splatGround handles what happens when you dive off a ledge and land on a lower z-level
  *
  * What happens when you dive off a ledge? Nothing pleasant probably! This is another special case like hitting an obstacle, where you probably get into a horrible mess upon impact, unless you hit a mob in which case, very nice!
  */
/datum/component/tackler/proc/splatGround(mob/living/carbon/owner, turf/T, levels)
	if(!tackling)
		return

	var/mob/living/preferred
	for(var/mob/living/L in T)
		if(!L.density)
			continue
		if(ishuman(L)) // prefer humans > carbons > other living mobs, get first human standing we see
			sack(owner, L, levels_fell=levels)
			return FALL_NO_IMPACT
		else if(iscarbon(L) && (preferred && !iscarbon(preferred)))
			preferred = L
		else if(!preferred)
			preferred = L

	if(preferred)
		sack(owner, preferred, levels_fell=levels)
		return FALL_NO_IMPACT

	var/r = rand(1, 100)
	var/oopsie_mod = 0
	oopsie_mod += (levels - 1) * 20

	var/obj/item/organ/tail/cat/cat_tail = owner.getorganslot(ORGAN_SLOT_TAIL) // tails probably do more for balance than ears do for cats
	var/obj/item/clothing/head/headgear = owner.get_item_by_slot(ITEM_SLOT_HEAD)
	var/kitty_check = (cat_tail && istype(cat_tail)) || (headgear && istype(headgear, /obj/item/clothing/head/kitty)) // we'll throw cultural appropriators a bone though

	if(HAS_TRAIT(owner, TRAIT_CLUMSY))
		oopsie_mod += 10

	if(kitty_check)
		oopsie_mod -= 15 // cats always land on their feet! usually, anyway

	if(headgear && istype(headgear, /obj/item/clothing/head/helmet))
		oopsie_mod -= 5

	var/mob/living/carbon/human/H = owner
	if(istype(H))
		if(H.is_shove_knockdown_blocked())
			oopsie_mod -= 5

	r += oopsie_mod

	var/limbs_to_dismember = 0
	var/dismembers = 0
	var/list/splatters = list()
	var/spin_clockwise = tackle.init_dir in list(NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH)

	switch(r)
		if(99 to INFINITY)
			playsound(owner, 'sound/effects/blobattack.ogg', 60, TRUE)
			playsound(owner, 'sound/effects/splat.ogg', 70, TRUE)
			owner.visible_message("<span class='danger'>[owner] impacts [T] and deforms into a horrible amorphous blob of flesh and bone, splattering everything around [owner.p_them()] in a spray of gore! Holy fucking shit!</span>", "<span class='userdanger'>You resign yourself to your imminent future as a pancake. A really, really dumb pancake.</span>")
			for(var/obj/item/bodypart/B in owner.bodyparts)
				splatters += B.contents.Copy()
				splatters += B
				B.drop_organs()
				B.dismember()
			owner.gib(safe_gib=TRUE)

		if(95 to 98)
			playsound(owner, 'sound/effects/blobattack.ogg', 60, TRUE)
			playsound(owner, 'sound/effects/splat.ogg', 70, TRUE)
			limbs_to_dismember = 3
			owner.visible_message("<span class='danger'>[owner] crashes into [T] head-first like a speeding missile in a spectacular spray of gore, severing several limbs and killing [owner.p_them()] instantly! Holy shit!</span>", "<span class='userdanger'>Your life flashes before your eyes and you try to find peace as you hurtle towards [T]!</span>")
			for(var/obj/item/bodypart/B in owner.bodyparts)
				B.receive_damage(30)
				if(istype(B, /obj/item/bodypart/head))
					continue
				B.dismember()
				splatters += B
				dismembers++
				if(dismembers >= limbs_to_dismember)
					break

		if(85 to 94)
			playsound(owner, 'sound/effects/blobattack.ogg', 30, TRUE)
			playsound(owner, 'sound/effects/splat.ogg', 70, TRUE)
			owner.visible_message("<span class='danger'>[owner] slams into [T] at a horrible angle, crushing a majority of [owner.p_their()] body with a disgusting squelch!</span>", "<span class='userdanger'>You flail helplessly as you smash into [T], a resounding CRUNCH deafening you as you black out!</span>")
			for(var/obj/item/bodypart/B in owner.bodyparts)
				B.receive_damage(brute=20)
				for(var/obj/item/organ/O in B)
					O.applyOrganDamage(30)

			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50) // bonus brain damage
			owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE)
			owner.Unconscious(10 SECONDS) // assuming they're not in crit, anyway
			owner.Knockdown(17 SECONDS)

		if(70 to 84)
			playsound(owner, 'sound/effects/blobattack.ogg', 30, TRUE)
			playsound(owner, 'sound/effects/splat.ogg', 50, TRUE)
			owner.visible_message("<span class='danger'>[owner] slams [owner.p_their()] head into [T], cartwheeling over and falling limp!</span>", "<span class='userdanger'>You try hopelessly to right yourself as you hurdle towards [T] and feel your head spasm on impact as you black out!</span>")
			for(var/obj/item/bodypart/B in owner.bodyparts)
				if(istype(B, /obj/item/bodypart/head))
					B.receive_damage(40) // extra head damage
				B.receive_damage(brute=10, stamina=20)
				for(var/obj/item/organ/O in B)
					O.applyOrganDamage(15)
			owner.gain_trauma_type(BRAIN_TRAUMA_MILD)
			owner.Unconscious(5 SECONDS)
			owner.Knockdown(10 SECONDS)

		if(50 to 69)
			playsound(owner, 'sound/effects/blobattack.ogg', 30, TRUE)
			playsound(owner, 'sound/effects/splat.ogg', 30, TRUE)
			playsound(owner, 'sound/weapons/thudswoosh.ogg', 50, TRUE)
			owner.visible_message("<span class='danger'>[owner] slams into [T] with a resounding and very painful sounding thud!</span>", "<span class='userdanger'>You slam into [T] with a very painful thud, sending a burning pain shooting through your body!</span>")
			owner.Paralyze(3 SECONDS)
			owner.Knockdown(6 SECONDS)
			for(var/obj/item/bodypart/B in owner.bodyparts)
				B.receive_damage(brute=12, stamina=20) // 6 bodyparts for normal humans
				for(var/obj/item/organ/O in B)
					O.applyOrganDamage(10)

		if(50 to 69)
			playsound(owner, 'sound/effects/splat.ogg', 30, TRUE)
			playsound(owner, 'sound/weapons/thudswoosh.ogg', 50, TRUE)
			owner.visible_message("<span class='danger'>[owner] slams into [T] with a painful sounding thud!</span>", "<span class='userdanger'>You slam into [T] with a painful thud, sending a sharp pain through your body!</span>")
			owner.Paralyze(2 SECONDS)
			owner.Knockdown(6 SECONDS)
			for(var/obj/item/bodypart/B in owner.bodyparts)
				B.receive_damage(brute=8,stamina=16)
				for(var/obj/item/organ/O in B)
					O.applyOrganDamage(10)

		if(20 to 49)
			if(kitty_check)
				owner.SpinAnimation(5, 1, spin_clockwise)
				playsound(owner, 'sound/weapons/thudswoosh.ogg', 50, TRUE)
				owner.visible_message("<span class='danger'>[owner] does an impressive tactical roll and manages to stick the landing with [owner.p_their()] cat-like reflexes!</span>", "<span class='danger'>You manage an impressive tactical roll and manages to stick the landing with your cat-like reflexes!</span>")
				owner.forceMove(get_step(T, tackle.init_dir))
			else
				owner.visible_message("<span class='danger'>[owner] manages a rough tactical roll and survives the fall only slightly worse for wear!</span>", "<span class='userdanger'>You manage a rough tactical roll, surviving the fall only slightly worse for wear!</span>")
				for(var/obj/item/bodypart/B in owner.bodyparts)
					B.receive_damage(brute=4,stamina=5)
				owner.forceMove(get_step(T, tackle.init_dir))

		if(-INFINITY to 19)
			if(kitty_check)
				owner.SpinAnimation(5, 1, spin_clockwise)
				playsound(owner, 'sound/weapons/thudswoosh.ogg', 50, TRUE)
				owner.visible_message("<span class='danger'>[owner] does an impressive tactical roll and manages to stick the landing with [owner.p_their()] cat-like reflexes!</span>", "<span class='danger'>You manage an impressive tactical roll and manages to stick the landing with your cat-like reflexes!</span>")
				owner.forceMove(get_step(T, tackle.init_dir))
			else
				owner.SpinAnimation(5, 1, spin_clockwise)
				playsound(owner, 'sound/weapons/thudswoosh.ogg', 50, TRUE)
				owner.visible_message("<span class='danger'>[owner] manages a tactical roll and rights [owner.p_them()]self without much issue!</span>", "<span class='userdanger'>You manage a tactical roll, landing without much issue!</span>")
				owner.forceMove(get_step(T, tackle.init_dir))

	if(owner && owner.stat != CONSCIOUS)
		if(owner.stat == DEAD)
			to_chat(owner, "<span class='warning'>That was stupid of you.</span>")
		else
			owner.visible_message("<span class='danger'>[owner] blacks out from the fall!</span>", "<span class='userdanger'>You black out from the fall!</span>")

	for(var/obj/item/I in splatters)
		var/turf/splash_zone = get_step(pick(RANGE_TURFS(2, T)), tackle.init_dir)
		I.throw_at(splash_zone, 3)

	return FALL_NO_IMPACT

/datum/component/tackler/proc/checkSkipFall(mob/living/carbon/owner, turf/T, levels)
	if(tackling)
		return FALL_SKIP_FALLTIME

#undef MAX_TABLE_MESSES
