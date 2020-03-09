/datum/component/hot_ice

/datum/component/hot_ice/Initialize()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby_react)
	RegisterSignal(parent, COMSIG_ATOM_FIRE_ACT, .proc/flame_react)

/datum/component/thermite/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)
	UnregisterSignal(parent, COMSIG_ATOM_FIRE_ACT)

/datum/component/hot_ice/proc/hot_ice_melt(mob/user as mob)
	var/turf/open/T = get_turf(parent)
	var/obj/item/stack/sheet/hot_ice = parent
	if(istype(hot_ice))
		T.atmos_spawn_air("plasma=[hot_ice.amount*500];TEMP=[hot_ice.amount*500]")
		message_admins("Plasma sheets ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(T)]")
		log_game("Plasma sheets ignited by [key_name(user)] in [AREACOORD(T)]")

/datum/component/hot_ice/proc/flame_react(datum/source, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		hot_ice_melt()

/datum/component/hot_ice/proc/attackby_react(datum/source, obj/item/thing, mob/user, params)
	if(thing.get_temperature())
		hot_ice_melt(user)
