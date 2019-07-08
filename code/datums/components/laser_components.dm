/datum/component/extralasers
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/lens_path
	var/obj/item/ammo_casing/energy/ammo

/datum/component/extralasers/Initialize(_ammo, _lens_path)
	if(!istype(parent, /obj/item/gun/energy/laser))
		return COMPONENT_INCOMPATIBLE
	ammo = _ammo
	lens_path = _lens_path

/datum/component/extralasers/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby)
	var/obj/item/gun/energy/laser/L = parent
	ammo =  new ammo (src)
	L.ammo_type  += ammo

/datum/component/extralasers/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)
	var/obj/item/gun/energy/laser/L = parent
	if(L.chambered)
		L.chambered = null
	LAZYREMOVE(L.ammo_type, ammo)
	L.select_fire()
	L.recharge_newshot()
	L.update_icon(TRUE)

/datum/component/extralasers/proc/attackby(datum/source, obj/item/I, mob/user, params)
	. = ..()
	if(I.tool_behaviour == TOOL_CROWBAR)
		var/turf/T = get_turf(parent)
		new lens_path(T)
		qdel(src)

/datum/component/extralasers/InheritComponent(datum/newcomp, orig, list/arglist)
	. = ..()
	var/obj/item/gun/energy/laser/L = parent
	if(L.chambered)
		L.chambered = null
	LAZYREMOVE(L.ammo_type, ammo)
	L.select_fire()
	L.recharge_newshot()
	L.update_icon(TRUE)
	qdel(ammo)
	var/turf/T = get_turf(parent)
	new lens_path(T)

	ammo = arglist[1]
	ammo =  new ammo (src)
	L.ammo_type  += ammo
	lens_path = arglist[2]

/datum/component/extralasers/Destroy()
	. = ..()
	qdel(ammo)