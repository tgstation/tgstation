/obj/item/ammo_box/c9mm/ap
	name = "ammo box (9mm AP)"
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/c9mm/hp
	name = "ammo box (9mm HP)"
	ammo_type = /obj/item/ammo_casing/c9mm/hp

/obj/item/ammo_box/c9mm/fire
	name = "ammo box (9mm Incen)"
	ammo_type = /obj/item/ammo_casing/c9mm/fire

/obj/item/ammo_box/c10mm/ap
	name = "ammo box (10mm AP)"
	ammo_type = /obj/item/ammo_casing/c10mm/ap
	max_ammo = 20

/obj/item/ammo_box/c10mm/hp
	name = "ammo box (10mm HP)"
	ammo_type = /obj/item/ammo_casing/c10mm/hp
	max_ammo = 20

/obj/item/ammo_box/c10mm/fire
	name = "ammo box (10mm Incen)"
	ammo_type = /obj/item/ammo_casing/c10mm/fire
	max_ammo = 20

/obj/item/ammo_box/c46x30mm
	name = "ammo box (4.6x30mm)"
	icon = 'modular_skyrat/modules/gun_cargo/icons/ammo.dmi'
	icon_state = "ammo_46"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	max_ammo = 20

/obj/item/ammo_box/c46x30mm/ap
	name = "ammo box (4.6x30mm AP)"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/c46x30mm/rubber
	name = "ammo box (4.6x30mm Rubber)"
	ammo_type = /obj/item/ammo_casing/c46x30mm/rubber

/obj/item/ammo_box/c32
	name = "ammo box (.32)"
	icon = 'modular_skyrat/modules/gun_cargo/icons/ammo.dmi'
	icon_state = "ammo_32"
	ammo_type = /obj/item/ammo_casing/c32
	max_ammo = 20

/obj/item/ammo_box/c32/ap
	name = "ammo box (.32 AP)"
	ammo_type = /obj/item/ammo_casing/c32/ap

/obj/item/ammo_box/c32/rubber
	name = "ammo box (.32 Rubber)"
	ammo_type = /obj/item/ammo_casing/c32/rubber

/obj/item/ammo_box/c32/fire
	name = "ammo box (.32 Incen)"
	ammo_type = /obj/item/ammo_casing/c32_incendiary

/obj/item/ammo_box/c34
	name = "ammo box (.34)"
	icon = 'modular_skyrat/modules/gun_cargo/icons/ammo.dmi'
	icon_state = "ammo_34"
	ammo_type = /obj/item/ammo_casing/c34
	max_ammo = 20

/obj/item/ammo_box/c34/ap
	name = "ammo box (.34 AP)"
	ammo_type = /obj/item/ammo_casing/c34/ap

/obj/item/ammo_box/c34/rubber
	name = "ammo box (.34 Rubber)"
	ammo_type = /obj/item/ammo_casing/c34/rubber

/obj/item/ammo_box/c34/fire
	name = "ammo box (.34 Incen)"
	ammo_type = /obj/item/ammo_casing/c34_incendiary

/obj/item/ammo_box/c12mm
	name = "ammo box (12mm)"
	icon = 'modular_skyrat/modules/gun_cargo/icons/ammo.dmi'
	icon_state = "ammo_12mm"
	ammo_type = /obj/item/ammo_casing/c12mm
	max_ammo = 20

/obj/item/ammo_box/c12mm/ap
	name = "ammo box (12mm AP)"
	ammo_type = /obj/item/ammo_casing/c12mm/ap

/obj/item/ammo_box/c12mm/hp
	name = "ammo box (12mm HP)"
	ammo_type = /obj/item/ammo_casing/c12mm/hp

/obj/item/ammo_box/c12mm/fire
	name = "ammo box (12mm Incen)"
	ammo_type = /obj/item/ammo_casing/c12mm/fire

/obj/item/storage/box/ammo_box/microfusion/bluespace
	name = "bluespace microfusion cell container"
	desc = "A box filled with microfusion cells."

/obj/item/storage/box/ammo_box/microfusion/bluespace/PopulateContents()
	new /obj/item/storage/bag/ammo(src)
	new /obj/item/stock_parts/cell/microfusion/bluespace(src)
	new /obj/item/stock_parts/cell/microfusion/bluespace(src)
	new /obj/item/stock_parts/cell/microfusion/bluespace(src)

/obj/item/storage/box/ammo_box/microfusion/bluespace/bagless

/obj/item/storage/box/ammo_box/microfusion/bluespace/bagless/PopulateContents()
	new /obj/item/stock_parts/cell/microfusion/bluespace(src)
	new /obj/item/stock_parts/cell/microfusion/bluespace(src)
	new /obj/item/stock_parts/cell/microfusion/bluespace(src)

/obj/item/ammo_box/b10mm
	name = "ammo box (10mm Auto)"
	ammo_type = /obj/item/ammo_casing/b10mm
	max_ammo = 20

/obj/item/ammo_box/b10mm/hp
	name = "ammo box (10mm Auto HP)"
	ammo_type = /obj/item/ammo_casing/b10mm/hp
	max_ammo = 20

/obj/item/ammo_box/b10mm/rubber
	name = "ammo box (10mm Auto Rubber)"
	ammo_type = /obj/item/ammo_casing/b10mm/rubber
	max_ammo = 20
