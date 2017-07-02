/obj/item/ammo_casing/magic
	name = "magic casing"
	desc = "I didn't even know magic needed ammo..."
	projectile_type = /obj/item/projectile/magic
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/magic

/obj/item/ammo_casing/magic/change
	projectile_type = /obj/item/projectile/magic/change

/obj/item/ammo_casing/magic/animate
	projectile_type = /obj/item/projectile/magic/animate

/obj/item/ammo_casing/magic/heal
	projectile_type = /obj/item/projectile/magic/resurrection

/obj/item/ammo_casing/magic/death
	projectile_type = /obj/item/projectile/magic/death

/obj/item/ammo_casing/magic/teleport
	projectile_type = /obj/item/projectile/magic/teleport

/obj/item/ammo_casing/magic/door
	projectile_type = /obj/item/projectile/magic/door

/obj/item/ammo_casing/magic/fireball
	projectile_type = /obj/item/projectile/magic/aoe/fireball

/obj/item/ammo_casing/magic/chaos
	projectile_type = /obj/item/projectile/magic

/obj/item/ammo_casing/magic/spellblade
	projectile_type = /obj/item/projectile/magic/spellblade

/obj/item/ammo_casing/magic/arcane_barrage
	projectile_type = /obj/item/projectile/magic/arcane_barrage

/obj/item/ammo_casing/magic/chaos/newshot()
	..()

/obj/item/ammo_casing/magic/honk
	projectile_type = /obj/item/projectile/bullet/honker

/obj/item/ammo_casing/syringegun
	name = "syringe gun spring"
	desc = "A high-power spring that throws syringes."
	projectile_type = /obj/item/projectile/bullet/dart/syringe
	firing_effect_type = null

/obj/item/ammo_casing/syringegun/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!BB)
		return
	if(istype(loc, /obj/item/weapon/gun/syringe))
		var/obj/item/weapon/gun/syringe/SG = loc
		if(!SG.syringes.len)
			return

		var/obj/item/weapon/reagent_containers/syringe/S = SG.syringes[1]

		S.reagents.trans_to(BB, S.reagents.total_volume)
		BB.name = S.name
		var/obj/item/projectile/bullet/dart/D = BB
		D.piercing = S.proj_piercing
		SG.syringes.Remove(S)
		qdel(S)
	..()

/obj/item/ammo_casing/dnainjector
	name = "rigged syringe gun spring"
	desc = "A high-power spring that throws DNA injectors."
	projectile_type = /obj/item/projectile/bullet/dnainjector
	firing_effect_type = null

/obj/item/ammo_casing/dnainjector/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!BB)
		return
	if(istype(loc, /obj/item/weapon/gun/syringe/dna))
		var/obj/item/weapon/gun/syringe/dna/SG = loc
		if(!SG.syringes.len)
			return

		var/obj/item/weapon/dnainjector/S = popleft(SG.syringes)
		var/obj/item/projectile/bullet/dnainjector/D = BB
		S.forceMove(D)
		D.injector = S
	..()

/obj/item/ammo_casing/energy/c3dbullet
	projectile_type = /obj/item/projectile/bullet/midbullet3
	select_name = "spraydown"
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	e_cost = 20
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect
