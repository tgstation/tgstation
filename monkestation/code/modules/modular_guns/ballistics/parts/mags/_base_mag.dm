/obj/item/attachment/mag
	name = "generic mag"

	attachment_type = ATTACHMENT_TYPE_MAG
	var/accepted_magazine_type = /obj/item/ammo_box/magazine/m10mm

/obj/item/attachment/mag/unique_attachment_effects(obj/item/gun/ballistic/modular/modular)
	modular.accepted_magazine_type = accepted_magazine_type
	modular.mag_icon_state = icon_state
