#define ATK_MISS 0
#define ATK_HIT 1
#define ATK_CRIT_HIT 2
#define HIT_MIN 5
#define HIT_MAX 10


/datum/martial_art/monk
	name = "Monk"
	var/current_exp = 100
	var/next_level_exp = 200
	var/static/exp_slope = 10.5
	var/current_level = 1
	var/level_cap = 20

	var/curr_ab = 3 // increase every 4 levels
	var/flurry_of_blows_penalty = -2 // -2 at 1-4, -1 at 5-8, 0 at 9-20
	var/attacks_w_flurry = 2 // increase to 3 at 11
	var/ki_level = 0
	var/cleave_level = 0
	var/circle_kick = FALSE
	var/diamond_body = FALSE
	var/purity_of_body = FALSE
	var/using_flurry = TRUE

	var/list/available_actions = list()
	var/datum/action/monk_rest/monk_rest = new/datum/action/monk_rest()
	var/datum/action/flurry_toggle/flurry_toggle = new/datum/action/flurry_toggle()
	var/datum/action/monk/stunning_fist/stunning_fist = new/datum/action/monk/stunning_fist()
	var/datum/action/monk/quivering_palm/quivering_palm = new/datum/action/monk/quivering_palm()
	var/datum/action/monk/wholeness_of_body/wholeness_of_body = new/datum/action/monk/wholeness_of_body()
	no_guns = TRUE


/datum/martial_art/monk/teach(mob/living/carbon/human/H,make_temporary=0)
	if(..())
		monk_rest.Grant(H)
		flurry_toggle.Grant(H)
		flurry_toggle.martial = src
		to_chat(H, "<span class = 'userdanger'>You know the ancient Monk techniques!</span>")
		to_chat(H, "<span class = 'danger'>This technique becomes more powerful the more you use it.</span>")
		to_chat(H, "<span class = 'danger'>Your power level will increase from 1 to 20, gaining new abilities and growing stronger the more you train.</span>")
		to_chat(H, "<span class = 'danger'>Your abilities have a use limit, before you need to rest to regain your strength.</span>")
		to_chat(H, "<span class = 'danger'>You can't gain experience on yourself, dead humans, non humans, or braindead humans.</span>")
		START_PROCESSING(SSfastprocess, src)
		H.hair_style = "Short Hair"
		H.facial_hair_style = "Shaved"
		H.update_hair()

/datum/martial_art/monk/proc/flurry_penalty()
	if(using_flurry)
		return flurry_of_blows_penalty
	return 0

/datum/martial_art/monk/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class = 'userdanger'>You forget the ways of a Monk...</span>")
	stunning_fist.Remove(H)
	quivering_palm.Remove(H)
	flurry_toggle.Remove(H)
	monk_rest.Remove(H)
	wholeness_of_body.Remove(H)
	STOP_PROCESSING(SSfastprocess, src)

/datum/martial_art/monk/process()
	..()
	if(diamond_body)
		owner.reagents.remove_all_type(/datum/reagent/toxin, 30)
	if(purity_of_body)
		if(owner.viruses && owner.viruses.len)
			for(var/V in owner.viruses)
				var/datum/disease/D = V
				D.cure()

