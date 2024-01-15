/obj/item/ammo_box
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/magazine
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/strilka310
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/a357
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/c38
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/c9mm/ap
	name = "ammo box (9mm AP)"
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/c9mm/hp
	name = "ammo box (9mm HP)"
	ammo_type = /obj/item/ammo_casing/c9mm/hp

/obj/item/ammo_box/c9mm/fire
	name = "ammo box (9mm incendiary)"
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
	name = "ammo box (10mm incendiary)"
	ammo_type = /obj/item/ammo_casing/c10mm/fire
	max_ammo = 20

/obj/item/ammo_box/c46x30mm
	name = "ammo box (4.6x30mm)"
	icon = 'modular_skyrat/modules/company_imports/icons/ammo.dmi'
	icon_state = "ammo_46"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	max_ammo = 20

/obj/item/ammo_box/c46x30mm/ap
	name = "ammo box (4.6x30mm AP)"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/c46x30mm/rubber
	name = "ammo box (4.6x30mm rubber)"
	ammo_type = /obj/item/ammo_casing/c46x30mm/rubber

/obj/item/ammo_box/c34
	name = "ammo box (.34)"
	icon = 'modular_skyrat/modules/company_imports/icons/ammo.dmi'
	icon_state = "ammo_34"
	ammo_type = /obj/item/ammo_casing/c34
	max_ammo = 20

/obj/item/ammo_box/c34/ap
	name = "ammo box (.34 AP)"
	ammo_type = /obj/item/ammo_casing/c34/ap

/obj/item/ammo_box/c34/rubber
	name = "ammo box (.34 rubber)"
	ammo_type = /obj/item/ammo_casing/c34/rubber

/obj/item/ammo_box/c34/fire
	name = "ammo box (.34 incendiary)"
	ammo_type = /obj/item/ammo_casing/c34_incendiary

/obj/item/ammo_box/c56mm
	name = "ammo box (5.6mm civilian)"
	desc = "5.6x40mm ammunition specifically made for civilian use like recreation, hunting, self-defense or LARP. While the package itself lacks any real identification \
	and does, in fact, appear like a bland green box with a colored stripe, the insides have a boatload of information, \
	ranging from manufacturer advertisements and intended use to the cartridge's tactical and technical characteristics."
	icon = 'modular_skyrat/modules/novaya_ert/icons/ammo_boxes.dmi'
	icon_state = "boxnrifle-lethal"
	base_icon_state = "boxnrifle-lethal"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	ammo_type = /obj/item/ammo_casing/realistic/a762x39/civilian
	max_ammo = 60

/obj/item/ammo_box/c56mm/rubber
	name = "ammo box (5.6mm rubber)"
	icon_state = "boxnrifle-rubber"
	base_icon_state = "boxnrifle-rubber"
	ammo_type = /obj/item/ammo_casing/realistic/a762x39/civilian/rubber

/obj/item/ammo_box/c56mm/hunting
	name = "ammo box (5.6mm hunting)"
	icon_state = "boxnrifle-hunting"
	base_icon_state = "boxnrifle-hunting"
	ammo_type = /obj/item/ammo_casing/realistic/a762x39/civilian/hunting

/obj/item/ammo_box/c56mm/blank
	name = "ammo box (5.6mm blank)"
	icon_state = "boxnrifle-blank"
	base_icon_state = "boxnrifle-blank"
	ammo_type = /obj/item/ammo_casing/realistic/a762x39/civilian/blank

/obj/item/storage/box/ammo_box/microfusion/bluespace
	name = "bluespace microfusion cell container"
	desc = "A box filled with microfusion cells."

/obj/item/storage/box/ammo_box/microfusion/bluespace/PopulateContents()
	new /obj/item/stock_parts/cell/microfusion/bluespace(src)
	new /obj/item/stock_parts/cell/microfusion/bluespace(src)
	new /obj/item/stock_parts/cell/microfusion/bluespace(src)
