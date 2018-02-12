/datum/relic_type
	var/list/added_effects = list()
	var/list/hogged_signals = list()

/datum/relic_type/proc/pre_generate(obj/item/relic/A)
	apply_cosmetics(A)

/datum/relic_type/proc/reveal(obj/item/relic/A)
	var/obj/item/new_relic = get_item(A)
	if(new_relic != A)
		apply_cosmetics(new_relic)
		qdel(A)
	apply_effects(new_relic)

/datum/relic_type/proc/get_item(obj/item/relic/A) //Override this to provide your own item that serves as the relic. Relic effects are components and can go on anything. The original relic will be automatically deleted on reveal.
	return A

/datum/relic_type/proc/add_one_random_effect(type)
	var/list/valid_effects = get_valid_relic_effects(type)
	for(var/datum/relic_effect/eff in added_effects)
		valid_effects -= eff.type
	if(!valid_effects.len)
		return
	var/picked_type = pickweight(valid_effects)
	var/datum/relic_effect/new_effect = new picked_type()
	if((new_effect.hogged_signals & hogged_signals).len == 0) //Late cancel if the signals overlap
		added_effects += new_effect
		hogged_signals += new_effect.hogged_signals

/datum/relic_type/proc/apply_cosmetics(obj/item/A)
	var/list/firstnames = list(pick("broken","twisted","spun","improved","silly","regular","badly made"))
	var/list/lastnames = list(pick("device","object","toy","illegal tech","weapon"))

	for(var/datum/relic_effect/eff in added_effects)
		if(istype(eff,/datum/relic_effect/cosmetic))
			eff.apply(A)

		if(eff.firstname && prob(50))
			firstnames += pick(eff.firstname)
		else if(eff.lastname)
			lastnames += pick(eff.lastname)

	A.name = "[pick(firstnames)] [pick(lastnames)]"

/datum/relic_type/proc/apply_effects(obj/item/A)
	var/datum/component/relic/comp = A.AddComponent(/datum/component/relic)
	for(var/datum/relic_effect/eff in added_effects)
		if(!istype(eff,/datum/relic_effect/cosmetic))
			eff.apply(A)
		eff.apply_to_component(comp)

/datum/relic_type/classic/pre_generate(obj/item/relic/A)
	add_one_random_effect(/datum/relic_effect/activate) //Yeah, nothin else just like it used to be
	add_one_random_effect(/datum/relic_effect/cost)
	add_one_random_effect(/datum/relic_effect/cosmetic)
	add_one_random_effect(/datum/relic_effect/cosmetic/color)
	..()

/datum/relic_type/tool/pre_generate(obj/item/relic/A)
	if(prob(30))
		add_one_random_effect(/datum/relic_effect/activate)
	if(prob(30))
		add_one_random_effect(/datum/relic_effect/passive)
	add_one_random_effect(/datum/relic_effect/attack)
	add_one_random_effect(/datum/relic_effect/cost)
	add_one_random_effect(/datum/relic_effect/cosmetic)
	add_one_random_effect(/datum/relic_effect/cosmetic/color)
	if(prob(60))
		add_one_random_effect(/datum/relic_effect/cosmetic)
		add_one_random_effect(/datum/relic_effect/cosmetic)
	add_one_random_effect(/datum/relic_effect/cosmetic/melee/tool)
	..()

/datum/relic_type/weapon/pre_generate(obj/item/relic/A)
	if(prob(10))
		add_one_random_effect(/datum/relic_effect/activate)
	add_one_random_effect(/datum/relic_effect/attack)
	add_one_random_effect(/datum/relic_effect/passive)
	add_one_random_effect(/datum/relic_effect/passive)
	add_one_random_effect(/datum/relic_effect/passive)
	add_one_random_effect(/datum/relic_effect/cost)
	add_one_random_effect(/datum/relic_effect/cosmetic/color)
	if(prob(60))
		add_one_random_effect(/datum/relic_effect/cosmetic)
		add_one_random_effect(/datum/relic_effect/cosmetic)
	add_one_random_effect(/datum/relic_effect/cosmetic/melee)
	..()

/datum/relic_type/toy/pre_generate(obj/item/relic/A)
	add_one_random_effect(/datum/relic_effect/activate)
	add_one_random_effect(/datum/relic_effect/passive)
	add_one_random_effect(/datum/relic_effect/cost/cooldown_only) //toys can be used anytime
	add_one_random_effect(/datum/relic_effect/cosmetic)
	add_one_random_effect(/datum/relic_effect/cosmetic/color)
	if(prob(60))
		add_one_random_effect(/datum/relic_effect/cosmetic)
		add_one_random_effect(/datum/relic_effect/cosmetic)
	..()

/datum/relic_type/armor/pre_generate(obj/item/relic/A)
	add_one_random_effect(/datum/relic_effect/passive)
	add_one_random_effect(/datum/relic_effect/passive)
	add_one_random_effect(/datum/relic_effect/passive)
	add_one_random_effect(/datum/relic_effect/passive)
	add_one_random_effect(/datum/relic_effect/passive)
	add_one_random_effect(/datum/relic_effect/cosmetic)
	add_one_random_effect(/datum/relic_effect/cosmetic/color)
	if(prob(60))
		add_one_random_effect(/datum/relic_effect/cosmetic)
		add_one_random_effect(/datum/relic_effect/cosmetic)
	..()

/datum/relic_type/stock_part/pre_generate(obj/item/relic/A)
	add_one_random_effect(/datum/relic_effect/passive)
	add_one_random_effect(/datum/relic_effect/cosmetic)
	add_one_random_effect(/datum/relic_effect/cosmetic/color)
	if(prob(60))
		add_one_random_effect(/datum/relic_effect/cosmetic)
		add_one_random_effect(/datum/relic_effect/cosmetic)
	..()