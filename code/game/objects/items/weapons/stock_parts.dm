/obj/item/weapon/stock_parts
	name = "stock part"
	desc = "What?"
	gender = PLURAL
	icon = 'icons/obj/stock_parts.dmi'
	w_class = 2.0
	var/rating = 1
	melt_temperature = MELTPOINT_STEEL

/obj/item/weapon/stock_parts/New()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/weapon/stock_parts/get_rating()
	return rating

//Rank 1

/obj/item/weapon/stock_parts/console_screen
	name = "console screen"
	desc = "Used in the construction of computers and other devices with a interactive console."
	icon_state = "screen"
	origin_tech = "materials=1"
	starting_materials = list(MAT_GLASS = 200)
	w_type = RECYK_GLASS

/obj/item/weapon/stock_parts/capacitor
	name = "capacitor"
	desc = "A basic capacitor used in the construction of a variety of devices."
	icon_state = "capacitor2_basic"
	origin_tech = "powerstorage=1"
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 50)
	w_type = RECYK_ELECTRONIC

/obj/item/weapon/stock_parts/scanning_module
	name = "scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"
	origin_tech = "magnets=1"
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 20)
	w_type = RECYK_ELECTRONIC

/obj/item/weapon/stock_parts/manipulator
	name = "micro-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "micro_mani"
	origin_tech = "materials=1;programming=1"
	starting_materials = list(MAT_IRON = 30)
	w_type = RECYK_ELECTRONIC

/obj/item/weapon/stock_parts/micro_laser
	name = "micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "micro_laser"
	origin_tech = "magnets=1"
	starting_materials = list(MAT_IRON = 10, MAT_GLASS = 20)
	w_type = RECYK_ELECTRONIC

/obj/item/weapon/stock_parts/matter_bin
	name = "matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "matter_bin"
	origin_tech = "materials=1"
	starting_materials = list(MAT_IRON = 80)
	w_type = RECYK_ELECTRONIC

//Rank 2

/obj/item/weapon/stock_parts/capacitor/adv
	name = "advanced capacitor"
	desc = "An advanced capacitor used in the construction of a variety of devices."
	icon_state = "capacitor2_adv"
	origin_tech = "powerstorage=3"
	rating = 2
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 50)

/obj/item/weapon/stock_parts/scanning_module/adv
	name = "advanced scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "adv_scan_module"
	origin_tech = "magnets=3"
	rating = 2
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 20)

/obj/item/weapon/stock_parts/manipulator/nano
	name = "nano-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "nano_mani"
	origin_tech = "materials=3;programming=2"
	rating = 2
	starting_materials = list(MAT_IRON = 30)

/obj/item/weapon/stock_parts/micro_laser/high
	name = "high-power micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "high_micro_laser"
	origin_tech = "magnets=3"
	rating = 2
	starting_materials = list(MAT_IRON = 10, MAT_GLASS = 20)

/obj/item/weapon/stock_parts/matter_bin/adv
	name = "advanced matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "advanced_matter_bin"
	origin_tech = "materials=3"
	rating = 2
	starting_materials = list(MAT_IRON = 80)

//Rating 3

/obj/item/weapon/stock_parts/capacitor/adv/super
	name = "super capacitor"
	desc = "A super-high capacity capacitor used in the construction of a variety of devices."
	icon_state = "capacitor2_super"
	origin_tech = "powerstorage=5;materials=4"
	rating = 3
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 50)

/obj/item/weapon/stock_parts/scanning_module/adv/phasic
	name = "phasic scanning module"
	desc = "A compact, high resolution phasic scanning module used in the construction of certain devices."
	icon_state = "super_scan_module"
	origin_tech = "magnets=5"
	rating = 3
	starting_materials = list(MAT_PLASTIC = 300)

/obj/item/weapon/stock_parts/manipulator/nano/pico
	name = "pico-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "pico_mani"
	origin_tech = "materials=5;programming=2"
	rating = 3
	starting_materials = list(MAT_PLASTIC = 300)

/obj/item/weapon/stock_parts/micro_laser/high/ultra
	name = "ultra-high-power micro-laser"
	icon_state = "ultra_high_micro_laser"
	desc = "A tiny laser used in certain devices."
	origin_tech = "magnets=5"
	rating = 3
	starting_materials = list(MAT_PLASTIC = 300)

/obj/item/weapon/stock_parts/matter_bin/adv/super
	name = "super matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "super_matter_bin"
	origin_tech = "materials=5"
	rating = 3
	starting_materials = list(MAT_PLASTIC = 300)

// Subspace stock parts

/obj/item/weapon/stock_parts/subspace/ansible
	name = "subspace ansible"
	icon_state = "subspace_ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	origin_tech = "programming=3;magnets=5;materials=4;bluespace=2"
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 10)

/obj/item/weapon/stock_parts/subspace/filter
	name = "hyperwave filter"
	icon_state = "hyperwave_filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."
	origin_tech = "programming=4;magnets=2"
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 10)

/obj/item/weapon/stock_parts/subspace/amplifier
	name = "subspace amplifier"
	icon_state = "subspace_amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	origin_tech = "programming=3;magnets=4;materials=4;bluespace=2"
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 10)

/obj/item/weapon/stock_parts/subspace/treatment
	name = "subspace treatment disk"
	icon_state = "treatment_disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	origin_tech = "programming=3;magnets=2;materials=5;bluespace=2"
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 10)

/obj/item/weapon/stock_parts/subspace/analyzer
	name = "subspace wavelength analyzer"
	icon_state = "wavelength_analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	origin_tech = "programming=3;magnets=4;materials=4;bluespace=2"
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 10)

/obj/item/weapon/stock_parts/subspace/crystal
	name = "ansible crystal"
	icon_state = "ansible_crystal"
	desc = "A crystal made from pure glass used to transmit laser databursts to subspace."
	origin_tech = "magnets=4;materials=4;bluespace=2"
	starting_materials = list(MAT_GLASS = 50)

/obj/item/weapon/stock_parts/subspace/transmitter
	name = "subspace transmitter"
	icon_state = "subspace_transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	origin_tech = "magnets=5;materials=5;bluespace=3"
	starting_materials = list(MAT_IRON = 50)
