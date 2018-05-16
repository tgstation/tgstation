/datum/relic_effect/cost/instant
	weight = 20

/datum/relic_effect/cost/instant/apply_to_component(obj/item/A,datum/component/relic/comp)
	comp.cooldown_time = 0

/datum/relic_effect/cost/cooldown_only
	weight = 20

/datum/relic_effect/cost/cooldown_only/apply_to_component(obj/item/A,datum/component/relic/comp)
	comp.max_charges = INFINITY
	comp.charges = INFINITY

/datum/relic_effect/cost/recharge_cell
	weight = 40
	hint = list("A small LED labelled with a power symbol flashes profusely.")
	hogged_signals = list(COMSIG_PARENT_ATTACKBY)
	var/conversion_rate = 5000 //How much charge in W per point

/datum/relic_effect/cost/recharge_cell/init()
	conversion_rate = rand(200,5000)

/datum/relic_effect/cost/recharge_cell/apply_to_component(obj/item/A,datum/component/relic/comp)
	comp.charges = 0
	comp.add_attackby(CALLBACK(src, .proc/recharge, A))

/datum/relic_effect/cost/recharge_cell/proc/recharge(obj/item/A, obj/item/stock_parts/cell/B, mob/living/attacker)
	if(!istype(B))
		return
	var/datum/component/relic/comp = A.GetComponent(/datum/component/relic)
	if(!B.charge)
		to_chat(attacker,"<span class='notice'>/the [B] is empty!</span>")
		return
	to_chat(attacker,"<span class='notice'>You plug /[B] into [A] to recharge it.</span>")
	comp.recharge(round(B.charge / conversion_rate))
	B.use(B.charge)
	B.update_icon()
	return COMPONENT_NO_AFTERATTACK