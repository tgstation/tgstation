/**
 * Command
 */

/obj/item/modular_computer/tablet/pda/heads
	greyscale_config = /datum/greyscale_config/tablet/head
	greyscale_colors = "#67A364#a92323"
	default_applications = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
	)

/obj/item/modular_computer/tablet/pda/heads/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/card_slot/secondary)

/obj/item/modular_computer/tablet/pda/heads/captain
	name = "captain PDA"
	greyscale_config = /datum/greyscale_config/tablet/captain
	greyscale_colors = "#2C7CB2#FF0000#FFFFFF#FFD55B"
	insert_type = /obj/item/pen/fountain/captain

/obj/item/modular_computer/tablet/pda/heads/captain/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TABLET_CHECK_DETONATE, .proc/tab_no_detonate)
	var/obj/item/computer_hardware/hard_drive/drive = all_components[MC_HDD]
	if(!drive)
		return
	for(var/datum/computer_file/program/messenger/messenger_app in drive.stored_files)
		messenger_app.spam_mode = TRUE

/obj/item/modular_computer/tablet/pda/heads/hop
	name = "head of personnel PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#374f7e#a52f29#a52f29"
	default_applications = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/job_management,
	)

/obj/item/modular_computer/tablet/pda/heads/hos
	name = "head of security PDA"
	greyscale_config = /datum/greyscale_config/tablet/head
	greyscale_colors = "#EA3232#0000CC"
	default_applications = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/records/security,
	)

/obj/item/modular_computer/tablet/pda/heads/ce
	name = "chief engineer PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#D99A2E#69DBF3#FAFAFA"
	default_applications = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/alarm_monitor,
		/datum/computer_file/program/supermatter_monitor,
	)

/obj/item/modular_computer/tablet/pda/heads/cmo
	name = "chief medical officer PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#FAFAFA#000099#3F96CC"
	default_applications = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/phys_scanner/all,
		/datum/computer_file/program/records/medical,
	)

/obj/item/modular_computer/tablet/pda/heads/rd
	name = "research director PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#FAFAFA#000099#B347BC"
	insert_type = /obj/item/pen/fountain
	default_applications = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/phys_scanner/chemistry,
		/datum/computer_file/program/signal_commander,
	)

/**
 * Security
 */

/obj/item/modular_computer/tablet/pda/security
	name = "security PDA"
	greyscale_colors = "#EA3232#0000cc"
	default_applications = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/tablet/pda/detective
	name = "detective PDA"
	greyscale_colors = "#805A2F#990202"
	default_applications = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/phys_scanner/medical,
	)

/obj/item/modular_computer/tablet/pda/warden
	name = "warden PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#EA3232#0000CC#363636"
	default_applications = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
	)

/**
 * Engineering
 */

/obj/item/modular_computer/tablet/pda/engineering
	name = "engineering PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D99A2E#69DBF3#E3DF3D"
	default_applications = list(
		/datum/computer_file/program/supermatter_monitor,
	)

/obj/item/modular_computer/tablet/pda/atmos
	name = "atmospherics PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#EEDC43#00E5DA#727272"
	default_applications = list(
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/alarm_monitor,
	)

/**
 * Science
 */

/obj/item/modular_computer/tablet/pda/science
	name = "scientist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#000099#B347BC"
	default_applications = list(
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/signal_commander,
	)

