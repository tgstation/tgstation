#define TACKLE_MAX_RANGE 		4
#define TACKLE_SPEED 			1
#define TACKLE_STAM_COST		20
#define TACKLE_MISS_KNOCKDOWN	5

/datum/component/tackler
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/tackle_cooldown = 1 SECONDS

	var/tackling = TRUE

	/// debug for rigging rolls
	var/skill_mod = 3

/datum/component/tackler/Initialize(skill)
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/P = parent
	to_chat(P, "<span class='notice'>You can now tackle!</span>")

	if(skill)
		skill_mod = skill

	addtimer(VARSET_CALLBACK(src, tackling, FALSE), tackle_cooldown)

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
	if(!user.in_throw_mode || user.get_active_held_item())
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
	user.visible_message("<span class='warning'>[user] leaps at [A]!</span>", "<span class='danger'>You leap at [A]!</span>")

	user.Knockdown(TACKLE_MISS_KNOCKDOWN, TRUE, TRUE)
	user.take_bodypart_damage(stamina=TACKLE_STAM_COST)
	user.throw_at(A, TACKLE_MAX_RANGE, TACKLE_SPEED, user, FALSE)
	addtimer(VARSET_CALLBACK(src, tackling, FALSE), tackle_cooldown)
	return(COMSIG_MOB_CANCEL_CLICKON)

