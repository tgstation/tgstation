/mob/living/basic/mining/ice_whelp
	name = "ice whelp"
	desc = "The offspring of an ice drake, weak in comparison but still terrifying."
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "ice_whelp"
	icon_living = "ice_whelp"
	icon_dead = "ice_whelp_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list(
		/obj/item/stack/ore/diamond = 3,
		/obj/item/stack/sheet/animalhide/ashdrake = 1,
		/obj/item/stack/sheet/bone = 10,
		/obj/item/stack/sheet/sinew = 2,
	)
	crusher_loot = /obj/item/crusher_trophy/tail_spike
	speed = 12

	maxHealth = 300
	health = 300
	obj_damage = 40
	armour_penetration = 20
	melee_damage_lower = 20
	melee_damage_upper = 20

	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	death_message = "collapses on its side."
	death_sound = 'sound/magic/demon_dies.ogg'

	attack_sound = 'sound/magic/demon_attack1.ogg'
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG

	ai_controller = /datum/ai_controller/basic_controller/ice_whelp
	///how much we will heal when cannibalizing a target
	var/heal_on_cannibalize = 5

/mob/living/basic/mining/ice_whelp/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_GLIDE, INNATE_TRAIT)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY)
	AddComponent(/datum/component/basic_mob_ability_telegraph)
	AddComponent(/datum/component/basic_mob_attack_telegraph, telegraph_duration = 0.6 SECONDS)
	var/datum/action/cooldown/mob_cooldown/fire_breath/ice/flamethrower = new(src)
	flamethrower.Grant(src)
	ai_controller.set_blackboard_key(BB_WHELP_STRAIGHTLINE_FIRE, flamethrower)
	var/datum/action/cooldown/mob_cooldown/fire_breath/ice/cross/wide_flames = new(src)
	wide_flames.Grant(src)
	ai_controller.set_blackboard_key(BB_WHELP_WIDESPREAD_FIRE, wide_flames)
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))


/mob/living/basic/mining/ice_whelp/proc/pre_attack(mob/living/sculptor, atom/target)
	SIGNAL_HANDLER

	if(istype(target, /obj/structure/flora/rock/icy))
		INVOKE_ASYNC(src, PROC_REF(create_sculpture), target)
		return COMPONENT_HOSTILE_NO_ATTACK

	if(!istype(target, src.type))
		return

	var/mob/living/victim = target
	if(victim.stat != DEAD)
		return

	INVOKE_ASYNC(src, PROC_REF(cannibalize_victim), victim)
	return COMPONENT_HOSTILE_NO_ATTACK

/// Carve a stone into a beautiful self-portrait
/mob/living/basic/mining/ice_whelp/proc/create_sculpture(atom/target)
	balloon_alert(src, "sculpting...")
	if(!do_after(src, 5 SECONDS, target = target))
		return
	var/obj/structure/statue/custom/dragon_statue = new(get_turf(target))
	dragon_statue.set_visuals(src)
	dragon_statue.name = "statue of [src]"
	dragon_statue.desc = "Let this serve as a warning."
	dragon_statue.set_anchored(TRUE)
	qdel(target)

/// Gib and consume our fellow ice drakes
/mob/living/basic/mining/ice_whelp/proc/cannibalize_victim(mob/living/target)
	start_pulling(target)
	balloon_alert(src, "devouring...")
	if(!do_after(src, 5 SECONDS, target))
		return
	target.gib(DROP_ALL_REMAINS)
	adjustBruteLoss(-1 * heal_on_cannibalize)
