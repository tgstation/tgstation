/proc/get_valid_relic_effects(type)
	var/list/L = list()
	for(var/efftype in typesof(type))
		var/datum/relic_effect/efftype2 = efftype
		if(initial(efftype2.weight))
			L[efftype] = initial(efftype2.weight)
	return L

/datum/relic_effect
	var/list/firstname
	var/list/lastname
	var/physical_part
	var/hint
	var/weight
	var/free = FALSE //Using this doesn't consume charge/trigger cooldown
	var/list/hogged_signals = list()
	var/list/added_effects = list() //effect types needed for this effect, effectively adds it after

/datum/relic_effect/proc/init()

/datum/relic_effect/proc/use_power(obj/item/A,mob/user)
	if(free)
		return TRUE
	var/datum/component/relic/comp = A.GetComponent(/datum/component/relic)
	if(!comp.can_use())
		if(user)
			to_chat(user, "<span class='warning'>[A] does not react!</span>")
		return FALSE
	comp.use_charge()
	return TRUE

/datum/relic_effect/proc/apply(obj/item/A)

/datum/relic_effect/proc/apply_to_component(obj/item/A,datum/component/relic/comp) //All of these get called simultaneously