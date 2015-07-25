/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	req_tech = list("materials" = 2, "biotech" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 2000, MAT_GLASS = 500, MAT_URANIUM = 500)
	category = "Misc"
	build_path = /obj/item/weapon/gun/energy/floragun

/datum/design/janicart_upgrade
	name = "Janicart Upgrade Module"
	desc = "Used to allow the janicart to clean surfaces while moving."
	id = "janicart_upgrade"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/mecha_parts/janicart_upgrade
	req_tech = list("engineering" = 1, "materials" = 1)
	materials = list(MAT_IRON=10000)
	category = "Misc"
