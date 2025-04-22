/obj/item/storage/box/syndie_kit/syndicate_teleporter
	name = "syndicate teleporter kit"

/obj/item/storage/box/syndie_kit/syndicate_teleporter/PopulateContents()
	new /obj/item/syndicate_teleporter(src)
	new /obj/item/paper/syndicate_teleporter(src)

/obj/item/storage/box/itemset/crusader/blue/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/crusader/blue(src)
	new /obj/item/clothing/head/helmet/plate/crusader/blue(src)
	new /obj/item/clothing/gloves/plate/blue(src)
	new /obj/item/clothing/shoes/plate/blue(src)

/obj/item/storage/box/itemset/crusader/red/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/crusader/red(src)
	new /obj/item/clothing/head/helmet/plate/crusader/red(src)
	new /obj/item/clothing/gloves/plate/red(src)
	new /obj/item/clothing/shoes/plate/red(src)

/obj/item/storage/box/wizard_kit
	name = "Generic Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/PopulateContents()
	new /obj/item/clothing/head/wizard(src)
	new /obj/item/clothing/suit/wizrobe(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/red
	name = "Evocation Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/red/PopulateContents()
	new /obj/item/clothing/head/wizard/red(src)
	new /obj/item/clothing/suit/wizrobe/red(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/yellow
	name = "Translocation Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/yellow/PopulateContents()
	new /obj/item/clothing/head/wizard/yellow(src)
	new /obj/item/clothing/suit/wizrobe/yellow(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/magusred
	name = "Conjuration Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/yellow/PopulateContents()
	new /obj/item/clothing/head/wizard/magus(src)
	new /obj/item/clothing/suit/wizrobe/magusred(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/magusblue
	name = "Transmutation Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/yellow/PopulateContents()
	new /obj/item/clothing/head/wizard/magus(src)
	new /obj/item/clothing/suit/wizrobe/magusblue(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/black
	name = "Necromancy Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/black/PopulateContents()
	new /obj/item/clothing/head/wizard/black(src)
	new /obj/item/clothing/suit/wizrobe/black(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/alchemist_basic_chems
	name = "box of alchemical bases"
	desc = "Contains a set of basic reagents, for all your potion-making needs! If only you labeled them."
	illustration = "beaker"

/obj/item/storage/box/alchemist_basic_chems/PopulateContents()
	for(var/i in 1 to 7)
		if(prob(1))
			new /obj/item/reagent_containers/cup/glass/coffee(src)
			continue
		new /obj/item/reagent_containers/cup/bottle/alchemist_basic(src)

/obj/item/storage/box/alchemist_random_chems
	name = "box of potions"
	desc = "An especially fancy box to keep your finished potions safe."
	icon_state = "syndiebox"
	illustration = "beaker"

/obj/item/storage/box/alchemist_random_chems/PopulateContents()
	for(var/i in 1 to 7)
		if(prob(1))
			new /obj/item/reagent_containers/cup/glass/coffee(src)
			continue
		new /obj/item/reagent_containers/cup/bottle/alchemist_random(src)

/obj/item/storage/box/alchemist_chemistry_kit
	name = "box of alchemy tools"
	desc = "Contains everything needed for the up and coming chemistry student to enact hazardous chemical mishaps in the comfort of their own home."

/obj/item/storage/box/alchemist_chemistry_kit/PopulateContents()
	new /obj/item/reagent_containers/cup/mortar(src)
	new /obj/item/pestle(src)
	new /obj/item/lighter/skull(src)
	new /obj/item/ph_booklet(src)
	new /obj/item/thermometer(src)
	new /obj/item/storage/test_tube_rack/full(src)
	new /obj/item/reagent_containers/cup/glass/coffee(src)
