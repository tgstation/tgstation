/obj/mecha/combat/mime
	desc = "A lightweight, security exosuit. Popular among private and corporate security."
	name = "\improper Recitence"
	icon_state = "gygax"
	step_in = 3
	dir_in = 1 //Facing North.
	health = 100
	deflect_chance = 5
	damage_absorption = list("brute"=0.75,"fire"=1,"bullet"=0.8,"laser"=0.7,"energy"=0.85,"bomb"=1)
	max_temperature = 25000
	infra_luminosity = 6
	wreckage = /obj/structure/mecha_wreckage/gygax
	internal_damage_threshold = 35
	max_equip = 2
	step_energy_drain = 3
	color = "#00000010"

/obj/mecha/combat/mime/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tool/rcd //HAHA IT MAKES WALLS GET IT
	ME.attach(src)
	return