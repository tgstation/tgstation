/**
 * Command
 */

/obj/item/modular_computer/pda/heads
	greyscale_config = /datum/greyscale_config/tablet/head
	greyscale_colors = "#67A364#a92323"
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
	)

/obj/item/modular_computer/pda/heads/captain
	name = "captain PDA"
	greyscale_config = /datum/greyscale_config/tablet/captain
	greyscale_colors = "#2C7CB2#FF0000#FFFFFF#FFD55B"
	inserted_item = /obj/item/pen/fountain/captain

/obj/item/modular_computer/pda/heads/captain/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TABLET_CHECK_DETONATE, PROC_REF(tab_no_detonate))
	for(var/datum/computer_file/program/messenger/messenger_app in stored_files)
		messenger_app.spam_mode = TRUE

/obj/item/modular_computer/pda/heads/captain/proc/tab_no_detonate()
	SIGNAL_HANDLER
	return COMPONENT_TABLET_NO_DETONATE

/obj/item/modular_computer/pda/heads/hop
	name = "head of personnel PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#374f7e#a52f29#a52f29"
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/job_management,
	)

/obj/item/modular_computer/pda/heads/hos
	name = "head of security PDA"
	greyscale_config = /datum/greyscale_config/tablet/head
	greyscale_colors = "#EA3232#0000CC"
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/records/security,
	)

/obj/item/modular_computer/pda/heads/ce
	name = "chief engineer PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#D99A2E#69DBF3#FAFAFA"
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/alarm_monitor,
		/datum/computer_file/program/supermatter_monitor,
	)

/obj/item/modular_computer/pda/heads/cmo
	name = "chief medical officer PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#FAFAFA#000099#3F96CC"
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/maintenance/phys_scanner,
		/datum/computer_file/program/records/medical,
	)

/obj/item/modular_computer/pda/heads/rd
	name = "research director PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#FAFAFA#000099#B347BC"
	inserted_item = /obj/item/pen/fountain
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/signal_commander,
	)

/obj/item/modular_computer/pda/heads/quartermaster
	name = "quartermaster PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D6B328#6506CA#927444"
	inserted_item = /obj/item/pen/survival
	stored_paper = 20
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/shipping,
		/datum/computer_file/program/robocontrol,
	)

/**
 * Security
 */

/obj/item/modular_computer/pda/security
	name = "security PDA"
	greyscale_colors = "#EA3232#0000cc"
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/detective
	name = "detective PDA"
	greyscale_colors = "#805A2F#990202"
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/warden
	name = "warden PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#EA3232#0000CC#363636"
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
	)

/**
 * Engineering
 */

/obj/item/modular_computer/pda/engineering
	name = "engineering PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D99A2E#69DBF3#E3DF3D"
	starting_programs = list(
		/datum/computer_file/program/supermatter_monitor,
	)

/obj/item/modular_computer/pda/atmos
	name = "atmospherics PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#EEDC43#00E5DA#727272"
	starting_programs = list(
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/alarm_monitor,
	)

/**
 * Science
 */

/obj/item/modular_computer/pda/science
	name = "scientist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#000099#B347BC"
	starting_programs = list(
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/signal_commander,
	)

