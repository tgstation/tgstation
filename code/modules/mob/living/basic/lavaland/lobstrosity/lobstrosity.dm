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
	melee_damage_lower = 15
	melee_damage_upper = 19
	attack_verb_continuous = "snips"
	attack_verb_simple = "snip"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE // Closer than a scratch to a crustacean pinching effect
	melee_attack_cooldown = 1 SECONDS
	butcher_results = list(
		/obj/item/food/meat/slab/rawcrab = 2,
		/obj/item/stack/sheet/bone = 2,
		/obj/item/organ/internal/monster_core/rush_gland = 1,
	)
	crusher_loot = /obj/item/crusher_trophy/lobster_claw
	ai_controller = /datum/ai_controller/basic_controller/lobstrosity
	/// Charging ability
	var/datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster/charge
	/// The type of charging ability we give this mob
	var/charge_type = /datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster
	/// At which speed do we amputate limbs
	var/snip_speed = 5 SECONDS
	/// Things we will eat if we see them (arms, chiefly)
	var/static/list/target_foods = list(/obj/item/bodypart/arm, /obj/item/fish/lavaloop)

/mob/living/basic/mining/lobstrosity/Initialize(mapload)
	. = ..()
	var/static/list/food_types = list(/obj/item/fish/lavaloop)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(food_types))
	var/static/list/fishing_preset = list(
		/turf/open/lava = /datum/fish_source/lavaland,
		/turf/open/lava/plasma = /datum/fish_source/lavaland/icemoon,
	)
	AddComponent(/datum/component/profound_fisher, npc_fishing_preset = fishing_preset)
	AddElement(/datum/element/mob_grabber)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/basic_eating, food_types = target_foods)
	AddComponent(\
		/datum/component/amputating_limbs,\
		surgery_time = snip_speed, \
		surgery_verb = "begins snipping",\
		target_zones = GLOB.arm_zones,\
	)
	charge = new charge_type(src)
	charge.Grant(src)
	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, charge)

/mob/living/basic/mining/lobstrosity/Destroy()
	QDEL_NULL(charge)
	return ..()

/mob/living/basic/mining/lobstrosity/ranged_secondary_attack(atom/atom_target, modifiers)
	charge.Trigger(target = atom_target)

/mob/living/basic/mining/lobstrosity/tamed(mob/living/tamer, obj/item/food)
	new /obj/effect/temp_visual/heart(loc)
	/// Pet commands for this mob, however you'll have to tame juvenile lobstrosities to a trained adult one.
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/point_targeting/attack,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/fish,
	)

	AddComponent(/datum/component/obeys_commands, pet_commands)
	ai_controller.ai_traits = STOP_MOVING_WHEN_PULLED

/mob/living/basic/mining/lobstrosity/befriend(mob/living/new_friend)
	. = ..()
	faction |= new_friend.faction
	faction -= FACTION_MINING

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
	maxHealth = 65
	health = 65
	obj_damage = 6
	melee_damage_lower = 6
	melee_damage_upper = 9
	melee_attack_cooldown = 0.9 SECONDS
	mob_size = MOB_SIZE_HUMAN
	butcher_results = list(
		/obj/item/food/meat/slab/rawcrab = 1,
		/obj/item/stack/sheet/bone = 1,
		/obj/item/organ/internal/monster_core/rush_gland = 1,
	)
	crusher_loot = null
	snip_speed = 6.5 SECONDS
	charge_type = /datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster/shrimp
	/// What do we become when we grow up?
	var/mob/living/basic/mining/lobstrosity/grow_type = /mob/living/basic/mining/lobstrosity
	/// Were we tamed? If yes, tame the mob we become when we grow up too.
	var/was_tamed = FALSE

/mob/living/basic/mining/lobstrosity/juvenile/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_time = rand(12 MINUTES, 15 MINUTES),\
		growth_path = grow_type,\
		optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
		optional_grow_behavior = CALLBACK(src, PROC_REF(grow_up))\
	)
	AddComponent(/datum/component/tameable, target_foods, tame_chance = 35, bonus_tame_chance = 25)

/mob/living/basic/mining/lobstrosity/juvenile/add_ranged_armour(list/vulnerable_projectiles)
	AddElement(\
		/datum/element/ranged_armour,\
		minimum_projectile_force = 30,\
		below_projectile_multiplier = 0.6,\
		vulnerable_projectile_types = vulnerable_projectiles,\
		minimum_thrown_force = 13,\
		throw_blocked_message = throw_blocked_message,\
	)

/mob/living/basic/mining/lobstrosity/juvenile/tamed(mob/living/tamer, obj/item/food)
	. = ..()
	was_tamed = TRUE

/mob/living/basic/mining/lobstrosity/juvenile/proc/ready_to_grow()
	return isturf(loc)

/mob/living/basic/mining/lobstrosity/juvenile/proc/grow_up()
	var/name_to_use = name == initial(name) ? grow_type::name : name
	var/mob/living/basic/mining/lobstrosity/grown = change_mob_type(grow_type, get_turf(src), name_to_use)
	for(var/friend in ai_controller?.blackboard?[BB_FRIENDS_LIST])
		grown.befriend(friend)
	if(was_tamed)
		grown.tamed()
	grown.setBruteLoss(getBruteLoss())
	grown.setFireLoss(getFireLoss())

/mob/living/basic/mining/lobstrosity/juvenile/lava
	name = "juvenile chasm lobstrosity"
	desc = "A youngling of the behemothic lobstrosity. They usually don't crawl out of the vents they reside in until they're fully grown."
	icon_state = "juveline_lobstrosity"
	icon_living = "juveline_lobstrosity"
	icon_dead = "juveline_lobstrosity_dead"
	grow_type = /mob/living/basic/mining/lobstrosity/lava

/// Shorter, weaker version of the Lobster Rush, but faster
/datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster/shrimp
	name = "Shrimp Rush"
	charge_distance = 4
	knockdown_duration = 1.5 SECONDS
	cooldown_time = 1.4 SECONDS
	charge_delay = 0.2 SECONDS
	charge_speed = 0.3
	charge_damage = 13

/datum/action/cooldown/mob_cooldown/charge/basic_charge/lobster/apply_post_charge(mob/living/charger)
	charger.apply_status_effect(/datum/status_effect/tired_post_charge/easy)
