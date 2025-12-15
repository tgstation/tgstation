#define WRIST_WRENCH_COMBO "HG"
#define LAUNCH_KICK_COMBO "HD"
#define DROP_KICK_COMBO "DD"
#define KNEE_STOMACH_COMBO "GH"

/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	id = MARTIALART_SLEEPINGCARP
	help_verb = /mob/living/proc/sleeping_carp_help
	display_combos = TRUE
	grab_state_modifier = 1
	/// List of traits applied to users of this martial art.
	var/list/scarp_traits = list(TRAIT_NOGUNS, TRAIT_TOSS_GUN_HARD, TRAIT_HARDLY_WOUNDED, TRAIT_NODISMEMBER, TRAIT_HEAVY_SLEEPER, TRAIT_PERFECT_ATTACKER)
	/// List of objects exempt from reducing dodge probabilities
	var/list/exempt_objects = list(
		/obj/item/melee/baton/nunchaku,
		/obj/item/staff/bostaff,
		/obj/item/bambostaff,
		/obj/item/cane,
		/obj/item/nullrod/bostaff,
		/obj/item/knife,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/storage/toolbox,
		/obj/item/spear,
		/obj/item/claymore/shortsword,
		/obj/item/nullrod/nullblade,
		/obj/item/extendohand,
		/obj/item/mop,
		/obj/item/pushbroom,
		/obj/item/melee/baseball_bat,
		/obj/item/crowbar/hammer,
		/obj/item/toy/plush/carpplushie,
	)

/datum/martial_art/the_sleeping_carp/activate_style(mob/living/new_holder)
	. = ..()
	new_holder.add_traits(scarp_traits, SLEEPING_CARP_TRAIT)
	RegisterSignal(new_holder, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(new_holder, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(hit_by_projectile))
	RegisterSignal(new_holder, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(check_dodge))
	new_holder.faction |= FACTION_CARP //:D
	new_holder.grant_language(/datum/language/carptongue, ALL, type)

/datum/martial_art/the_sleeping_carp/deactivate_style(mob/living/remove_from)
	remove_from.remove_traits(scarp_traits, SLEEPING_CARP_TRAIT)
	UnregisterSignal(remove_from, list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_PRE_BULLET_ACT, COMSIG_LIVING_CHECK_BLOCK))
	remove_from.faction -= FACTION_CARP //:(
	remove_from.remove_language(/datum/language/carptongue, ALL, type)
	return ..()

/datum/martial_art/the_sleeping_carp/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak,WRIST_WRENCH_COMBO))
		reset_streak()
		return wrist_wrench(attacker, defender)

	if(findtext(streak,LAUNCH_KICK_COMBO))
		reset_streak()
		return launch_kick(attacker, defender)

	if(findtext(streak,DROP_KICK_COMBO))
		reset_streak()
		return drop_kick(attacker, defender)

	if(findtext(streak,KNEE_STOMACH_COMBO))
		reset_streak()
		return knee_stomach(attacker, defender)

	return FALSE

