#define SEC_RADIO_SCAN_SOUND_ACCEPT list('sound/machines/beep.ogg')
#define SEC_RADIO_SCAN_SOUND_DENY list('sound/machines/buzz-two.ogg')
#define SEC_RADIO_SCAN_COOLDOWN 2 SECONDS

/obj/item/storage/belt/security/fulp_starter_full/PopulateContents()
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/radio/off/security(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/loaded(src)
	update_icon()

/obj/item/storage/box/survival/security/improved/PopulateContents()
	..() // we want the regular stuff too; crowbar and glowsticks for latejoins into depowered situations
	new /obj/item/flashlight/glowstick(src)
	new /obj/item/flashlight/glowstick(src)
	new /obj/item/flashlight/glowstick(src)
	new /obj/item/crowbar/red(src)

/obj/item/radio/off/security
	name = "security station bounced radio"
	icon = 'icons/Fulpicons/Surreal_stuff/sec_radio.dmi'
	icon_state = "sec_radio"
	desc = "A sophisticated full range station bounced radio. Preconfigured with a radio frequency for emergency security use in the event of telecom disruption. You can use a Security ID to reset its frequency to the emergency security channel."
	freerange = TRUE //Can access the full spectrum
	subspace_switchable = TRUE
	req_one_access = list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS)
	custom_materials = list(/datum/material/iron = 500, /datum/material/glass = 250)
	canhear_range = 3 //To keep dispatches private
	var/sound_time_stamp
	var/static/random_static_channel //This is the random channel we use.

/obj/item/radio/off/security/Initialize()
	. = ..()
	if(!random_static_channel)
		random_static_channel = pick(rand(MIN_FREE_FREQ, MIN_FREQ-2), rand(MAX_FREQ+2, MAX_FREE_FREQ)) //No public frequencies
		random_static_channel = sanitize_frequency(random_static_channel, freerange) //Make sure the pick is valid
	var/list/comparison_frequency_list = list(FREQ_SYNDICATE, FREQ_CTF_RED, FREQ_CTF_BLUE, FREQ_CENTCOM, FREQ_SUPPLY, FREQ_SERVICE, FREQ_SCIENCE, FREQ_COMMAND, FREQ_MEDICAL, FREQ_ENGINEERING, FREQ_SECURITY, FREQ_STATUS_DISPLAYS, FREQ_ATMOS_ALARMS, FREQ_ATMOS_CONTROL)
	for(var/comparison_frequency in comparison_frequency_list) //No taken frequencies
		if(random_static_channel == comparison_frequency)
			random_static_channel += pick(2, -2)
	if(random_static_channel >= MIN_FREQ && random_static_channel <= MAX_FREQ)
		random_static_channel = pick(rand(MAX_FREQ+2, MAX_FREE_FREQ)) //Fail safe reroll

	frequency = sanitize_frequency(random_static_channel, freerange)
	set_frequency(frequency)


/obj/item/radio/off/security/attackby(obj/item/W, mob/user, params)
	. = ..()
	var/obj/item/card/id/I
	if (istype(W, /obj/item/card/id))
		I = W
	else if (istype(W, /obj/item/pda))
		var/obj/item/pda/P = W
		I = P.id

	if(!I)
		return

	if(check_access(I))
		to_chat(user, "<span class='notice'>ID authenticated. Unit reset to security emergency frequency.</span>") //If we swipe it with Sec access, we return to the default emergency signal.
		frequency = sanitize_frequency(random_static_channel, freerange)
		set_frequency(frequency)
		sec_radio_sound()

	else
		to_chat(user, "<span class='warning'>ID is not authorized for reset to security emergency frequency.</span>")
		sec_radio_sound(FALSE)

/obj/item/radio/off/security/proc/sec_radio_sound(accepted = TRUE)
	if(world.time - sound_time_stamp > SEC_RADIO_SCAN_COOLDOWN)

		if(accepted)
			playsound(loc, SEC_RADIO_SCAN_SOUND_ACCEPT, get_clamped_volume(), TRUE, -1)
		else
			playsound(loc, SEC_RADIO_SCAN_SOUND_DENY, get_clamped_volume(), TRUE, -1)

		sound_time_stamp = world.time

/datum/design/security_station_bounced_radio
	name = "Security Station Bounced Radio"
	desc = "A sophisticated full range station bounced radio. Preconfigured with a radio channel for emergency security use in the event of telecom disruption."
	id = "sec_radio"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 250)
	build_path = /obj/item/radio/off/security
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/security_belt
	name = "Security Belt"
	desc = "A utility belt designed to hold various kinds of standard security gear, including but not limited to batons, flashes, radios, pepperspray, flashlights and handcuffs."
	id = "sec_belt"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/storage/belt/security
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/protolathe_handcuffs
	name = "Handcuffs"
	desc = "A standard pair of handcuffs, albeit with a more efficient manufacturing process."
	id = "protolathe_handcuffs"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 400) //Costs 25% less than autolathe cuffs, but requires research
	build_path = /obj/item/restraints/handcuffs
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/sec_helmet
	name = "Security Helmet"
	desc = "A standard issue security helmet. Protects the head from impacts."
	id = "security_helmet"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/plastic = 1000)
	build_path = /obj/item/clothing/head/helmet
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/sec_armor
	name = "Security Armor"
	desc = "A standard issue Type I security armored vest that provides decent protection against most types of damage."
	id = "security_armor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/plastic = 2500)
	build_path = /obj/item/clothing/suit/armor/vest/alt
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/sec_uniform
	name = "Security Uniform"
	desc = "A standard issue tactical security jumpsuit for officers complete with Nanotrasen belt buckle."
	id = "security_uniform"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/plastic = 200)
	build_path = /obj/item/clothing/under/rank/security/officer
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/sec_boots
	name = "Security Jackboots"
	desc = "Standard-issue security combat boots for combat scenarios or combat situations. All combat, all the time."
	id = "security_boots"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/plastic = 100)
	build_path = /obj/item/clothing/shoes/jackboots
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/sec_headset
	name = "Security Bowman Headset"
	desc = "Standard-issue security bowman headset. Protects ears from flashbangs. Comes with security encryption key."
	id = "security_headset"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 100)
	build_path = /obj/item/radio/headset/headset_sec/alt
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/stun_baton
	name = "Stun Baton"
	desc = "A standard issue stun baton for security officers."
	id = "stun_baton"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 500, /datum/material/silver = 1000, /datum/material/plastic = 1000)
	build_path = /obj/item/melee/baton
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/forensic_disk
	name = "Forensic Data Disk"
	desc = "A forensic data storage disk used with the detective's forensic scanner. Has read and write functionality."
	id = "forensic_data_disk"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/disk/forensic
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY