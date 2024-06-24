/obj/item/storage/box/nri_survival_pack
	name = "NRI survival pack"
	desc = "A box filled with useful emergency items, supplied by the NRI."
	icon_state = "survival_pack"
	icon = 'monkestation/code/modules/blueshift/icons/survival_pack.dmi'
	illustration = null

/obj/item/storage/box/nri_survival_pack/PopulateContents()
	new /obj/item/oxygen_candle(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)
	new /obj/item/stack/spacecash/c1000(src)
	new /obj/item/storage/pill_bottle/iron(src)
	new /obj/item/storage/box/nri_pens(src)
	new /obj/item/storage/box/nri_flares(src)
	new /obj/item/crowbar/red(src)

/obj/item/storage/box/nri_pens
	name = "box of injectors"
	desc = "A box full of first aid and combat MediPens."
	illustration = "epipen"

/obj/item/storage/box/nri_pens/PopulateContents()
	new /obj/item/reagent_containers/hypospray/medipen/ekit(src)
	new /obj/item/reagent_containers/hypospray/medipen/stimpack/traitor(src)
	new /obj/item/reagent_containers/hypospray/medipen/oxandrolone(src)
	new /obj/item/reagent_containers/hypospray/medipen/salacid(src)
	new /obj/item/reagent_containers/hypospray/medipen/salacid(src)
	new /obj/item/reagent_containers/hypospray/medipen/penacid(src)
	new /obj/item/reagent_containers/hypospray/medipen/salbutamol(src)
	new /obj/item/reagent_containers/hypospray/medipen/atropine(src)
	new /obj/item/reagent_containers/hypospray/medipen/blood_loss(src)

/obj/item/storage/box/nri_flares
	name = "box of flares"
	desc = "A box full of red emergency flares."
	illustration = "firecracker"

/obj/item/storage/box/nri_flares/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/flashlight/flare(src)
