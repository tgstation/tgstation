/////////////////////////////////////////
////////////Service Designs//////////////
/////////////////////////////////////////

/datum/design/buffer
	name = "Floor Buffer Upgrade"
	desc = "A floor buffer that can be attached to vehicular janicarts."
	id = "buffer"
	req_tech = list("materials" = 5, "engineering" = 3, "service" = 1)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000, "$glass" = 200)
	build_path = /obj/item/janiupgrade
	category = list("service")

/datum/design/holosign
	name = "Holographic Sign Projector"
	desc = "A holograpic projector used to project various warning signs."
	id = "holosign"
	req_tech = list("magnets" = 3, "powerstorage" = 2, "service" = 1)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000, "$glass" = 1000)
	build_path = /obj/item/weapon/holosign_creator
	category = list("service")

/datum/design/galoshes
	name = "Galoshes"
	desc = "A pair of yellow rubber boots, designed to prevent slipping on wet surfaces." 
	id = "galoshes"
	req_tech = list("materials" = 3 "service" = 3)
	build_type = PROTOLATHE
	materials = ("$metal" = 2000, "$uranium" = 1000)
	build_path = /obj/item/clothing/shoes/galoshes
	category = list("service")

/datum/design/soapnt
	name = "Soap"
	desc = "A Nanotrasen brand bar of soap. Smells of plasma." 
	id = "soapnt"
	req_tech = ("plasma" = 2 "service" = 1)
	build_type = PROTOLATHE
	materials = ("$metal" = 1000, "$plasma" = 1000)
	build_path = /obj/item/weapon/soap/nanotrasen
	category = list("service")

/datum/design/soapsyndie
	name = "Red Soap"
	desc = "An untrustworthy bar of soap made of strong chemical agents that dissolve blood faster."
	id = "soapsyndie"
	req_tech = ("plasma" = 2 "service" = 1, "illegal" = 2)
	build_type = PROTOLATHE
	materials = ("$plasma" = 2000)
	build_path = /obj/item/weapon/soap/syndie
	category = list("service")

/datum/design/fastcart //needs to be created
	name = "Janicart SpeedBoost Module"
	desc = "An upgraded motor for the janicart which greatly improves the speed it travels." 
	id = "fastcart"
	req_tech = ("materials" = 2 "programming" = 4, "magnets" = 2 "service" = 6)
	build_type = PROTOLATHE
	materials = ("$metal" = 2000, "$gold" = 2000)
	build_path = /obj/item/devices/upgrades/fastcart
	category = list("service")

/datum/design/tankcart //needs to be created and sprited
	name = "Janicart Armor Module"
	desc = "Upgraded plating for the janicart which greatly improves the durability of it and protects the user." 
	id = "tankcart"
	req_tech = ("materials" = 4 "service" = 5)
	build_type = PROTOLATHE
	materials = ("$metal" = 4000, "$plasma" = 2000)
	build_path = /obj/item/devices/upgrades/tankcart
	category = list("service")

/datum/design/spacecart //needs to be created and sprited
	name = "Janicart Thruster Module"
	desc = "Adds a set of recharging thrusters to the janicart for those hard to reach messes in space." 
	id = "spacecart"
	req_tech = ("materials" = 6, "magnets" = 4, "powerstorage" = 7, "service" = 8)
	build_type = PROTOLATHE
	materials = ("$metal" = 8000, "$uranium" = 4000, "$plasma" = 4000)
	build_path = /obj/item/devices/upgrades/spacecart
	category = list("service")

/datum/design/Whetstone //needs to be created and sprited
	name = "Whetstone"
	desc = "A strange stone used by many citizens of ancient Earth to sharpen metal tools."
	id = "whetstone"
	req_tech = ("materials" = 4 "service" = 3, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = ("$metal" = 2500)
	build_path = /obj/item/weapon/whetstone
	category = list("service")
	
/datum/design/synthesizer //needs to be created
	name = "Beverage Synthesizer"
	desc = "A tool used to generate drinks, like the one service cyborgs use."
	id = "synthesizer"
	req_tech = list("materials" = 3 "programming" = 3, "powerstorage" = 4, "bluespace" = 4, "service" = 6)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000, "$diamond" = 2000)
	build_path = /obj/item/weapon/chainsaw
	category = list("service")
	
/datum/design/crack //needs to be created and sprited
	name = "Secret Spice"
	desc = "A fine white powder that makes most drinks and cuisine taste REALLY good."
	id = "crack"
	req_tech = list("materials" = 4, "syndicate" = 3, "service" = 2)
	build_type = PROTOLATHE
	materials = list("$plasma" = 500, "$glass" = 500)
	build_path = /obj/item/weapon/reagent_containers/food/condiment/crack
	category = list("service")
	
/datum/design/plantbag //needs to be created and maybe sprited
	name = "Plant Bag of Holding"
	desc = "A bag infused with bluespace magic to allow infinite storage of flora."
	id = "plantbag"
	req_tech = list("materials" =4 "magnets" = 4, "bluespace" = 3, "service" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000, "$diamond" = 2000)
	build_path = /obj/item/weapon/storage/bag/plants/holding
	category = list("service")

/datum/design/chainsaw //needs to be ported
	name = "Chainsaw"
	desc = "A curious tool used to effectively and efficiently cuts down trees and hedges. Powered by ???."
	id = "chainsaw"
	req_tech = list("materials" = 5 "combat" = 5, "powerstorage" = 3, "syndicate" = 5, "service" = 8)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000, "$diamond" = 2000, "$plasma" = 1000)
	build_path = /obj/item/weapon/chainsaw
	category = list("service")
	
/datum/design/muffinbutton //needs to be created and sprited
	name = "Muffin Dispenser"
	desc = "A strange machine that generates unlimited muffins with the push of a button."
	id = "muffinbutton"
	req_tech = list("materials" = 6 "magnets" = 5, "programming" = 3, "powerstorage" = 4, "bluespace" = 6 "service" = 8)
	build_type = PROTOLATHE
	materials = list("$metal" = 10000, "$glass" = 2000, "$diamond" = 4000)
	build_path = /obj/machinery/muffinbutton
	category = list("service")
