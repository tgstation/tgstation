/obj/item/ammo_casing/energy/chameleon
	projectile_type = /obj/item/projectile/energy/chameleon
	e_cost = 0
	var/hitscan_mode = FALSE
	var/list/projectile_vars = list()

/obj/item/ammo_casing/energy/chameleon/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	. = ..()
	if(!BB)
		newshot()
	for(var/V in projectile_vars)
		if(BB.vars.Find(V))
			BB.vv_edit_var(V, projectile_vars[V])
	if(hitscan_mode)
		BB.hitscan = TRUE
