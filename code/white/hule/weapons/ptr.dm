/obj/item/gun/ballistic/shotgun/boltaction/ptr
	name = "AMATR M4ND4"
	desc = "Ого етож антиматериальное противотанковое ружье M4ND4"
	icon = 'code/white/hule/weapons/weapons.dmi'
	icon_state = "ptr"
	item_state = "ptr"
	lefthand_file = 'code/white/hule/weapons/guns96_lefthand.dmi'
	righthand_file = 'code/white/hule/weapons/guns96_righthand.dmi'
	inhand_x_dimension = -32
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/ptr
	can_bayonet = FALSE


/obj/item/ammo_box/magazine/internal/boltaction/ptr
	max_ammo = 1
	ammo_type = /obj/item/ammo_casing/a15mm
	caliber = "15mm"

/obj/item/ammo_casing/a15mm
	name = "15mm bullet casing"
	desc = "A 15mm bullet casing."
	icon = 'code/white/hule/weapons/weapons.dmi'
	icon_state = "15mm-casing"
	caliber = "15mm"
	projectile_type = /obj/item/projectile/bullet/a15mm

/obj/item/projectile/bullet/a15mm
	name = "15mm bullet"
	damage = 99
	speed = 0.5
	pass_flags = PASSTABLE | PASSGRILLE

/obj/item/projectile/bullet/a15mm/on_hit(atom/target)
	. = ..()
	if(istype(target, /obj/mecha))
		target.ex_act(EXPLODE_HEAVY)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(def_zone == BODY_ZONE_HEAD)
			var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
			head.drop_limb()
			playsound(src,'code/white/hule/weapons/headshot.ogg', 100, 5, pressure_affected = FALSE)

/obj/item/ammo_box/a15mm
	name = "ammo box (15mm)"
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "10mmbox" //haha prikol
	ammo_type = /obj/item/ammo_casing/a15mm
	max_ammo = 5
