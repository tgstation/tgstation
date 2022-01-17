/datum/martial_art/krav_maga
	name = "Krav Maga"
	id = MARTIALART_KRAVMAGA
	var/datum/action/neck_chop/neckchop = new/datum/action/neck_chop()
	var/datum/action/leg_sweep/legsweep = new/datum/action/leg_sweep()
	var/datum/action/lung_punch/lungpunch = new/datum/action/lung_punch()

/datum/action/neck_chop
	name = "Neck Chop - Injures the neck, stopping the victim from speaking for a while."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "neckchop"

/datum/action/neck_chop/Trigger(trigger_flags)
	if(owner.incapacitated())
		to_chat(owner, span_warning("You can't use [name] while you're incapacitated."))
		return
	if (owner.mind.martial_art.streak == "neck_chop")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack is cleared.</i></b>")
		owner.mind.martial_art.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Neck Chop stance!"), "<b><i>Your next attack will be a Neck Chop.</i></b>")
		owner.mind.martial_art.streak = "neck_chop"

/datum/action/leg_sweep
	name = "Leg Sweep - Trips the victim, knocking them down for a brief moment."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "legsweep"

/datum/action/leg_sweep/Trigger(trigger_flags)
	if(owner.incapacitated())
		to_chat(owner, span_warning("You can't use [name] while you're incapacitated."))
		return
	if (owner.mind.martial_art.streak == "leg_sweep")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack is cleared.</i></b>")
		owner.mind.martial_art.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Leg Sweep stance!"), "<b><i>Your next attack will be a Leg Sweep.</i></b>")
		owner.mind.martial_art.streak = "leg_sweep"

/datum/action/lung_punch//referred to internally as 'quick choke'
	name = "Lung Punch - Delivers a strong punch just above the victim's abdomen, constraining the lungs. The victim will be unable to breathe for a short time."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "lungpunch"

/datum/action/lung_punch/Trigger(trigger_flags)
	if(owner.incapacitated())
		to_chat(owner, span_warning("You can't use [name] while you're incapacitated."))
		return
	if (owner.mind.martial_art.streak == "quick_choke")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack is cleared.</i></b>")
		owner.mind.martial_art.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Lung Punch stance!"), "<b><i>Your next attack will be a Lung Punch.</i></b>")
		owner.mind.martial_art.streak = "quick_choke"//internal name for lung punch

/datum/martial_art/krav_maga/teach(mob/living/owner, make_temporary=FALSE)
	if(..())
		to_chat(owner, span_userdanger("You know the arts of [name]!"))
		to_chat(owner, span_danger("Place your cursor over a move at the top of the screen to see what it does."))
		neckchop.Grant(owner)
		legsweep.Grant(owner)
		lungpunch.Grant(owner)

/datum/martial_art/krav_maga/on_remove(mob/living/owner)
	to_chat(owner, span_userdanger("You suddenly forget the arts of [name]..."))
	neckchop.Remove(owner)
	legsweep.Remove(owner)
	lungpunch.Remove(owner)

/datum/martial_art/krav_maga/proc/check_streak(mob/living/attacker, mob/living/defender)
	switch(streak)
		if("neck_chop")
			streak = ""
			neck_chop(attacker, defender)
			return TRUE
		if("leg_sweep")
			streak = ""
			leg_sweep(attacker, defender)
			return TRUE
		if("quick_choke")//is actually lung punch
			streak = ""
			quick_choke(attacker, defender)
			return TRUE
	return FALSE

