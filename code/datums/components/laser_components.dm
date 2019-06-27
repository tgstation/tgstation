/datum/component/extralasers
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/lens_path
	var/obj/item/ammo_casing/energy/ammo

/datum/component/extralasers/Initialize(_ammo, _lens_path)
	if(!istype(parent, /obj/item/gun/energy/laser))
		return COMPONENT_INCOMPATIBLE
	attach(_ammo, _lens_path)

/datum/component/extralasers/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby)

/datum/component/extralasers/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)

/datum/component/extralasers/proc/attackby(datum/source, obj/item/I, mob/user, params)
	. = ..()
	if(I.tool_behaviour == TOOL_CROWBAR)
		detach(TRUE)

/datum/component/extralasers/proc/attach(obj/item/ammo_casing/energy/_ammo, _lens_path)
	var/obj/item/gun/energy/laser/L = parent
	ammo =  new _ammo (src)
	L.ammo_type  += ammo
	lens_path = _lens_path

/datum/component/extralasers/proc/detach(breaklens = FALSE)
	var/obj/item/gun/energy/laser/L = parent
	L?.chambered = null
	if(L.ammo_type.len)
		LAZYREMOVE(L.ammo_type, ammo)
	L.select_fire()
	L.recharge_newshot()
	L.update_icon(TRUE)
	var/turf/T = get_turf(parent)
	new lens_path(T)
	if(breaklens)
		qdel(src)

/datum/component/extralasers/InheritComponent(datum/newcomp, orig, list/arglist)
	. = ..()
	detach()
	attach(arglist[1],arglist[2])