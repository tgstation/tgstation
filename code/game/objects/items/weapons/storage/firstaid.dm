
/obj/item/weapon/storage/firstaid/fire/New()
	..()
	if (empty) return

	icon_state = pick("ointment","firefirstaid")

	new /obj/item/device/healthanalyzer( src )
	new /obj/item/stack/medical/ointment( src )
	new /obj/item/stack/medical/ointment( src )
	new /obj/item/weapon/reagent_containers/pill/kelotane( src )
	new /obj/item/weapon/reagent_containers/pill/kelotane( src )
	new /obj/item/weapon/reagent_containers/pill/kelotane( src )
	new /obj/item/weapon/reagent_containers/pill/kelotane( src ) //Replaced ointment with these since they actually work --Errorage
	return

/obj/item/weapon/storage/syringes/New()
	..()
	new /obj/item/weapon/reagent_containers/syringe( src )
	new /obj/item/weapon/reagent_containers/syringe( src )
	new /obj/item/weapon/reagent_containers/syringe( src )
	new /obj/item/weapon/reagent_containers/syringe( src )
	new /obj/item/weapon/reagent_containers/syringe( src )
	new /obj/item/weapon/reagent_containers/syringe( src )
	new /obj/item/weapon/reagent_containers/syringe( src )
	return

/obj/item/weapon/storage/firstaid/regular/New()
	..()
	if (empty) return
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/ointment(src)
	return

/obj/item/weapon/storage/firstaid/toxin/New()
	..()
	if (empty) return

	icon_state = pick("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

	new /obj/item/device/healthanalyzer( src )
	new /obj/item/weapon/reagent_containers/syringe/antitoxin( src )
	new /obj/item/weapon/reagent_containers/syringe/antitoxin( src )
	new /obj/item/weapon/reagent_containers/pill/antitox( src )
	new /obj/item/weapon/reagent_containers/pill/antitox( src )
	new /obj/item/weapon/reagent_containers/pill/antitox( src )
	new /obj/item/weapon/reagent_containers/pill/antitox( src )
	return

/obj/item/weapon/storage/firstaid/o2/New()
	..()
	if (empty) return
	new /obj/item/device/healthanalyzer( src )
	new /obj/item/weapon/reagent_containers/syringe/inaprovaline( src )
	new /obj/item/weapon/reagent_containers/syringe/inaprovaline( src )
	new /obj/item/weapon/reagent_containers/pill/dexalin( src )
	new /obj/item/weapon/reagent_containers/pill/dexalin( src )
	new /obj/item/weapon/reagent_containers/pill/dexalin( src )
	new /obj/item/weapon/reagent_containers/pill/dexalin( src )
	return

/obj/item/weapon/storage/firstaid/adv/New()
	..()
	if (empty) return
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	return

/obj/item/weapon/storage/pill_bottle/kelotane
	name = "Pill bottle (kelotane)"
	desc = "Contains pills used to treat burns."

/obj/item/weapon/storage/pill_bottle/kelotane/New()
	..()
	new /obj/item/weapon/reagent_containers/pill/kelotane( src )
	new /obj/item/weapon/reagent_containers/pill/kelotane( src )
	new /obj/item/weapon/reagent_containers/pill/kelotane( src )
	new /obj/item/weapon/reagent_containers/pill/kelotane( src )
	new /obj/item/weapon/reagent_containers/pill/kelotane( src )
	new /obj/item/weapon/reagent_containers/pill/kelotane( src )
	new /obj/item/weapon/reagent_containers/pill/kelotane( src )

/obj/item/weapon/storage/pill_bottle/tramadol
	name = "Pill bottle (tramadol)"
	desc = "Contains painkiller pills."

/obj/item/weapon/storage/pill_bottle/tramadol/New()
	..()
	new /obj/item/weapon/reagent_containers/pill/tramadol( src )
	new /obj/item/weapon/reagent_containers/pill/tramadol( src )
	new /obj/item/weapon/reagent_containers/pill/tramadol( src )
	new /obj/item/weapon/reagent_containers/pill/tramadol( src )
	new /obj/item/weapon/reagent_containers/pill/tramadol( src )
	new /obj/item/weapon/reagent_containers/pill/tramadol( src )
	new /obj/item/weapon/reagent_containers/pill/tramadol( src )

/obj/item/weapon/storage/pill_bottle/antitox
	name = "Pill bottle (Anti-toxin)"
	desc = "Contains pills used to counter toxins."

/obj/item/weapon/storage/pill_bottle/antitox/New()
	..()
	new /obj/item/weapon/reagent_containers/pill/antitox( src )
	new /obj/item/weapon/reagent_containers/pill/antitox( src )
	new /obj/item/weapon/reagent_containers/pill/antitox( src )
	new /obj/item/weapon/reagent_containers/pill/antitox( src )
	new /obj/item/weapon/reagent_containers/pill/antitox( src )
	new /obj/item/weapon/reagent_containers/pill/antitox( src )
	new /obj/item/weapon/reagent_containers/pill/antitox( src )

/obj/item/weapon/storage/pill_bottle/inaprovaline
	name = "Pill bottle (inaprovaline)"
	desc = "Contains pills used to stabilize patients."

/obj/item/weapon/storage/pill_bottle/inaprovaline/New()
	..()
	new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
	new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
	new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
	new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
	new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
	new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
	new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
