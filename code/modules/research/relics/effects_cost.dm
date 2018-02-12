/datum/relic_effect/cost/instant
	weight = 20

/datum/relic_effect/cost/instant/apply_to_component(datum/component/relic/comp)
	comp.cooldown_time = 0

/datum/relic_effect/cost/cooldown_only
	weight = 20

/datum/relic_effect/cost/cooldown_only/apply_to_component(datum/component/relic/comp)
	comp.max_charges = INFINITY
	comp.charges = INFINITY