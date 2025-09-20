#define SHIELD_FILTER "shield filter"

/// gives the mobs a regenerative shield, it will tank hits for them and then need to recharge for a bit
/datum/component/regenerative_shield
	///number of hits we can tank
	var/number_of_hits = 15
	///the limit of the damage we can tank
	var/damage_threshold
	///the overlay of the shield
	var/list/shield_overlays = list()
	///how long before the shield can regenerate
	var/regeneration_time

/datum/component/regenerative_shield/Initialize(number_of_hits = 15, damage_threshold = 50, regeneration_time = 2 MINUTES, list/shield_overlays)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.number_of_hits = number_of_hits
	src.damage_threshold = damage_threshold
	src.regeneration_time = regeneration_time

	var/atom/movable/living_parent = parent
	for(var/type_path in shield_overlays)
		if(!ispath(type_path))
			continue
		var/obj/effect/overlay/new_effect = new type_path()
		living_parent.vis_contents += new_effect
		apply_filter_effects(new_effect)
		src.shield_overlays += new_effect

/datum/component/regenerative_shield/RegisterWithParent()
	. = ..()
	ADD_TRAIT(parent, TRAIT_REGEN_SHIELD, REF(src))
	RegisterSignal(parent, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(block_attack))

/datum/component/regenerative_shield/UnregisterFromParent()
	var/atom/movable/living_parent = parent
	for(var/obj/effect/overlay as anything in shield_overlays)
		living_parent.vis_contents -= overlay
	QDEL_LIST(shield_overlays)
	UnregisterSignal(parent, COMSIG_LIVING_CHECK_BLOCK)
	REMOVE_TRAIT(parent, TRAIT_REGEN_SHIELD, REF(src))
	return ..()

/datum/component/regenerative_shield/proc/block_attack(
	mob/living/source,
	atom/hitby,
	damage,
	attack_text,
	attack_type,
	armour_penetration,
	damage_type,
	attack_flag,
)
	SIGNAL_HANDLER

	if(damage <= 0 ||damage_type == STAMINA)
		return NONE

	if(damage >= damage_threshold || number_of_hits <= 0)
		return NONE

	playsound(get_turf(parent), 'sound/items/weapons/tap.ogg', 20)
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(parent))
	number_of_hits = max(0, number_of_hits - 1)
	if(number_of_hits <= 0)
		disable_shield()
	return SUCCESSFUL_BLOCK

/datum/component/regenerative_shield/proc/disable_shield()
	addtimer(CALLBACK(src, PROC_REF(enable_shield)), regeneration_time)
	for(var/obj/effect/my_effect as anything in shield_overlays)
		animate(my_effect, alpha = 0, time = 3 SECONDS)
		my_effect.remove_filter(SHIELD_FILTER)
	playsound(parent, 'sound/vehicles/mecha/mech_shield_drop.ogg', 20)

/datum/component/regenerative_shield/proc/enable_shield()
	number_of_hits = initial(number_of_hits)
	for(var/obj/effect/my_effect as anything in shield_overlays)
		animate(my_effect, alpha = 255, time = 3 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(apply_filter_effects), my_effect), 5 SECONDS)
	playsound(parent, 'sound/vehicles/mecha/mech_shield_raise.ogg', 20)

/datum/component/regenerative_shield/proc/apply_filter_effects(obj/effect/new_effect)
	if(isnull(new_effect))
		return
	new_effect.add_filter(SHIELD_FILTER, 1, list("type" = "outline", "color" = "#b6e6f3", "alpha" = 0, "size" = 1))
	var/filter = new_effect.get_filter(SHIELD_FILTER)
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)

#undef SHIELD_FILTER
