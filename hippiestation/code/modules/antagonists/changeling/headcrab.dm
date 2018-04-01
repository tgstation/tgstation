// Nerfs Last Resort, referred to as "headcrab" in the code.

/obj/effect/proc_holder/changeling/headcrab
	chemical_cost = 35
	dna_cost = 2
	req_human = 1

/obj/effect/proc_holder/changeling/headcrab/sting_action(mob/user)
	set waitfor = FALSE
	if(alert("Are we sure we wish to kill ourself and create a headslug?",,"Yes", "No") == "No")
		return
	var/datum/mind/M = user.mind
	var/list/organs = user.getorganszone("head", 1)

	for(var/obj/item/organ/I in organs)
		I.Remove(user, 1)

	for(var/mob/living/carbon/human/H in range(2,user))
		to_chat(H, "<span class='userdanger'>You are blinded by a shower of blood!</span>")
		H.blur_eyes(10)
		H.confused += 1
	for(var/mob/living/silicon/S in range(2,user))
		to_chat(S, "<span class='userdanger'>Your sensors are disabled by a shower of blood!</span>")
		S.Knockdown(25)
	var/turf = get_turf(user)
	user.gib()
	. = TRUE
	var/mob/living/simple_animal/hostile/headcrab/crab = new(turf)
	for(var/obj/item/organ/I in organs)
		I.forceMove(crab)
	crab.origin = M
	if(crab.origin)
		crab.origin.active = 1
		crab.origin.transfer_to(crab)
		to_chat(crab, "<span class='warning'>You burst out of the remains of your former body in a shower of gore!</span>")

/mob/living/simple_animal/hostile/headcrab
	health = 25
	maxHealth = 25