////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////

/datum/design/RPED
	name = "Rapid Part Exchange Device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	id = "rped"
	req_tech = list("engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000) //hardcore
	build_path = /obj/item/weapon/storage/part_replacer
	category = list("Stock Parts")

/datum/design/BS_RPED
	name = "Bluespace RPED"
	desc = "Powered by bluespace technology, this RPED variant can upgrade buildings from a distance, without needing to remove the panel first."
	id = "bs_rped"
	req_tech = list("engineering" = 4, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 15000, MAT_GLASS = 5000, MAT_SILVER = 2500) //hardcore
	build_path = /obj/item/weapon/storage/part_replacer/bluespace
	category = list("Stock Parts")

//Capacitors
/datum/design/basic_capacitor
	name = "Basic Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "basic_capacitor"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/weapon/stock_parts/capacitor
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2

/datum/design/adv_capacitor
	name = "Advanced Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "adv_capacitor"
	req_tech = list("powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 150)
	build_path = /obj/item/weapon/stock_parts/capacitor/adv
	category = list("Stock Parts")
	lathe_time_factor = 0.2

/datum/design/super_capacitor
	name = "Super Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "super_capacitor"
	req_tech = list("powerstorage" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_GOLD = 100)
	build_path = /obj/item/weapon/stock_parts/capacitor/super
	category = list("Stock Parts")
	lathe_time_factor = 0.2

/datum/design/quadratic_capacitor
	name = "Quadratic Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "quadratic_capacitor"
	req_tech = list("powerstorage" = 6, "engineering" = 5, "materials" = 5, "bluespace" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_DIAMOND = 100)
	build_path = /obj/item/weapon/stock_parts/capacitor/quadratic
	category = list("Stock Parts")
	lathe_time_factor = 0.2

//Scanning modules
/datum/design/basic_scanning
	name = "Basic Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "basic_scanning"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 50)
	build_path = /obj/item/weapon/stock_parts/scanning_module
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2

/datum/design/adv_scanning
	name = "Advanced Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "adv_scanning"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 100)
	build_path = /obj/item/weapon/stock_parts/scanning_module/adv
	category = list("Stock Parts")
	lathe_time_factor = 0.2

/datum/design/phasic_scanning
	name = "Phasic Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "phasic_scanning"
	req_tech = list("magnets" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 150, MAT_SILVER = 60)
	build_path = /obj/item/weapon/stock_parts/scanning_module/phasic
	category = list("Stock Parts")
	lathe_time_factor = 0.2

/datum/design/triphasic_scanning
	name = "Triphasic Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "triphasic_scanning"
	req_tech = list("magnets" = 6, "materials" = 5, "engineering" = 5, "bluespace" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_DIAMOND = 60)
	build_path = /obj/item/weapon/stock_parts/scanning_module/triphasic
	category = list("Stock Parts")
	lathe_time_factor = 0.2

//Maipulators
/datum/design/micro_mani
	name = "Micro Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "micro_mani"
	req_tech = list("materials" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 100)
	build_path = /obj/item/weapon/stock_parts/manipulator
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2

/datum/design/nano_mani
	name = "Nano Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "nano_mani"
	req_tech = list("materials" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150)
	build_path = /obj/item/weapon/stock_parts/manipulator/nano
	category = list("Stock Parts")
	lathe_time_factor = 0.2

/datum/design/pico_mani
	name = "Pico Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "pico_mani"
	req_tech = list("materials" = 5, "programming" = 4, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/weapon/stock_parts/manipulator/pico
	category = list("Stock Parts")
	lathe_time_factor = 0.2

/datum/design/femto_mani
	name = "Femto Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "femto_mani"
	req_tech = list("materials" = 7, "programming" = 5, "engineering" = 5, "bluespace" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_DIAMOND = 30, MAT_TITANIUM = 30)
	build_path = /obj/item/weapon/stock_parts/manipulator/femto
	category = list("Stock Parts")
	lathe_time_factor = 0.2

//Micro-lasers
/datum/design/basic_micro_laser
	name = "Basic Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "basic_micro_laser"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 50)
	build_path = /obj/item/weapon/stock_parts/micro_laser
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2

/datum/design/high_micro_laser
	name = "High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "high_micro_laser"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 100)
	build_path = /obj/item/weapon/stock_parts/micro_laser/high
	category = list("Stock Parts")
	lathe_time_factor = 0.2

/datum/design/ultra_micro_laser
	name = "Ultra-High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "ultra_micro_laser"
	req_tech = list("magnets" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 150, MAT_URANIUM = 60)
	build_path = /obj/item/weapon/stock_parts/micro_laser/ultra
	category = list("Stock Parts")
	lathe_time_factor = 0.2

/datum/design/quadultra_micro_laser
	name = "Quad-Ultra Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "quadultra_micro_laser"
	req_tech = list("magnets" = 6, "materials" = 5, "engineering" = 5, "bluespace" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_URANIUM = 100, MAT_DIAMOND = 60)
	build_path = /obj/item/weapon/stock_parts/micro_laser/quadultra
	category = list("Stock Parts")
	lathe_time_factor = 0.2

/datum/design/basic_matter_bin
	name = "Basic Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "basic_matter_bin"
	req_tech = list("materials" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 100)
	build_path = /obj/item/weapon/stock_parts/matter_bin
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2

/datum/design/adv_matter_bin
	name = "Advanced Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "adv_matter_bin"
	req_tech = list("materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150)
	build_path = /obj/item/weapon/stock_parts/matter_bin/adv
	category = list("Stock Parts")
	lathe_time_factor = 0.2

/datum/design/super_matter_bin
	name = "Super Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "super_matter_bin"
	req_tech = list("materials" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/weapon/stock_parts/matter_bin/super
	category = list("Stock Parts")
	lathe_time_factor = 0.2

/datum/design/bluespace_matter_bin
	name = "Bluespace Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "bluespace_matter_bin"
	req_tech = list("materials" = 7, "engineering" = 5, "bluespace" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 250, MAT_DIAMOND = 200)
	build_path = /obj/item/weapon/stock_parts/matter_bin/bluespace
	category = list("Stock Parts")
	lathe_time_factor = 0.2

//T-Comms devices
/datum/design/subspace_ansible
	name = "Subspace Ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	id = "s-ansible"
	req_tech = list("programming" = 2, "magnets" = 2, "materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_SILVER = 100)
	build_path = /obj/item/weapon/stock_parts/subspace/ansible
	category = list("Stock Parts")

/datum/design/hyperwave_filter
	name = "Hyperwave Filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."
	id = "s-filter"
	req_tech = list("programming" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_SILVER = 100)
	build_path = /obj/item/weapon/stock_parts/subspace/filter
	category = list("Stock Parts")

/datum/design/subspace_amplifier
	name = "Subspace Amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	id = "s-amplifier"
	req_tech = list("programming" = 3, "magnets" = 4, "materials" = 3, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GOLD = 100, MAT_URANIUM = 100)
	build_path = /obj/item/weapon/stock_parts/subspace/amplifier
	category = list("Stock Parts")

/datum/design/subspace_treatment
	name = "Subspace Treatment Disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	id = "s-treatment"
	req_tech = list("programming" = 2, "magnets" = 3, "materials" = 2, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_SILVER = 200)
	build_path = /obj/item/weapon/stock_parts/subspace/treatment
	category = list("Stock Parts")

/datum/design/subspace_analyzer
	name = "Subspace Analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	id = "s-analyzer"
	req_tech = list("programming" = 3, "magnets" = 4, "materials" = 2, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GOLD = 100)
	build_path = /obj/item/weapon/stock_parts/subspace/analyzer
	category = list("Stock Parts")

/datum/design/subspace_crystal
	name = "Ansible Crystal"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	id = "s-crystal"
	req_tech = list("magnets" = 2, "materials" = 2, "bluespace" = 3, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 800, MAT_SILVER = 100, MAT_GOLD = 100)
	build_path = /obj/item/weapon/stock_parts/subspace/crystal
	category = list("Stock Parts")

/datum/design/subspace_transmitter
	name = "Subspace Transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	id = "s-transmitter"
	req_tech = list("magnets" = 3, "materials" = 4, "bluespace" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 100, MAT_SILVER = 100, MAT_URANIUM = 100)
	build_path = /obj/item/weapon/stock_parts/subspace/transmitter
	category = list("Stock Parts")