/// Gnashing Teeth: Harm Grab, twists and possibly breaks the target's arm, disarming them.
/datum/martial_art/the_sleeping_carp/proc/wrist_wrench(mob/living/attacker, mob/living/defender)
	// Determine if our defender is a carbon. If not, we don't wrist wrench
	if(!iscarbon(defender))
		return FALSE

	// Determine if our target has a functioning active arm. If not, return.
	var/obj/item/bodypart/affecting = defender.get_active_hand()

	if(!affecting)
		return FALSE

	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.visible_message(
		span_danger("[attacker] violently twists [defender]'s [affecting]!"),
		span_userdanger("[attacker] violently twists your [affecting]!"),
		span_hear("You hear a sickening sound of bone snapping!"),
		null,
		attacker,
	)
	to_chat(attacker, span_danger("You violently twist [defender]'s [affecting]!"))
	playsound(defender, 'sound/items/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(attacker, defender, "wrist wrenched (Sleeping Carp)")
	defender.apply_damage(20, BRUTE, affecting, wound_bonus = 30)
	defender.drop_all_held_items()
	return TRUE

/// Crashing Wave Kick: Harm Disarm combo, throws people seven tiles backwards
/datum/martial_art/the_sleeping_carp/proc/launch_kick(mob/living/attacker, mob/living/defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
	defender.visible_message(
		span_warning("[attacker] kicks [defender] square in the chest, sending them flying!"),
		span_userdanger("You are kicked square in the chest by [attacker], sending you flying!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)
	playsound(attacker, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	var/atom/throw_target = get_edge_target_turf(defender, attacker.dir)
	defender.throw_at(throw_target, 7, 4, attacker)
	defender.apply_damage(15, attacker.get_attack_type(), BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
	log_combat(attacker, defender, "launchkicked (Sleeping Carp)")
	return TRUE

/// Keelhaul: Disarm Disarm combo, knocks people down and deals substantial stamina damage, and also discombobulates them. Knocks objects out of their hands if they're already on the ground.
/datum/martial_art/the_sleeping_carp/proc/drop_kick(mob/living/attacker, mob/living/defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
	playsound(attacker, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	if(defender.body_position == STANDING_UP)
		defender.Knockdown(4 SECONDS)
		defender.visible_message(span_warning("[attacker] kicks [defender] in the head, sending them face first into the floor!"), \
					span_userdanger("You are kicked in the head by [attacker], sending you crashing to the floor!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
	else
		defender.drop_all_held_items()
		defender.visible_message(span_warning("[attacker] kicks [defender] in the head!"), \
					span_userdanger("You are kicked in the head by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
	defender.apply_damage(40, STAMINA)
	defender.adjust_dizzy_up_to(10 SECONDS, 10 SECONDS)
	defender.adjust_temp_blindness_up_to(2 SECONDS, 10 SECONDS)
	log_combat(attacker, defender, "dropkicked (Sleeping Carp)")
	return TRUE

/// Kraken Wrack: Grab Harm combo, causes them to be silenced and briefly stunned, as well as doing a moderate amount of stamina damage.
/datum/martial_art/the_sleeping_carp/proc/knee_stomach(mob/living/attacker, mob/living/defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
	playsound(attacker, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	defender.visible_message(
		span_warning("[attacker] violently slams [attacker.p_their()] knee into [defender]!"),
		span_userdanger("You slam your knee straight into [defender]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)
	defender.apply_damage(20, STAMINA)
	defender.Paralyze(1 SECONDS)
	defender.adjust_silence_up_to(5 SECONDS, 5 SECONDS)
	if(defender.losebreath <= 10)
		defender.losebreath = clamp(defender.losebreath + 5, 0, 10)
	log_combat(attacker, defender, "kneed in the stomach (Sleeping Carp)")
	return TRUE

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/attacker, mob/living/defender)
	if(!can_deflect(attacker)) //allows for deniability
		return MARTIAL_ATTACK_INVALID

	if(defender.check_block(attacker, 0, "[attacker]'s grab", UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("G", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	var/grab_log_description = "grabbed"
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	playsound(defender, 'sound/items/weapons/punch1.ogg', 25, TRUE, -1)
	if(defender.stat != DEAD && !defender.IsUnconscious() && defender.get_stamina_loss() >= 80) //We put our target to sleep.
		defender.visible_message(
			span_danger("[attacker] carefully pinch a nerve in [defender]'s neck, knocking them out cold!"),
			span_userdanger("[attacker] pinches something in your neck, and you fall unconscious!"),
		)
		grab_log_description = "grabbed and nerve pinched"
		defender.Unconscious(10 SECONDS)
	defender.apply_damage(20, STAMINA)
	log_combat(attacker, defender, "[grab_log_description] (Sleeping Carp)")
	return MARTIAL_ATTACK_INVALID // normal grab

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/attacker, mob/living/defender)
	if(attacker.grab_state == GRAB_KILL \
		&& attacker.zone_selected == BODY_ZONE_HEAD \
		&& attacker.pulling == defender \
		&& defender.stat != DEAD \
	)
		var/obj/item/bodypart/head = defender.get_bodypart(BODY_ZONE_HEAD)
		if(!isnull(head))
			playsound(defender, 'sound/effects/wounds/crack1.ogg', 100)
			defender.visible_message(
				span_danger("[attacker] snaps the neck of [defender]!"),
				span_userdanger("Your neck is snapped by [attacker]!"),
				span_hear("You hear a sickening snap!"),
				ignored_mobs = attacker
			)
			to_chat(attacker, span_danger("In a swift motion, you snap the neck of [defender]!"))
			log_combat(attacker, defender, "snapped neck")
			defender.apply_damage(100, BRUTE, BODY_ZONE_HEAD, wound_bonus=CANT_WOUND)
			if(!HAS_TRAIT(defender, TRAIT_NODEATH))
				defender.death()
				defender.investigate_log("has had [defender.p_their()] neck snapped by [attacker].", INVESTIGATE_DEATHS)
			return MARTIAL_ATTACK_SUCCESS

	if(defender.check_block(attacker, 10, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	return MARTIAL_ATTACK_INVALID // normal punch

/datum/martial_art/the_sleeping_carp/disarm_act(mob/living/attacker, mob/living/defender)
	if(!can_deflect(attacker)) //allows for deniability
		return MARTIAL_ATTACK_INVALID
	if(defender.check_block(attacker, 0, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("D", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	playsound(defender, 'sound/items/weapons/punch1.ogg', 25, TRUE, -1)
	defender.apply_damage(20, STAMINA)
	log_combat(attacker, defender, "disarmed (Sleeping Carp)")
	return MARTIAL_ATTACK_INVALID // normal disarm

/datum/martial_art/the_sleeping_carp/proc/can_deflect(mob/living/carp_user)
	if(!can_use(carp_user) || !carp_user.combat_mode)
		return FALSE
	if(INCAPACITATED_IGNORING(carp_user, INCAPABLE_GRAB)) //NO STUN
		return FALSE
	if(!(carp_user.mobility_flags & MOBILITY_USE)) //NO UNABLE TO USE
		return FALSE
	if(HAS_TRAIT(carp_user, TRAIT_HULK)) //NO HULK
		return FALSE
	if(!isturf(carp_user.loc)) //NO MOTHERFLIPPIN MECHS!
		return FALSE
	return TRUE

/datum/martial_art/the_sleeping_carp/proc/hit_by_projectile(mob/living/carp_user, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER

	var/determine_avoidance = 100
	var/additional_adjustments = 0

	if(istype(hitting_projectile, /obj/projectile/bullet/c38/match/true)) // 75% chance to ignore evasion
		additional_adjustments -= 75

	determine_avoidance = clamp(determine_avoidance + carp_style_check(carp_user) + additional_adjustments, 0, 100)

	if(istype(hitting_projectile, /obj/projectile/bullet/harpoon)) // WHITE WHALE HOLY GRAIL
		return NONE

	if(!can_deflect(carp_user))
		return NONE

	if(!prob(determine_avoidance))
		return NONE



	carp_user.visible_message(
		span_danger("[carp_user] effortlessly swats [hitting_projectile] aside! [carp_user.p_They()] can block bullets with [carp_user.p_their()] bare hands!"),
		span_userdanger("You deflect [hitting_projectile]!"),
	)
	playsound(carp_user, SFX_BULLET_MISS, 75, TRUE)
	hitting_projectile.firer = carp_user
	hitting_projectile.set_angle(rand(0, 360))//SHING
	return COMPONENT_BULLET_PIERCED

/// Signal from getting attacked with an item, for a special interaction with touch spells
/datum/martial_art/the_sleeping_carp/proc/on_attackby(mob/living/carp_user, obj/item/attack_weapon, mob/attacker, list/modifiers)
	SIGNAL_HANDLER

	if(!istype(attack_weapon, /obj/item/melee/touch_attack))
		return
	if(!can_deflect(carp_user))
		return
	var/obj/item/melee/touch_attack/touch_weapon = attack_weapon
	carp_user.visible_message(
		span_danger("[carp_user] carefully dodges [attacker]'s [touch_weapon]!"),
		span_userdanger("You take great care to remain untouched by [attacker]'s [touch_weapon]!"),
	)
	return COMPONENT_NO_AFTERATTACK

/// If our user has committed to being as martial arty as they can be, they may be able to avoid incoming attacks.
/datum/martial_art/the_sleeping_carp/proc/check_dodge(mob/living/carp_user, atom/movable/hitby, damage, attack_text, attack_type, ...)
	SIGNAL_HANDLER

	var/determine_avoidance = clamp(round(carp_style_check(carp_user) / (attack_type == OVERWHELMING_ATTACK ? 2 : 1), 1), 0, 75)

	if(!can_deflect(carp_user))
		return

	if(attack_type == PROJECTILE_ATTACK || attack_type == THROWN_PROJECTILE_ATTACK)
		return NONE

	if(!prob(determine_avoidance))
		return NONE

	carp_user.visible_message(
		span_danger("[carp_user] cleanly avoids [attack_text] with incredible speed!"),
		span_userdanger("You dodge [attack_text]"),
	)
	playsound(carp_user.loc, 'sound/items/weapons/punchmiss.ogg', 25, TRUE, -1)
	return SUCCESSFUL_BLOCK

/* Determines how 'carp-y' or how 'martial arts-y' we are, granting us the ability to avoid attacks.
* At a baseline, we will always avoid projectile attacks, but we may not necessarily avoid other attacks.
* If we wear carp based clothing, or martial arts based clothing, we improve our style factor.
* If we are a carp mutant, we improve our style factor.
* If we literally are a carp, we just assume we're very carpy and return our max value.
* If we wear a lot of armor, we reduce our style factor. Some martial arts or carp items may result in a net netural bonus.
* If there is anything in our hands, we're also less likely to avoid attacks.
*/
/datum/martial_art/the_sleeping_carp/proc/carp_style_check(mob/living/carp_user)
	// An evaluation of how 'carp' we are.
	var/style_factor_points = 0

	if(istype(carp_user, /mob/living/basic/space_dragon) || istype(carp_user, /mob/living/basic/carp))
		return 100

	if(!ishuman(carp_user)) // We're not concerned about nonhumans here, we can assume we've covered any relevant mobs by checking for carp.
		return 0

	var/mob/living/carbon/human/human_carp_user = carp_user

	var/obj/item/bodypart/potential_head = human_carp_user.get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/bodypart/potential_chest = human_carp_user.get_bodypart(BODY_ZONE_CHEST)
	var/obj/item/clothing/is_it_the_shoes = human_carp_user.get_item_by_slot(ITEM_SLOT_FEET)

	// The presence of armor and heavy objects is a style malus
	var/style_factor_malus = 0

	// Lets look to see if any relevant headwear is armored or on theme
	if(potential_head)
		for(var/obj/item/clothing/possible_headbands in human_carp_user.get_clothing_on_part(potential_head))
			if(possible_headbands.clothing_flags & CARP_STYLE_FACTOR)
				style_factor_points += 20 // Basically, you only need one chest level item to contribute
		style_factor_malus += human_carp_user.run_armor_check(potential_head, MELEE)

	// Then let's look for any chest clothing that is either armored or on theme
	if(potential_chest)
		for(var/obj/item/clothing/possible_gi in human_carp_user.get_clothing_on_part(potential_chest))
			if(possible_gi.clothing_flags & CARP_STYLE_FACTOR)
				style_factor_points += 20 // Only need one head level item to contribute
		style_factor_malus += human_carp_user.run_armor_check(potential_chest, MELEE)

	// We also consider whether our footwear is appropriate
	if(istype(is_it_the_shoes) && is_it_the_shoes.clothing_flags & CARP_STYLE_FACTOR)
		style_factor_points += 20

	// Achieved a carp state of mind.
	if(human_carp_user.has_status_effect(/datum/status_effect/organ_set_bonus/carp))
		style_factor_points += 20

	// We check for wielded objects. If they're not abstract items or exempt items, we add their weight as a penalty. And their block chance.
	for(var/obj/item/possibly_a_held_object in human_carp_user.held_items)
		if(possibly_a_held_object.item_flags & (ABSTRACT|HAND_ITEM) && !possibly_a_held_object.block_chance)
			continue

		if(possibly_a_held_object in exempt_objects)
			continue

		if(possibly_a_held_object.w_class <= WEIGHT_CLASS_SMALL && !possibly_a_held_object.block_chance)
			continue

		style_factor_malus += possibly_a_held_object.block_chance
		style_factor_malus += possibly_a_held_object.w_class * 10 * (HAS_TRAIT(possibly_a_held_object, TRAIT_WIELDED) ? 2 : 1)

	if(human_carp_user.body_position != STANDING_UP) // this ain't monkey style
		style_factor_points -= 30

	style_factor_points -= style_factor_malus

	return style_factor_points

/// Verb added to humans who learn the art of the sleeping carp.
/mob/living/proc/sleeping_carp_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Sleeping Carp clan."
	set category = "Sleeping Carp"

	to_chat(usr, span_info("<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>\n\
	[span_notice("Gnashing Teeth")]: Punch Grab. Violently twists your opponent's arm, dislocating or even shattering bone and forcing them to drop their held items.\n\
	[span_notice("Crashing Wave Kick")]: Punch Shove. Launch your opponent away from you with incredible force!\n\
	[span_notice("Keelhaul")]: Shove Shove. Nonlethally kick an opponent to the floor, knocking them down, discombobulating them and dealing substantial stamina damage. If they're already prone, disarm them as well.\n\
	[span_notice("Kraken Wrack")]: Grab Punch. Deliver a knee jab into the opponent, dealing high stamina damage, as well as briefly stunning them, winding them and making it difficult for them to speak.\n\
	[span_notice("Grabs and Shoves")]: While in combat mode, your typical grab and shove do decent stamina damage, and your grabs harder to break. If you grab someone who has substantial amounts of stamina damage, you knock them out!\n\
	<span class='notice'>While in combat mode (and not stunned, not a hulk, and not in a mech), you can reflect all projectiles that come your way, sending them back at the people who fired them! \n\
	However, your ability to avoid projectiles is negatively affected when your are burdened by armor, or whenever you are carrying normal-sized or heavier objects in your hands. \n\
	But if you commmit fully to the martial arts lifestyle by wearing martial arts or carp-related regalia, you will feel empowered enough to potentially avoid attacks even from melee weapons or other unarmed combatants. \n\
	Some melee weapons, such as bo starves, spears, short blades, knives, toolboxes, baseball bats and non-blocking small objects are safe to carry without affecting your ability to defend yourself. Exploit this for a tactical advantage. \n\
	Also, you are more resilient against suffering wounds in combat, and your limbs cannot be dismembered. This grants you extra staying power during extended combat, especially against slashing and other bleeding weapons. \n\
	You are not invincible, however- while you may not suffer debilitating wounds often, you must still watch your health and should have appropriate medical supplies for use during downtime. \n\
	In addition, your training has imbued you with a loathing of guns, and you can no longer use them.</span>"))

/obj/item/staff/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 2
	attack_verb_continuous = list("smashes", "slams", "whacks", "thwacks")
	attack_verb_simple = list("smash", "slam", "whack", "thwack")
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "bostaff0"
	base_icon_state = "bostaff"
	icon_angle = -135
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	block_chance = 50

/obj/item/staff/bostaff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 10, \
		force_wielded = 24, \
	)

/obj/item/staff/bostaff/update_icon_state()
	icon_state = inhand_icon_state = "[base_icon_state][HAS_TRAIT(src, TRAIT_WIELDED)]"
	return ..()

/obj/item/staff/bostaff/attack(mob/target, mob/living/user, list/modifiers, list/attack_modifiers)
	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, span_warning("You club yourself over the head with [src]."))
		user.Paralyze(6 SECONDS)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, span_warning("It would be dishonorable to attack a foe while they cannot retaliate."))
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(!HAS_TRAIT(src, TRAIT_WIELDED))
			return ..()
		if(!ishuman(target))
			return ..()
		var/mob/living/carbon/human/H = target
		var/list/fluffmessages = list("club", "smack", "broadside", "beat", "slam")
		H.visible_message(span_warning("[user] [pick(fluffmessages)]s [H] with [src]!"), \
						span_userdanger("[user] [pick(fluffmessages)]s you with [src]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
		to_chat(user, span_danger("You [pick(fluffmessages)] [H] with [src]!"))
		playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, TRUE, -1)
		H.adjust_stamina_loss(rand(13,20))
		if(prob(10))
			H.visible_message(span_warning("[H] collapses!"), \
							span_userdanger("Your legs give out!"))
			H.Paralyze(8 SECONDS)
		if(H.staminaloss && !H.IsSleeping())
			var/total_health = (H.health - H.staminaloss)
			if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
				H.visible_message(span_warning("[user] delivers a heavy hit to [H]'s head, knocking [H.p_them()] out cold!"), \
								span_userdanger("You're knocked unconscious by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
				to_chat(user, span_danger("You deliver a heavy hit to [H]'s head, knocking [H.p_them()] out cold!"))
				H.SetSleeping(60 SECONDS)
				H.adjust_organ_loss(ORGAN_SLOT_BRAIN, 15, 150)
	else
		return ..()

/obj/item/staff/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()
	return FALSE

/obj/item/clothing/gloves/the_sleeping_carp
	name = "carp gloves"
	desc = "These gloves are capable of making people use The Sleeping Carp."
	icon_state = "black"
	greyscale_colors = COLOR_BLACK
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/gloves/the_sleeping_carp/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/martial_art_giver, /datum/martial_art/the_sleeping_carp)

#undef WRIST_WRENCH_COMBO
#undef LAUNCH_KICK_COMBO
#undef DROP_KICK_COMBO
#undef KNEE_STOMACH_COMBO
