/// Cowardly mob with a charging attack
/mob/living/basic/mining/lobstrosity
	name = "arctic lobstrosity"
	desc = "These hairy crustaceans creep and multiply in underground lakes deep below the ice. They have a particular taste for fingers."
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "arctic_lobstrosity"
	icon_living = "arctic_lobstrosity"
	icon_dead = "arctic_lobstrosity_dead"
	friendly_verb_continuous = "chitters at"
	friendly_verb_simple = "chitters at"
	speak_emote = list("chitters")
	maxHealth = 150
	health = 150
	obj_damage = 15
	mob_biotypes = MOB_ORGANIC|MOB_CRUSTACEAN|MOB_AQUATIC|MOB_MINING
	melee_damage_lower = 15
	melee_damage_upper = 19
	attack_verb_continuous = "snips"
	attack_verb_simple = "snip"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE // Closer than a scratch to a crustacean pinching effect
	melee_attack_cooldown = 1 SECONDS
	butcher_results = list(
		/obj/item/food/meat/slab/rawcrab = 2,
		/obj/item/stack/sheet/bone = 2,
		/obj/item/organ/monster_core/rush_gland = 1,
	)
	crusher_loot = /obj/item/crusher_trophy/lobster_claw
	ai_controller = /datum/ai_controller/basic_controller/lobstrosity
	/// Charging ability
	var/datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster/charge
	/// The type of charging ability we give this mob
	var/charge_type = /datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster
	/// The pet command for the charging ability we give this mob
	var/charge_command = /datum/pet_command/use_ability/lob_charge
	/// At which speed do we amputate limbs
	var/snip_speed = 5 SECONDS
	///Lobstrosities are natural anglers. This rapresent their proficiency at fishing when not mindless
	var/base_fishing_level = SKILL_LEVEL_APPRENTICE
	/// Things we will eat if we see them (arms, chiefly)
	var/static/list/target_foods = list(/obj/item/bodypart/arm, /obj/item/fish/lavaloop)

/mob/living/basic/mining/lobstrosity/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_NODROWN, TRAIT_SWIMMER), INNATE_TRAIT)
	AddComponent(/datum/component/profound_fisher)
	AddElement(/datum/element/mob_grabber)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/basic_eating, food_types = target_foods)
	AddComponent(/datum/component/speechmod, replacements = strings("crustacean_replacement.json", "crustacean"))
	AddComponent(\
		/datum/component/amputating_limbs,\
		surgery_time = snip_speed, \
		surgery_verb = "begins snipping",\
		target_zones = GLOB.arm_zones,\
	)
	charge = new charge_type(src)
	charge.Grant(src)
	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, charge)
	var/static/list/fishable_turfs = typecacheof(list(/turf/open/lava))
	ai_controller.set_blackboard_key(BB_FISHABLE_LIST, fishable_turfs)

/mob/living/basic/mining/lobstrosity/Destroy()
	QDEL_NULL(charge)
	return ..()

/mob/living/basic/mining/lobstrosity/ranged_secondary_attack(atom/atom_target, modifiers)
	charge.Trigger(target = atom_target)

/mob/living/basic/mining/lobstrosity/tamed(mob/living/tamer, obj/item/food)
	new /obj/effect/temp_visual/heart(loc)
	/// Pet commands for this mob, however you'll have to tame juvenile lobstrosities to a trained adult one.
	var/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/move,
		/datum/pet_command/attack,
		charge_command,
		/datum/pet_command/follow/start_active,
		/datum/pet_command/fish,
	)
	AddComponent(/datum/component/happiness)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	ai_controller.ai_traits |= STOP_MOVING_WHEN_PULLED
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"

/mob/living/basic/mining/lobstrosity/befriend(mob/living/new_friend)
	. = ..()
	if(isnull(.))
		return
	faction |= new_friend.faction
	faction -= FACTION_MINING

/mob/living/basic/mining/lobstrosity/mind_initialize()
	. = ..()
	if(mind.get_skill_level(/datum/skill/fishing) < base_fishing_level)
		mind.set_level(/datum/skill/fishing, base_fishing_level, TRUE)