/obj/item/modular_computer/tablet/pda/roboticist
	name = "roboticist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#484848#0099CC#D94927"
	default_applications = list(
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/tablet/pda/geneticist
	name = "geneticist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#FAFAFA#000099#0097CA"
	default_applications = list(
		/datum/computer_file/program/phys_scanner/medical,
		/datum/computer_file/program/records/medical,
	)

/**
 * Medical
 */

/obj/item/modular_computer/tablet/pda/medical
	name = "medical PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#000099#3F96CC"
	default_applications = list(
		/datum/computer_file/program/phys_scanner/medical,
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/tablet/pda/viro
	name = "virology PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#FAFAFA#355FAC#57C451"
	default_applications = list(
		/datum/computer_file/program/phys_scanner/medical,
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/tablet/pda/chemist
	name = "chemist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#355FAC#EA6400"
	default_applications = list(
		/datum/computer_file/program/phys_scanner/chemistry,
	)

/**
 * Supply
 */

/obj/item/modular_computer/tablet/pda/cargo
	name = "cargo technician PDA"
	greyscale_colors = "#D6B328#6506CA"
	default_applications = list(
		/datum/computer_file/program/shipping,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/tablet/pda/quartermaster/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/pda/quartermaster
	name = "quartermaster PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D6B328#6506CA#927444"
	insert_type = /obj/item/pen/survival
	default_applications = list(
		/datum/computer_file/program/shipping,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/tablet/pda/quartermaster/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/pda/shaftminer
	name = "shaft miner PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#927444#D6B328#6C3BA1"

/**
 * Service
 */

/obj/item/modular_computer/tablet/pda/janitor
	name = "janitor PDA"
	greyscale_colors = "#933ea8#235AB2"
	default_applications = list(
		/datum/computer_file/program/radar/custodial_locator,
	)

/obj/item/modular_computer/tablet/pda/chaplain
	name = "chaplain PDA"
	greyscale_config = /datum/greyscale_config/tablet/chaplain
	greyscale_colors = "#333333#D11818"

/obj/item/modular_computer/tablet/pda/lawyer
	name = "lawyer PDA"
	greyscale_colors = "#4C76C8#FFE243"
	insert_type = /obj/item/pen/fountain
	default_applications = list(
		/datum/computer_file/program/records/security,
	)

/obj/item/modular_computer/tablet/pda/lawyer/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/drive = all_components[MC_HDD]
	if(!drive)
		return
	for(var/datum/computer_file/program/messenger/messenger_app in drive.stored_files)
		messenger_app.spam_mode = TRUE

/obj/item/modular_computer/tablet/pda/botanist
	name = "botanist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#50E193#E26F41#71A7CA"

/obj/item/modular_computer/tablet/pda/cook
	name = "cook PDA"
	greyscale_colors = "#FAFAFA#A92323"

/obj/item/modular_computer/tablet/pda/bar
	name = "bartender PDA"
	greyscale_colors = "#333333#C7C7C7"

/obj/item/modular_computer/tablet/pda/clown
	name = "clown PDA"
	loaded_cartridge = /obj/item/computer_hardware/hard_drive/portable/virus/clown
	icon_state = "pda-clown"
	greyscale_config = null
	greyscale_colors = null
	insert_type = /obj/item/toy/crayon/rainbow

/obj/item/modular_computer/tablet/pda/clown/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery/clowning, 120, NO_SLIP_WHEN_WALKING, CALLBACK(src, .proc/AfterSlip), slot_whitelist = list(ITEM_SLOT_ID, ITEM_SLOT_BELT))
	AddComponent(/datum/component/wearertargeting/sitcomlaughter, CALLBACK(src, .proc/after_sitcom_laugh))

/obj/item/modular_computer/tablet/pda/clown/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "pda_stripe_clown") // clowns have eyes that go over their screen, so it needs to be compiled last

/obj/item/modular_computer/tablet/pda/clown/proc/AfterSlip(mob/living/carbon/human/M)
	if (istype(M) && (M.real_name != saved_identification))
		var/obj/item/computer_hardware/hard_drive/portable/virus/clown/cart = all_components[MC_SDD]
		if(istype(cart) && cart.charges < 5)
			cart.charges++
			playsound(src,'sound/machines/ping.ogg',30,TRUE)

/obj/item/modular_computer/tablet/pda/clown/proc/after_sitcom_laugh(mob/victim)
	victim.visible_message("[src] lets out a burst of laughter!")

/obj/item/modular_computer/tablet/pda/mime
	name = "mime PDA"
	loaded_cartridge = /obj/item/computer_hardware/hard_drive/portable/virus/mime
	greyscale_config = /datum/greyscale_config/tablet/mime
	greyscale_colors = "#FAFAFA#EA3232"
	insert_type = /obj/item/toy/crayon/mime

/obj/item/modular_computer/tablet/pda/mime/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hdd = all_components[MC_HDD]

	if(hdd)
		for(var/datum/computer_file/program/messenger/msg in hdd.stored_files)
			msg.mime_mode = TRUE
			msg.allow_emojis = TRUE

/obj/item/modular_computer/tablet/pda/curator
	name = "curator PDA"
	greyscale_config = null
	greyscale_colors = null
	icon_state = "pda-library"
	insert_type = /obj/item/pen/fountain
	default_applications = list(
		/datum/computer_file/program/newscaster,
	)

/obj/item/modular_computer/tablet/pda/curator/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hdd = all_components[MC_HDD]

	if(hdd)
		for(var/datum/computer_file/program/messenger/msg in hdd.stored_files)
			msg.allow_emojis = TRUE

/**
 * Non-roles
 */

/obj/item/modular_computer/tablet/pda/syndicate
	name = "military PDA"
	greyscale_colors = "#891417#80FF80"
	saved_identification = "John Doe"
	saved_job = "Citizen"
	invisible = TRUE
	device_theme = "syndicate"

/obj/item/modular_computer/tablet/pda/clear
	name = "clear PDA"
	icon_state = "pda-clear"
	greyscale_config = null
	greyscale_colors = null