/datum/martial_art/krav_maga/proc/leg_sweep(mob/living/attacker, mob/living/defender)
	if(defender.stat || defender.IsParalyzed())
		return FALSE
	var/obj/item/bodypart/affecting = defender.get_bodypart(BODY_ZONE_CHEST)
	var/armor_block = defender.run_armor_check(affecting, MELEE)
	defender.visible_message(span_warning("[attacker] leg sweeps [defender]!"), \
					span_userdanger("Your legs are sweeped by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, attacker)
	to_chat(attacker, span_danger("You leg sweep [defender]!"))
	playsound(get_turf(attacker), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	defender.apply_damage(rand(20, 30), STAMINA, affecting, armor_block)
	defender.Knockdown(60)
	log_combat(attacker, defender, "leg sweeped")
	return TRUE

/datum/martial_art/krav_maga/proc/quick_choke(mob/living/attacker, mob/living/defender)//is actually lung punch
	defender.visible_message(span_warning("[attacker] pounds [defender] on the chest!"), \
					span_userdanger("Your chest is slammed by [attacker]! You can't breathe!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_danger("You pound [defender] on the chest!"))
	playsound(get_turf(attacker), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	if(defender.losebreath <= 10)
		defender.losebreath = clamp(defender.losebreath + 5, 0, 10)
	defender.adjustOxyLoss(10)
	log_combat(attacker, defender, "quickchoked")
	return TRUE

/datum/martial_art/krav_maga/proc/neck_chop(mob/living/attacker, mob/living/defender)
	defender.visible_message(span_warning("[attacker] karate chops [defender]'s neck!"), \
					span_userdanger("Your neck is karate chopped by [attacker], rendering you unable to speak!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_danger("You karate chop [defender]'s neck, rendering [defender.p_them()] unable to speak!"))
	playsound(get_turf(attacker), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	defender.apply_damage(5, attacker.get_attack_type())
	if (iscarbon(defender))
		var/mob/living/carbon/carbon_defender = defender
		if(carbon_defender.silent <= 10)
			carbon_defender.silent = clamp(carbon_defender.silent + 10, 0, 10)
	log_combat(attacker, defender, "neck chopped")
	return TRUE

/datum/martial_art/krav_maga/grab_act(mob/living/attacker, mob/living/defender)
	if(check_streak(attacker, defender))
		return TRUE
	log_combat(attacker, defender, "grabbed (Krav Maga)")
	..()

/datum/martial_art/krav_maga/harm_act(mob/living/attacker, mob/living/defender)
	if(check_streak(attacker, defender))
		return TRUE
	log_combat(attacker, defender, "punched")
	var/obj/item/bodypart/affecting = defender.get_bodypart(ran_zone(attacker.zone_selected))
	var/armor_block = defender.run_armor_check(affecting, MELEE)
	var/picked_hit_type = pick("punch", "kick")
	var/bonus_damage = 0
	if(defender.body_position == LYING_DOWN)
		bonus_damage += 5
		picked_hit_type = "stomp"
	defender.apply_damage(rand(5, 10) + bonus_damage, attacker.get_attack_type(), affecting, armor_block)
	if(picked_hit_type == "kick" || picked_hit_type == "stomp")
		attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
		playsound(get_turf(defender), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	else
		attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(defender), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	defender.visible_message(span_danger("[attacker] [picked_hit_type]s [defender]!"), \
					span_userdanger("You're [picked_hit_type]ed by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_danger("You [picked_hit_type] [defender]!"))
	log_combat(attacker, defender, "[picked_hit_type] with [name]")
	return TRUE

/datum/martial_art/krav_maga/disarm_act(mob/living/attacker, mob/living/defender)
	if(check_streak(attacker, defender))
		return TRUE
	var/obj/item/bodypart/affecting = defender.get_bodypart(ran_zone(attacker.zone_selected))
	var/armor_block = defender.run_armor_check(affecting, MELEE)
	if(defender.body_position == STANDING_UP)
		defender.visible_message(span_danger("[attacker] reprimands [defender]!"), \
					span_userdanger("You're slapped by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
		to_chat(attacker, span_danger("You jab [defender]!"))
		attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
		playsound(defender, 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
		defender.apply_damage(rand(5, 10), STAMINA, affecting, armor_block)
		log_combat(attacker, defender, "punched nonlethally")
	if(defender.body_position == LYING_DOWN)
		defender.visible_message(span_danger("[attacker] reprimands [defender]!"), \
					span_userdanger("You're manhandled by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
		to_chat(attacker, span_danger("You stomp [defender]!"))
		attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
		playsound(defender, 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
		defender.apply_damage(rand(10, 15), STAMINA, affecting, armor_block)
		log_combat(attacker, defender, "stomped nonlethally")
	if(prob(defender.getStaminaLoss()) && defender.stat < UNCONSCIOUS)
		defender.visible_message(span_warning("[defender] sputters and recoils in pain!"), span_userdanger("You recoil in pain as you are jabbed in a nerve!"))
		defender.drop_all_held_items()
	return TRUE

//Krav Maga Gloves

/obj/item/clothing/gloves/krav_maga
	var/datum/martial_art/krav_maga/style = new

/obj/item/clothing/gloves/krav_maga/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		style.teach(user, TRUE)

/obj/item/clothing/gloves/krav_maga/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(user)

/obj/item/clothing/gloves/krav_maga/sec//more obviously named, given to sec
	name = "krav maga gloves"
	desc = "These gloves can teach you to perform Krav Maga using nanochips."
	icon_state = "fightgloves"
	inhand_icon_state = "fightgloves"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/gloves/krav_maga/combatglovesplus
	name = "combat gloves plus"
	desc = "These tactical gloves are fireproof and electrically insulated, and through the use of nanochip technology will teach you the martial art of krav maga."
	icon_state = "black"
	inhand_icon_state = "blackgloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 80, ACID = 50)