/datum/martial_art/monk/proc/do_level_up()
	if(current_level % 4 == 0)
		curr_ab++
	switch(current_level)
		if(2)
			to_chat(owner, "<span class = 'danger'>You have practiced the Stunning Fist technique enough to use it in combat.</span>")
			stunning_fist.Grant(owner)
			stunning_fist.martial = src
			available_actions = list(stunning_fist)
		if(4)
			to_chat(owner, "<span class = 'danger'>Your Ki has begun to develop, probing at the armor of your foes.</span>")
			ki_level = 50
		if(5)
			to_chat(owner, "<span class = 'danger'>You feel more confident in your strikes, and your body is pure.</span>")
			flurry_of_blows_penalty = -1
			purity_of_body = TRUE
			owner.hair_style = "Balding Hair"
			owner.update_hair()
		if(7)
			to_chat(owner, "<span class = 'danger'>You can perform more Stunning Fists before resting. You have figured out the wholeness of your body.</span>")
			stunning_fist.max_uses = 7
			wholeness_of_body.Grant(owner)
			wholeness_of_body.martial = src
			available_actions = list(stunning_fist, wholeness_of_body)
		if(8)
			to_chat(owner, "<span class = 'danger'>You move from one downed target to the next quickly.</span>")
			cleave_level = 1
		if(9)
			to_chat(owner, "<span class = 'danger'>You have become completely confident in your ability to land a strike.</span>")
			flurry_of_blows_penalty = 0
		if(10)
			to_chat(owner, "<span class = 'danger'>Your Ki helps you seek the holes in enemy armor.</span>")
			ki_level = 75
			owner.hair_style = "Bald"
			owner.update_hair()
		if(11)
			to_chat(owner, "<span class = 'danger'>You feel confident enough to strike more and harder, and use this against toxins in your body.</span>")
			attacks_w_flurry = 3
			diamond_body = TRUE
		if(12)
			to_chat(owner, "<span class = 'danger'>You now use a circle kick to extend your attacks to other foes in combat.</span>")
			circle_kick = TRUE
		if(14)
			to_chat(owner, "<span class = 'danger'>You use a downed foe to strike at their allies.</span>")
			cleave_level = 2
		if(15)
			to_chat(owner, "<span class = 'danger'>You have practiced the Quivering Palm technique enough to use it in combat.</span>")
			quivering_palm.Grant(owner)
			quivering_palm.martial = src
			available_actions = list(stunning_fist, wholeness_of_body, quivering_palm)
		if(16)
			to_chat(owner, "<span class = 'danger'>Your Ki has fully developed, and can be used to nullify armor.</span>")
			ki_level = 100
		if(17)
			to_chat(owner, "<span class = 'danger'>You can perform more Stunning Fists before resting.</span>")
			stunning_fist.max_uses = 14

