/obj/item/gps/computer/beacon
	name = "\improper GPS beacon"
	desc = "A GPS beacon, anchored to the ground to prevent loss or accidental movement."
	icon = 'modular_doppler/kahraman_equipment/icons/gps_beacon.dmi'
	icon_state = "gps_beacon"
	pixel_y = 0
	/// What this is undeployed back into
	var/undeploy_type = /obj/item/flatpacked_machine/gps_beacon

/obj/item/gps/computer/beacon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, undeploy_type, 2 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

/obj/item/flatpacked_machine/gps_beacon
	name = "packed GPS beacon"
	icon = 'modular_doppler/kahraman_equipment/icons/gps_beacon.dmi'
	icon_state = "beacon_folded"
	w_class = WEIGHT_CLASS_SMALL
	type_to_deploy = /obj/item/gps/computer/beacon

/obj/item/flatpacked_machine/gps_beacon/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)
