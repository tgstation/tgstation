#define ATK_MISS 0
#define ATK_HIT 1
#define ATK_CRIT_HIT 2
#define HIT_MIN 5
#define HIT_MAX 10


/datum/martial_art/monk
	name = "Monk"
	var/current_exp = 0
	var/next_level_exp = 50
	var/static/exp_slope = 10.5
	var/current_level = 1
	var/level_cap = 20

	var/curr_ab = 3 // increase every 4 levels
	var/flurry_of_blows_penalty = -2 // -2 at 1-4, -1 at 5-8, 0 at 9-20
	var/attacks_w_flurry = 2 // increase to 3 at 11
	var/ki_level = 0
	var/list/available_actions = list()
	var/datum/action/monk_rest/monk_rest = new/datum/action/monk_rest()
	var/datum/action/monk/stunning_fist/stunning_fist = new/datum/action/monk/stunning_fist()
	var/datum/action/monk/stunning_fist/quivering_palm = new/datum/action/monk/quivering_palm()
	no_guns = TRUE


/datum/martial_art/monk/teach(mob/living/carbon/human/H,make_temporary=0)
	if(..())
		monk_rest.Grant(H)
		to_chat(H, "<span class = 'userdanger'>You know the ancient Monk techniques!</span>")
		to_chat(H, "<span class = 'danger'>This technique becomes more powerful the more you use it.</span>")
		to_chat(H, "<span class = 'danger'>Your power level will increase from 1 to 20, gaining new abilities and growing stronger the more you train.</span>")
		to_chat(H, "<span class = 'danger'>Your abilities have a use limit, before you need to rest to regain your strength.</span>")

/datum/martial_art/monk/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class = 'userdanger'>You fprget the ways of a Monk...</span>")
	stunning_fist.Remove(H)
	quivering_palm.Remove(H)
	monk_rest.Remove(H)

/datum/martial_art/monk/proc/do_level_up()
	if(current_level % 4 == 0)
		curr_ab++
	switch(current_level)
		if(2)
			to_chat(owner, "<span class = 'danger'>You have practiced the Stunning Fist technique enough to use it in combat.</span>")
			stunning_fist.Grant(owner)
			available_actions = list(stunning_fist)
		if(4)
			to_chat(owner, "<span class = 'danger'>Your Ki has begun to develop, probing at the armor of your foes.</span>")
			ki_level = 50
		if(5)
			to_chat(owner, "<span class = 'danger'>You feel more confident in your strikes.</span>")
			flurry_of_blows_penalty = -1
		if(7)
			to_chat(owner, "<span class = 'danger'>You can perform more Stunning Fists before resting.</span>")
			stunning_fist.max_uses = 7
		if(9)
			to_chat(owner, "<span class = 'danger'>You have become completely confident in your ability to land a strike.</span>")
			flurry_of_blows_penalty = 0
		if(10)
			to_chat(owner, "<span class = 'danger'>Your Ki helps you seek the holes in enemy armor.</span>")
			ki_level = 75
		if(11)
			to_chat(owner, "<span class = 'danger'>You feel confident enough to strike more and harder.</span>")
			attacks_w_flurry = 3
		if(15)
			to_chat(owner, "<span class = 'danger'>You have practiced the Quivering Palm technique enough to use it in combat.</span>")
			quivering_palm.Grant(owner)
			available_actions = list(stunning_fist, quivering_palm)
		if(16)
			to_chat(owner, "<span class = 'danger'>Your Ki has fully developed, and can be used to nullify armor.</span>")
			ki_level = 100
		if(17)
			to_chat(owner, "<span class = 'danger'>You can perform more Stunning Fists before resting.</span>")
			stunning_fist.max_uses = 14

/datum/martial_art/monk/proc/attack_roll(mob/living/T, abm)
	var/armor_class = 10 + (T.getarmor("chest", "melee") * 0.1)
	var/attack_bonus = curr_ab + abm
	var/attack_roll = ROLL_DICE(1,20) + attack_bonus
	if(attack_roll >= armor_class)
		if(attack_roll == 20)
			attack_roll = ROLL_DICE(1,20) + attack_bonus
			if(attack_roll >= armor_class)
				return ATK_CRIT_HIT
			return ATK_HIT
		else
			return ATK_HIT
	return ATK_MISS

/datum/martial_art/monk/proc/add_exp(amt)
	if(current_level == level_cap)
		return
	current_exp += amt
	if(current_exp >= next_level_exp)
		current_level++
		var/next_level = current_level + 1
		next_level_exp = (next_level^2-next_level) * exp_slope
		do_level_up()
		to_chat(owner, "<span class = 'danger'>You feel more confident in your powers.</span>")



/datum/martial_art/monk/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	var/picked_hit_type = pick("punched", "kicked")
	for(var/i in 1 to attacks_w_flurry)
		switch(picked_hit_type)
			if("punched")
				A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
			if("kicked")
				A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		var/atr = attack_roll(D, flurry_of_blows_penalty)
		if(atr)
			var/dmg = rand(HIT_MIN, HIT_MAX)
			var/was_crit = ""
			var/armor = (D.run_armor_check("chest", "melee", armour_penetration = ki_level)) / 100
			if(armor > 1)
				armor = 1
			if(atr == ATK_CRIT_HIT)
				dmg *= 2
				was_crit = "critically "
			dmg -= (dmg * armor)
			D.adjustBruteLoss(dmg) // TODO: code cleave
			add_exp(5)
			add_logs(A, D, "[was_crit]punched (monk)")
			D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] you!</span>")
		else
			add_exp(2.5)
			add_logs(A, D, "missed a punch (monk)")
			D.visible_message("<span class='danger'>[A] missed [D]!</span>", \
					  "<span class='userdanger'>[A] misses you!</span>")
	return 1

