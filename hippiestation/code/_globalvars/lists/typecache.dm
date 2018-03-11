//see: https://github.com/HippieStation/HippieStation/blob/fix-lag/code/_globalvars/lists/typecache.dm
//please store common type caches here.
//type caches should only be stored here if used in mutiple places or likely to be used in mutiple places.

//Note: typecache can only replace istype if you know for sure the thing is at least a datum.

// Don't show reaction messages in these atoms
GLOBAL_LIST_INIT(no_reagent_message_typecache, typecacheof(list(
  /obj/effect/particle_effect,
  /obj/effect/decal/cleanable,
  /mob/living,
  /obj/item/reagent_containers/food,
  /turf/open/pool)
))

// Don't do state change in these atoms
GLOBAL_LIST_INIT(no_reagent_statechange_typecache, typecacheof(list(
  /obj/effect/particle_effect/water,
  /obj/effect/decal/cleanable,
  /obj/effect/particle_effect/smoke/chem/smoke_machine,
  /mob/living)
))

GLOBAL_LIST_INIT(statechange_reagent_blacklist, typecacheof(list(
	/datum/reagent/water,
	/datum/reagent/toxin/bleach,
	/datum/reagent/lube,
	/datum/reagent/consumable/condensedcapsaicin,
	/datum/reagent/space_cleaner,
	/datum/reagent/smoke_powder,
	/datum/reagent/consumable/sugar,
	/datum/reagent/thermite,
	/datum/reagent/toxin/plasma,
	/datum/reagent/radium,
	/datum/reagent/oxygen,
	/datum/reagent/nitrogen,
	/datum/reagent/nitrous_oxide,
	/datum/reagent/cryostylane)
))

GLOBAL_LIST_INIT(statechange_turf_blacklist, typecacheof(list(
	/turf/open/pool,
	/turf/open/space,
	/turf/open/chasm,
	/turf/open/lava)
))