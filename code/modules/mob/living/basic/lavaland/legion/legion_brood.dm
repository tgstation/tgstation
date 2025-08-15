/// A spooky skull which heals lavaland mobs, attacks miners, and infests their bodies
/mob/living/basic/legion_brood
	name = "legion"
	desc = "One of many."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "legion_head"
	icon_living = "legion_head"
	icon_dead = "legion_head"
	icon_gib = "syndicate_gib"
	basic_mob_flags = DEL_ON_DEATH
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE | PASSMOB
	mob_biotypes = MOB_ORGANIC|MOB_UNDEAD|MOB_MINING
	faction = list(FACTION_MINING)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	friendly_verb_continuous = "chatters near"
	friendly_verb_simple = "chatter near"
	maxHealth = 1
	health = 1
	melee_damage_lower = 12
	melee_damage_upper = 12
	obj_damage = 0
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("echoes") // who the fuck speaking as this mob it dies 10 seconds after it spawns
	attack_sound = 'sound/items/weapons/pierce.ogg'
	density = FALSE
	ai_controller = /datum/ai_controller/basic_controller/legion_brood
	/// Reference to a guy who made us
	var/datum/weakref/created_by

/mob/living/basic/legion_brood/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE, TRAIT_PERMANENTLY_MORTAL), INNATE_TRAIT)
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/swarming)
	AddComponent(/datum/component/clickbox, icon_state = "sphere", max_scale = 2)
	addtimer(CALLBACK(src, PROC_REF(death)), 10 SECONDS)

/mob/living/basic/legion_brood/death(gibbed)
	if (!gibbed)
		new /obj/effect/temp_visual/despawn_effect(get_turf(src), /* copy_from = */ src)
	return ..()

/mob/living/basic/legion_brood/melee_attack(mob/living/target, list/modifiers, ignore_cooldown)
	if (ishuman(target) && target.stat > SOFT_CRIT)
		infest(target)
		return

	var/mob/living/mob_creator = created_by?.resolve()
	if(isnull(mob_creator))
		created_by = null

	if (isliving(target) && faction_check_atom(target) && !istype(target, mob_creator?.type))
		visible_message(span_warning("[src] melds with [target]'s flesh!"))
		target.apply_status_effect(/datum/status_effect/regenerative_core)
		new /obj/effect/temp_visual/heal(get_turf(target), COLOR_HEALING_CYAN)
		death()
		return
	return ..()

/// Turn the targeted mob into one of us
/mob/living/basic/legion_brood/proc/infest(mob/living/carbon/human/target)
	visible_message(span_warning("[name] burrows into the flesh of [target]!"))
	var/spawn_type = get_legion_type(target)
	var/mob/living/basic/mining/legion/new_legion = new spawn_type(loc)
	new_legion.consume(target)
	new_legion.faction = faction.Copy()
	qdel(src)

/// Returns the kind of legion we make out of the target
/mob/living/basic/legion_brood/proc/get_legion_type(mob/living/carbon/human/target)
	if (ismonkey(target))
		return /mob/living/basic/mining/legion/monkey
	if (HAS_TRAIT(target, TRAIT_DWARF))
		return /mob/living/basic/mining/legion/dwarf
	return /mob/living/basic/mining/legion

/// Sets someone as our creator, mostly so you can't use skulls to heal yourself
/mob/living/basic/legion_brood/proc/assign_creator(mob/living/creator, copy_full_faction = TRUE)
	if (copy_full_faction)
		faction = creator.faction.Copy()
	else
		faction |= REF(creator)
	created_by = WEAKREF(creator)
	ai_controller?.set_blackboard_key(BB_LEGION_BROOD_CREATOR, creator)
	RegisterSignal(creator, COMSIG_QDELETING, PROC_REF(creator_destroyed))

/// Reference handling
/mob/living/basic/legion_brood/proc/creator_destroyed()
	SIGNAL_HANDLER
	created_by = null

/// Like the Legion's summoned skull but funnier (it's snow now)
/mob/living/basic/legion_brood/snow
	name = "snow legion"
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "snowlegion_head"
	icon_living = "snowlegion_head"
	icon_dead = "snowlegion_head"

/mob/living/basic/legion_brood/snow/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SNOWSTORM_IMMUNE, INNATE_TRAIT)

/mob/living/basic/legion_brood/snow/get_legion_type(mob/living/target)
	if (ismonkey(target))
		return /mob/living/basic/mining/legion/monkey/snow
	return /mob/living/basic/mining/legion/snow
