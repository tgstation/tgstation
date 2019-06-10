/datum/component/extralasers
	var/obj/item/external_lens/lens
	var/obj/item/ammo_casing/energy/laser/ammo

/datum/component/extralasers/Initialize(ammo, _lens)
	lens = _lens
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/detach)

	var/obj/item/ammo_casing/energy/laser/shoot =  ammo
	var/obj/item/gun/energy/laser/L = parent
	L.ammo_type  += new shoot (src)

/datum/component/extralasers/proc/detach(datum/source, obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		var/obj/item/gun/energy/laser/L = parent
		L.chambered = null
		var/obj/item/ammo_casing/energy/R = LAZYACCESS(L.ammo_type, L.ammo_type.len)
		LAZYREMOVE(L.ammo_type, R)
		L.select_fire(user)
		L.recharge_newshot()
		lens.forceMove(user.loc)
		L.update_icon(TRUE)
		L.modifystate = FALSE
		RemoveComponent()
		return TRUE