/datum/martial_art/monk/proc/check_streak(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	switch(streak)
		if("stunning_fist")
			streak = ""
			stunning_fist(A,D)
			stunning_fist.uses_left--
			return 1
		if("quivering_palm")
			streak = ""
			quivering_palm(A,D)
			quivering_palm.uses_left--
			return 1
	return 0

/datum/martial_art/monk/proc/stunning_fist(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	var/atr = attack_roll(D, flurry_of_blows_penalty-4)
	if(atr)
		var/fort_save = ROLL_DICE(1,20) // todo: figure out a good way to calc a save bonus
		if(fort_save >= 10)
			D.visible_message("<span class='danger'>[A] punches [D], but [D] is unfazed!</span>", \
					  "<span class='userdanger'>[A] punches you, but you are unfazed!</span>")
		else
			D.Stun(30)
			D.visible_message("<span class='danger'>[A] punches [D], stunning them!</span>", \
					  "<span class='userdanger'>[A] misses you!</span>")
			add_logs(A, D, "stunning fist (monk)")
	else
		D.visible_message("<span class='danger'>[A] missed [D]!</span>", \
				  "<span class='userdanger'>[A] misses you!</span>")
	return 1

/datum/martial_art/monk/proc/quivering_palm(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	var/atr = attack_roll(D, flurry_of_blows_penalty)
	if(atr)
		var/fort_save = ROLL_DICE(1,20) + 3 // bonus save for this
		if(fort_save >= 10)
			D.visible_message("<span class='danger'>[A] punches [D], but [D] is unfazed!</span>", \
					  "<span class='userdanger'>[A] punches you, but you are unfazed!</span>")
		else
			var/datum/disease/DE = new /datum/disease/heart_failure
			D.ForceContractDisease(DE)
			D.visible_message("<span class='danger'>[A] punches [D], and they start to quiver!</span>", \
					  "<span class='userdanger'>[A] punches you, and you feel your heart stop!</span>")
			add_logs(A, D, "quivering palm (monk)")
	else
		D.visible_message("<span class='danger'>[A] missed [D]!</span>", \
				  "<span class='userdanger'>[A] misses you!</span>")
	return 1

/datum/martial_art/monk/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	..()

/datum/martial_art/monk/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	..()

/datum/action/monk_rest
	name = "Rest - Sleep to regain your strength."
	button_icon_state = "neckchop" // todo: replace
	icon_icon = 'icons/mob/actions/actions_items.dmi'

/datum/action/monk_rest/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use [name] while you're incapacitated.</span>")
		return
	owner.Sleeping(100)
	to_chat(owner, "<span class='warning'>You fall into a meditative sleep...</span>")
	var/mob/living/carbon/human/H = owner
	var/datum/martial_art/monk/MA = H.mind.martial_art
	for(var/ME in MA.available_actions)
		var/datum/action/monk/M = ME
		M.uses_left = M.max_uses


/datum/action/monk
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	var/uses_left
	var/max_uses
	var/skill_name
	var/pretty_name

/datum/action/monk/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use [name] while you're incapacitated.</span>")
		return
	if(!uses_left)
		to_chat(owner, "<span class='warning'>You must rest before you can use [name]!</span>")
		return
	var/mob/living/carbon/human/H = owner
	if (H.mind.martial_art.streak == skill_name)
		owner.visible_message("<span class='danger'>[owner] assumes a neutral stance.</span>", "<b><i>Your next attack is cleared.</i></b>")
		H.mind.martial_art.streak = ""
	else
		owner.visible_message("<span class='danger'>[owner] prepares a technique!</span>", "<b><i>Your next attack will be a [pretty_name].</i></b>")
		H.mind.martial_art.streak = skill_name


/datum/action/monk/stunning_fist
	name = "Stunning Fist - A disabling strike that stuns for 3 seconds."
	button_icon_state = "neckchop" // todo: replace
	uses_left = 4
	max_uses = 4
	skill_name = "stunning_fist"
	pretty_name = "Stunning Fist"

/datum/action/monk/quivering_palm
	name = "Quivering Palm - A monk can set up fatal vibrations within the body of another creature once per day."
	button_icon_state = "neckchop" // todo: replace
	uses_left = 1
	max_uses = 1
	skill_name = "quivering_palm"
	pretty_name = "Quivering Palm"

/obj/item/nullrod/monk_manual
	name = "monk manual"
	desc = "A small, black manual. Inside is the collective history of all Monk orders to ever exist."
	icon = 'icons/obj/library.dmi'
	icon_state ="cqcmanual"
	force = 1
	throwforce = 1

/obj/item/nullrod/monk_manual/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	to_chat(user, "<span class='boldannounce'>You have become a Monk!</span>")
	var/datum/martial_art/monk/D = new(null)
	D.teach(user)
	visible_message("<span class='warning'>You tear up [src] as described in the final pages.</span>")
	qdel(src)
