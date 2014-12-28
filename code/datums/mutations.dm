/var/global/list/mutations_list = list()

/datum/mutation/

	var/name

/datum/mutation/New()

	mutations_list[name] = src

/datum/mutation/human

	var/dna_block
	var/quality
	var/get_chance = 100
	var/lowest_value = 256 * 9
	var/text_indication = ""
	var/list/visual_indicators = list()

/datum/mutation/human/proc/force_give(mob/living/carbon/human/owner)
	set_block(owner)
	on_acquiring(owner)

/datum/mutation/human/proc/set_se(se_string)
	if(!se_string || lentext(se_string) < DNA_STRUC_ENZYMES_BLOCKS * DNA_BLOCK_SIZE)	return
	var/before = copytext(se_string, 1, (dna_block * DNA_BLOCK_SIZE) + 1)
	var/injection = num2hex(lowest_value + rand(1, 256 * 6))
	var/after = copytext(se_string, (dna_block * DNA_BLOCK_SIZE) + DNA_BLOCK_SIZE + 1)
	return before + injection + after

/datum/mutation/human/proc/set_block(mob/living/carbon/human/owner)
	owner.dna.struc_enzymes = set_se(owner.dna.struc_enzymes)

/datum/mutation/human/proc/check_block_string(se_string)
	if(!se_string || lentext(se_string) < DNA_STRUC_ENZYMES_BLOCKS * DNA_BLOCK_SIZE)	return 0
	if(hex2num(getblock(se_string, dna_block)) >= lowest_value)
		return 1

/datum/mutation/human/proc/check_block(mob/living/carbon/human/owner)
	if(check_block_string(owner.dna.struc_enzymes))
		if(prob(get_chance))
			. = on_acquiring(owner)
	else
		. = on_losing(owner)

/datum/mutation/human/proc/on_acquiring(mob/living/carbon/human/owner)
	if(src in owner.dna.mutations)
		return 1
	owner.dna.mutations.Add(src)
	gain_indication(owner)
	owner << text_indication

/datum/mutation/human/proc/gain_indication(mob/living/carbon/human/owner)
	owner.overlays.Add(visual_indicators)
/*
	var/list/result_overlays = list()
	var/list/limbs = owner_get_limbs(NON_MECHANICAL|NON_AMPUTATED)   //I dunno how its done by RR but i assume something like this, proc that returns the list of limbs based on what types of limbs to return in argument
	for(var/obj/limb/L in limbs)
		result_overlays[L.identificator] = visual_indicators[L.identificator]  //visual_indicators is where overlays icons are stored, they are all created on new of each mutation, i assume you will change it to linked list for easyness, but for now its just a list
	return owner.redraw_overlays(result_overlays, MUTATION_LAYER)    //Currently mutations draw the overlays themselves but i assume if dismemberment will be overriding lots of shit like maybe clothes or something else mutations will just pass the shit to redraw proc
*/
/datum/mutation/human/proc/lose_indication(mob/living/carbon/human/owner)
	owner.overlays.Remove(visual_indicators)
/*
	owner.remove_overlay(MUTATIONS_LAYER)
	for(var/datum/mutation/human/H in owner.dna.mutations)
		H.gain_indication(owner)
*/
/datum/mutation/human/proc/on_attack_hand(mob/living/carbon/human/owner, atom/target)
	return

/datum/mutation/human/proc/on_ranged_attack(mob/living/carbon/human/owner, atom/target)
	return

/datum/mutation/human/proc/on_life(mob/living/carbon/human/owner)
	return

/datum/mutation/human/proc/on_losing(mob/living/carbon/human/owner)
	if(owner.dna.mutations.Remove(src))
		lose_indication(owner)
		return 0
	return 1

/datum/mutation/human/hulk

	name = "Hulk"
	quality = POSITIVE
	get_chance = 100
	lowest_value = 256 * 9
	text_indication = "Your muscles hurt!"

/datum/mutation/human/hulk/New()
	..()
	visual_indicators |= image("icon"='icons/effects/genetics.dmi', "icon_state"="hulk_f_s", "layer"=-MUTATIONS_LAYER)
	visual_indicators |= image("icon"='icons/effects/genetics.dmi', "icon_state"="hulk_m_s", "layer"=-MUTATIONS_LAYER)

