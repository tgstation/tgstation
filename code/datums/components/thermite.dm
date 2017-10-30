/datum/component/thermite
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/amount
	var/overlay

	var/static/list/blacklist = typecacheof(/turf/closed/wall/mineral/diamond)
	var/static/list/resistlist = typecacheof(/turf/closed/wall/r_wall)

/datum/component/thermite/Initialize(_amount)
	if(!istype(parent, /turf))
		return COMPONENT_INCOMPATIBLE
	if(blacklist[parent.type])
		_amount*=0 //Yeah the overlay can still go on it and be cleaned but you arent burning down a diamond wall
	if(resistlist[parent.type])
		_amount*=0.25

	amount = _amount*10

	var/turf/master = parent
	overlay = mutable_appearance('icons/effects/effects.dmi', "thermite")
	master.add_overlay(overlay)

	RegisterSignal(COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_react)
	RegisterSignal(COMSIG_PARENT_ATTACKBY, .proc/attackby_react)
	RegisterSignal(COMSIG_ATOM_FIRE_ACT, .proc/flame_react)

/datum/component/thermite/Destroy()
	var/turf/master = parent
	master.cut_overlay(overlay)
	return ..()

/datum/component/thermite/InheritComponent(datum/component/thermite/newC, i_am_original)
	if(!i_am_original)
		return
	amount += newC.amount

/datum/component/thermite/proc/thermite_melt(mob/user)
	var/turf/master = parent
	master.cut_overlay(overlay)
	var/obj/effect/overlay/thermite/fakefire = new(master)

	playsound(master, 'sound/items/welder.ogg', 100, 1)

	if(amount >= 50)
		var/burning_time = max(100, 100-amount)
		master = master.ChangeTurf(master.baseturf)
		master.burn_tile()
		if(user)
			master.add_hiddenprint(user)
		QDEL_IN(fakefire, burning_time)
	else
		QDEL_IN(fakefire, 50)

/datum/component/thermite/proc/clean_react(strength)
	//Thermite is just some loose powder, you could probably clean it with your hands. << todo?
	qdel(src)

/datum/component/thermite/proc/flame_react(exposed_temperature, exposed_volume)
	if(exposed_temperature > 1922) // This is roughly the real life requirement to ignite thermite
		thermite_melt()

/datum/component/thermite/proc/attackby_react(obj/item/thing, mob/user, params)
	if(thing.is_hot())
		thermite_melt(user)