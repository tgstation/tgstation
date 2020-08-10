///Cheaper roundstart avaiable version of ripley, is a little bit faster but has less equipment slots and is less tanky
/obj/mecha/working/jerry
	desc = "Nanotransen has provided these cheap mass-manufactured ripley knockoffs from space-china. They are a little bit faster than ripley but are much less tough"
	name = "10-CNT"
	icon_state = "jerry"
	max_temperature = 6500
	max_integrity = 150
	step_in = 1.4
	resistance_flags = FIRE_PROOF | ACID_PROOF
	lights_power = 7
	deflect_chance = 10
	step_energy_drain = 15 //slightly higher energy drain since you movin those wheels FAST
	armor = list("melee" = 20, "bullet" = 10, "laser" = 20, "energy" = 10, "bomb" = 60, "bio" = 0, "rad" = 70, "fire" = 100, "acid" = 100)
	max_equip = 4
	wreckage = /obj/structure/mecha_wreckage/jerry
	enter_delay = 40
	/// Handles an internal ore box for jerry
	var/obj/structure/ore_box/box

/obj/mecha/working/jerry/Initialize()
	. = ..()
	box = new /obj/structure/ore_box(src)
	var/obj/item/mecha_parts/mecha_equipment/orebox_manager/ME = new(src)
	ME.attach(src)

/obj/mecha/working/jerry/Destroy()
	box.dump_box_contents()
	return ..()
