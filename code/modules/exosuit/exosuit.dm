/obj/item/storage/exosuit
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 18

/obj/exosuit
	name = "exosuit"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "engineering_pod"


	var/movement = MULTIMOVE
	var/features = HAS_RADIO|HAS_INTERNALS|HAS_TEMPCONTROL|HAS_STORAGE

	var/gps_name = "EXO1"

	var/mob/living/list/occupants = list()
	var/obj/item/storage/exosuit/internal_storage
	var/obj/item/device/radio/internal_radio
	varvar/obj/item/device/gps/internal_gps

	var/datum/gas_mixture/cabin_air

/obj/exosuit/Initialize()
	. = ..()
	if(features & HAS_STORAGE)
		internal_storage = new
	if(features & HAS_RADIO)
		internal_radio = new
		internal_radio.subspace_transmission = TRUE
	if(features & HAS_INTERNALS)
		cabin_air = new
		cabin_air.temperature = T20C
		cabin_air.volume = 200
		cabin_air.assert_gases("o2","n2")
		cabin_air.gases["o2"][MOLES] = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
		cabin_air.gases["n2"][MOLES] = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	if(features & HAS_GPS)
		internal_gps = new
		internal_gps.gpstag = gps_name