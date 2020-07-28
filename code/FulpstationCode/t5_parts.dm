//T5 DESIGNS[XEON/FULP]
/datum/design/quantum_cap
	name = "Quantum Capacitor"
	desc = "A capacitor engineered with a mix of bluespace and quantum technologies."
	id = "quantumcap"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron =225, /datum/material/glass =180, /datum/material/gold =135, /datum/material/diamond = 90)
	build_path = /obj/item/stock_parts/capacitor/quantumcap
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quantum_scan
	name = "Quantum field scanning module"
	desc = "A special scanning module using a mix of bluespace and quantum tech to scan even sub-atomic materials."
	id = "quantumscan"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron= 225, /datum/material/glass = 180, /datum/material/diamond = 54, /datum/material/bluespace = 54)
	build_path = /obj/item/stock_parts/scanning_module/quantumscan
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quantum_manip
	name = "Quantum field manipulator"
	desc = "A strange, almost intangible manipulator that uses bluespace tech to manipulate and fold quantum states."
	id = "quantummanip"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron= 180, /datum/material/diamond = 27, /datum/material/titanium = 27, /datum/material/uranium = 27)
	build_path = /obj/item/stock_parts/manipulator/quantummanip
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quantum_laser
	name = "Quantum micro-laser"
	desc = "A modified quadultra micro-laser designed to make use of newly discovered quantum tech."
	id = "quantumlaser"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron= 180, /datum/material/glass = 180, /datum/material/uranium = 90, /datum/material/diamond = 90)
	build_path = /obj/item/stock_parts/micro_laser/quantumlaser
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quantum_bin
	name = "Entangled matter bin"
	desc = "A bluespace matter bin that makes use of entangled particles to store states of materials as energy."
	id = "quantumbin"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron= 225, /datum/material/diamond = 90, /datum/material/bluespace = 135)
	build_path = /obj/item/stock_parts/matter_bin/quantumbin
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quantum_cell
	name = "Quantum Power Cell"
	desc = "A rechargeable, entangled power cell."
	id = "quantumcell"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 5500, /datum/material/plasma = 3500, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/stock_parts/cell/quantum/empty
	category = list("Power Designs","Misc")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quantum_beaker
	name = "Quantum Beaker"
	desc = "A quantum entangled beaker, capable of holding a massive 400 units of any reagent."
	id = "quantumbeaker"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 5000, /datum/material/plasma = 3000, /datum/material/diamond = 1500, /datum/material/bluespace = 1500)
	build_path = /obj/item/reagent_containers/glass/beaker/quantum
	category = list("Medical Designs")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//T5 PARTS TECHWEB [XEON/FULP]
/datum/techweb_node/quantum_tech
	id = "quantum_tech"
	starting_node = FALSE
	display_name = "Quantum Tech"
	description = "Strange modified bluespace stock parts, with a dash of quantum physics mixed in."
	design_ids = list("quantumscan","quantummanip","quantumbin","quantumbeaker")
	prereq_ids = list("micro_bluespace")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

//T5 OBJECT [XEON/FULP]

/obj/item/stock_parts/capacitor/quantumcap
	name = "Quantum Capacitor"
	desc = "A capacitor engineered with a mix of bluespace and quantum technologies."
	icon_state = "quantumcap"
	icon = 'icons/Fulpicons/quantumcell_fulp.dmi'
	rating = 5
	custom_materials = list(/datum/material/iron =225, /datum/material/glass =180, /datum/material/gold =135, /datum/material/diamond = 90)

/obj/item/stock_parts/scanning_module/quantumscan
	name = "quantum field scanning module"
	desc = "A special scanning module using a mix of bluespace and quantum tech to scan even sub-atomic materials."
	icon_state = "quantumscan"
	icon = 'icons/Fulpicons/quantumcell_fulp.dmi'
	rating = 5
	custom_materials = list(/datum/material/iron= 225, /datum/material/glass = 180, /datum/material/diamond = 54, /datum/material/bluespace = 54)

/obj/item/stock_parts/manipulator/quantummanip
	name = "quantum field manipulator"
	desc = "A strange, almost intangible manipulator that uses bluespace tech to manipulate and fold quantum states."
	icon_state = "quantummanip"
	icon = 'icons/Fulpicons/quantumcell_fulp.dmi'
	rating = 5
	custom_materials = list(/datum/material/iron= 180, /datum/material/diamond = 27, /datum/material/titanium = 27, /datum/material/uranium = 27)

/obj/item/stock_parts/micro_laser/quantumlaser
	name = "quantum micro-laser"
	desc = "A modified quadultra micro-laser designed to make use of newly discovered quantum tech."
	icon_state = "quantumlaser"
	icon = 'icons/Fulpicons/quantumcell_fulp.dmi'
	rating = 5
	custom_materials = list(/datum/material/iron= 180, /datum/material/glass = 180, /datum/material/uranium = 90, /datum/material/diamond = 90)

