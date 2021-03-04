/*

Difficulty: Very Easy
Was planned to be something more but due to the content freeze it unfortunately cannot be
I'd rather there be something than the clockwork ruin be entirely empty though so here is a basic mob

*/

/mob/living/simple_animal/hostile/megafauna/clockwork_defender
	name = "the clockwork defender"
	desc = "A traitorous clockwork knight who lived on, despite its creators destruction."
	health = 300
	maxHealth = 300
	icon_state = "clockwork_defender"
	icon_living = "clockwork_defender"
	icon = 'icons/mob/icemoon/icemoon_monsters.dmi'
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	weather_immunities = list("snow")
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 20
	melee_damage_upper = 20
	vision_range = 9
	aggro_vision_range = 9
	speed = 5
	move_to_delay = 5
	rapid_melee = 2 // every second
	melee_queue_distance = 20
	ranged = TRUE
	gps_name = "Clockwork Signal"
	loot = list(/obj/item/clockwork_alloy)
	crusher_loot = list(/obj/item/clockwork_alloy)
	wander = FALSE
	del_on_death = TRUE
	deathmessage = "falls, quickly decaying into centuries old dust."
	deathsound = "bodyfall"
	footstep_type = FOOTSTEP_MOB_HEAVY
	attack_action_types = list()

/mob/living/simple_animal/hostile/megafauna/clockwork_defender/OpenFire()
	return

/obj/item/clockwork_alloy
	name = "clockwork alloy"
	desc = "The remains of the strongest clockwork knight."
	icon = 'icons/obj/ice_moon/artifacts.dmi'
	icon_state = "clockwork_alloy"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
