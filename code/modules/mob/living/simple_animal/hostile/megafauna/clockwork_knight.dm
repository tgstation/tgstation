/*

Difficulty: Very Easy
Was planned to be something more but due to the content freeze it unfortunately cannot be
I'd rather there be something than the clockwork ruin be entirely empty though so here is a basic mob

*/

/mob/living/simple_animal/hostile/megafauna/clockwork_defender
	name = "clockwork defender"
	desc = "A traitorous clockwork knight who lived on, despite its creators destruction."
	health = 300
	maxHealth = 300
	icon_state = "clockwork_defender"
	icon_living = "clockwork_defender"
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	weather_immunities = list(TRAIT_SNOWSTORM_IMMUNE)
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 20
	melee_damage_upper = 20
	mob_biotypes = MOB_ROBOTIC|MOB_SPECIAL|MOB_MINING
	vision_range = 9
	aggro_vision_range = 9
	speed = 5
	move_to_delay = 5
	rapid_melee = 2 // every second
	melee_queue_distance = 20
	ranged = TRUE
	gps_name = "Clockwork Signal"
	loot = list(/obj/item/clockwork_alloy)
	wander = FALSE
	del_on_death = TRUE
	death_message = "falls, quickly decaying into centuries old dust."
	death_sound = SFX_BODYFALL
	footstep_type = FOOTSTEP_MOB_HEAVY
	attack_action_types = list()

/mob/living/simple_animal/hostile/megafauna/clockwork_defender/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)

/mob/living/simple_animal/hostile/megafauna/clockwork_defender/OpenFire()
	return

/obj/item/clockwork_alloy
	name = "clockwork alloy"
	desc = "The remains of the strongest clockwork knight."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "clockwork_alloy"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
