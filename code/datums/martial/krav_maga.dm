/datum/martial_art/krav_maga
	name = "Krav Maga"
	id = MARTIALART_KRAVMAGA
	help_verb = /mob/living/carbon/human/proc/krav_maga_help

/datum/martial_art/krav_maga/teach(mob/living/carbon/human/H,make_temporary=0)
	if(..())
		to_chat(H, "<span class = 'userdanger'>You know the arts of [name]!</span>")

/datum/martial_art/krav_maga/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class = 'userdanger'>You suddenly forget the arts of [name]...</span>")

/datum/martial_art/krav_maga/proc/check_streak(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	switch(streak)
		if("neck_chop")
			streak = ""
			neck_chop(A,D)
			return 1
		if("leg_sweep")
			streak = ""
			leg_sweep(A,D)
			return 1
		if("quick_choke")//is actually lung punch
			streak = ""
			quick_choke(A,D)
			return 1
	return 0

/datum/martial_art/krav_maga/proc/leg_sweep(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(D.stat || D.IsParalyzed())
		return 0
	D.visible_message("<span class='warning'>[A] leg sweeps [D]!</span>", \
					  	"<span class='userdanger'>[A] leg sweeps you!</span>")
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	D.apply_damage(5, BRUTE)
	D.Paralyze(40)
	log_combat(A, D, "leg sweeped")
	return 1

/datum/martial_art/krav_maga/proc/quick_choke(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)//is actually lung punch
	D.visible_message("<span class='warning'>[A] pounds [D] on the chest!</span>", \
				  	"<span class='userdanger'>[A] slams your chest! You can't breathe!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	if(D.losebreath <= 10)
		D.losebreath = CLAMP(D.losebreath + 5, 0, 10)
	D.adjustOxyLoss(10)
	log_combat(A, D, "quickchoked")
	return 1

/datum/martial_art/krav_maga/proc/neck_chop(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] karate chops [D]'s neck!</span>", \
				  	"<span class='userdanger'>[A] karate chops your neck, rendering you unable to speak!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.apply_damage(5, A.dna.species.attack_type)
	if(D.silent <= 10)
		D.silent = CLAMP(D.silent + 10, 0, 10)
	log_combat(A, D, "neck chopped")
	return 1

/datum/martial_art/krav_maga/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "grabbed (Krav Maga)")
	..()

/datum/martial_art/krav_maga/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
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
	if(check_streak(A,D))
		return 1
	var/obj/item/I = null
	if(prob(60))
		I = D.get_active_held_item()
		if(I)
			if(D.temporarilyRemoveItemFromInventory(I))
				A.put_in_hands(I)
		D.visible_message("<span class='danger'>[A] has disarmed [D]!</span>", \
							"<span class='userdanger'>[A] has disarmed [D]!</span>")
		playsound(D, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	else
		D.visible_message("<span class='danger'>[A] attempted to disarm [D]!</span>", \
							"<span class='userdanger'>[A] attempted to disarm [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	log_combat(A, D, "disarmed (Krav Maga)", "[I ? " removing \the [I]" : ""]")
	return 1

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
	to_chat(usr, "<span class='notice'>Headbutt</span>: Head. Locks opponents into a restraining position, disarm to knock them out with a chokehold.")
	to_chat(usr, "<span class='notice'>Lung Punch</span>: Chest. Delivers a strong punch just above the victim's abdomen, constraining the lungs. The victim will be unable to breathe for a short time.")
	to_chat(usr, "<span class='notice'>Unarm</span>: Arm. Knocks the victim's items out of their hands.")
	to_chat(usr, "<span class='notice'>Leg Sweep</span>: Leg. Trips the victim, knocking them down for a brief moment.")
	to_chat(usr, "<span class='notice'>Groin Kick</span>: Groin. Slows down the victim and deals decent damage, may include screaming.")
