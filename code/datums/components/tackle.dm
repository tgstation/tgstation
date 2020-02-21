/*
	tackle.dm

	This component is made for carbon mobs (really, humans), and allows its parent to throw themselves and perform tackles. This is done by enabling throw mode, then clicking on your
		intended target with an empty hand. You will then launch toward your target. If you hit a carbon, you'll roll to see how hard you hit them. If you hit a solid non-mob, you'll
		roll to see how badly you just messed yourself up.

	still wip, all the other comments below explain everything thoroughly

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
	///A flat modifier to your roll against your target, as described in rollTackle(). Slightly misleading, skills aren't relevant here, this is a matter of what type of gloves (or whatever) is granting you the ability to tackle.
	var/skill_mod
	///Some gloves, generally ones that increase mobility, may have a minimum distance to fly. Rocket gloves are especially dangerous with this, be sure you'll hit your target or have a clear background if you miss, or else!
	var/min_distance

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
	to_chat(P, "<span class='notice'>You can now tackle!</span>")

	addtimer(VARSET_CALLBACK(src, tackling, FALSE), base_knockdown)

/datum/component/tackler/Destroy()
	var/mob/P = parent
	to_chat(P, "<span class='notice'>You can no longer tackle.</span>")
	..()

/datum/component/tackler/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLICKON, .proc/checkTackle)
	RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, .proc/sack)

/datum/component/tackler/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_CLICKON, COMSIG_MOVABLE_IMPACT))

/datum/component/tackler/proc/checkTackle(mob/living/carbon/user, atom/A, params)
	if(!user.in_throw_mode || user.get_active_held_item() || user.pulling)
		return

	if(user.lying)
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
	if(can_see(user, A, 7))
		user.visible_message("<span class='warning'>[user] leaps at [A]!</span>", "<span class='danger'>You leap at [A]!</span>")
	else
		user.visible_message("<span class='warning'>[user] leaps!</span>", "<span class='danger'>You leap!</span>")

	if(get_dist(user, A) < min_distance)
		A = get_ranged_target_turf(user, get_dir(user, A), min_distance) //TODO: this only works in cardinals/diagonals, make it work with in-betweens too!

	user.Knockdown(base_knockdown, TRUE, TRUE)
	user.take_bodypart_damage(stamina=stamina_cost)
	user.throw_at(A, range, speed, user, FALSE)
	addtimer(VARSET_CALLBACK(src, tackling, FALSE), base_knockdown)
	return(COMSIG_MOB_CANCEL_CLICKON)

/*
	sack() is called when you actually smack into something, assuming we're mid-tackle. First it deals with smacking into non-carbons, in two cases:
		If it's a non-carbon mob, we don't care, get out of here and do normal thrown-into-mob stuff
		Else, if it's something dense (walls, machinery, structures, most things other than the floor), go to splat() and get ready for some high grade shit

	If it's a carbon we hit, we'll call rollTackle() which rolls a die and calculates modifiers for both the tackler and target, then gives us a number. Negatives favor the target, while positives favor the tackler.
		Check rollTackle() for a more thorough explanation on the modifiers at play.

	Then, we figure out what effect we want, and we get to work! Note that with standard gripper gloves and no modifiers, the range of rolls is (-3, 3). The results are as follows, based on what we rolled:
		-inf to -5: Seriously botched tackle, tackler suffers a concussion, brute damage, and a 3 second paralyze, target suffers nothing
		-4 to -2: weak tackle, tackler gets 3 second knockdown, target gets shove slowdown but is otherwise fine
		-1 to 0: decent tackle, both parties are inconvenienced equally, each get paralyzed half a second and knocked down for 3 seconds, and the target suffers the same stamina damage the tackler paid to tackle
		1: solid tackle, tackler has a bit of an advantage and is only knocked down for one second, target is paralyzed for half a second and knocked down for two seconds
		2 to 4: expert tackle, takcler has sizeable advantage and is only knocked down for one second, target is paralyzed for half a second and knocked down for three seconds as well as 40 stam damage
		5 to inf: MONSTER tackle, tackler gets up immediately and gets a free aggressive grab, target takes sizeable stamina damage from the hit and is paralyzed for one and a half seconds and knocked down for three seconds

	Finally, we return a bitflag to COMSIG_MOVABLE_IMPACT that forces the thrownthing datum to be gentle so that we don't proc the standard thrown-into-mob reactions.
*/
/datum/component/tackler/proc/sack(mob/living/carbon/user, atom/hit, datum/thrownthing/throwingdatum)
	if(!tackling || !throwingdatum)
		return

	if(!iscarbon(hit))
		if(hit.density)
			splat(user, hit, throwingdatum)
		return

	var/mob/living/carbon/target = hit
	var/mob/living/carbon/human/T = target
	var/mob/living/carbon/human/S = user

	var/roll = rollTackle(target)
	tackling = FALSE

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

			target.take_bodypart_damage(stamina=stamina_cost)
			user.Paralyze(5)
			target.Paralyze(5)
			user.Knockdown(25)
			target.Knockdown(25)

		if(1 to 2) // solid hit, tackler has a slight advantage
			user.visible_message("<span class='warning'>[user] lands a solid tackle on [target], knocking them both down hard!</span>", "<span class='userdanger'>You land a solid tackle on [target], knocking you both down hard!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] lands a solid tackle on you, knocking you both down hard!</span>")

			target.take_bodypart_damage(stamina=30)
			target.Paralyze(5)
			user.Knockdown(10)
			target.Knockdown(20)

		if(3 to 4) // really good hit, the target is definitely worse off here. Without positive modifiers, this is as good a tackle as you can land
			user.visible_message("<span class='warning'>[user] lands an expert tackle on [target], knocking [target.p_them()] down hard!</span>", "<span class='userdanger'>You land an expert tackle on [target], knocking [target.p_them()] down hard!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] lands an expert tackle on you, knocking you down hard!</span>")

			target.take_bodypart_damage(stamina=40)
			target.Paralyze(5)
			user.Knockdown(10)
			target.Knockdown(30)

		if(5 to INFINITY) // absolutely BODIED
			user.visible_message("<span class='warning'>[user] lands a monster tackle on [target], knocking [target.p_them()] senseless and applying an aggressive pin!</span>", "<span class='userdanger'>You land a monster tackle on [target], knocking [target.p_them()] senseless and applying an aggressive pin!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] lands a monster tackle on you, knocking you senseless and aggressively pinning you!</span>")

			user.SetKnockdown(0)
			target.take_bodypart_damage(stamina=40)
			if(ishuman(target) && ishuman(user))
				S.dna.species.grab(S, T)
				S.setGrabState(GRAB_AGGRESSIVE)
				target.Paralyze(15)
				target.Knockdown(30)

	return COMPONENT_MOVABLE_IMPACT_FLIP_GENTLE