/obj/item/modular_computer/pda/roboticist
	name = "roboticist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#484848#0099CC#D94927"
	starting_programs = list(
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/geneticist
	name = "geneticist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#FAFAFA#000099#0097CA"
	starting_programs = list(
		/datum/computer_file/program/records/medical,
	)

/**
 * Medical
 */

/obj/item/modular_computer/pda/medical
	name = "medical PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#000099#3F96CC"
	starting_programs = list(
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/medical/paramedic
	name = "paramedic PDA"
	starting_programs = list(
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/radar/lifeline,
	)

/obj/item/modular_computer/pda/viro
	name = "virology PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#FAFAFA#355FAC#57C451"
	starting_programs = list(
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/chemist
	name = "chemist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#355FAC#EA6400"

/**
 * Supply
 */

/obj/item/modular_computer/pda/cargo
	name = "cargo technician PDA"
	greyscale_colors = "#D6B328#6506CA"
	stored_paper = 20
	starting_programs = list(
		/datum/computer_file/program/shipping,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/shaftminer
	name = "shaft miner PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#927444#D6B328#6C3BA1"
	starting_programs = list(
		/datum/computer_file/program/skill_tracker,
	)

/**
 * Service
 */

/obj/item/modular_computer/pda/janitor
	name = "janitor PDA"
	greyscale_colors = "#933ea8#235AB2"
	starting_programs = list(
		/datum/computer_file/program/skill_tracker,
		/datum/computer_file/program/radar/custodial_locator,
	)

/obj/item/modular_computer/pda/chaplain
	name = "chaplain PDA"
	greyscale_config = /datum/greyscale_config/tablet/chaplain
	greyscale_colors = "#333333#D11818"

/obj/item/modular_computer/pda/lawyer
	name = "lawyer PDA"
	greyscale_colors = "#4C76C8#FFE243"
	inserted_item = /obj/item/pen/fountain
	starting_programs = list(
		/datum/computer_file/program/records/security,
	)

/obj/item/modular_computer/pda/lawyer/Initialize(mapload)
	. = ..()
	for(var/datum/computer_file/program/messenger/messenger_app in stored_files)
		messenger_app.spam_mode = TRUE

/obj/item/modular_computer/pda/botanist
	name = "botanist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#50E193#E26F41#71A7CA"

/obj/item/modular_computer/pda/cook
	name = "cook PDA"
	greyscale_colors = "#FAFAFA#A92323"

/obj/item/modular_computer/pda/bar
	name = "bartender PDA"
	greyscale_colors = "#333333#C7C7C7"

/obj/item/modular_computer/pda/clown
	name = "clown PDA"
	inserted_disk = /obj/item/computer_disk/virus/clown
	icon_state = "pda-clown"
	greyscale_config = null
	greyscale_colors = null
	inserted_item = /obj/item/toy/crayon/rainbow

/obj/item/modular_computer/pda/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery/clowning, 120, NO_SLIP_WHEN_WALKING, CALLBACK(src, PROC_REF(AfterSlip)), slot_whitelist = list(ITEM_SLOT_ID, ITEM_SLOT_BELT))
	AddComponent(/datum/component/wearertargeting/sitcomlaughter, CALLBACK(src, PROC_REF(after_sitcom_laugh)))

/obj/item/modular_computer/pda/clown/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "pda_stripe_clown") // clowns have eyes that go over their screen, so it needs to be compiled last

/obj/item/modular_computer/pda/clown/proc/AfterSlip(mob/living/carbon/human/M)
	if (istype(M) && (M.real_name != saved_identification))
		var/obj/item/computer_disk/virus/clown/cart = inserted_disk
		if(istype(cart) && cart.charges < 5)
			cart.charges++
			playsound(src,'sound/machines/ping.ogg',30,TRUE)

/obj/item/modular_computer/pda/clown/proc/after_sitcom_laugh(mob/victim)
	victim.visible_message("[src] lets out a burst of laughter!")

/obj/item/modular_computer/pda/mime
	name = "mime PDA"
	inserted_disk = /obj/item/computer_disk/virus/mime
	greyscale_config = /datum/greyscale_config/tablet/mime
	greyscale_colors = "#FAFAFA#EA3232"
	inserted_item = /obj/item/toy/crayon/mime
	starting_programs = list(
		/datum/computer_file/program/emojipedia,
	)

/obj/item/modular_computer/pda/mime/Initialize(mapload)
	. = ..()
	for(var/datum/computer_file/program/messenger/msg in stored_files)
		msg.mime_mode = TRUE
		msg.ringer_status = FALSE

/obj/item/modular_computer/pda/curator
	name = "curator PDA"
	desc = "A small experimental microcomputer."
	greyscale_config = null
	greyscale_colors = null
	icon_state = "pda-library"
	inserted_item = /obj/item/pen/fountain
	long_ranged = TRUE
	starting_programs = list(
		/datum/computer_file/program/emojipedia,
		/datum/computer_file/program/newscaster,
	)

/obj/item/modular_computer/pda/curator/Initialize(mapload)
	. = ..()
	for(var/datum/computer_file/program/messenger/msg in stored_files)
		msg.ringer_status = FALSE

/**
 * No Department
 */

/obj/item/modular_computer/pda/assistant
	name = "assistant PDA"
	starting_programs = list(
		/datum/computer_file/program/bounty_board,
	)

/**
 * Non-roles
 */

/obj/item/modular_computer/pda/syndicate
	name = "military PDA"
	greyscale_colors = "#891417#80FF80"
	saved_identification = "John Doe"
	saved_job = "Citizen"
	device_theme = "syndicate"

/obj/item/modular_computer/pda/syndicate/Initialize(mapload)
	. = ..()
	var/datum/computer_file/program/messenger/msg = locate() in stored_files
	if(msg)
		msg.invisible = TRUE

/obj/item/modular_computer/pda/clear
	name = "clear PDA"
	icon_state = "pda-clear"
	greyscale_config = null
	greyscale_colors = null
	long_ranged = TRUE
