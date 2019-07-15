/datum/component/thermite
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/amount
	var/overlay

	var/static/list/blacklist = typecacheof(list(
		/turf/open/lava,
		/turf/open/space,
		/turf/open/water,
		/turf/open/chasm)
		)

	var/static/list/immunelist = typecacheof(list(
		/turf/closed/wall/mineral/diamond,
		/turf/closed/indestructible,
		/turf/open/indestructible)
		)
	
	var/static/list/resistlist = typecacheof(
		/turf/closed/wall/r_wall
		)

/datum/component/thermite/Initialize(_amount)
	if(!istype(parent, /turf) || blacklist[parent.type])
		return COMPONENT_INCOMPATIBLE
	if(immunelist[parent.type])
		_amount*=0 //Yeah the overlay can still go on it and be cleaned but you arent burning down a diamond wall
	if(resistlist[parent.type])
		_amount*=0.25

	amount = _amount*10

	var/turf/master = parent
	overlay = mutable_appearance('icons/effects/effects.dmi', "thermite")
	master.add_overlay(overlay)

	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_react)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby_react)
	RegisterSignal(parent, COMSIG_ATOM_FIRE_ACT, .proc/flame_react)

/datum/component/thermite/Destroy()
	var/turf/master = parent
	master.cut_overlay(overlay)
	return ..()

/datum/component/thermite/InheritComponent(datum/component/thermite/newC, i_am_original, list/arguments)
	if(!i_am_original)
		return
	if(newC)
		amount += newC.amount
	else
		amount += arguments[1]

/datum/component/thermite/proc/thermite_melt(mob/user)
	var/turf/master = parent
	master.cut_overlay(overlay)
	var/obj/effect/overlay/thermite/fakefire = new(master)

	playsound(master, 'sound/items/welder.ogg', 100, 1)

	if(amount >= 50)
		var/burning_time = max(100, 100-amount)
		master = master.Melt()
		master.burn_tile()
		if(user)
			master.add_hiddenprint(user)
		QDEL_IN(fakefire, burning_time)
	else
		QDEL_IN(fakefire, 50)

/datum/component/thermite/proc/clean_react(datum/source, strength)
	//Thermite is just some loose powder, you could probably clean it with your hands. << todo?
	qdel(src)

/datum/component/thermite/proc/flame_react(datum/source, exposed_temperature, exposed_volume)
	if(exposed_temperature > 1922) // This is roughly the real life requirement to ignite thermite
		thermite_melt()

/datum/component/thermite/proc/attackby_react(datum/source, obj/item/thing, mob/user, params)
	if(thing.is_hot())
		thermite_melt(user)
