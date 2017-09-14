/obj/mecha/working/ripley/mining_roundstart
	desc = "A complimentary APLU fitted with an array of tools suitable for mining, \
			courtesy of the Nanotrasen geological exploitation department.  \
			Don't forget to bring your minerals to the hard working boys at R&D \
			and not to pinch the ORM so they can upgrade it for you."
	name = "\improper APLU \"Miner\""

/obj/mecha/working/ripley/mining_roundstart/Initialize()
	. = ..()
	if(prob(15)) // Maybe get a diamond drill one every few rounds.
		var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new
		D.attach(src)
	else
		var/obj/item/mecha_parts/mecha_equipment/drill/D = new
		D.attach(src)

	if(prob(30)) //Or perhaps a free plasma cutter!
		var/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/P = new
		P.attach(src)

	cargo.Add(new /obj/structure/ore_box(src)) //Starts with its own nice little ore box.

	//A free clamp too, gosh am I generous!
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)

	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new //And a free scanner just for you!
	scanner.attach(src)