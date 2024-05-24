/mob/living/basic/chicken/cockatrice
	icon_suffix = "cockatrice"

	breed_name_male = "Cockatrice"
	breed_name_female = "Cockatrice"

	ai_controller = /datum/ai_controller/chicken/hostile
	health = 150
	maxHealth = 150
	melee_damage_upper = 10
	melee_damage_lower = 8
	obj_damage = 10

	pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/attack/chicken/ranged,
		/datum/pet_command/point_targeting/fetch,
		/datum/pet_command/play_dead,
	)

	targeted_ability = /datum/action/cooldown/mob_cooldown/chicken/petrifying_gaze

	egg_type = /obj/item/food/egg/cockatrice

	book_desc = "Part lizard, part chicken, part bat. The Males of this species are capable of spitting a venom that will petrify you temporarily, and are very hostile."
/obj/item/food/egg/cockatrice
	name = "Petrifying Egg"
	icon_state = "cockatrice"

	layer_hen_type = /mob/living/basic/chicken/cockatrice

/mob/living/basic/chicken/cockatrice/Initialize(mapload)
	. = ..()
	if(gender == FEMALE)
		var/list/new_planning_subtree = list()
		for(var/datum/ai_planning_subtree/listed_tree as anything in ai_controller.planning_subtrees)
			new_planning_subtree |= listed_tree.type

		new_planning_subtree -= /datum/ai_planning_subtree/basic_melee_attack_subtree/chicken
		ai_controller.replace_planning_subtrees(new_planning_subtree)

/obj/item/ammo_casing/venomous_spit
	projectile_type = /obj/projectile/magic/venomous_spit

/obj/projectile/magic/venomous_spit
	name = "venomous spit"
	icon_state = "ion"
	damage = 5
	damage_type = BURN

/obj/projectile/magic/venomous_spit/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/user = target
		user.petrify(10)

/datum/action/cooldown/mob_cooldown/chicken/petrifying_gaze
	name = "Petrifying Gaze"
	desc = "Petrify those who dare to look at you."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	cooldown_time = 20 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	click_to_activate = TRUE
	shared_cooldown = NONE
	what_range = /datum/ai_behavior/targeted_mob_ability/min_range/chicken/gaze

/datum/action/cooldown/mob_cooldown/chicken/petrifying_gaze/PreActivate(atom/target)
	if (target == owner)
		return
	. = ..()

/datum/action/cooldown/mob_cooldown/chicken/petrifying_gaze/Activate(mob/living/target)
	var/mob/living/living_owner = owner
	living_owner.visible_message("[living_owner] glares at [target] petrifying them.", "You glare at [target] petrifying them.")
	living_owner.face_atom(target)
	target.petrify(10)
	StartCooldown()
	return TRUE
