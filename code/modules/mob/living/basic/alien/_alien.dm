/mob/living/basic/alien
	name = "alien hunter"
	desc = "Hiss!"
	icon = 'icons/mob/nonhuman-player/alien.dmi'
	icon_state = "alienh"
	icon_living = "alienh"
	icon_dead = "alienh_dead"
	icon_gib = "syndicate_gib"
	gender = FEMALE
	status_flags = CANPUSH
	butcher_results = list(
		/obj/item/food/meat/slab/xeno = 4,
		/obj/item/stack/sheet/animalhide/xeno = 1,
	)

	maxHealth = 125
	health = 125
	bubble_icon = "alien"
	combat_mode = TRUE
	faction = list(ROLE_ALIEN)

	// Going for a dark purple here
	lighting_cutoff_red = 30
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 50
	unique_name = TRUE

	basic_mob_flags = FLAMMABLE_MOB
	speed = 0
	obj_damage = 60

	speak_emote = list("hisses")
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"

	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	gold_core_spawnable = NO_SPAWN
	death_sound = 'sound/voice/hiss6.ogg'
	death_message = "lets out a waning guttural screech, green blood bubbling from its maw..."

	habitable_atmos = null
	unsuitable_atmos_damage = FALSE
	unsuitable_heat_damage = 20

	ai_controller = /datum/ai_controller/basic_controller/alien

	///List of loot items to drop when deleted, if this is set then we apply DEL_ON_DEATH
	var/list/loot
	///Boolean on whether the xeno can plant weeds.
	var/can_plant_weeds = TRUE
	///Boolean on whether the xeno can lay eggs.
	var/can_lay_eggs = FALSE

/mob/living/basic/alien/Initialize(mapload)
	. = ..()
	if(length(loot))
		basic_mob_flags |= DEL_ON_DEATH
		loot = string_list(loot)
		AddElement(/datum/element/death_drops, loot)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_CLAW)

/mob/living/basic/alien/get_butt_sprite()
	return icon('icons/mob/butts.dmi', BUTT_SPRITE_XENOMORPH)

///Places alien weeds on the turf the mob is currently standing on.
/mob/living/basic/alien/proc/place_weeds()
	if(!isturf(loc) || isspaceturf(loc))
		return
	if(locate(/obj/structure/alien/weeds/node) in get_turf(src))
		return
	visible_message(span_alertalien("[src] plants some alien weeds!"))
	new /obj/structure/alien/weeds/node(loc)

///Lays an egg on the turf the mob is currently standing on.
/mob/living/basic/alien/proc/lay_alien_egg()
	if(!isturf(loc) || isspaceturf(loc))
		return
	if(locate(/obj/structure/alien/egg) in get_turf(src))
		return
	visible_message(span_alertalien("[src] lays an egg!"))
	new /obj/structure/alien/egg(loc)
