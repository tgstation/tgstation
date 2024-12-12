//not quite simple animal megafauna but close enough
// port actual megafauna stuff once it gets used for lavaland megafauna
//im using it for stuff both of them get
/mob/living/basic/boss
	combat_mode = TRUE
	sentience_type = SENTIENCE_BOSS
	mob_biotypes = MOB_ORGANIC|MOB_SPECIAL
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1

/mob/living/basic/boss/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	add_traits(list(TRAIT_NO_TELEPORT, TRAIT_MARTIAL_ARTS_IMMUNE, TRAIT_LAVA_IMMUNE,TRAIT_ASHSTORM_IMMUNE, TRAIT_NO_FLOATING_ANIM), MEGAFAUNA_TRAIT)
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/simple_flying)

/mob/living/basic/boss/gib()
	if(health > 0)
		return

	return ..()

/mob/living/basic/boss/dust(just_ash, drop_items, force)
	if(!force && health > 0)
		return

	/*crusher_loot.Cut()
	loot.Cut()*/

	return ..()
