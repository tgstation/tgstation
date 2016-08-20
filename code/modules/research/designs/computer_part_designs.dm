////////////////////////////////////////
///////////Computer Parts///////////////
////////////////////////////////////////

/datum/design/disk/normal
	name = "basic hard drive"
	id = "hdd_basic"
	req_tech = list("programming" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 100)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/
	category = list("Computer Parts")

/datum/design/disk/advanced
	name = "advanced hard drive"
	id = "hdd_advanced"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/advanced
	category = list("Computer Parts")

/datum/design/disk/super
	name = "super hard drive"
	id = "hdd_super"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1600, MAT_GLASS = 400)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/super
	category = list("Computer Parts")

/datum/design/disk/cluster
	name = "cluster hard drive"
	id = "hdd_cluster"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3200, MAT_GLASS = 800)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/cluster
	category = list("Computer Parts")

/datum/design/disk/small
	name = "small hard drive"
	id = "hdd_small"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/small
	category = list("Computer Parts")

/datum/design/disk/micro
	name = "micro hard drive"
	id = "hdd_micro"
	req_tech = list("programming" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 100)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/micro
	category = list("Computer Parts")

// Network cards
/datum/design/netcard/basic
	name = "basic network card"
	id = "netcard_basic"
	req_tech = list("programming" = 2, "engineering" = 1)
	build_type = IMPRINTER
	materials = list(MAT_METAL = 250, MAT_GLASS = 100)
	reagents = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/network_card
	category = list("Computer Parts")

/datum/design/netcard/advanced
	name = "advanced network card"
	id = "netcard_advanced"
	req_tech = list("programming" = 4, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	reagents = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/network_card/advanced
	category = list("Computer Parts")

/datum/design/netcard/wired
	name = "wired network card"
	id = "netcard_wired"
	req_tech = list("programming" = 5, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_METAL = 2500, MAT_GLASS = 400)
	reagents = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/network_card/wired
	category = list("Computer Parts")

// Data crystals (USB flash drives)
/datum/design/portabledrive/basic
	name = "basic data crystal"
	id = "portadrive_basic"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 800)
	reagents = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/portable
	category = list("Computer Parts")

/datum/design/portabledrive/advanced
	name = "advanced data crystal"
	id = "portadrive_advanced"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1600)
	reagents = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/portable/advanced
	category = list("Computer Parts")

/datum/design/portabledrive/super
	name = "super data crystal"
	id = "portadrive_super"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 3200)
	reagents = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/portable/super
	category = list("Computer Parts")

// Card slot
/datum/design/cardslot
	name = "RFID card slot"
	id = "cardslot"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600)
	build_path = /obj/item/weapon/computer_hardware/card_slot
	category = list("Computer Parts")

// Nano printer
/datum/design/nanoprinter
	name = "nano printer"
	id = "nanoprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600)
	build_path = /obj/item/weapon/computer_hardware/nano_printer
	category = list("Computer Parts")

// Tesla Link
/datum/design/teslalink
	name = "tesla link"
	id = "teslalink"
	req_tech = list("programming" = 2, "powerstorage" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000)
	build_path = /obj/item/weapon/computer_hardware/tesla_link
	category = list("Computer Parts")

// Batteries
/datum/design/battery/normal
	name = "standard battery module"
	id = "bat_normal"
	req_tech = list("powerstorage" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400)
	build_path = /obj/item/weapon/computer_hardware/battery_module
	category = list("Computer Parts")

/datum/design/battery/advanced
	name = "advanced battery module"
	id = "bat_advanced"
	req_tech = list("powerstorage" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800)
	build_path = /obj/item/weapon/computer_hardware/battery_module/advanced
	category = list("Computer Parts")

/datum/design/battery/super
	name = "super battery module"
	id = "bat_super"
	req_tech = list("powerstorage" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1600)
	build_path = /obj/item/weapon/computer_hardware/battery_module/super
	category = list("Computer Parts")

/datum/design/battery/ultra
	name = "ultra battery module"
	id = "bat_ultra"
	req_tech = list("powerstorage" = 5, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3200)
	build_path = /obj/item/weapon/computer_hardware/battery_module/ultra
	category = list("Computer Parts")

/datum/design/battery/nano
	name = "nano battery module"
	id = "bat_nano"
	req_tech = list("powerstorage" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/weapon/computer_hardware/battery_module/nano
	category = list("Computer Parts")

/datum/design/battery/micro
	name = "micro battery module"
	id = "bat_micro"
	req_tech = list("powerstorage" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400)
	build_path = /obj/item/weapon/computer_hardware/battery_module/micro
	category = list("Computer Parts")

// Processor unit
/datum/design/cpu
	name = "computer processor unit"
	id = "cpu_normal"
	req_tech = list("programming" = 3, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1600)
	reagents = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/processor_unit
	category = list("Computer Parts")

/datum/design/cpu/small
	name = "computer microprocessor unit"
	id = "cpu_small"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 800)
	reagents = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/processor_unit/small
	category = list("Computer Parts")

/datum/design/cpu/photonic
	name = "computer photonic processor unit"
	id = "pcpu_normal"
	req_tech = list("programming" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS= 6400, MAT_GOLD = 2000)
	reagents = list("sacid" = 40)
	build_path = /obj/item/weapon/computer_hardware/processor_unit/photonic
	category = list("Computer Parts")

/datum/design/cpu/photonic/small
	name = "computer photonic microprocessor unit"
	id = "pcpu_small"
	req_tech = list("programming" = 4, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 3200, MAT_GOLD = 1000)
	reagents = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/processor_unit/photonic/small
	category = list("Computer Parts")