/obj/item/stock_parts/matter_bin/quantumbin
	name = "quantum entangled matter bin"
	desc = "A bluespace matter bin that makes use of entangled particles to store states of materials as energy."
	icon_state = "quantumbin"
	icon = 'icons/Fulpicons/quantumcell_fulp.dmi'
	rating = 5
	custom_materials = list(/datum/material/iron= 225, /datum/material/diamond = 90, /datum/material/bluespace = 135)

/obj/item/reagent_containers/glass/beaker/quantum
	name = "quantum entangled beaker"
	desc = "A quantum entangled beaker, capable of holding a massive 400 units of any reagent."
	icon_state = "quantumbeaker"
	icon = 'icons/Fulpicons/quantumcell_fulp.dmi'
	custom_materials = list(/datum/material/iron = 500, /datum/material/glass = 5000, /datum/material/plasma = 3000, /datum/material/diamond = 1500, /datum/material/bluespace = 1500)
	volume = 400
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100,300)

/obj/item/stock_parts/cell/quantum
	name = "quantum power cell"
	desc = "A rechargeable, entangled power cell."
	icon_state = "quantumcell"
	icon = 'icons/Fulpicons/quantumcell_fulp.dmi'
	maxcharge = 50000
	custom_materials = list(/datum/material/iron = 1000, /datum/material/glass = 5500, /datum/material/plasma = 3500, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)
	chargerate = 5000
	rating = 6

/obj/item/stock_parts/cell/quantum/empty/Initialize()
	. = ..()
	charge = 0
	update_icon()

///T5 RPED
/obj/item/storage/part_replacer/bluespace/tier5

/obj/item/storage/part_replacer/bluespace/tier5/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor/quantumcap(src)
		new /obj/item/stock_parts/scanning_module/quantumscan(src)
		new /obj/item/stock_parts/manipulator/quantummanip(src)
		new /obj/item/stock_parts/micro_laser/quantumlaser(src)
		new /obj/item/stock_parts/matter_bin/quantumbin(src)
		new /obj/item/reagent_containers/glass/beaker/quantum(src)

////9/18/19 BUGFIX/ADDITIONS BELOW////
/datum/techweb_node/quantum_tech_power
	id = "quantum_tech_power"
	starting_node = FALSE
	display_name = "Quantum Power Technology"
	description = "Quantum based power technologies, making apt use of newly discovered Bluespace Folds and Quantum Tears"
	design_ids = list("quantumcap","quantumcell")
	prereq_ids = list("bluespace_power")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/datum/techweb_node/quantum_tech_laser //Renamed 10/3/19, fixed a spelling mistake -Xeon
	id = "quantum_tech_laser"
	starting_node = FALSE
	display_name = "Integrated Quantum Laser Theory"
	description = "Improved quantum technologies that shake the foundations of the focal sciences. How far is too far?"
	design_ids = list("quantumlaser")
	prereq_ids = list("emp_super")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

///10/3/19 Update BELOW///

///T5 Motorized wheelchair code///

/obj/vehicle/ridden/wheelchair/motorized/proc/RunOver(var/mob/living/carbon/H)
	var/bloodiness = 0
	log_combat(src, H, "run over", null, "(DAMTYPE: [uppertext(BRUTE)])")
	H.visible_message("<span class='danger'>[src] runs [H] over!</span>", "<span class='userdanger'>[src] runs you over!</span>")
	playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)

	var/damage = rand(7,9) //Choose a number between 7 and 9, then use that number for the damage calculations applied to the head, chest, legs and arms.
	H.apply_damage(2*damage, BRUTE, BODY_ZONE_HEAD, H.run_armor_check(BODY_ZONE_HEAD, "melee"))
	H.apply_damage(2*damage, BRUTE, BODY_ZONE_CHEST, H.run_armor_check(BODY_ZONE_CHEST, "melee"))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_L_LEG, H.run_armor_check(BODY_ZONE_L_LEG, "melee"))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_R_LEG, H.run_armor_check(BODY_ZONE_R_LEG, "melee"))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_L_ARM, H.run_armor_check(BODY_ZONE_L_ARM, "melee"))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_R_ARM, H.run_armor_check(BODY_ZONE_R_ARM, "melee")) //in total, this will be 42-54 damage (before the application of melee armor)
	if(islizard(H)) //If H (target) is a lizard, deal 0.5*var/damage to their tail. Sorry rico!
		H.adjustOrganLoss(ORGAN_SLOT_TAIL, 0.5*damage)
	H.Knockdown(85)
	H.adjustStaminaLoss(40)

	var/turf/T = get_turf(src)
	T.add_mob_blood(H)

	var/list/blood_dna = H.get_blood_dna_list()
	add_blood_DNA(blood_dna)
	bloodiness += 4