/datum/mutation/human/hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())	return
	var/status = CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH
	owner.status_flags &= ~status

/datum/mutation/human/hulk/on_attack_hand(mob/living/carbon/human/owner, atom/target)
	return target.attack_hulk(owner)

/datum/mutation/human/hulk/gain_indication(mob/living/carbon/human/owner)
	var/g = (owner.gender == FEMALE) ? 1 : 2
	owner.overlays += visual_indicators[g]

/datum/mutation/human/hulk/on_life(mob/living/carbon/human/owner)
	if(owner.health < 25)
		on_losing(owner)
		owner << "<span class='danger'>You suddenly feel very weak.</span>"
		owner.Weaken(3)
		owner.emote("collapse")

/datum/mutation/human/hulk/on_losing(mob/living/carbon/human/owner)
	..()
	owner.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH

/datum/mutation/human/telekinesis

	name = "Telekinesis"
	quality = POSITIVE
	get_chance = 100
	lowest_value = 256 * 9
	text_indication = "You feel smarter!"

/datum/mutation/human/telekinesis/New()
	..()
	visual_indicators |= image("icon"='icons/effects/genetics.dmi', "icon_state"="telekinesishead_s", "layer"=-MUTATIONS_LAYER)

//datum/mutation/human/telekinesis/gain_indication(mob/living/carbon/human/owner)
/*	var/list/L = list()
	if(owner.overlays_standing[MUTATIONS_LAYER])
		L.Add(owner.overlays_standing[MUTATIONS_LAYER])
	L |= image("icon"='icons/effects/genetics.dmi', "icon_state"="telekinesishead_s", "layer"=-MUTATIONS_LAYER)
	owner.overlays_standing[MUTATIONS_LAYER] = L
	..()
*/
/datum/mutation/human/telekinesis/on_ranged_attack(mob/living/carbon/human/owner, atom/target)
	target.attack_tk(owner)

/datum/mutation/human/cold_resistance

	name = "Cold Resistance"
	quality = POSITIVE
	text_indication = "Your body feels warm!"

/datum/mutation/human/cold_resistance/New()
	..()
	visual_indicators |= image("icon"='icons/effects/genetics.dmi', "icon_state"="fire_s", "layer"=-MUTATIONS_LAYER)

//datum/mutation/human/cold_resistance/gain_indication(mob/living/carbon/human/owner)
/*	var/list/L = list()
	if(owner.overlays_standing[MUTATIONS_LAYER])
		L.Add(owner.overlays_standing[MUTATIONS_LAYER])
	L |= image("icon"='icons/effects/genetics.dmi', "icon_state"="fire_s", "layer"=-MUTATIONS_LAYER)
	owner.overlays_standing[MUTATIONS_LAYER] = L
	..()
*/
/datum/mutation/human/cold_resistance/on_life(mob/living/carbon/human/owner)
	if(owner.getFireLoss())
		if(prob(1))
			owner.heal_organ_damage(0,1)   //Is this really needed?

/datum/mutation/human/x_ray

	name = "X Ray Vision"
	quality = POSITIVE
	text_indication = "The walls suddenly disappear!"

/datum/mutation/human/x_ray/on_acquiring(mob/living/carbon/human/owner)
	if(..())	return
	on_life(owner)

/datum/mutation/human/x_ray/on_life(mob/living/carbon/human/owner)
	owner.sight |= SEE_MOBS|SEE_OBJS|SEE_TURFS
	owner.see_in_dark = 8
	owner.see_invisible = SEE_INVISIBLE_LEVEL_TWO

/datum/mutation/human/x_ray/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner.see_in_dark = initial(owner.see_in_dark)
	owner.see_invisible = initial(owner.see_invisible)
	owner.sight = initial(owner.sight)

/datum/mutation/human/nearsight

	name = "Near Sightness"
	quality = MINOR_NEGATIVE
	text_indication = "You can't see very well."

/datum/mutation/human/nearsight/on_acquiring(mob/living/carbon/human/owner)
	if(..())	return
	owner.disabilities |= NEARSIGHT

/datum/mutation/human/nearsight/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner.disabilities &= ~NEARSIGHT

/datum/mutation/human/epilepsy

	name = "Epilepsy"
	quality = NEGATIVE
	text_indication = "You get a headache."

