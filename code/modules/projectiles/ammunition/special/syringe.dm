/obj/item/ammo_casing/syringegun
	name = "syringe gun spring"
	desc = "A high-power spring that throws syringes."
	slot_flags = null
	projectile_type = /obj/projectile/bullet/dart/syringe
	firing_effect_type = null

/obj/item/ammo_casing/syringegun/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!loaded_projectile)
		return
	if(istype(loc, /obj/item/gun/syringe))
		var/obj/item/gun/syringe/SG = loc
		if(!SG.syringes.len)
			return

		var/obj/item/reagent_containers/syringe/S = SG.syringes[1]

		S.reagents.trans_to(loaded_projectile, S.reagents.total_volume, transfered_by = user)
		loaded_projectile.name = S.name
		var/obj/projectile/bullet/dart/D = loaded_projectile
		D.piercing = S.proj_piercing
		SG.syringes.Remove(S)
		qdel(S)
	else if(istype(loc, /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun))
		var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/syringe_gun = loc
		var/obj/item/reagent_containers/syringe/loaded_syringe = syringe_gun.syringes[1]
		var/obj/projectile/bullet/dart/shot_dart = loaded_projectile
		syringe_gun.reagents.trans_to(shot_dart, min(loaded_syringe.volume, syringe_gun.reagents.total_volume), transfered_by = user)
		shot_dart.name = loaded_syringe.name
		shot_dart.piercing = loaded_syringe.proj_piercing
		LAZYREMOVE(syringe_gun.syringes, loaded_syringe)
		qdel(loaded_syringe)
	return ..()

/obj/item/ammo_casing/chemgun
	name = "dart synthesiser"
	desc = "A high-power spring, linked to an energy-based piercing dart synthesiser."
	projectile_type = /obj/projectile/bullet/dart/piercing
	firing_effect_type = null

/obj/item/ammo_casing/chemgun/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!loaded_projectile)
		return
	if(istype(loc, /obj/item/gun/chem))
		var/obj/item/gun/chem/CG = loc
		if(CG.syringes_left <= 0)
			return
		CG.reagents.trans_to(loaded_projectile, 15, transfered_by = user)
		loaded_projectile.name = "piercing chemical dart"
		CG.syringes_left--
	return ..()

/obj/item/ammo_casing/dnainjector
	name = "rigged syringe gun spring"
	desc = "A high-power spring that throws DNA injectors."
	projectile_type = /obj/projectile/bullet/dnainjector
	firing_effect_type = null

/obj/item/ammo_casing/dnainjector/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!loaded_projectile)
		return
	if(istype(loc, /obj/item/gun/syringe/dna))
		var/obj/item/gun/syringe/dna/SG = loc
		if(!SG.syringes.len)
			return

		var/obj/item/dnainjector/S = popleft(SG.syringes)
		var/obj/projectile/bullet/dnainjector/D = loaded_projectile
		S.forceMove(D)
		D.injector = S
	return ..()
