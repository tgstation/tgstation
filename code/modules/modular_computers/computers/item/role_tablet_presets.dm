/obj/item/modular_computer/tablet/pda/medical
	name = "medical PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#e2e2e2#000099#5d99be"

/obj/item/modular_computer/tablet/pda/viro
	name = "virology PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#e2e2e2#355FAC#789876"

/obj/item/modular_computer/tablet/pda/engineering
	name = "engineering PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/engineering
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#C5994C#69DBF3#D9D65B"

/obj/item/modular_computer/tablet/pda/security
	name = "security PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/security
	greyscale_colors = "#cc4242#0000cc"

/obj/item/modular_computer/tablet/pda/detective
	name = "detective PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/detective
	greyscale_colors = "#90714F#990202"

/obj/item/modular_computer/tablet/pda/warden
	name = "warden PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/security
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#cc4242#0000cc#666666"

/obj/item/modular_computer/tablet/pda/janitor
	name = "janitor PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/janitor
	greyscale_colors = "#933ea8#235AB2"

/obj/item/modular_computer/tablet/pda/science
	name = "scientist PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/signal/ordnance
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#e2e2e2#000099#9F5CA5"

/obj/item/modular_computer/tablet/pda/heads
	default_disk = /obj/item/computer_hardware/hard_drive/role/head
	greyscale_config = /datum/greyscale_config/tablet/head
	greyscale_colors = "#789876#a92323"

/obj/item/modular_computer/tablet/pda/heads/hop
	name = "head of personnel PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/hop

/obj/item/modular_computer/tablet/pda/heads/hos
	name = "head of security PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/hos
	greyscale_config = /datum/greyscale_config/tablet/head
	greyscale_colors = "#cc4242#0000cc"

/obj/item/modular_computer/tablet/pda/heads/ce
	name = "chief engineer PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/ce
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#C4A56D#69DBF3#e2e2e2"

/obj/item/modular_computer/tablet/pda/heads/cmo
	name = "chief medical officer PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/cmo
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#e2e2e2#000099#5d99be"

/obj/item/modular_computer/tablet/pda/heads/rd
	name = "research director PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/rd
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#e2e2e2#000099#9F5CA5"
	insert_type = /obj/item/pen/fountain

/obj/item/modular_computer/tablet/pda/captain
	name = "captain PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/captain
	greyscale_config = /datum/greyscale_config/tablet/captain
	greyscale_colors = "#2C7CB2#FF0000#FFFFFF#F5D67B"
	insert_type = /obj/item/pen/fountain

/obj/item/modular_computer/tablet/pda/captain/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TABLET_CHECK_DETONATE, .proc/tab_no_detonate)

/obj/item/modular_computer/tablet/pda/cargo
	name = "cargo technician PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/quartermaster
	greyscale_colors = "#D6B328#6506ca"

/obj/item/modular_computer/tablet/pda/quartermaster/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/pda/quartermaster
	name = "quartermaster PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/quartermaster
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D6B328#6506ca#927444"

/obj/item/modular_computer/tablet/pda/quartermaster/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/pda/shaftminer
	name = "shaft miner PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#927444#D6B328#6C3BA1"

/obj/item/modular_computer/tablet/pda/chaplain
	name = "chaplain PDA"
	greyscale_config = /datum/greyscale_config/tablet/chaplain
	greyscale_colors = "#333333#d11818"

/obj/item/modular_computer/tablet/pda/lawyer
	name = "lawyer PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/lawyer
	greyscale_colors = "#5B74A5#f7e062"
	insert_type = /obj/item/pen/fountain

/obj/item/modular_computer/tablet/pda/botanist
	name = "botanist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#50E193#E26F41#71A7CA"

/obj/item/modular_computer/tablet/pda/roboticist
	name = "roboticist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#484848#0099cc#d33725"
	default_disk = /obj/item/computer_hardware/hard_drive/role/roboticist

/obj/item/modular_computer/tablet/pda/cook
	name = "cook PDA"
	greyscale_colors = "#e2e2e2#a92323"

/obj/item/modular_computer/tablet/pda/bar
	name = "bartender PDA"
	greyscale_colors = "#333333#c7c7c7"

/obj/item/modular_computer/tablet/pda/atmos
	name = "atmospherics PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/atmos
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#ceca2b#00E5DA#727272"

/obj/item/modular_computer/tablet/pda/chemist
	name = "chemist PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/chemistry
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#e2e2e2#355FAC#ea6400"

/obj/item/modular_computer/tablet/pda/geneticist
	name = "geneticist PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#e2e2e2#000099#0097ca"

/obj/item/modular_computer/tablet/pda/clown
	name = "clown PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/virus/clown
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
		var/obj/item/computer_hardware/hard_drive/role/virus/clown/cart = all_components[MC_HDD_JOB]
		if(istype(cart) && cart.charges < 5)
			cart.charges++
			playsound(src,'sound/machines/ping.ogg',30,TRUE)

/obj/item/modular_computer/tablet/pda/clown/proc/after_sitcom_laugh(mob/victim)
	victim.visible_message("[src] lets out a burst of laughter!")

/obj/item/modular_computer/tablet/pda/mime
	name = "mime PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/virus/mime
	greyscale_config = /datum/greyscale_config/tablet/mime
	greyscale_colors = "#e2e2e2#cc4242"
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
	default_disk = /obj/item/computer_hardware/hard_drive/role/curator
	greyscale_config = null
	greyscale_colors = null
	icon_state = "pda-library"
	insert_type = /obj/item/pen/fountain
	display_overlays = FALSE

/obj/item/modular_computer/tablet/pda/curator/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hdd = all_components[MC_HDD]

	if(hdd)
		for(var/datum/computer_file/program/messenger/msg in hdd.stored_files)
			msg.allow_emojis = TRUE

/obj/item/modular_computer/tablet/pda/syndicate
	name = "military PDA"
	greyscale_colors = "#891417#80FF80"
	saved_identification = "John Doe"
	saved_job = "Citizen"
	invisible = TRUE

/obj/item/modular_computer/tablet/pda/clear
	name = "clear PDA"
	icon_state = "pda-clear"
	greyscale_config = null
	greyscale_colors = null

