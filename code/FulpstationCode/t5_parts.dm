//T5 DESIGNS[XEON/FULP]
/datum/design/quantum_cap
	name = "Quantum Capacitor"
	desc = "A capacitor engineered with a mix of bluespace and quantum technologies."
	id = "quantumcap"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1)
	build_path = /obj/item/stock_parts/capacitor/quantumcap
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quantum_scan
	name = "Quantum field scanning module"
	desc = "A special scanning module using a mix of bluespace and quantum tech to scan even sub-atomic materials."
	id = "quantumscan"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1)
	build_path = /obj/item/stock_parts/scanning_module/quantumscan
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quantum_manip
	name = "Quantum field manipulator"
	desc = "A strange, almost intangible manipulator that uses bluespace tech to manipulate and fold quantum states."
	id = "quantummanip"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1)
	build_path = /obj/item/stock_parts/manipulator/quantummanip
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quantum_laser
	name = "Quantum micro-laser"
	desc = "A modified quadultra micro-laser designed to make use of newly discovered quantum tech."
	id = "quantumlaser"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1)
	build_path = /obj/item/stock_parts/micro_laser/quantumlaser
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quantum_bin
	name = "Entangled matter bin"
	desc = "A bluespace matter bin that makes use of entangled particles to store states of materials as energy."
	id = "quantumbin"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1)
	build_path = /obj/item/stock_parts/matter_bin/quantumbin
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quantum_cell
	name = "Quantum Power Cell"
	desc = "A rechargeable, entangled power cell."
	id = "quantumcell"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1)
	build_path = /obj/item/stock_parts/cell/quantum
	category = list("Stock Parts") //Needs proper location
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quantum_beaker
	name = "Quantum Beaker"
	desc = "A quantum entangled beaker, capable of holding a massive 400 units of any reagent."
	id = "quantumbeaker"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1)
	build_path = /obj/item/reagent_containers/glass/beaker/quantum
	category = list("Stock Parts") //Needs proper location
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//T5 PARTS TECHWEB [XEON/FULP]
/datum/techweb_node/quantum_tech
	id = "quantum_tech"
	starting_node = FALSE
	display_name = "Quantum Tech"
	description = "Strange modified bluespace stock parts, with a dash of quantum physics mixed in."
	design_ids = list("quantumcap","quantumscan","quantummanip","quantumlaser","quantumbin","quantumcell","quantumbeaker")
	prereq_ids = list("micro_bluespace")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

//T5 OBJECT [XEON/FULP] 

/obj/item/stock_parts/capacitor/quantumcap
	name = "Quantum Capacitor"
	desc = "A capacitor engineered with a mix of bluespace and quantum technologies."
	icon_state = "quantumcap"
	icon = 'icons/Fulpicons/quantumcap_fulp.dmi'
	rating = 5
	materials = list(/datum/material/iron = 225, /datum/material/glass = 180, /datum/material/gold = 135, /datum/material/diamond = 90)

/obj/item/stock_parts/scanning_module/quantumscan
	name = "quantum field scanning module"
	desc = "A special scanning module using a mix of bluespace and quantum tech to scan even sub-atomic materials."
	icon_state = "quantumscan"
	icon = 'icons/Fulpicons/quantumscan_fulp.dmi'
	rating = 5
	materials = list(/datum/material/iron= 225, /datum/material/glass = 180, /datum/material/diamond = 54, /datum/material/bluespace = 54)

/obj/item/stock_parts/manipulator/quantummanip
	name = "quantum field manipulator"
	desc = "A strange, almost intangible manipulator that uses bluespace tech to manipulate and fold quantum states."
	icon_state = "quantummanip"
	icon = 'icons/Fulpicons/quantummanip_fulp.dmi'
	rating = 5
	materials = list(/datum/material/iron= 180, /datum/material/diamond = 27, /datum/material/titanium = 27, /datum/material/uranium = 27)

/obj/item/stock_parts/micro_laser/quantumlaser
	name = "quantum micro-laser"
	desc = "A modified quadultra micro-laser designed to make use of newly discovered quantum tech."
	icon_state = "quantumlaser"
	icon = 'icons/Fulpicons/quantumlaser_fulp.dmi'
	rating = 5
	materials = list(/datum/material/iron= 180, /datum/material/glass = 180, /datum/material/uranium = 90, /datum/material/diamond = 90)

/obj/item/stock_parts/matter_bin/quantumbin
	name = "entangled matter bin"
	desc = "A bluespace matter bin that makes use of entangled particles to store states of materials as energy."
	icon_state = "quantumbin"
	icon = 'icons/Fulpicons/quantumbin_fulp.dmi'
	rating = 5
	materials = list(/datum/material/iron= 225, /datum/material/diamond = 90, /datum/material/bluespace = 135)

/obj/item/reagent_containers/glass/beaker/quantum
	name = "quantum entangled beaker"
	desc = "A quantum entangled beaker, capable of holding a massive 400 units of any reagent."
	icon_state = "quantumbeaker"
	icon = 'icons/Fulpicons/quantumbeaker_fulp.dmi'
	materials = list(/datum/material/iron = 500, /datum/material/glass = 5000, /datum/material/plasma = 3000, /datum/material/diamond = 1500, /datum/material/bluespace = 1500)
	volume = 400
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100,300)

/obj/item/stock_parts/cell/quantum
	name = "quantum power cell"
	desc = "A rechargeable, entangled power cell."
	icon_state = "bscell"
	//icon_state = "quantumcell"
	//icon = 'icons/Fulpicons/quantumcell_fulp.dmi'	maxcharge = 50000
	materials = list(/datum/material/glass=600)
	chargerate = 5000

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

///Chem dispenser t5 manip reagents list
