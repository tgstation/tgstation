//A mob with this compoent will heal on its life() if standing on the given turfs
/datum/component/turf_healing
	///what damage types to heal with a key of how much to heal for
	var/list/healing_types = list()
	///typecache of what turfs to heal on
	var/list/healing_turfs

/datum/component/turf_healing/Initialize(list/healing_types, list/healing_turfs)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	if(healing_types)
		src.healing_types = healing_types
	if(healing_turfs)
		src.healing_turfs = typecacheof(healing_turfs)
	return ..()

/datum/component/turf_healing/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(handle_healing))

/datum/component/turf_healing/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_LIFE)

/datum/component/turf_healing/proc/handle_healing(seconds_per_tick)
	SIGNAL_HANDLER

	var/mob/living/healed_mob = parent
	var/turf/on_turf = get_turf(healed_mob)
	if(!is_type_in_typecache(on_turf, healing_turfs) || (healed_mob.health >= healed_mob.maxHealth))
		return

	for(var/entry in healing_types)
		if(entry == STAMINA)
			healed_mob.stamina.adjust(healing_types[entry] * seconds_per_tick * 0.5)
			continue
		healed_mob.heal_damage_type((healing_types[entry] * seconds_per_tick * 0.5), entry)