/datum/martial_art/monk/proc/attack_roll(mob/living/T, abm)
	if(istype(T, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = T
		if(H.mind && istype(H.mind.martial_art, /datum/martial_art/monk))
			var/datum/martial_art/monk/M = H.mind.martial_art
			return M.defense_roll(curr_ab + abm)
	var/armor_class = 10 + (T.getarmor("chest", "melee") * 0.1)
	var/attack_bonus = curr_ab + abm
	if(T.incapacitated())
		attack_bonus += 3
	var/attack_roll = roll(1,20) + attack_bonus
	if(attack_roll >= armor_class)
		if(attack_roll >= 20)
			attack_roll = roll(1,20) + attack_bonus
			if(attack_roll >= armor_class)
				return ATK_CRIT_HIT
			return ATK_HIT
		else
			return ATK_HIT
	return ATK_MISS

/datum/martial_art/monk/proc/defense_roll(abm)
	var/armor = (owner.getarmor("chest", "melee") * 0.1)
	var/armor_class = 10
	if(!armor)
		armor_class = 15
	else
		armor_class -= armor
	var/attack_bonus = abm
	if(owner.incapacitated())
		attack_bonus += 3
	var/attack_roll = roll(1,20) + attack_bonus
	if(attack_roll >= armor_class)
		if(attack_roll >= 20)
			attack_roll = roll(1,20) + attack_bonus
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
		next_level_exp = next_level*100
		do_level_up()
		to_chat(owner, "<span class = 'danger'>You feel more confident in your powers.</span>")

/datum/martial_art/monk/proc/do_attack(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D, use_cleave, use_circle, surrounding_mobs)
	var/picked_hit_type = pick("punched")
	switch(picked_hit_type)
		if("punched")
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atr = attack_roll(D, flurry_penalty())
	if(atr)
		var/old_stat = D.stat
		if(D.stat != DEAD && D.ckey && D != A)
			add_exp(5)
		var/dmg = rand(HIT_MIN, HIT_MAX)
		var/was_crit = ""
		var/armor = (D.run_armor_check("chest", "melee", armour_penetration = ki_level)) / 100
		if(armor > 1)
			armor = 1
		if(atr == ATK_CRIT_HIT)
			dmg *= 2
			was_crit = "critically "
		dmg -= (dmg * armor)
		D.adjustBruteLoss(dmg)
		if(use_circle)
			do_attack(A, pick(surrounding_mobs), FALSE, FALSE, null)
		if(old_stat != DEAD && D.stat == DEAD)
			if(use_cleave)
				switch(use_cleave)
					if(1)
						do_attack(A, pick(surrounding_mobs), FALSE, FALSE, null)
					if(2)
						for(var/H in surrounding_mobs)
							do_attack(A, H, FALSE, FALSE, null)
		playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)
		add_logs(A, D, "[was_crit]punched (monk)")
		D.visible_message("<span class='danger'>[A] [was_crit][picked_hit_type] [D]!</span>", \
				  "<span class='userdanger'>[A] [was_crit][picked_hit_type] you!</span>")
		return 1
	else
		if(D.stat != DEAD && D.ckey && D != A)
			add_exp(2.5)
		add_logs(A, D, "missed a punch (monk)")
		playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		D.visible_message("<span class='danger'>[A] missed [D]!</span>", \
				  "<span class='userdanger'>[A] misses you!</span>")
		return 0

/datum/martial_art/monk/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	var/list/surrounding_mobs
	if(cleave_level || circle_kick)
		surrounding_mobs = list()
		for(var/mob/living/carbon/human/H in orange(1, A))
			surrounding_mobs += H
	if(using_flurry)
		for(var/i in 1 to attacks_w_flurry)
			do_attack(A, D, cleave_level, circle_kick, surrounding_mobs)
	else
		do_attack(A, D, cleave_level, circle_kick, surrounding_mobs)
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
	var/atr = attack_roll(D, flurry_penalty())
	if(atr)
		var/save_bonus = 0
		if(D.incapacitated())
			save_bonus -= 3
		var/fort_save = roll(1,20) + save_bonus
		if(fort_save >= 10)
			D.visible_message("<span class='danger'>[A] punches [D], but [D] is unfazed!</span>", \
					  "<span class='userdanger'>[A] punches you, but you are unfazed!</span>")
		else
			D.Stun(30)
			D.visible_message("<span class='danger'>[A] punches [D], stunning them!</span>", \
					  "<span class='userdanger'>[A] punches you, and you're stunned!</span>")
			add_logs(A, D, "stunning fist (monk)")
	else
		D.visible_message("<span class='danger'>[A] missed [D]!</span>", \
				  "<span class='userdanger'>[A] misses you!</span>")
	return 1

/datum/martial_art/monk/proc/quivering_palm(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	var/atr = attack_roll(D, flurry_penalty())
	if(atr)
		var/save_bonus = 3
		if(D.incapacitated())
			save_bonus -= 3
		var/fort_save = roll(1,20) + save_bonus // bonus save for this
		if(fort_save >= 10)
			D.visible_message("<span class='danger'>[A] punches [D], but [D] is unfazed!</span>", \
					  "<span class='userdanger'>[A] punches you, but you are unfazed!</span>")
		else
			D.set_heartattack(TRUE)
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
	var/mob/living/carbon/human/H = owner
	H.AdjustUnconscious(200)
	to_chat(H, "<span class='warning'>You fall into a meditative sleep...</span>")
	var/datum/martial_art/monk/MA = H.mind.martial_art
	for(var/ME in MA.available_actions)
		var/datum/action/monk/M = ME
		M.uses_left = M.max_uses

/datum/action/flurry_toggle
	name = "Flurry Of Blows - Enable/Disable, attack more in 1 turn but with an attack penalty at early levels."
	button_icon_state = "neckchop" // todo: replace
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	var/datum/martial_art/monk/martial

/datum/action/flurry_toggle/Trigger()
	if(martial)
		martial.using_flurry = !martial.using_flurry
		if(martial.using_flurry)
			to_chat(owner, "<span class='warning'>You enable Flurry of Blows.</span>")
		else
			to_chat(owner, "<span class='warning'>You disable Flurry of Blows.</span>")

/datum/action/monk
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	var/uses_left
	var/max_uses
	var/skill_name
	var/pretty_name
	var/datum/martial_art/monk/martial

/datum/action/monk/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use [name] while you're incapacitated.</span>")
		return
	if(!uses_left)
		to_chat(owner, "<span class='warning'>You must rest before you can use [pretty_name]!</span>")
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

/datum/action/monk/wholeness_of_body
	name = "Wholeness of Body - Restores health equal to twice the monk's level."
	button_icon_state = "neckchop" // todo: replace
	uses_left = 1
	max_uses = 1
	skill_name = "wholeness_of_body"
	pretty_name = "Wholeness Of Body"


/datum/action/monk/wholeness_of_body/Trigger()
	if(!uses_left)
		to_chat(owner, "<span class='warning'>You must rest before you can use [pretty_name]!</span>")
		return
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use [name] while you're incapacitated.</span>")
		return
	var/mob/living/carbon/human/H = owner
	var/amt_to_heal = martial.current_level * 2
	H.adjustBruteLoss(-amt_to_heal)
	H.adjustFireLoss(-amt_to_heal)
	H.adjustToxLoss(-amt_to_heal)
	H.adjustOxyLoss(-amt_to_heal)
	uses_left--
	to_chat(owner, "<span class='warning'>You focus on your inner being, identifying that wounds are merely material.</span>")


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
