/datum/relic_effect
	var/list/valid_types //Which types of items this effect is valid for
	var/list/hogged_signals = list()

/datum/relic_effect/proc/init()
	valid_types = typecacheof(/obj/item)

/datum/relic_effect/proc/apply(obj/item/A)

/datum/relic_effect/proc/apply_to_component(datum/component/relic/comp) //All of these get called simultaneously

/datum/relic_effect/bullet/proc/on_impact(obj/item/projectile/proj,/atom/A)

/datum/relic_effect/bullet/proc/on_range(obj/item/projectile/proj)