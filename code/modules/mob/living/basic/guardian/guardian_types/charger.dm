/**
 * Very fast, has a charging attack, and most importantly can be ridden like a horse.
 */
/mob/living/basic/guardian/charger
	guardian_type = GUARDIAN_CHARGER
	melee_damage_lower = 15
	melee_damage_upper = 15
	speed = -0.5
	damage_coeff = list(BRUTE = 0.75, BURN = 0.75, TOX = 0.75, CLONE = 0.75, STAMINA = 0, OXY = 0.75)
	playstyle_string = span_holoparasite("As a <b>charger</b> type you do medium damage, have light damage resistance, move very fast, can be ridden, and can charge at a location, damaging any target hit and forcing them to drop any items they are holding.")
	creator_name = "Charger"
	creator_desc = "Moves very fast, does medium damage on attack, can be ridden and can charge at targets, damaging the first target hit and forcing them to drop any items they are holding."
	creator_icon = "charger"

/mob/living/basic/guardian/charger/Initialize(mapload, datum/guardian_fluff/theme)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/creature/guardian)
	var/datum/action/cooldown/mob_cooldown/charge/guardian/charge = new(src)
	charge.Grant(src)

/// Guardian charger's charging attack, it knocks items out of people's hands
/datum/action/cooldown/mob_cooldown/charge/guardian
	name = "Charge!"
	cooldown_time = 4 SECONDS
	melee_cooldown_time = 0 SECONDS
	button_icon = 'icons/mob/actions/actions_elites.dmi'
	button_icon_state = "legionnaire_charge"
	charge_damage = 20
	unset_after_click = FALSE

/datum/action/cooldown/mob_cooldown/charge/guardian/can_hit_target(atom/movable/source, atom/target)
	var/mob/living/living_target = target
	if (!istype(living_target))
		return FALSE
	var/mob/living/basic/guardian/guardian_owner = owner
	if (!istype(guardian_owner))
		return TRUE
	if (living_target == guardian_owner.summoner || guardian_owner.shares_summoner(target))
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/charge/basic_charge/guardian/hit_target(atom/movable/source, mob/living/target, damage_dealt)
	if(ishuman(target))
		var/mob/living/carbon/human/hit_human = target
		if(hit_human.check_shields(src, charge_damage, name, attack_type = LEAP_ATTACK))
			return
	. = ..()
	var/mob/living/hit_mob = target
	hit_mob.drop_all_held_items()