/datum/mutation/human/epilepsy/on_life(mob/living/carbon/human/owner)
	if ((prob(1) && owner.paralysis < 1))
		owner << "<span class='danger'>You have a seizure!</span>"
		for(var/mob/O in viewers(owner, null) - owner)
			O.show_message(text("<span class='userdanger'>[src] starts having a seizure!</span>"), 1)
		owner.Paralyse(10)
		owner.Jitter(1000)

/datum/mutation/human/bad_dna

	name = "Unstable DNA"
	quality = NEGATIVE
	text_indication = "You feel strange."

/datum/mutation/human/bad_dna/on_acquiring(mob/living/carbon/human/owner)
	if(prob(95))
		if(prob(50))
			randmutb(owner)
		else
			randmuti(owner)
	else
		randmutg(owner)
	on_losing(owner)

/datum/mutation/human/cough

	name = "Cough"
	quality = MINOR_NEGATIVE
	text_indication = "You start coughing."

/datum/mutation/human/cough/on_life(mob/living/carbon/human/owner)
	if((prob(5) && owner.paralysis <= 1))
		owner.drop_item()
		owner.emote("cough")

/datum/mutation/human/clumsy

	name = "Clumsiness"
	quality = MINOR_NEGATIVE
	text_indication = "You feel lightheaded."

/datum/mutation/human/clumsy/on_acquiring(mob/living/carbon/human/owner)
	if(..())	return
	owner.disabilities |= CLUMSY

/datum/mutation/human/clumsy/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner.disabilities &= ~CLUMSY

/datum/mutation/human/tourettes

	name = "Tourettes Syndrome"
	quality = NEGATIVE
	text_indication = "You twitch."

/datum/mutation/human/tourettes/on_life(mob/living/carbon/human/owner)
	if((prob(10) && owner.paralysis <= 1))
		owner.Stun(10)
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
		var/x_offset = owner.pixel_x + rand(-2,2) //Should probably be moved into the twitch emote at some point.
		var/y_offset = owner.pixel_y + rand(-1,1)
		animate(owner, owner.pixel_x = owner.pixel_x + x_offset, owner.pixel_y = owner.pixel_y + y_offset, time = 1)
		animate(owner.pixel_x = initial(owner.pixel_x) , owner.pixel_y = initial(owner.pixel_y), time = 1)

/datum/mutation/human/nervousness

	name = "Nervousness"
	quality = MINOR_NEGATIVE
	text_indication = "You feel nervous."

/datum/mutation/human/nervousness/on_life(mob/living/carbon/human/owner)
	if(prob(10))
		owner.stuttering = max(10, owner.stuttering)

/datum/mutation/human/deaf

	name = "Deafness"
	quality = NEGATIVE
	text_indication = "You can't seem to hear anything."

/datum/mutation/human/deaf/on_acquiring(mob/living/carbon/human/owner)
	if(..())	return
	owner.disabilities |= DEAF

/datum/mutation/human/deaf/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner.disabilities &= ~DEAF

/datum/mutation/human/blind

	name = "Blindness"
	quality = NEGATIVE
	text_indication = "You can't seem to see anything."

/datum/mutation/human/blind/on_acquiring(mob/living/carbon/human/owner)
	if(..())	return
	owner.disabilities |= BLIND

/datum/mutation/human/blind/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner.disabilities &= ~BLIND

/datum/mutation/human/race

	name = "Monkified"
	quality = NEGATIVE

/datum/mutation/human/race/on_acquiring(mob/living/carbon/human/owner)
	if(..())	return
	. = owner.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE)

/datum/mutation/human/race/gain_indication(mob/living/carbon/human/owner)
	return

/datum/mutation/human/race/lose_indication(mob/living/carbon/monkey/owner)
	return

/datum/mutation/human/race/on_losing(mob/living/carbon/monkey/owner)
	if(..())	return
	. = owner.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE)

/datum/mutation/human/laser_eyes

	name = "Laser Eyes"
	quality = POSITIVE
	dna_block = NON_SCANNABLE
	text_indication = "You feel pressure building up behind your eyes."

/datum/mutation/human/laser_eyes/on_ranged_attack(mob/living/carbon/human/owner, atom/target)
	if(owner.a_intent == "harm")
		owner.LaserEyes(target)