/*
	rollTackle() handles all of the modifiers for the actual carbon-on-carbon tackling, and gets its own proc because of how many there are (with plenty more in mind!)

	The base roll is between (-3, 3), with negative numbers favoring the target, and positive numbers favoring the tackler. The target and the tackler are both assessed for
		how easy they are to knock over, with clumsiness and dwarfiness being strong maluses for each, and gigantism giving a bonus for each. These numbers and ideas
		are absolutely subject to change.

	In addition, after subtracting the defender's mod and adding the attacker's mod to the roll, the component's base (skill) mod is added as well. Some sources of tackles
		are better at taking people down, like the bruiser and rocket gloves, while the dolphin gloves have a malus in exchange for better mobility.

*/
/datum/component/tackler/proc/rollTackle(mob/living/carbon/target)
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

	if(ishuman(target))
		var/mob/living/carbon/human/T = target
		if(T.dna.check_mutation(DWARFISM))
			defense_mod -= 2
		if(T.dna.check_mutation(GIGANTISM))
			defense_mod += 2


	// OF-FENSE
	var/mob/living/carbon/sacker = parent

	if(sacker.drunkenness > 60) // you're far too drunk to hold back!
		attack_mod += 1
	else if(sacker.drunkenness > 30) // if you're only a bit drunk though, you're just sloppy
		attack_mod -= 1
	if(HAS_TRAIT(sacker, TRAIT_CLUMSY))
		attack_mod -= 2

	if(ishuman(sacker))
		var/mob/living/carbon/human/S = sacker
		if(S.dna.check_mutation(DWARFISM))
			attack_mod -= 2
		if(S.dna.check_mutation(GIGANTISM))
			attack_mod += 2

	var/r = rand(-3, 3) - defense_mod + attack_mod + skill_mod
	return r


