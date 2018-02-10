/datum/relic_effect/activate
	var/range = 0

/datum/relic_effect/activate/apply_to_component(obj/item/A,datum/component/relic/comp)
	if(range)
		comp.RegisterSignal(COMSIG_ITEM_AFTER_ATTACK, CALLBACK(src, .proc/activate, A))
	else
		comp.RegisterSignal(COMSIG_ITEM_ATTACK_SELF, CALLBACK(src, .proc/activate, A, A))

/datum/relic_effect/activate/proc/activate(obj/item/A,atom/target,mob/user)
	var/datum/component/relic/comp = A.GetComponent(/datum/component/relic)
	if(!comp.can_use())
		to_chat(user, "<span class='warning'>[A] does not react!</span>")
		return FALSE
	comp.use_charge()
	return TRUE

/datum/relic_effect/activate/smoke
	var/radius = 2

/datum/relic_effect/activate/smoke/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(radius, get_turf(target))
	smoke.start()

/datum/relic_effect/activate/flash/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	var/obj/item/grenade/flashbang/CB = new(get_turf(target))
	CB.prime()

/datum/relic_effect/activate/clean/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	var/obj/item/grenade/chem_grenade/cleaner/CL = new(get_turf(target))
	CL.prime()

/datum/relic_effect/activate/corgi_cannon/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	var/mob/living/simple_animal/pet/dog/corgi/C = new(get_turf(A))
	if(range)
		C.throw_at(target, 10, rand(3,8))
	else
		C.throw_at(pick(oview(10,user)), 10, rand(3,8))