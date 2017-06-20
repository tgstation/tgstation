/datum/martial_art
	var/name = "Martial Art"
	var/streak = ""
	var/max_streak_length = 6
	var/current_target = null
	var/temporary = 0
	var/datum/martial_art/base = null // The permanent style
	var/deflection_chance = 0 //Chance to deflect projectiles
	var/block_chance = 0 //Chance to block melee attacks using items while on throw mode.
	var/restraining = 0 //used in cqc's disarm_act to check if the disarmed is being restrained and so whether they should be put in a chokehold or not
	var/help_verb = null
	var/mob/living/carbon/human/martial_art_owner //The human that owns this martial art
	var/no_guns = FALSE
	var/obj/required_object //Any object required to use the martial art
	var/required_slot //If there's a required object, it needs to be in this slot
	var/allow_temp_override = TRUE //if this martial art can be overridden by temporary martial arts

/datum/martial_art/proc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/add_to_streak(element,mob/living/carbon/human/D)
	if(D != current_target)
		current_target = D
		streak = ""
		restraining = 0
	streak = streak+element
	if(length(streak) > max_streak_length)
		streak = copytext(streak,2)
	return

/datum/martial_art/proc/basic_hit(mob/living/carbon/human/A,mob/living/carbon/human/D)

	var/damage = rand(A.dna.species.punchdamagelow, A.dna.species.punchdamagehigh)

	var/atk_verb = A.dna.species.attack_verb
	if(D.lying)
		atk_verb = "kick"

	switch(atk_verb)
		if("kick")
			A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		if("slash")
			A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
		if("smash")
			A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
		else
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	if(!damage)
		playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		D.visible_message("<span class='warning'>[A] has attempted to [atk_verb] [D]!</span>", \
			"<span class='userdanger'>[A] has attempted to [atk_verb] [D]!</span>", null, COMBAT_MESSAGE_RANGE)
		add_logs(A, D, "attempted to [atk_verb]")
		return 0

	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)
	D.visible_message("<span class='danger'>[A] has [atk_verb]ed [D]!</span>", \
			"<span class='userdanger'>[A] has [atk_verb]ed [D]!</span>", null, COMBAT_MESSAGE_RANGE)

	D.apply_damage(damage, BRUTE, affecting, armor_block)

	add_logs(A, D, "punched")

	if((D.stat != DEAD) && damage >= A.dna.species.punchstunthreshold)
		D.visible_message("<span class='danger'>[A] has weakened [D]!!</span>", \
								"<span class='userdanger'>[A] has weakened [D]!</span>")
		D.apply_effect(4, WEAKEN, armor_block)
		D.forcesay(GLOB.hit_appends)
	else if(D.lying)
		D.forcesay(GLOB.hit_appends)
	return 1

/datum/martial_art/proc/teach(mob/living/carbon/human/H,make_temporary=0)
	if(make_temporary)
		temporary = 1
	if(temporary && H.mind.martial_art)
		if(!H.mind.martial_art.allow_temp_override)
			return
		base = H.mind.martial_art
	if(help_verb)
		H.verbs += help_verb
	H.mind.martial_art = src
	martial_art_owner = H

/datum/martial_art/proc/remove(mob/living/carbon/human/H)
	if(H.mind.martial_art != src)
		return
	H.mind.martial_art = base
	if(help_verb)
		H.verbs -= help_verb
	martial_art_owner = null

/datum/martial_art/proc/mind_transfer(mob/living/carbon/human/present, mob/living/future)
	if(!required_object)
		martial_art_owner = future
	else
		var/obj/O = locate(required_object) in future
		if(!O)
			remove(present) //The player can always just re-equip the object, assuming they have access to their old corpse
		else
			if(!required_slot && present.get_item_by_slot(required_slot) != O)
				remove(present)
			else
				martial_art_owner = future
