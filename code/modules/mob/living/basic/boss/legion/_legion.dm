/mob/living/basic/boss/legion
	name = "Legion, Guardian of the Necropolis"
	health = 10000
	maxHealth = 10000
	icon_state = "mega_legion"
	icon_living = "mega_legion"
	health_doll_icon = "mega_legion"
	desc = "One of many."
	icon = 'icons/mob/simple/lavaland/96x96megafauna.dmi'
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("echoes")
	armour_penetration = 50
	melee_damage_lower = 0
	melee_damage_upper = 0
	speed = 1
	SET_BASE_PIXEL(-32, -16)
	maptext_height = 96
	maptext_width = 96
	appearance_flags = LONG_GLIDE
	mouse_opacity = MOUSE_OPACITY_ICON
	ai_controller = /datum/ai_controller/basic_controller/legion
	//wander = FALSE
	//small_sprite_type = /datum/action/small_sprite/megafauna/legion
	//del_on_death = TRUE
	//retreat_distance = 5
	//minimum_distance = 5
	//gps_name = "Echoing Signal"
	//achievement_type = /datum/award/achievement/boss/legion_kill
	//crusher_achievement_type = /datum/award/achievement/boss/legion_crusher
	//score_achievement_type = /datum/award/score/legion_score
	//vision_range = 13
	//elimination = TRUE

/mob/living/basic/boss/legion/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, INNATE_TRAIT)
	AddElement(/datum/element/death_drops, list(/obj/item/stack/sheet/bone = 3))
	AddElement(/datum/element/crusher_loot, /obj/item/crusher_trophy/bileworm_spewlet, 15)

	var/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/bone_shotgun/shotgun = new(src)
	shotgun.Grant(src)

	var/datum/action/cooldown/mob_cooldown/legion_lasers/lasers = new(src)
	lasers.Grant(src)

	ai_controller.blackboard[BB_LEGION_BONE] = WEAKREF(shotgun)
	ai_controller.blackboard[BB_LEGION_LASERS] = WEAKREF(lasers)