/// Lavaland lobster variant, it basically just looks different
/mob/living/basic/mining/lobstrosity/lava
	name = "chasm lobstrosity"
	desc = "Twitching crustaceans boiled red by the sulfurous fumes of the chasms in which they lurk. They have a particular taste for fingers."
	icon_state = "lobstrosity"
	icon_living = "lobstrosity"
	icon_dead = "lobstrosity_dead"

/// Charge a long way, knock down for longer, and perform an instant melee attack
/datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster
	name = "Lobster Rush"
	charge_distance = 8
	knockdown_duration = 2.5 SECONDS

/datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster/hit_target(atom/movable/source, atom/target, damage_dealt)
	. = ..()
	if(!isbasicmob(source) || !isliving(target))
		return
	var/mob/living/basic/basic_source = source
	var/mob/living/living_target = target
	basic_source.melee_attack(living_target, ignore_cooldown = TRUE)
	basic_source.ai_controller?.set_blackboard_key(BB_BASIC_MOB_STOP_FLEEING, TRUE)
	basic_source.start_pulling(living_target)

/datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster/do_charge(atom/movable/charger, atom/target_atom, delay, past)
	. = ..()
	if(!isliving(charger))
		return
	apply_post_charge(charger)

/datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster/proc/apply_post_charge(mob/living/charger)
	charger.apply_status_effect(/datum/status_effect/tired_post_charge)

///A weaker, yet somewhat faster lobstrosity. Sources include aquarium chasm chrabs, chasms, plasma rivers and perhaps xenobio.
/mob/living/basic/mining/lobstrosity/juvenile
	name = "juvenile arctic lobstrosity"
	desc = "A youngling of the behemothic arctic lobstrosity. They usually stay put in the underground lakes they reside in until they're fully grown."
	icon_state = "arctic_juveline_lobstrosity"
	icon_living = "arctic_juveline_lobstrosity"
	icon_dead = "arctic_juveline_lobstrosity_dead"
	status_flags = parent_type::status_flags | CANPUSH
	maxHealth = 65
	health = 65
	obj_damage = 6
	melee_damage_lower = 6
	melee_damage_upper = 9
	melee_attack_cooldown = 0.9 SECONDS
	speed = 0.7
	mob_size = MOB_SIZE_HUMAN
	butcher_results = list(
		/obj/item/food/meat/slab/rawcrab = 1,
		/obj/item/stack/sheet/bone = 1,
		/obj/item/organ/monster_core/rush_gland = 1,
	)
	crusher_loot = null
	ai_controller = /datum/ai_controller/basic_controller/lobstrosity/juvenile
	snip_speed = 6.5 SECONDS
	charge_type = /datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster/shrimp
	charge_command = /datum/pet_command/use_ability/lob_charge/shrimp
	base_fishing_level = SKILL_LEVEL_NOVICE
	/// What do we become when we grow up?
	var/mob/living/basic/mining/lobstrosity/grow_type = /mob/living/basic/mining/lobstrosity
	/// Were we tamed? If yes, tame the mob we become when we grow up too.
	var/was_tamed = FALSE

/datum/emote/lobstrosity_juvenile
	mob_type_allowed_typecache = /mob/living/basic/mining/lobstrosity/juvenile
	mob_type_blacklist_typecache = list()

/datum/emote/lobstrosity_juvenile/chitter
	key = "chitter"
	key_third_person = "chitters"
	message = "chitters pleasantly!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	sound = 'sound/mobs/non-humanoids/insect/chitter.ogg'

/mob/living/basic/mining/lobstrosity/juvenile/Initialize(mapload)
	. = ..()
	var/growth_step = 1000/(7 MINUTES) //It should take 7-ish minutes if you keep the happiness above 40% and at most 12
	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_path = grow_type,\
		growth_probability = 58,\
		lower_growth_value = growth_step,\
		upper_growth_value = growth_step,\
		scale_with_happiness = TRUE,\
		optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
		optional_grow_behavior = CALLBACK(src, PROC_REF(grow_up))\
	)
	AddComponent(/datum/component/tameable, tame_chance = 35, bonus_tame_chance = 20)
	AddComponent(/datum/component/swarming, 16, 11)
	ADD_TRAIT(src, TRAIT_MOB_HIDE_HAPPINESS, INNATE_TRAIT) //Do not let strangers know it gets happy when poked if stray.

