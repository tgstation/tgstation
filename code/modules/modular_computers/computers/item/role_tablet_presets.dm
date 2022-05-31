/obj/item/modular_computer/tablet/pda/medical
	name = "medical PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#000099#3F96CC"

/obj/item/modular_computer/tablet/pda/viro
	name = "virology PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#FAFAFA#355FAC#57C451"

/obj/item/modular_computer/tablet/pda/engineering
	name = "engineering PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/engineering
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D99A2E#69DBF3#E3DF3D"

/obj/item/modular_computer/tablet/pda/security
	name = "security PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/security
	greyscale_colors = "#EA3232#0000cc"

/obj/item/modular_computer/tablet/pda/detective
	name = "detective PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/detective
	greyscale_colors = "#805A2F#990202"

/obj/item/modular_computer/tablet/pda/warden
	name = "warden PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/security
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#EA3232#0000CC#363636"

/obj/item/modular_computer/tablet/pda/janitor
	name = "janitor PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/janitor
	greyscale_colors = "#933ea8#235AB2"

/obj/item/modular_computer/tablet/pda/science
	name = "scientist PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/signal/ordnance
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#000099#B347BC"

/obj/item/modular_computer/tablet/pda/heads
	default_disk = /obj/item/computer_hardware/hard_drive/role/head
	greyscale_config = /datum/greyscale_config/tablet/head
	greyscale_colors = "#67A364#a92323"

/obj/item/modular_computer/tablet/pda/heads/hop
	name = "head of personnel PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/hop

/obj/item/modular_computer/tablet/pda/heads/hos
	name = "head of security PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/hos
	greyscale_config = /datum/greyscale_config/tablet/head
	greyscale_colors = "#EA3232#0000CC"

/obj/item/modular_computer/tablet/pda/heads/ce
	name = "chief engineer PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/ce
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#D99A2E#69DBF3#FAFAFA"

/obj/item/modular_computer/tablet/pda/heads/cmo
	name = "chief medical officer PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/cmo
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#FAFAFA#000099#3F96CC"

/obj/item/modular_computer/tablet/pda/heads/rd
	name = "research director PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/rd
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#FAFAFA#000099#B347BC"
	insert_type = /obj/item/pen/fountain

/obj/item/modular_computer/tablet/pda/captain
	name = "captain PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/captain
	greyscale_config = /datum/greyscale_config/tablet/captain
	greyscale_colors = "#2C7CB2#FF0000#FFFFFF#FFD55B"
	insert_type = /obj/item/pen/fountain

/obj/item/modular_computer/tablet/pda/captain/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TABLET_CHECK_DETONATE, .proc/tab_no_detonate)

/obj/item/modular_computer/tablet/pda/cargo
	name = "cargo technician PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/quartermaster
	greyscale_colors = "#D6B328#6506CA"

/obj/item/modular_computer/tablet/pda/quartermaster/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/pda/quartermaster
	name = "quartermaster PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/quartermaster
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D6B328#6506CA#927444"

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
	greyscale_colors = "#333333#D11818"

/obj/item/modular_computer/tablet/pda/lawyer
	name = "lawyer PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/lawyer
	greyscale_colors = "#4C76C8#FFE243"
	insert_type = /obj/item/pen/fountain

/obj/item/modular_computer/tablet/pda/botanist
	name = "botanist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#50E193#E26F41#71A7CA"

/obj/item/modular_computer/tablet/pda/roboticist
	name = "roboticist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#484848#0099CC#D94927"
	default_disk = /obj/item/computer_hardware/hard_drive/role/roboticist

/obj/item/modular_computer/tablet/pda/cook
	name = "cook PDA"
	greyscale_colors = "#FAFAFA#A92323"

/obj/item/modular_computer/tablet/pda/bar
	name = "bartender PDA"
	greyscale_colors = "#333333#C7C7C7"

/obj/item/modular_computer/tablet/pda/atmos
	name = "atmospherics PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/atmos
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#EEDC43#00E5DA#727272"

/obj/item/modular_computer/tablet/pda/chemist
	name = "chemist PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/chemistry
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#355FAC#EA6400"

/obj/item/modular_computer/tablet/pda/geneticist
	name = "geneticist PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#FAFAFA#000099#0097CA"

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
	default_disk = /obj/item/computer_hardware/hard_drive/role/curator
	greyscale_config = null
	greyscale_colors = null
	icon_state = "pda-library"
	insert_type = /obj/item/pen/fountain

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
	device_theme = "syndicate"

/obj/item/modular_computer/tablet/pda/clear
	name = "clear PDA"
	icon_state = "pda-clear"
	greyscale_config = null
	greyscale_colors = null

