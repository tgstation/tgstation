////////////////////////////////////////
///////////Computer Parts///////////////
////////////////////////////////////////

/datum/design/disk/normal
	name = "hard disk drive"
	id = "hdd_basic"
	req_tech = list("programming" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 100)
	build_path = /obj/item/weapon/computer_hardware/hard_drive
	category = list("Computer Parts")

/datum/design/disk/advanced
	name = "advanced hard disk drive"
	id = "hdd_advanced"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/advanced
	category = list("Computer Parts")

/datum/design/disk/super
	name = "super hard disk drive"
	id = "hdd_super"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1600, MAT_GLASS = 400)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/super
	category = list("Computer Parts")

/datum/design/disk/cluster
	name = "cluster hard disk drive"
	id = "hdd_cluster"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3200, MAT_GLASS = 800)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/cluster
	category = list("Computer Parts")

/datum/design/disk/small
	name = "solid state drive"
	id = "ssd_small"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/small
	category = list("Computer Parts")

/datum/design/disk/micro
	name = "micro solid state drive"
	id = "ssd_micro"
	req_tech = list("programming" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 100)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/micro
	category = list("Computer Parts")


// Network cards
/datum/design/netcard/basic
	name = "network card"
	id = "netcard_basic"
	req_tech = list("programming" = 2, "engineering" = 1)
	build_type = IMPRINTER
	materials = list(MAT_METAL = 250, MAT_GLASS = 100)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/network_card
	category = list("Computer Parts")

/datum/design/netcard/advanced
	name = "advanced network card"
	id = "netcard_advanced"
	req_tech = list("programming" = 4, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/network_card/advanced
	category = list("Computer Parts")

/datum/design/netcard/wired
	name = "wired network card"
	id = "netcard_wired"
	req_tech = list("programming" = 5, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_METAL = 2500, MAT_GLASS = 400)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/network_card/wired
	category = list("Computer Parts")


// Data disks
/datum/design/portabledrive/basic
	name = "data disk"
	id = "portadrive_basic"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 800)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/portable
	category = list("Computer Parts")

/datum/design/portabledrive/advanced
	name = "advanced data disk"
	id = "portadrive_advanced"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1600)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/portable/advanced
	category = list("Computer Parts")

/datum/design/portabledrive/super
	name = "super data disk"
	id = "portadrive_super"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 3200)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/hard_drive/portable/super
	category = list("Computer Parts")


// Card slot
/datum/design/cardslot
	name = "ID card slot"
	id = "cardslot"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600)
	build_path = /obj/item/weapon/computer_hardware/card_slot
	category = list("Computer Parts")

// Intellicard slot
/datum/design/aislot
	name = "Intellicard slot"
	id = "aislot"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600)
	build_path = /obj/item/weapon/computer_hardware/ai_slot
	category = list("Computer Parts")

// Mini printer
/datum/design/miniprinter
	name = "miniprinter"
	id = "miniprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600)
	build_path = /obj/item/weapon/computer_hardware/printer/mini
	category = list("Computer Parts")


// APC Link
/datum/design/APClink
	name = "area power connector"
	id = "APClink"
	req_tech = list("programming" = 2, "powerstorage" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000)
	build_path = /obj/item/weapon/computer_hardware/recharger/APC
	category = list("Computer Parts")


// Batteries
/datum/design/battery/controller
	name = "power cell controller"
	id = "bat_control"
	req_tech = list("powerstorage" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400)
	build_path = /obj/item/weapon/computer_hardware/battery
	category = list("Computer Parts")

/datum/design/battery/normal
	name = "battery module"
	id = "bat_normal"
	req_tech = list("powerstorage" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400)
	build_path = /obj/item/weapon/stock_parts/cell/computer
	category = list("Computer Parts")

/datum/design/battery/advanced
	name = "advanced battery module"
	id = "bat_advanced"
	req_tech = list("powerstorage" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800)
	build_path = /obj/item/weapon/stock_parts/cell/computer/advanced
	category = list("Computer Parts")

/datum/design/battery/super
	name = "super battery module"
	id = "bat_super"
	req_tech = list("powerstorage" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1600)
	build_path = /obj/item/weapon/stock_parts/cell/computer/super
	category = list("Computer Parts")

/datum/design/battery/nano
	name = "nano battery module"
	id = "bat_nano"
	req_tech = list("powerstorage" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/weapon/stock_parts/cell/computer/nano
	category = list("Computer Parts")

/datum/design/battery/micro
	name = "micro battery module"
	id = "bat_micro"
	req_tech = list("powerstorage" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400)
	build_path = /obj/item/weapon/stock_parts/cell/computer/micro
	category = list("Computer Parts")


// Processor unit
/datum/design/cpu
	name = "processor board"
	id = "cpu_normal"
	req_tech = list("programming" = 3, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1600)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/processor_unit
	category = list("Computer Parts")

/datum/design/cpu/small
	name = "microprocessor"
	id = "cpu_small"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 800)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/processor_unit/small
	category = list("Computer Parts")

/datum/design/cpu/photonic
	name = "photonic processor board"
	id = "pcpu_normal"
	req_tech = list("programming" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS= 6400, MAT_GOLD = 2000)
	reagents_list = list("sacid" = 40)
	build_path = /obj/item/weapon/computer_hardware/processor_unit/photonic
	category = list("Computer Parts")

/datum/design/cpu/photonic/small
	name = "photonic microprocessor"
	id = "pcpu_small"
	req_tech = list("programming" = 4, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 3200, MAT_GOLD = 1000)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/weapon/computer_hardware/processor_unit/photonic/small
	category = list("Computer Parts")