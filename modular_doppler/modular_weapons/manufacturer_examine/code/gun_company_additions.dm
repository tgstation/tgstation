/// Adds the gun manufacturer examine component to the gun on subtypes, does nothing by default
/obj/item/gun/proc/give_manufacturer_examine()
	return

// Ballistics

/obj/item/gun/ballistic/automatic/pistol/aps/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/rifle/boltaction/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SAKHNO)

/obj/item/gun/ballistic/rifle/boltaction/prime/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_XHIHAO)

/obj/item/gun/ballistic/rifle/boltaction/pipegun/give_manufacturer_examine()
	return

/obj/item/gun/ballistic/rifle/boltaction/harpoon/give_manufacturer_examine()
	return

/obj/item/gun/ballistic/rifle/boltaction/lionhunter/give_manufacturer_examine()
	return

/obj/item/gun/ballistic/revolver/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/shotgun/riot/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/shotgun/bulldog/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/shotgun/automatic/combat/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/automatic/pistol/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/revolver/c38/detective/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/shotgun/toy/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_DONK)

/obj/item/gun/ballistic/automatic/c20r/toy/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_DONK)

/obj/item/gun/ballistic/automatic/pistol/clandestine/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/automatic/l6_saw/toy/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_DONK)

/obj/item/gun/ballistic/revolver/mateba/give_manufacturer_examine()
	return

/obj/item/gun/ballistic/revolver/russian/give_manufacturer_examine()
	return

// Energy

/obj/item/gun/energy/e_gun/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ALLSTAR)

/obj/item/gun/energy/laser/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ALLSTAR)

/obj/item/gun/energy/pulse/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/energy/laser/redtag/give_manufacturer_examine()
	return

/obj/item/gun/energy/laser/bluetag/give_manufacturer_examine()
	return

/obj/item/gun/energy/laser/instakill/give_manufacturer_examine()
	return

/obj/item/gun/energy/laser/chameleon/give_manufacturer_examine()
	return

/obj/item/gun/energy/laser/captain/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/energy/laser/retro/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_REMOVED)

/obj/item/gun/energy/laser/retro/old/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/energy/e_gun/old/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/energy/e_gun/advtaser/cyborg/give_manufacturer_examine()
	return

/obj/item/gun/energy/recharge/ebow/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/energy/lasercannon/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ALLSTAR)

/obj/item/gun/energy/ionrifle/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ALLSTAR)

/obj/item/gun/energy/temperature/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ALLSTAR)

/obj/item/gun/energy/shrink_ray/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ABDUCTOR)

/obj/item/gun/energy/alien/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ABDUCTOR)

// Syringe

/obj/item/gun/syringe/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_INTERDYNE)

/obj/item/gun/syringe/blowgun/give_manufacturer_examine()
	return

/obj/item/gun/syringe/syndicate/prototype/give_manufacturer_examine()
	return
