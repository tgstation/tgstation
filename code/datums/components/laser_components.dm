/datum/component/extralasers
	var/lens_path
	var/obj/item/ammo_casing/energy/ammo
	var/user

/datum/component/extralasers/Initialize(_ammo, _lens_path, lens)
	if(!istype(parent, /obj/item/gun/energy/laser))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/gun/energy/laser/L = parent
	ammo =  new _ammo (src)
	L.ammo_type  += ammo
	lens_path = _lens_path
	qdel(lens)

/datum/component/extralasers/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby)

/datum/component/extralasers/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)

/datum/component/extralasers/proc/attackby(datum/source, obj/item/I, mob/user, params)
	. = ..()
	if(I.tool_behaviour == TOOL_CROWBAR && istype(I, /obj/item/external_lens))
		detach(source, user)

/datum/component/extralasers/proc/detach(datum/source, mob/user)
	if(parent)
		var/obj/item/gun/energy/laser/L = parent
		L?.chambered = null
		if(L.ammo_type.len)
			LAZYREMOVE(L.ammo_type, ammo)
		L.select_fire(user)
		L.recharge_newshot()
		L.update_icon(TRUE)
		var/turf/T = get_turf(parent)
		new lens_path(T)
		qdel(src)