/mob/living/basic/mining/wolf
	name = "white wolf"
	desc = "Pack hunters of the Icemoon wastes. While a mere nuisance individually, they become fearsome foes in larger groups."
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "whitewolf"
	icon_living = "whitewolf"
	icon_dead = "whitewolf_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	speak_emote = list("howls")
	friendly_verb_continuous = "howls at"
	friendly_verb_simple = "howl at"

	butcher_results = list(
		/obj/item/food/meat/slab = 2,
		/obj/item/stack/sheet/sinew/wolf = 2,
		/obj/item/stack/sheet/bone = 2
	)
	crusher_loot = /obj/item/crusher_trophy/wolf_ear

	maxHealth = 130
	health = 130
	obj_damage = 15
	melee_damage_lower = 7.5
	melee_damage_upper = 7.5
	attack_vis_effect = ATTACK_EFFECT_BITE
	melee_attack_cooldown = 1.2 SECONDS

	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	death_message = "snarls its last and perishes."

	attack_sound = 'sound/items/weapons/bite.ogg'
	move_force = MOVE_FORCE_WEAK
	move_resist = MOVE_FORCE_WEAK
	pull_force = MOVE_FORCE_WEAK

	ai_controller = /datum/ai_controller/basic_controller/wolf

	//can we tame this wolf?
	var/can_tame = TRUE

	//commands to give when tamed
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/good_boy/wolf,
		/datum/pet_command/follow/wolf,
		/datum/pet_command/point_targeting/attack,
		/datum/pet_command/point_targeting/fetch,
		/datum/pet_command/play_dead,
		/datum/pet_command/protect_owner,
	)

/mob/living/basic/mining/wolf/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_WOUND_LICKER, INNATE_TRAIT)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/ai_flee_while_injured)
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/basic_mob_ability_telegraph)
	AddComponent(/datum/component/basic_mob_attack_telegraph, telegraph_duration = 0.6 SECONDS)

	if(can_tame)
		make_tameable()

/mob/living/basic/mining/wolf/proc/make_tameable()
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/meat/slab), tame_chance = 15, bonus_tame_chance = 5)

/mob/living/basic/mining/wolf/tamed(mob/living/tamer, atom/food)
	new /obj/effect/temp_visual/heart(src.loc)
	// ride wolf, life good
	AddElement(/datum/element/ridable, /datum/component/riding/creature/wolf)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	// this is purely a convenience thing once tamed so you can drag them away from shit
	ai_controller.ai_traits = STOP_MOVING_WHEN_PULLED
	// makes tamed wolves run away far less
	ai_controller.set_blackboard_key(BB_BASIC_MOB_FLEE_DISTANCE, 7)

//port the faction fix from goliath basicmob to make the wildlife hostile when tamed (and also help defuckulate reinforcements ai)
//this should also produce interesting behavior where tamed wolves defend other tamed wolves.
/mob/living/basic/mining/wolf/befriend(mob/living/new_friend)
	. = ..()
	faction = new_friend.faction.Copy()
	visible_message(span_notice("[src] lowers [src.p_their()] snout at [new_friend]'s offering and begins to wag [src.p_their()] tail."))
