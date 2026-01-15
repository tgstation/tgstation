/obj/item/implant/weapons_auth
	name = "firearms authentication implant"
	desc = "Lets you shoot your guns."
	icon_state = "auth"
	actions_types = null

	implant_info = "Automatically activates upon implantation. Provides authentication for weapons with \
		appropriate security systems, typically in the firing pin."

	implant_lore = "The Cybersun Equipment Authentication Implant is a subdermal RFID authentication module \
		and paired transmitter, designed to interface with equipment that has appropriate security systems, \
		such as implant-locked firing pins popular with associated covert operatives and non-state actors. \
		Equipment with such authentication systems is noteworthy for inconveniencing those trying to \
		pilfer equipment from fallen enemies' hands, preventing their equipment from easily being used. \
		However, it should be noted that the weakest link in a digital authentication scheme is oftentimes the physical layer."

/obj/item/implant/emp
	name = "\improper EMP implant"
	desc = "Triggers an EMP."
	icon_state = "emp"
	uses = 3

	implant_info = "Activated manually. Generates an indiscriminate electromagnetic pulse of moderate size when triggered."

	implant_lore = "The Cybersun Subdermal Electromagnetic Pulse Generator is, true to its name, \
		a subdermal implant designed to generate indiscriminate electromagnetic pulses when triggered, \
		disrupting electronic equipment, such as energy weaponry, and lifeforms, \
		such as stationbound silicon units, within the user's radius. \
		Prospective users are reminded that the S-EPG does not protect the host from their own electromagnetic pulses."

/obj/item/implant/emp/activate()
	. = ..()
	uses--
	empulse(imp_in, 3, 5, emp_source = src)
	if(!uses)
		qdel(src)

/obj/item/implanter/emp
	name = "implanter (EMP)"
	imp_type = /obj/item/implant/emp

/obj/item/implant/smoke
	name = "smoke implant"
	desc = "Releases a plume of smoke."
	icon_state = "smoke"
	uses = 3

	implant_info = "Activated manually. Generates an indiscriminate cloud of smoke of moderate size when triggered."

	implant_lore = "The Cybersun Subdermal Visual Obstruction Generator is, true to its name, \
		a subdermal implant designed to generate visual obstructions in the form of smoke clouds when triggered, \
		disrupting lines of sight to the user. \
		Prospective users are reminded that the S-VOG does not protect the host particularly well from \
		thermal imaging, nor does it actually stop blind fire into the smoke, nor does it stop movement."

/obj/item/implant/smoke/activate()
	. = ..()
	uses--
	var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
	smoke.set_up(6, holder = imp_in, location = imp_in)
	smoke.start()
	if(!uses)
		qdel(src)

/obj/item/implanter/smoke
	name = "implanter (Smoke)"
	imp_type = /obj/item/implant/smoke

/obj/item/implant/radio
	name = "internal radio implant"
	var/obj/item/radio/radio
	var/radio_key
	var/subspace_transmission = FALSE
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "walkietalkie"

	implant_info = "Automatically activates upon implantation. Provides radio transmission and reception capabilities."

	implant_lore = "The Internal Radio Implant, a long open-sourced design manufactured by \
		just about everyone from Nanotrasen to Cybersun, is a subdermal two-way radio system designed \
		to interface with telecommunications networks. It's mainly useful for those who expect either \
		equipment loss or lack the ability to use standalone radio equipment easily."

/obj/item/implant/radio/activate()
	. = ..()
	// needs to be GLOB.deep_inventory_state otherwise it won't open
	radio.ui_interact(usr, state = GLOB.deep_inventory_state)

/obj/item/implant/radio/Initialize(mapload)
	. = ..()

	radio = new(src)
	// almost like an internal headset, but without the
	// "must be in ears to hear" restriction.
	radio.name = "internal radio"
	radio.subspace_transmission = subspace_transmission
	radio.canhear_range = 0
	if(radio_key)
		radio.keyslot = new radio_key
	radio.recalculateChannels()

/obj/item/implant/radio/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/item/implant/radio/mining
	radio_key = /obj/item/encryptionkey/headset_cargo

/obj/item/implant/radio/syndicate
	desc = "Are you there God? It's me, Syndicate Comms Agent."
	radio_key = /obj/item/encryptionkey/syndicate
	subspace_transmission = TRUE

/obj/item/implant/radio/slime
	name = "slime radio"
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "adamantine_resonator"
	radio_key = /obj/item/encryptionkey/headset_sci
	subspace_transmission = TRUE

/obj/item/implanter/radio
	name = "implanter (internal radio)"
	imp_type = /obj/item/implant/radio

/obj/item/implanter/radio/syndicate
	name = "implanter (internal syndicate radio)"
	imp_type = /obj/item/implant/radio/syndicate