/*
	sack() handles when you actually smack into something, assuming we're mid-tackle. Roll A comes if you hit something that isn't a carbon (like a wall), while Roll B is if you do hit a carbon.


	Roll A is a simple percentile roll, with no modifiers (maybe check helmet?)
	The odds are as follows:

		75%: negligible brute, a bit of extra stam damage, 3 second knockdown
		15%: a bit of brute, a fair amount of stam damage, 3 second knockdown, 10 seconds confusion
		9%: fair bit of brute, fair amount of stam damage, 1 second paralyze, 10 second knockdown, minor deafness, concussion
		1%: major brute, fair amount of stam, lifetime paralyze because you broke your spinal cord! nice!


	Roll B has some modifiers, though I don't know if people would actually like that idea, right now it's just traits which can make tackles easier/harder if either person is drunk/dwarf/giant/tacklee is fat, etc
	The roll is by default in the range (-3, 3) before modifiers, lower numbers are better for the tacklee, higher numbers are better for tackler. Modifiers and their values are just scratchwork WIP right now
	The outcomes are as follows:

		-inf to -5: Seriously botched tackle, tackler suffers a concussion, brute damage, and a 3 second paralyze, target suffers nothing
		-4 to -2: weak tackle, tackler gets 3 second knockdown, target gets shove slowdown but is otherwise fine
		-1 to 0: decent tackle, both parties are inconvenienced equally, each get paralyzed half a second and knocked down for 3 seconds, and equal stamina damage cost (standard tackle stam cost)
		1: solid tackle, tackler has a bit of an advantage and is only knocked down for one second, target is paralyzed for half a second and knocked down for two seconds
		2 to 4: expert tackle, takcler has sizeable advantage and is only knocked down for one second, target is paralyzed for half a second and knocked down for three seconds as well as 40 stam damage
		5 to inf: MONSTER tackle, tackler gets up immediately and gets a free aggressive grab, target takes brain and stamina damage from the hit and is paralyzed for one second

*/
/datum/component/tackler/proc/sack(mob/living/carbon/user, atom/hit, datum/thrownthing/throwingdatum)
	if(!tackling || !throwingdatum)
		return

	if(!iscarbon(hit))
		if(hit.density)
			var/oopsie = rand(1, 100)
			testing(oopsie)
			switch(oopsie)
				if(1)
					user.audible_message("<b><span class='warning'>CRRCKCKSHH</span></b>")
					// can you imagine standing around minding your own business when all of the sudden some guy fucking launches himself into a wall at full speed and irreparably paralyzes himself?
					user.visible_message("<span class='danger'>[user] slams face-first into [hit] at an awkward angle, severing [user.p_their()] spinal column with a sickening crack! Holy shit!</span>", "<span class='userdanger'>You slam face-first into [hit] at an awkward angle, severing your spinal column with a sickening crack! Holy shit!</span>")
					var/obj/item/bodypart/head/hed = user.get_bodypart(BODY_ZONE_HEAD)
					if(hed)
						hed.receive_damage(brute=40, updating_health=TRUE)
					user.take_bodypart_damage(stamina=30)
					user.emote("scream")
					user.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic) // oopsie indeed!
					shake_camera(user, 7, 6)

				if(2 to 10)
					user.visible_message("<span class='danger'>[user] slams face first into [hit], suffering major cranial trauma!</span>", "<span class='userdanger'>You slam face-first into [hit], and the world explodes around you!</span>")
					user.take_bodypart_damage(stamina=30, brute=20)
					user.gain_trauma(/datum/brain_trauma/mild/concussion)
					user.soundbang_act(1, 100, rand(5, 10))
					shake_camera(user, 5, 5)

				if(11 to 25)
					user.visible_message("<span class='danger'>[user] slams hard into [hit], knocking [user.p_them()] senseless!</span>", "<span class='userdanger'>You slam hard into [hit], knocking yourself senseless!</span>")
					user.take_bodypart_damage(stamina=30, brute=10)
					user.confused += 10
					user.Knockdown(30)
					shake_camera(user, 3, 4)

				if(26 to 100)
					user.visible_message("<span class='danger'>[user] slams into [hit]!</span>", "<span class='userdanger'>You slam into [hit]!</span>")
					user.take_bodypart_damage(stamina=15, brute=5)
					user.Knockdown(30)
					shake_camera(user, 2, 2)

		return

	var/mob/living/carbon/target = hit
	var/mob/living/carbon/human/T = target
	var/mob/living/carbon/human/S = user

	var/roll = rollTackle(target)

	testing(roll)
	switch(roll)
		if(-INFINITY to -5) // botched the shit out of it and concussed themself
			user.visible_message("<span class='danger'>[user] botches [user.p_their()] tackle and slams [user.p_their()] head into [target], knocking [user.p_them()]self silly!</span>", "<span class='userdanger'>You botch your tackle and slam your head into [target], knocking yourself silly!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] botches [user.p_their()] tackle and slams [user.p_their()] head into you, knocking [user.p_them()]self silly!</span>")

			user.Paralyze(30)
			//something something NFL
			var/obj/item/bodypart/head/hed = user.get_bodypart(BODY_ZONE_HEAD)
			if(hed)
				hed.receive_damage(brute=20, updating_health=TRUE)
			user.gain_trauma(/datum/brain_trauma/mild/concussion)

		if(-4 to -2) // glancing blow at best, tackler is far worse off than the target. Without negative modifiers, this is as bad a tackle as you can land
			user.visible_message("<span class='warning'>[user] lands a weak tackle on [target], briefly knocking [target.p_them()] off-balance!</span>", "<span class='userdanger'>You land a weak tackle on [target], briefly knocking [target.p_them()] off-balance!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] lands a weak tackle on you, briefly knocking you off-balance!</span>")

			user.Knockdown(30)
			if(ishuman(target))
				if(!T.has_movespeed_modifier(MOVESPEED_ID_SHOVE))
					T.add_movespeed_modifier(MOVESPEED_ID_SHOVE, multiplicative_slowdown = SHOVE_SLOWDOWN_STRENGTH)
					addtimer(CALLBACK(T, /mob/living/carbon/human/proc/clear_shove_slowdown), SHOVE_SLOWDOWN_LENGTH)

		if(-1 to 0) // decent hit, both parties are about equally inconvenienced
			user.visible_message("<span class='warning'>[user] lands a passable tackle on [target], sending them both tumbling!</span>", "<span class='userdanger'>You land a passable tackle on [target], sending you both tumbling!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] lands a passable tackle on you, sending you both tumbling!</span>")

			target.take_bodypart_damage(stamina=TACKLE_STAM_COST)
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
			user.SetKnockdown(0)
			user.visible_message("<span class='warning'>[user] lands a monster tackle on [target], knocking [target.p_them()] senseless and applying an aggressive pin!</span>", "<span class='userdanger'>You land a monster tackle on [target], knocking [target.p_them()] senseless and applying an aggressive pin!</span>", target)
			to_chat(target, "<span class='userdanger'>[user] lands a monster tackle on you, knocking you senseless and aggressively pinning you!</span>")

			target.take_bodypart_damage(stamina=40)
			if(ishuman(target) && ishuman(user))
				S.dna.species.grab(S, T)
				S.setGrabState(GRAB_AGGRESSIVE)
				target.Paralyze(10)
				target.Knockdown(30)
				S.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(20, 30))
			else
				target.Paralyze(30) // can't grab a nonhuman/as a nonhuman and the stamina damage would do nothing, so just stun them longer for the "pin"

	tackling = FALSE

	return COMPONENT_MOVABLE_IMPACT_FLIP_GENTLE

/*
	This proc brings some tabletop into the equation and rolls a die, then modifies the result based on various factors for how steady each person involved is.
	This is, of course, heavily WIP, and may end up being scrapped if people don't like the RNG nature

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


	var/r = rand(-3, 3) - defense_mod + attack_mod + skill_mod // negative results are better for the target, positive results are better for the tackler

	return r


#undef TACKLE_MAX_RANGE
#undef TACKLE_SPEED
