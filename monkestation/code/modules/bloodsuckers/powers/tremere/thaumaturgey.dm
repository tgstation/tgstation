/**
 *	# Thaumaturgy
 *
 *	Level 1 - One shot bloodbeam spell
 *	Level 2 - Bloodbeam spell - Gives them a Blood shield until they use Bloodbeam
 *	Level 3 - Bloodbeam spell that breaks open lockers/doors - Gives them a Blood shield until they use Bloodbeam
 *	Level 4 - Bloodbeam spell that breaks open lockers/doors + double damage to victims - Gives them a Blood shield until they use Bloodbeam
 *	Level 5 - Bloodbeam spell that breaks open lockers/doors + double damage & steals blood - Gives them a Blood shield until they use Bloodbeam
 */

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy
	name = "Level 1: Thaumaturgy"
	upgraded_power = /datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/two
	desc = "Fire a blood bolt at your enemy, dealing Burn damage."
	level_current = 1
	button_icon_state = "power_thaumaturgy"
	power_explanation = "Thaumaturgy:\n\
		Gives you a one shot blood bolt spell, firing it at a person deals 20 Burn damage"
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_UNCONSCIOUS
	bloodcost = 20
	constant_bloodcost = 0
	cooldown_time = 6 SECONDS
	prefire_message = "Click where you wish to fire."
	///Blood shield given while this Power is active.
	var/datum/weakref/blood_shield

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/two
	name = "Level 2: Thaumaturgy"
	upgraded_power = /datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/three
	desc = "Create a Blood shield and fire a blood bolt at your enemy, dealing Burn damage."
	level_current = 2
	power_explanation = "Thaumaturgy:\n\
		Activating Thaumaturgy will temporarily give you a Blood Shield,\n\
		The blood shield has a 75% block chance, but costs 15 Blood per hit to maintain.\n\
		You will also have the ability to fire a Blood beam, ending the Power.\n\
		If the Blood beam hits a person, it will deal 20 Burn damage."
	prefire_message = "Click where you wish to fire (using your power removes blood shield)."
	bloodcost = 40
	cooldown_time = 4 SECONDS

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/three
	name = "Level 3: Thaumaturgy"
	upgraded_power = /datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/advanced
	desc = "Create a Blood shield and fire a blood bolt, dealing Burn damage and opening doors/lockers."
	level_current = 3
	power_explanation = "Thaumaturgy:\n\
		Activating Thaumaturgy will temporarily give you a Blood Shield,\n\
		The blood shield has a 75% block chance, but costs 15 Blood per hit to maintain.\n\
		You will also have the ability to fire a Blood beam, ending the Power.\n\
		If the Blood beam hits a person, it will deal 20 Burn damage. If it hits a locker or door, it will break it open."
	bloodcost = 50
	cooldown_time = 6 SECONDS

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/advanced
	name = "Level 4: Blood Strike"
	upgraded_power = /datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/advanced/two
	desc = "Create a Blood shield and fire a blood bolt, dealing Burn damage and opening doors/lockers."
	level_current = 4
	power_explanation = "Thaumaturgy:\n\
		Activating Thaumaturgy will temporarily give you a Blood Shield,\n\
		The blood shield has a 75% block chance, but costs 15 Blood per hit to maintain.\n\
		You will also have the ability to fire a Blood beam, ending the Power.\n\
		If the Blood beam hits a person, it will deal 40 Burn damage.\n\
		If it hits a locker or door, it will break it open."
	background_icon_state = "tremere_power_gold_off"
	active_background_icon_state = "tremere_power_gold_on"
	base_background_icon_state = "tremere_power_gold_off"
	prefire_message = "Click where you wish to fire (using your power removes blood shield)."
	bloodcost = 60
	cooldown_time = 6 SECONDS

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/advanced/two
	name = "Level 5: Blood Strike"
	upgraded_power = null
	desc = "Create a Blood shield and fire a blood bolt, dealing Burn damage, stealing Blood and opening doors/lockers."
	level_current = 5
	power_explanation = "Thaumaturgy:\n\
		Activating Thaumaturgy will temporarily give you a Blood Shield,\n\
		The blood shield has a 75% block chance, but costs 15 Blood per hit to maintain.\n\
		You will also have the ability to fire a Blood beam, ending the Power.\n\
		If the Blood beam hits a person, it will deal 40 Burn damage and steal blood to feed yourself, though at a net-negative.\n\
		If it hits a locker or door, it will break it open."
	bloodcost = 80
	cooldown_time = 8 SECONDS

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/ActivatePower(trigger_flags)
	. = ..()
	owner.balloon_alert(owner, "you start thaumaturgy")
	if(level_current >= 2) // Only if we're at least level 2.
		var/obj/item/shield/bloodsucker/new_shield = new
		blood_shield = WEAKREF(new_shield)
		if(!owner.put_in_inactive_hand(new_shield))
			owner.balloon_alert(owner, "off hand is full!")
			to_chat(owner, span_notice("Blood shield couldn't be activated as your off hand is full."))
			return FALSE
		owner.visible_message(
			span_warning("[owner]\'s hands begins to bleed and forms into a blood shield!"),
			span_warning("We activate our Blood shield!"),
			span_hear("You hear liquids forming together."),
		)

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/DeactivatePower()
	if(blood_shield)
		QDEL_NULL(blood_shield)
	return ..()

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/FireTargetedPower(atom/target_atom)
	. = ..()

	var/mob/living/user = owner
	owner.balloon_alert(owner, "you fire a blood bolt!")
	to_chat(user, span_warning("You fire a blood bolt!"))
	user.changeNext_move(CLICK_CD_RANGE)
	user.newtonian_move(get_dir(target_atom, user))
	var/obj/projectile/magic/arcane_barrage/bloodsucker/magic_9ball = new(user.loc)
	magic_9ball.bloodsucker_power = src
	magic_9ball.firer = user
	magic_9ball.def_zone = ran_zone(user.zone_selected)
	magic_9ball.preparePixelProjectile(target_atom, user)
	INVOKE_ASYNC(magic_9ball, TYPE_PROC_REF(/obj/projectile, fire))
	playsound(user, 'sound/magic/wand_teleport.ogg', 60, TRUE)
	power_activated_sucessfully()

