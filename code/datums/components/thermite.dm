/datum/component/thermite
	var/static/list/blacklist
	var/static/list/resistlist
	var/amount

/datum/component/thermite/Initialize(_amount)
	. = ..()
	blacklist = typecacheof(/turf/closed/wall/mineral/diamond)
	resistlist = typecacheof(/turf/closed/wall/r_wall)

	if(blacklist[parent.type])
		qdel(src)
		return
	if(resistlist[parent.type])
		_amount*=0.25

	amount = _amount*10

	if(!istype(parent, /turf))
		qdel(src)
		return

	var/turf/master = parent
	master.cut_overlays()
	master.add_overlay(mutable_appearance('icons/effects/effects.dmi', "thermite"))

	RegisterSignal(COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_react)
	RegisterSignal(COMSIG_PARENT_ATTACKBY, .proc/attackby_react)
	RegisterSignal(COMSIG_ATOM_FIRE_ACT, .proc/flame_react)

/datum/component/thermite/Destroy()
	var/turf/master = parent
	master.cut_overlays()
	return ..()

/datum/component/thermite/proc/thermite_melt(mob/user)
	var/turf/master = parent
	master.cut_overlays()
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
	qdel(src)

/datum/component/thermite/proc/flame_react(exposed_temperature, exposed_volume)
	if(exposed_temperature > 1922) // This is roughly the real life requirement to ignite thermite
		thermite_melt()

/datum/component/thermite/proc/attackby_react(obj/item/thing, mob/user, params)
	if(thing.is_hot())
		thermite_melt(user)

/obj/effect/overlay/thermite
	name = "thermite"
	desc = "Looks hot."
	icon = 'icons/effects/fire.dmi'
	icon_state = "2" //what?
	anchored = TRUE
	opacity = 1
	density = TRUE
	layer = FLY_LAYER