/*
	splat() is where we handle diving into dense atoms, generally with effects ranging from bad to REALLY bad. This works as a percentile roll that is modified in two steps as detailed below. The higher
	the roll, the more severe the result.

	Mod 1: Speed
		-Base tackle speed is 1, which is what normal gripper gloves use. For other sources with higher speed tackles, like dolphin and ESPECIALLY rocket gloves, we obey Newton's laws and hit things harder.
		-For every unit of speed above 1, move the lower bound of the roll up by 15. Unlike Mod 2, this only serves to raise the lower bound, so it can't be directly counteracted by anything you can control.

	Mod 2: Misc
		-Flat modifiers, these take whatever you rolled and add/subtract to it, with the end result capped between the minimum from Mod 1 and 100. Note that since we can't roll higher than 100 to start with,
			wearing a helmet should be enough to remove any chance of permanently paralyzing yourself and dramatically lessen knocking yourself unconscious, even with rocket gloves. Will expand on maybe

		Wearing a helmet: -5
		Clumsy: +6

	Effects: Below are the outcomes based off your roll, in order of increasing severity

		1-63: Knocked down for a few seconds and a bit of brute and stamina damage
		64-83: Knocked silly, gain some confusion as well as the above
		84-93: Cranial trauma, get a concussion and go deaf for a bit, plus more damage
		94-98: Knocked unconscious, get a concussion and a random mild brain trauma, as well as medium deafness and a fair amount of damage
		99-100: Break your spinal cord, get paralyzed, take a bunch of damage too. Very unlucky!

*/

/datum/component/tackler/proc/splat(mob/living/carbon/user, atom/hit, datum/thrownthing/throwingdatum)
	var/oopsie_mod = 0
	var/danger_zone = (speed - 1) * 15 // for every extra speed we have over 1, take away 10 of the safest chance
	danger_zone = max(min(danger_zone, 100), 1)

	if(ishuman(user))
		var/mob/living/carbon/human/S = user
		var/head_slot = S.get_item_by_slot(ITEM_SLOT_HEAD)
		if(head_slot && (istype(head_slot,/obj/item/clothing/head/helmet) || istype(head_slot,/obj/item/clothing/head/hardhat)))
			oopsie_mod -= 5

	if(HAS_TRAIT(user, TRAIT_CLUMSY))
		oopsie_mod += 6 //honk!

	var/oopsie = rand(danger_zone, 100)

	switch(oopsie)
		if(99 to 100)
			// can you imagine standing around minding your own business when all of the sudden some guy fucking launches himself into a wall at full speed and irreparably paralyzes himself?
			user.visible_message("<span class='danger'>[user] slams face-first into [hit] at an awkward angle, severing [user.p_their()] spinal column with a sickening crack! Holy shit!</span>", "<span class='userdanger'>You slam face-first into [hit] at an awkward angle, severing your spinal column with a sickening crack! Holy shit!</span>")
			user.take_bodypart_damage(stamina=30, brute=40)
			playsound(user, 'sound/effects/blobattack.ogg', 60, TRUE)
			playsound(user, 'sound/effects/splat.ogg', 70, TRUE)
			user.emote("scream")
			user.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic) // oopsie indeed!
			shake_camera(user, 7, 7)
			user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash)
			user.clear_fullscreen("flash", 3.5)

		if(94 to 98)
			user.visible_message("<span class='danger'>[user] slams face-first into [hit] with a concerning squish, immediately going limp!</span>", "<span class='userdanger'>You slam face-first into [hit], and immediately lose consciousness!</span>")
			user.take_bodypart_damage(stamina=30, brute=30)
			user.Unconscious(100)
			user.gain_trauma(/datum/brain_trauma/mild/concussion)
			user.gain_trauma_type(BRAIN_TRAUMA_MILD)
			user.adjustEarDamage(15, 60)
			user.playsound_local(get_turf(user), 'sound/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)
			shake_camera(user, 6, 6)
			user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash)
			user.clear_fullscreen("flash", 2.5)

		if(84 to 93)
			user.visible_message("<span class='danger'>[user] slams head-first into [hit], suffering major cranial trauma!</span>", "<span class='userdanger'>You slam head-first into [hit], and the world explodes around you!</span>")
			user.take_bodypart_damage(stamina=30, brute=20)
			user.gain_trauma(/datum/brain_trauma/mild/concussion)
			user.adjustEarDamage(7, 30)
			user.playsound_local(get_turf(user), 'sound/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)
			shake_camera(user, 5, 5)
			user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash)
			user.clear_fullscreen("flash", 2.5)

		if(64 to 83)
			user.visible_message("<span class='danger'>[user] slams hard into [hit], knocking [user.p_them()] senseless!</span>", "<span class='userdanger'>You slam hard into [hit], knocking yourself senseless!</span>")
			user.take_bodypart_damage(stamina=30, brute=10)
			user.confused += 10
			user.Knockdown(30)
			shake_camera(user, 3, 4)

		if(1 to 63)
			user.visible_message("<span class='danger'>[user] slams into [hit]!</span>", "<span class='userdanger'>You slam into [hit]!</span>")
			user.take_bodypart_damage(stamina=15, brute=5)
			user.Knockdown(30)
			shake_camera(user, 2, 2)

	playsound(user, 'sound/weapons/smash.ogg', 70, TRUE)
