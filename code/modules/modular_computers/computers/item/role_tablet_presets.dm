/obj/item/modular_computer/tablet/role/medical
	name = "medical tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#e2e2e2#000099#5d99be"

/obj/item/modular_computer/tablet/role/viro
	name = "virology tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#e2e2e2#355FAC#789876"

/obj/item/modular_computer/tablet/role/engineering
	name = "engineering tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/engineering
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#C5994C#69DBF3#D9D65B"

/obj/item/modular_computer/tablet/role/security
	name = "security tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/security
	greyscale_colors = "#cc4242#0000cc"

/obj/item/modular_computer/tablet/role/detective
	name = "detective tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/detective
	greyscale_colors = "#90714F#990202"

/obj/item/modular_computer/tablet/role/warden
	name = "warden tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/security
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#cc4242#0000cc#666666"

/obj/item/modular_computer/tablet/role/janitor
	name = "janitor tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/janitor
	greyscale_colors = "#933ea8#235AB2"

/obj/item/modular_computer/tablet/role/science
	name = "scientist tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/signal/ordnance
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#e2e2e2#000099#9F5CA5"

/obj/item/modular_computer/tablet/role/heads
	default_disk = /obj/item/computer_hardware/hard_drive/role/head
	greyscale_config = /datum/greyscale_config/tablet/head
	greyscale_colors = "#789876#a92323"

/obj/item/modular_computer/tablet/role/heads/hop
	name = "head of personnel tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/hop

/obj/item/modular_computer/tablet/role/heads/hos
	name = "head of security tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/hos
	greyscale_config = /datum/greyscale_config/tablet/head
	greyscale_colors = "#cc4242#0000cc"

/obj/item/modular_computer/tablet/role/heads/ce
	name = "chief engineer tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/ce
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#C4A56D#69DBF3#e2e2e2"

/obj/item/modular_computer/tablet/role/heads/cmo
	name = "chief medical officer tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/cmo
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#e2e2e2#000099#5d99be"

/obj/item/modular_computer/tablet/role/heads/rd
	name = "research director tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/rd
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#e2e2e2#000099#9F5CA5"
	insert_type = /obj/item/pen/fountain

/obj/item/modular_computer/tablet/role/captain
	name = "captain tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/captain
	greyscale_config = /datum/greyscale_config/tablet/captain
	greyscale_colors = "#2C7CB2#FF0000#FFFFFF#F5D67B"
	insert_type = /obj/item/pen/fountain

/obj/item/modular_computer/tablet/role/captain/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PDA_CHECK_DETONATE, .proc/tab_no_detonate)

/obj/item/modular_computer/tablet/role/cargo
	name = "cargo technician tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/quartermaster
	greyscale_colors = "#D6B328#6506ca"

/obj/item/modular_computer/tablet/role/quartermaster/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/role/quartermaster
	name = "quartermaster tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/quartermaster
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D6B328#6506ca#927444"

/obj/item/modular_computer/tablet/role/quartermaster/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/role/shaftminer
	name = "shaft miner tablet"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#927444#D6B328#6C3BA1"

/obj/item/modular_computer/tablet/role/chaplain
	name = "chaplain tablet"
	greyscale_config = /datum/greyscale_config/tablet/chaplain
	greyscale_colors = "#333333#d11818"

/obj/item/modular_computer/tablet/role/lawyer
	name = "lawyer tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/lawyer
	greyscale_colors = "#5B74A5#f7e062"
	insert_type = /obj/item/pen/fountain

/obj/item/modular_computer/tablet/role/botanist
	name = "botanist tablet"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#50E193#E26F41#71A7CA"

/obj/item/modular_computer/tablet/role/roboticist
	name = "roboticist tablet"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#484848#0099cc#d33725"
	default_disk = /obj/item/computer_hardware/hard_drive/role/roboticist

/obj/item/modular_computer/tablet/role/cook
	name = "cook tablet"
	greyscale_colors = "#e2e2e2#a92323"

/obj/item/modular_computer/tablet/role/bar
	name = "bartender tablet"
	greyscale_colors = "#333333#c7c7c7"

/obj/item/modular_computer/tablet/role/atmos
	name = "atmospherics tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/atmos
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#ceca2b#00E5DA#727272"

/obj/item/modular_computer/tablet/role/chemist
	name = "chemist tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/chemistry
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#e2e2e2#355FAC#ea6400"

/obj/item/modular_computer/tablet/role/geneticist
	name = "geneticist tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#e2e2e2#000099#0097ca"

/obj/item/modular_computer/tablet/role/clown
	name = "clown tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/virus/clown
	icon_state = "pda-clown"
	greyscale_config = null
	greyscale_colors = null
	insert_type = /obj/item/toy/crayon/rainbow

/obj/item/modular_computer/tablet/role/clown/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery/clowning, 120, NO_SLIP_WHEN_WALKING, CALLBACK(src, .proc/AfterSlip), slot_whitelist = list(ITEM_SLOT_ID, ITEM_SLOT_BELT))
	AddComponent(/datum/component/wearertargeting/sitcomlaughter, CALLBACK(src, .proc/after_sitcom_laugh))

/obj/item/modular_computer/tablet/role/clown/proc/AfterSlip(mob/living/carbon/human/M)
	if (istype(M) && (M.real_name != saved_identification))
		var/obj/item/computer_hardware/hard_drive/role/virus/clown/cart = all_components[MC_HDD_JOB]
		if(istype(cart) && cart.charges < 5)
			cart.charges++
			playsound(src,'sound/machines/ping.ogg',30,TRUE)

/obj/item/modular_computer/tablet/role/clown/proc/after_sitcom_laugh(mob/victim)
	victim.visible_message("[src] lets out a burst of laughter!")

/obj/item/modular_computer/tablet/role/mime
	name = "mime tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/virus/mime
	greyscale_config = /datum/greyscale_config/tablet/mime
	greyscale_colors = "#e2e2e2#cc4242"
	insert_type = /obj/item/toy/crayon/mime

/obj/item/modular_computer/tablet/role/curator
	name = "curator tablet"
	default_disk = /obj/item/computer_hardware/hard_drive/role/curator
	greyscale_config = null
	greyscale_colors = null
	icon_state = "pda-library"
	insert_type = /obj/item/pen/fountain
	display_overlays = FALSE

/obj/item/modular_computer/tablet/role/syndicate
	name = "military tablet"
	greyscale_colors = "#891417#80FF80"
	saved_identification = "John Doe"
	saved_job = "Citizen"
	invisible = TRUE

/obj/item/modular_computer/tablet/role/clear
	name = "clear tablet"
	icon_state = "pda-clear"
	greyscale_config = null
	greyscale_colors = null

