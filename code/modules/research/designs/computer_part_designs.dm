////////////////////////////////////////
///////////Computer Parts///////////////
////////////////////////////////////////

/datum/design/disk/normal
	name = "Hard Disk Drive"
	id = "hdd_basic"
	req_tech = list("programming" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 100)
	build_path = /obj/item/computer_hardware/hard_drive
	category = list("Computer Parts")

/datum/design/disk/advanced
	name = "Advanced Hard Disk Drive"
	id = "hdd_advanced"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/computer_hardware/hard_drive/advanced
	category = list("Computer Parts")

/datum/design/disk/super
	name = "Super Hard Disk Drive"
	id = "hdd_super"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1600, MAT_GLASS = 400)
	build_path = /obj/item/computer_hardware/hard_drive/super
	category = list("Computer Parts")

/datum/design/disk/cluster
	name = "Cluster Hard Disk Drive"
	id = "hdd_cluster"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3200, MAT_GLASS = 800)
	build_path = /obj/item/computer_hardware/hard_drive/cluster
	category = list("Computer Parts")

/datum/design/disk/small
	name = "Solid State Drive"
	id = "ssd_small"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/computer_hardware/hard_drive/small
	category = list("Computer Parts")

/datum/design/disk/micro
	name = "Micro Solid State Drive"
	id = "ssd_micro"
	req_tech = list("programming" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 100)
	build_path = /obj/item/computer_hardware/hard_drive/micro
	category = list("Computer Parts")


// Network cards
/datum/design/netcard/basic
	name = "Network Card"
	id = "netcard_basic"
	req_tech = list("programming" = 2, "engineering" = 1)
	build_type = IMPRINTER
	materials = list(MAT_METAL = 250, MAT_GLASS = 100)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/computer_hardware/network_card
	category = list("Computer Parts")

/datum/design/netcard/advanced
	name = "Advanced Network Card"
	id = "netcard_advanced"
	req_tech = list("programming" = 4, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/computer_hardware/network_card/advanced
	category = list("Computer Parts")

/datum/design/netcard/wired
	name = "Wired Network Card"
	id = "netcard_wired"
	req_tech = list("programming" = 5, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_METAL = 2500, MAT_GLASS = 400)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/computer_hardware/network_card/wired
	category = list("Computer Parts")


// Data disks
/datum/design/portabledrive/basic
	name = "Data Disk"
	id = "portadrive_basic"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 800)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/computer_hardware/hard_drive/portable
	category = list("Computer Parts")

/datum/design/portabledrive/advanced
	name = "Advanced Data Disk"
	id = "portadrive_advanced"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1600)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/computer_hardware/hard_drive/portable/advanced
	category = list("Computer Parts")

/datum/design/portabledrive/super
	name = "Super Data Disk"
	id = "portadrive_super"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 3200)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/computer_hardware/hard_drive/portable/super
	category = list("Computer Parts")


// Card slot
/datum/design/cardslot
	name = "ID Card Slot"
	id = "cardslot"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600)
	build_path = /obj/item/computer_hardware/card_slot
	category = list("Computer Parts")

// Intellicard slot
/datum/design/aislot
	name = "Intellicard Slot"
	id = "aislot"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600)
	build_path = /obj/item/computer_hardware/ai_slot
	category = list("Computer Parts")

// Mini printer
/datum/design/miniprinter
	name = "Miniprinter"
	id = "miniprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600)
	build_path = /obj/item/computer_hardware/printer/mini
	category = list("Computer Parts")


// APC Link
/datum/design/APClink
	name = "Area Power Connector"
	id = "APClink"
	req_tech = list("programming" = 2, "powerstorage" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000)
	build_path = /obj/item/computer_hardware/recharger/APC
	category = list("Computer Parts")


// Batteries
/datum/design/battery/controller
	name = "Power Cell Controller"
	id = "bat_control"
	req_tech = list("powerstorage" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400)
	build_path = /obj/item/computer_hardware/battery
	category = list("Computer Parts")

/datum/design/battery/normal
	name = "Battery Module"
	id = "bat_normal"
	req_tech = list("powerstorage" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400)
	build_path = /obj/item/stock_parts/cell/computer
	category = list("Computer Parts")

/datum/design/battery/advanced
	name = "Advanced Battery Module"
	id = "bat_advanced"
	req_tech = list("powerstorage" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800)
	build_path = /obj/item/stock_parts/cell/computer/advanced
	category = list("Computer Parts")

/datum/design/battery/super
	name = "Super Battery Module"
	id = "bat_super"
	req_tech = list("powerstorage" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1600)
	build_path = /obj/item/stock_parts/cell/computer/super
	category = list("Computer Parts")

/datum/design/battery/nano
	name = "Nano Battery Module"
	id = "bat_nano"
	req_tech = list("powerstorage" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/stock_parts/cell/computer/nano
	category = list("Computer Parts")

/datum/design/battery/micro
	name = "Micro Battery Module"
	id = "bat_micro"
	req_tech = list("powerstorage" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 400)
	build_path = /obj/item/stock_parts/cell/computer/micro
	category = list("Computer Parts")


// Processor unit
/datum/design/cpu
	name = "Processor Board"
	id = "cpu_normal"
	req_tech = list("programming" = 3, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1600)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/computer_hardware/processor_unit
	category = list("Computer Parts")

/datum/design/cpu/small
	name = "Microprocessor"
	id = "cpu_small"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 800)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/computer_hardware/processor_unit/small
	category = list("Computer Parts")

/datum/design/cpu/photonic
	name = "Photonic Processor Board"
	id = "pcpu_normal"
	req_tech = list("programming" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS= 6400, MAT_GOLD = 2000)
	reagents_list = list("sacid" = 40)
	build_path = /obj/item/computer_hardware/processor_unit/photonic
	category = list("Computer Parts")

/datum/design/cpu/photonic/small
	name = "Photonic Microprocessor"
	id = "pcpu_small"
	req_tech = list("programming" = 4, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 3200, MAT_GOLD = 1000)
	reagents_list = list("sacid" = 20)
	build_path = /obj/item/computer_hardware/processor_unit/photonic/small
	category = list("Computer Parts")