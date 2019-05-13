/datum/martial_art/krav_maga
	name = "Krav Maga"
	id = MARTIALART_KRAVMAGA
	help_verb = /mob/living/carbon/human/proc/krav_maga_help
	var/cooldown = 0

/datum/martial_art/krav_maga/teach(mob/living/carbon/human/H,make_temporary=0)
	if(..())
		to_chat(H, "<span class = 'userdanger'>You know the arts of [name]!</span>")

/datum/martial_art/krav_maga/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class = 'userdanger'>You suddenly forget the arts of [name]...</span>")

/datum/martial_art/krav_maga/proc/check_streak(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	switch(streak)
		if("neck_chop")
			streak = ""
			if(cooldown < world.time)
				return
			neck_chop(A,D)
			cooldown = world.time + 50
			return 1
		if("leg_sweep")
			if(cooldown < world.time)
				return
			leg_sweep(A,D)
			cooldown = world.time + 20
			return 1
		if("lung_punch")
			streak = ""
			if(cooldown < world.time)
				return
			lung_punch(A,D)
			cooldown = world.time + 30
			return 1
		if("eye_strike")
			streak = ""
			eye_strike(A,D)
			return 1
		if("unarm")
			streak = ""
			unarm(A,D)
			return 1
		if("headbutt")
			streak = ""
			if(cooldown < world.time)
				return
			headbutt(A,D)
			cooldown = world.time + 30
			return 1
		if("groin_kick")
			streak = ""
			if(cooldown < world.time)
				return
			groin_kick(A,D)
			cooldown = world.time + 30
			return 1
	return 0

/datum/martial_art/krav_maga/proc/leg_sweep(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(D.stat || D.IsParalyzed())
		return 0
	D.visible_message("<span class='warning'>[A] leg sweeps [D]!</span>", \
					  	"<span class='userdanger'>[A] leg sweeps you!</span>")
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	D.apply_damage(5, BRUTE, A.zone_selected)
	D.Paralyze(40)
	log_combat(A, D, "leg sweeped")
	return 1

/datum/martial_art/krav_maga/proc/lung_punch(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] pounds [D] on the chest!</span>", \
				  	"<span class='userdanger'>[A] slams your chest! You can't breathe!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	if(D.losebreath <= 10)
		D.losebreath = CLAMP(D.losebreath + 5, 0, 10)
	D.adjustOxyLoss(10)
	log_combat(A, D, "lung punched")
	return 1

/datum/martial_art/krav_maga/proc/neck_chop(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] karate chops [D]'s neck!</span>", \
				  	"<span class='userdanger'>[A] karate chops your neck, rendering you unable to speak!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.apply_damage(5, A.dna.species.attack_type, A.zone_selected)
	if(D.silent <= 10)
		D.silent = CLAMP(D.silent + 10, 0, 10)
	log_combat(A, D, "neck chopped")
	return 1

/datum/martial_art/krav_maga/proc/eye_strike(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] eye struck [D]!</span>", \
				  	"<span class='userdanger'>[A] strikes your eye!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.apply_damage(3, BRUTE, A.zone_selected)
	D.adjust_blurriness(3)
	D.adjust_eye_damage(rand(1,3))
	var/obj/item/organ/eyes/eyes = D.getorganslot(ORGAN_SLOT_EYES)
	if (!eyes)
		return
	if(eyes.eye_damage >= 10)
		D.adjust_blurriness(15)
		if(D.stat != DEAD)
			to_chat(D, "<span class='danger'>Your eyes start to bleed profusely!</span>")
		to_chat(D, "<span class='danger'>You become nearsighted!</span>")
		D.become_nearsighted(EYE_DAMAGE)
		if(prob(50))
			if(D.stat != DEAD)
				if(D.drop_all_held_items())
					to_chat(D, "<span class='danger'>You drop what you're holding and clutch at your eyes!</span>")
			D.adjust_blurriness(10)
			D.Unconscious(20)
			D.Paralyze(40)
		if (prob(eyes.eye_damage - 10 + 1))
			D.become_blind(EYE_DAMAGE)
			to_chat(D, "<span class='danger'>You go blind!</span>")
	log_combat(A, D, "eye struck")
	return 1

/datum/martial_art/krav_maga/proc/unarm(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	var/obj/item/I = null
	I = D.get_active_held_item()
	if(I)
		if(D.temporarilyRemoveItemFromInventory(I))
			A.put_in_hands(I)
	D.visible_message("<span class='danger'>[A] has unarmed [D]!</span>", \
					"<span class='userdanger'>[A] has unarmed you!</span>")
	playsound(D, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	log_combat(A, D, "unarmed", "[I ? " removing \the [I]" : ""]")
	return 1

/datum/martial_art/krav_maga/proc/headbutt(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] headbutts [D]!</span>", \
				  	"<span class='userdanger'>[A] headbutts you!</span>")
	playsound(get_turf(A), 'sound/effects/meteorimpact.ogg', 50, 1, -1)
	A.apply_damage(10, BRUTE, A.zone_selected)
	D.apply_damage(15, A.dna.species.attack_type, A.zone_selected)
	if (prob(50))
		D.adjustBrainLoss(10)
		if(D.stat == CONSCIOUS)
			D.confused = max(D.confused, 20)
			D.adjust_blurriness(10)
		if(prob(10))
			D.gain_trauma(/datum/brain_trauma/mild/concussion)
	log_combat(A, D, "headbutted")
	return 1

/datum/martial_art/krav_maga/proc/groin_kick(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] groin kicks [D]!</span>", \
				  	"<span class='userdanger'>[A] kicks your groin! You scream out!</span>")
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	D.apply_damage(10, A.dna.species.attack_type, A.zone_selected)
	D.add_movespeed_modifier(MOVESPEED_ID_KRAV_MAGA, update=TRUE, priority=100, multiplicative_slowdown=1)
	addtimer(CALLBACK(D, /mob/.proc/remove_movespeed_modifier, MOVESPEED_ID_KRAV_MAGA, TRUE), 3 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	D.emote("scream")
	log_combat(A, D, "groin kicked")
	return 1

/datum/martial_art/krav_maga/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	log_combat(A, D, "grabbed (Krav Maga)")
	..()

/datum/martial_art/krav_maga/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	log_combat(A, D, "punched")
	var/picked_hit_type = pick("punches", "kicks")
	var/bonus_damage = 10
	if(!(D.mobility_flags & MOBILITY_STAND))
		bonus_damage += 5
		picked_hit_type = "stomps on"
	D.apply_damage(bonus_damage, A.dna.species.attack_type)
	if(picked_hit_type == "kicks" || picked_hit_type == "stomps on")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	else
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	log_combat(A, D, "[picked_hit_type] with [name]")
	return 1

/datum/martial_art/krav_maga/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(A.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		A.mind.martial_art.streak = "neck_chop"
	if(A.zone_selected == BODY_ZONE_L_LEG || A.zone_selected == BODY_ZONE_R_LEG)
		A.mind.martial_art.streak = "leg_sweep"
	if(A.zone_selected == BODY_ZONE_CHEST)
		A.mind.martial_art.streak = "lung_punch"
	if(A.zone_selected == BODY_ZONE_PRECISE_EYES)
		A.mind.martial_art.streak = "eye_strike"
	if(A.zone_selected == BODY_ZONE_L_ARM || A.zone_selected == BODY_ZONE_R_ARM)
		A.mind.martial_art.streak = "unarm"
	if(A.zone_selected == BODY_ZONE_HEAD)
		A.mind.martial_art.streak = "headbutt"
	if(A.zone_selected == BODY_ZONE_PRECISE_GROIN)
		A.mind.martial_art.streak = "groin_kick"
	if(check_streak(A,D))
		return 1
	return 0

//Krav Maga Gloves

/obj/item/clothing/gloves/krav_maga
	var/datum/martial_art/krav_maga/style = new

/obj/item/clothing/gloves/krav_maga/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)

/obj/item/clothing/gloves/krav_maga/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(SLOT_GLOVES) == src)
		style.remove(H)

/obj/item/clothing/gloves/krav_maga/sec//more obviously named, given to sec
	name = "krav maga gloves"
	desc = "These gloves can teach you to perform Krav Maga using nanochips."
	icon_state = "fightgloves"
	item_state = "fightgloves"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/gloves/krav_maga/combatglovesplus
	name = "combat gloves plus"
	desc = "These tactical gloves are fireproof and shock resistant, and using nanochip technology it teaches you the powers of krav maga."
	icon_state = "black"
	item_state = "blackglovesplus"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)

/mob/living/carbon/human/proc/krav_maga_help()
	set name = "Remember The Basics"
	set desc = "You try to remember some of the basics of Krav Maga."
	set category = "Krav Maga"
	to_chat(usr, "<b><i>You try to remember some of the basics of Krav Maga.</i></b>")

	to_chat(usr, "<span class='notice'>Neck Chop</span>: Mouth. Injures the neck, stopping the victim from speaking for a while.")
	to_chat(usr, "<span class='notice'>Eye Strike</span>: Eye. Causes eye damage to the victim, may make him blind after considerable usage.")
	to_chat(usr, "<span class='notice'>Headbutt</span>: Head. Smashes your skull into the victim's, giving you small damage while giving the victim concussions.")
	to_chat(usr, "<span class='notice'>Lung Punch</span>: Chest. Delivers a strong punch just above the victim's abdomen, constraining the lungs. The victim will be unable to breathe for a short time.")
	to_chat(usr, "<span class='notice'>Unarm</span>: Arm. Knocks the victim's items out of their hands.")
	to_chat(usr, "<span class='notice'>Leg Sweep</span>: Leg. Trips the victim, knocking them down for a brief moment.")
	to_chat(usr, "<span class='notice'>Groin Kick</span>: Groin. Slows down the victim and deals decent damage, may include screaming.")
