/proc/get_valid_relic_effects(var/type)
	var/list/L = list()
	for(var/efftype in typesof(type))
		var/datum/relic_effect/efftype2 = efftype
		if(initial(efftype2.weight))
			L[efftype] = initial(efftype2.weight)
	return L

/datum/relic_effect
	var/list/firstname
	var/list/lastname
	var/weight
	var/free = FALSE //Using this doesn't consume charge/trigger cooldown
	var/list/valid_types //Which types of items this effect is valid for
	var/list/hogged_signals = list()

/datum/relic_effect/proc/init()
	valid_types = typecacheof(/obj/item)

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

/datum/relic_effect/proc/apply_to_component(datum/component/relic/comp) //All of these get called simultaneously