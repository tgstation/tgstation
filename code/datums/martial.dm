/datum/martial_art
	var/name = "Martial Art"
	var/id = "" //ID, used by mind/has_martialart
	var/streak = ""
	var/max_streak_length = 6
	var/current_target
	var/datum/martial_art/base // The permanent style. This will be null unless the martial art is temporary
	var/deflection_chance = 0 //Chance to deflect projectiles
	var/reroute_deflection = FALSE //Delete the bullet, or actually deflect it in some direction?
	var/block_chance = 0 //Chance to block melee attacks using items while on throw mode.
	var/restraining = 0 //used in cqc's disarm_act to check if the disarmed is being restrained and so whether they should be put in a chokehold or not
	var/help_verb
	var/no_guns = FALSE
	var/allow_temp_override = TRUE //if this martial art can be overridden by temporary martial arts

/datum/martial_art/proc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/can_use(mob/living/carbon/human/H)
	return TRUE

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
	if(!(D.mobility_flags & MOBILITY_STAND))
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

	var/miss_chance
	if(A.dna.species.punchdamagelow != 0) //dont divide by 0
		miss_chance = min((A.dna.species.punchdamagehigh/A.dna.species.punchdamagelow) + A.getStaminaLoss() + (A.getBruteLoss()/2), 100) //old base chance for a miss + various damage
	else
		miss_chance = 100 //0 dmg punches = always miss
	if(prob(miss_chance) && atk_verb != "kick") //kicks never miss though
		playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		D.visible_message("<span class='warning'>[A] has attempted to [atk_verb] [D]!</span>", \
			"<span class='userdanger'>[A] has attempted to [atk_verb] [D]!</span>", null, COMBAT_MESSAGE_RANGE)
		log_combat(A, D, "attempted to [atk_verb]")
		return 0

	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)
	D.visible_message("<span class='danger'>[A] has [atk_verb]ed [D]!</span>", \
			"<span class='userdanger'>[A] has [atk_verb]ed [D]!</span>", null, COMBAT_MESSAGE_RANGE)

	if(atk_verb == "kick")
		D.apply_damage(damage*1.5, A.dna.species.attack_type, affecting, armor_block) //kicks deal all damage in brute/burn/etc, no stamina
	else
		D.apply_damage(damage/2, A.dna.species.attack_type, affecting, armor_block) //deal half damage in brute/burn/etc
		D.apply_damage(damage, STAMINA, affecting, armor_block) //deal full damage in stamina


	log_combat(A, D, "punched")

	if((D.stat != DEAD) && damage >= A.dna.species.punchstunthreshold)
		D.visible_message("<span class='danger'>[A] has knocked [D] down!!</span>", \
								"<span class='userdanger'>[A] has knocked [D] down!</span>")
		var/knockdown_duration = 20 + (A.getStaminaLoss() + (A.getBruteLoss()/2))/2.5 //50 total damage = 20 + 20 = 40 duration, which is the old base duration
		D.apply_effect(knockdown_duration, EFFECT_KNOCKDOWN, armor_block)
		D.forcesay(GLOB.hit_appends)
	else if(!(D.mobility_flags & MOBILITY_STAND))
		D.forcesay(GLOB.hit_appends)
	return 1

/datum/martial_art/proc/teach(mob/living/carbon/human/H,make_temporary=0)
	if(!istype(H) || !H.mind)
		return FALSE
	if(H.mind.martial_art)
		if(make_temporary)
			if(!H.mind.martial_art.allow_temp_override)
				return FALSE
			store(H.mind.martial_art,H)
		else
			H.mind.martial_art.on_remove(H)
	else if(make_temporary)
		base = H.mind.default_martial_art
	if(help_verb)
		H.verbs += help_verb
	H.mind.martial_art = src
	return TRUE

/datum/martial_art/proc/store(datum/martial_art/M,mob/living/carbon/human/H)
	M.on_remove(H)
	if(M.base) //Checks if M is temporary, if so it will not be stored.
		base = M.base
	else //Otherwise, M is stored.
		base = M

/datum/martial_art/proc/remove(mob/living/carbon/human/H)
	if(!istype(H) || !H.mind || H.mind.martial_art != src)
		return
	on_remove(H)
	if(base)
		base.teach(H)
	else
		var/datum/martial_art/X = H.mind.default_martial_art
		X.teach(H)

/datum/martial_art/proc/on_remove(mob/living/carbon/human/H)
	if(help_verb)
		H.verbs -= help_verb
	return
