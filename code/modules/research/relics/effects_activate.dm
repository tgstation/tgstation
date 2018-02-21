//Untargetted activate
/datum/relic_effect/activate
	var/range = 0
	hogged_signals = list(COMSIG_ITEM_AFTER_ATTACK,COMSIG_ITEM_ATTACK_SELF)

/datum/relic_effect/activate/init()
	..()
	if(prob(30))
		range = rand(1,6)
	if(range)
		hint = list("It has something akin to a pistol trigger.","It appears to have some sort of antennae.")
	else
		hint = list("There's a small button it's back.","It vibrates when touched.")
	hogged_signals = list(range ? COMSIG_ITEM_AFTER_ATTACK : COMSIG_ITEM_ATTACK_SELF)

/datum/relic_effect/activate/apply_to_component(obj/item/A,datum/component/relic/comp)
	if(range)
		comp.RegisterSignal(COMSIG_ITEM_AFTER_ATTACK, CALLBACK(src, .proc/activate, A))
	else
		comp.RegisterSignal(COMSIG_ITEM_ATTACK_SELF, CALLBACK(src, .proc/activate, A, A))

/datum/relic_effect/activate/proc/activate(obj/item/A,atom/target,mob/user)
	if(range && !(target in view(range, get_turf(user))))
		return FALSE
	return use_power(A,user)

//React to explosions, emp, heat, radiation, acid, projectiles
/datum/relic_effect/reaction
	hogged_signals = list()
	var/list/valid_reaction_signals = list(COMSIG_ATOM_EX_ACT,COMSIG_ATOM_EMP_ACT,COMSIG_ATOM_FIRE_ACT,COMSIG_ATOM_BULLET_ACT,COMSIG_ATOM_ACID_ACT,COMSIG_ATOM_RAD_ACT)
	var/required_heat = 0
	var/required_radiation = 0

/datum/relic_effect/reaction/init()
	var/times = rand(1,valid_reaction_signals.len)
	for(var/i in 1 to times)
		hogged_signals += pick_n_take(valid_reaction_signals)
	if(prob(80))
		required_heat = rand(1000,30000)
	if(prob(20))
		required_radiation = rand(10,1000)

/datum/relic_effect/reaction/apply_to_component(obj/item/A,datum/component/relic/comp)
	for(var/signal in hogged_signals)
		switch(signal)
			if(COMSIG_ATOM_FIRE_ACT)
				comp.RegisterSignal(signal, CALLBACK(src, .proc/fire_react, A))
			if(COMSIG_ATOM_RAD_ACT)
				comp.RegisterSignal(signal, CALLBACK(src, .proc/rad_react, A))
			else
				comp.RegisterSignal(signal, CALLBACK(src, .proc/react, A))

/datum/relic_effect/reaction/proc/react(obj/item/A)

/datum/relic_effect/reaction/proc/fire_react(obj/item/A,exposed_temperature)
	if(exposed_temperature > required_heat)
		react(A)

/datum/relic_effect/reaction/proc/rad_react(obj/item/A,intensity)
	if(intensity > required_radiation)
		react(A)

/datum/relic_effect/reaction/activate
	weight = 20
	var/datum/relic_effect/activate/internal

/datum/relic_effect/reaction/activate/init()
	var/internaltype = pick(subtypesof(/datum/relic_effect/activate))
	internal = new internaltype()
	internal.init()
	internal.free = TRUE

/datum/relic_effect/reaction/activate/react(obj/item/A)
	if(..())
		internal.activate(A,A)