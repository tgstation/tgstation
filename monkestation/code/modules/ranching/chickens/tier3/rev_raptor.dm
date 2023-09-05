/mob/living/basic/chicken/rev_raptor
	icon_suffix = "rev_raptor"

	breed_name = "Revolutionary Raptor"
	breed_name_male = "Revolutionary Tiercel"
	egg_type = /obj/item/food/egg/raptor

	ai_controller = /datum/ai_controller/chicken/hostile
	health = 150
	maxHealth = 100
	melee_damage_upper = 6
	melee_damage_lower = 2
	obj_damage = 10

	targeted_ability_planning_tree = /datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/rev
	targeted_ability = /datum/action/cooldown/mob_cooldown/chicken/rev_convert

	book_desc = "This is what happens when we let the raptors learn from the stations crew."

/obj/item/food/egg/rev_raptor
	name = "Revolutionary Egg"
	icon_state = "rev_raptor"

	layer_hen_type = /mob/living/basic/chicken/rev_raptor


/datum/action/cooldown/mob_cooldown/chicken/rev_convert
	name = "Revolt"
	desc = "Bring more chickens into your cause."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	cooldown_time = 20 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	click_to_activate = TRUE
	shared_cooldown = NONE
	what_range = /datum/ai_behavior/targeted_mob_ability/min_range/chicken/melee


/datum/action/cooldown/mob_cooldown/chicken/rev_convert/PreActivate(atom/target)
	. = ..()
	if (target == owner)
		return
	if(!istype(target, /mob/living/basic/chicken))
		return

/datum/action/cooldown/mob_cooldown/chicken/rev_convert/Activate(mob/living/target)
	owner.say("VIVA, BAWK!")
	new /mob/living/basic/chicken/raptor(target.loc)
	qdel(target)
	StartCooldown()
	return TRUE