/mob/living/basic/mining/lobstrosity/juvenile/add_ranged_armour(list/vulnerable_projectiles)
	AddElement(\
		/datum/element/ranged_armour,\
		minimum_projectile_force = 30,\
		below_projectile_multiplier = 0.6,\
		vulnerable_projectile_types = vulnerable_projectiles,\
		minimum_thrown_force = 13,\
		throw_blocked_message = throw_blocked_message,\
	)

#define MAX_JUVENILES_ALLOWED_ON_TURF 3

///Juvenile lobstrosities can swarm and pass through each other, but only 3 at most can stand the same turf.
/mob/living/basic/mining/lobstrosity/juvenile/CanAllowThrough(atom/movable/mover, border_dir)
	if(!istype(mover, /mob/living/basic/mining/lobstrosity/juvenile))
		return ..()
	var/juveniles_count = 0
	for(var/mob/living/basic/mining/lobstrosity/juvenile/lob in loc)
		juveniles_count++
		if(juveniles_count > MAX_JUVENILES_ALLOWED_ON_TURF)
			return ..()
	return TRUE

#undef MAX_JUVENILES_ALLOWED_ON_TURF

/mob/living/basic/mining/lobstrosity/juvenile/tamed(mob/living/tamer, obj/item/food)
	. = ..()
	was_tamed = TRUE
	// They are more pettable I guess
	AddElement(/datum/element/pet_bonus, "chitter")
	REMOVE_TRAIT(src, TRAIT_MOB_HIDE_HAPPINESS, INNATE_TRAIT)

/mob/living/basic/mining/lobstrosity/juvenile/proc/ready_to_grow()
	return isturf(loc)

/mob/living/basic/mining/lobstrosity/juvenile/proc/grow_up()
	var/name_to_use = name == initial(name) ? grow_type::name : name
	var/mob/living/basic/mining/lobstrosity/grown = change_mob_type(grow_type, get_turf(src), name_to_use)
	if(was_tamed)
		grown.tamed()
	for(var/friend in ai_controller?.blackboard?[BB_FRIENDS_LIST])
		grown.befriend(friend)
	grown.setBruteLoss(getBruteLoss())
	grown.setFireLoss(getFireLoss())
	qdel(src) //We called change_mob_type without 'delete_old_mob = TRUE' since we had to pass down friends and damage

/mob/living/basic/mining/lobstrosity/juvenile/lava
	name = "juvenile chasm lobstrosity"
	desc = "A youngling of the behemothic lobstrosity. They usually don't crawl out of the vents they reside in until they're fully grown."
	icon_state = "juveline_lobstrosity"
	icon_living = "juveline_lobstrosity"
	icon_dead = "juveline_lobstrosity_dead"
	grow_type = /mob/living/basic/mining/lobstrosity/lava

/// Shorter, weaker version of the Lobster Rush
/datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster/shrimp
	name = "Shrimp Rush"
	charge_distance = 4
	knockdown_duration = 1.8 SECONDS
	charge_delay = 0.2 SECONDS
	charge_damage = 13

/datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster/apply_post_charge(mob/living/charger)
	charger.apply_status_effect(/datum/status_effect/tired_post_charge/lesser)

///Command the lobster to charge at someone.
/datum/pet_command/use_ability/lob_charge
	command_name = "Charge"
	command_desc = "Command your lobstrosity to charge against someone."
	radial_icon = 'icons/mob/actions/actions_items.dmi'
	radial_icon_state = "sniper_zoom"
	speech_commands = list("charge", "slam", "tackle")
	command_feedback = "growl"
	pointed_reaction = "and growls"
	pet_ability_key = BB_TARGETED_ACTION
	ability_behavior = /datum/ai_behavior/pet_use_ability/then_attack/long_ranged

/datum/pet_command/use_ability/lob_charge/set_command_target(mob/living/parent, atom/target)
	if (!target)
		return FALSE
	var/datum/targeting_strategy/targeter = GET_TARGETING_STRATEGY(parent.ai_controller.blackboard[targeting_strategy_key])
	if(!targeter?.can_attack(parent, target))
		parent.balloon_alert_to_viewers("shakes head!")
		return FALSE
	return ..()

/datum/pet_command/use_ability/lob_charge/shrimp
	ability_behavior = /datum/ai_behavior/pet_use_ability/then_attack/short_ranged