/**
 * 	# Blood Bolt
 *
 *	This is the projectile this Power will fire.
 */
/obj/projectile/magic/arcane_barrage/bloodsucker
	name = "blood bolt"
	icon_state = "mini_leaper"
	damage = 20
	var/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/bloodsucker_power

/obj/projectile/magic/arcane_barrage/bloodsucker/on_hit(target, blocked, pierce_hit)
	if(istype(target, /obj/structure/closet) && bloodsucker_power.level_current >= 3)
		var/obj/structure/closet/hit_closet = target
		if(hit_closet)
			hit_closet.welded = FALSE
			hit_closet.locked = FALSE
			hit_closet.broken = TRUE
			hit_closet.update_appearance()
			qdel(src)
			return BULLET_ACT_HIT
	if(istype(target, /obj/machinery/door) && bloodsucker_power.level_current >= 3)
		var/obj/machinery/door/hit_airlock = target
		hit_airlock.open(2)
		qdel(src)
		return BULLET_ACT_HIT
	if(ismob(target))
		if(bloodsucker_power.level_current >= 4)
			damage = 40
		if(bloodsucker_power.level_current >= 5)
			var/mob/living/person_hit = target
			person_hit.blood_volume -= 60
			bloodsucker_power.bloodsuckerdatum_power.AddBloodVolume(60)
		qdel(src)
		return BULLET_ACT_HIT
	. = ..()

/**
 *	# Blood Shield
 *
 *	The shield spawned when using Thaumaturgy when strong enough.
 *	Copied mostly from '/obj/item/shield/changeling'
 */

/obj/item/shield/bloodsucker
	name = "blood shield"
	desc = "A shield made out of blood, requiring blood to sustain hits."
	item_flags = ABSTRACT | DROPDEL
	icon = 'monkestation/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "blood_shield"
	lefthand_file = 'monkestation/icons/bloodsuckers/bs_leftinhand.dmi'
	righthand_file = 'monkestation/icons/bloodsuckers/bs_rightinhand.dmi'
	block_chance = 75

/obj/item/shield/bloodsucker/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)

/obj/item/shield/bloodsucker/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum)
		bloodsuckerdatum.AddBloodVolume(-15)
	return ..()
