/obj/item/modular_computer/tablet/nano
	name = "nanotablet"
	desc = "A result of collaborations between Thinktronic Systems, and Nanotrasen. Providing you with the best way to keep your ID and programs in one place!"
	deconstructable = FALSE
	upgradable = FALSE

	icon_state = "pda"

	greyscale_config = /datum/greyscale_config/pda
	greyscale_colors = "#999875#a92323"

	var/default_cartridge = 0

/obj/item/modular_computer/tablet/nano/update_icon_state()
	. = ..()
	icon_state = "pda"

/obj/item/modular_computer/tablet/nano/update_overlays()
	. = ..()
	var/init_icon = initial(icon)
	var/obj/item/computer_hardware/card_slot/card = all_components[MC_CARD]
	if(!init_icon)
		return
	if(card)
		if(card.stored_card)
			. += mutable_appearance(init_icon, "id_overlay")
	if(light_on)
		. += mutable_appearance(init_icon, "light_overlay")

/obj/item/modular_computer/tablet/nano/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/cartridge_slot/cart = new
	install_component(new /obj/item/computer_hardware/hard_drive/micro)
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(cart)
	install_component(new /obj/item/computer_hardware/identifier)

	if(default_cartridge)
		cart.stored_cart = SSwardrobe.provide_type(default_cartridge, src)
		cart.set_program(cart.stored_cart)

/obj/item/modular_computer/tablet/nano/proc/get_types_to_preload()
	var/list/preload = list()
	preload += default_cartridge
	return preload

/obj/item/modular_computer/tablet/nano/attack_ai(mob/user)
	return // we don't want ais or cyborgs using a private nanotablet

// PRESETS

/obj/item/modular_computer/tablet/nano/medical
	name = "medical nanotablet"
	default_cartridge = /obj/item/cartridge/medical
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#e2e2e2#000099#5d99be"

/obj/item/modular_computer/tablet/nano/viro
	name = "virology nanotablet"
	default_cartridge = /obj/item/cartridge/medical
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#e2e2e2#355FAC#789876"

/obj/item/modular_computer/tablet/nano/engineering
	name = "engineering nanotablet"
	default_cartridge = /obj/item/cartridge/engineering
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#C5994C#69DBF3#D9D65B"

/obj/item/modular_computer/tablet/nano/security
	name = "security nanotablet"
	default_cartridge = /obj/item/cartridge/security
	greyscale_colors = "#cc4242#0000cc"

/obj/item/modular_computer/tablet/nano/detective
	name = "detective nanotablet"
	default_cartridge = /obj/item/cartridge/detective
	greyscale_colors = "#90714F#990202"

/obj/item/modular_computer/tablet/nano/warden
	name = "warden nanotablet"
	default_cartridge = /obj/item/cartridge/security
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#cc4242#0000cc#666666"

/obj/item/modular_computer/tablet/nano/janitor
	name = "janitor nanotablet"
	default_cartridge = /obj/item/cartridge/janitor
	greyscale_colors = "#933ea8#235AB2"

/obj/item/modular_computer/tablet/nano/science
	name = "scientist nanotablet"
	default_cartridge = /obj/item/cartridge/signal/ordnance
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#e2e2e2#000099#9F5CA5"

/obj/item/modular_computer/tablet/nano/heads
	default_cartridge = /obj/item/cartridge/head
	greyscale_config = /datum/greyscale_config/pda/head
	greyscale_colors = "#789876#a92323"

/obj/item/modular_computer/tablet/nano/heads/hop
	name = "head of personnel nanotablet"
	default_cartridge = /obj/item/cartridge/hop

/obj/item/modular_computer/tablet/nano/heads/hos
	name = "head of security nanotablet"
	default_cartridge = /obj/item/cartridge/hos
	greyscale_config = /datum/greyscale_config/pda/head
	greyscale_colors = "#cc4242#0000cc"

/obj/item/modular_computer/tablet/nano/heads/ce
	name = "chief engineer nanotablet"
	default_cartridge = /obj/item/cartridge/ce
	greyscale_config = /datum/greyscale_config/pda/stripe_thick/head
	greyscale_colors = "#C4A56D#69DBF3#e2e2e2"

/obj/item/modular_computer/tablet/nano/heads/cmo
	name = "chief medical officer nanotablet"
	default_cartridge = /obj/item/cartridge/cmo
	greyscale_config = /datum/greyscale_config/pda/stripe_thick/head
	greyscale_colors = "#e2e2e2#000099#5d99be"

/obj/item/modular_computer/tablet/nano/heads/rd
	name = "research director nanotablet"
	default_cartridge = /obj/item/cartridge/rd
	greyscale_config = /datum/greyscale_config/pda/stripe_thick/head
	greyscale_colors = "#e2e2e2#000099#9F5CA5"

/obj/item/modular_computer/tablet/nano/captain
	name = "captain nanotablet"
	default_cartridge = /obj/item/cartridge/captain
	greyscale_config = /datum/greyscale_config/pda/captain
	greyscale_colors = "#2C7CB2#FF0000#FFFFFF#F5D67B"

/obj/item/modular_computer/tablet/nano/cargo
	name = "cargo technician nanotablet"
	default_cartridge = /obj/item/cartridge/quartermaster
	greyscale_colors = "#D6B328#6506ca"

/obj/item/modular_computer/tablet/nano/quartermaster
	name = "quartermaster nanotablet"
	default_cartridge = /obj/item/cartridge/quartermaster
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#D6B328#6506ca#927444"

/obj/item/modular_computer/tablet/nano/shaftminer
	name = "shaft miner nanotablet"
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#927444#D6B328#6C3BA1"

/obj/item/modular_computer/tablet/nano/chaplain
	name = "chaplain nanotablet"
	greyscale_config = /datum/greyscale_config/pda/chaplain
	greyscale_colors = "#333333#d11818"

/obj/item/modular_computer/tablet/nano/lawyer
	name = "lawyer nanotablet"
	default_cartridge = /obj/item/cartridge/lawyer
	greyscale_colors = "#5B74A5#f7e062"

/obj/item/modular_computer/tablet/nano/botanist
	name = "botanist nanotablet"
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#50E193#E26F41#71A7CA"

/obj/item/modular_computer/tablet/nano/roboticist
	name = "roboticist nanotablet"
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#484848#0099cc#d33725"
	default_cartridge = /obj/item/cartridge/roboticist

/obj/item/modular_computer/tablet/nano/cook
	name = "cook nanotablet"
	greyscale_colors = "#e2e2e2#a92323"

/obj/item/modular_computer/tablet/nano/bar
	name = "bartender nanotablet"
	greyscale_colors = "#333333#c7c7c7"

/obj/item/modular_computer/tablet/nano/atmos
	name = "atmospherics nanotablet"
	default_cartridge = /obj/item/cartridge/atmos
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#ceca2b#00E5DA#727272"

/obj/item/modular_computer/tablet/nano/chemist
	name = "chemist nanotablet"
	default_cartridge = /obj/item/cartridge/chemistry
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#e2e2e2#355FAC#ea6400"

/obj/item/modular_computer/tablet/nano/geneticist
	name = "geneticist nanotablet"
	default_cartridge = /obj/item/cartridge/medical
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#e2e2e2#000099#0097ca"

// unimplemented

/obj/item/modular_computer/tablet/nano/clown
	name = "clown nanotablet"
	default_cartridge = /obj/item/cartridge/virus/clown
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#e2e2e2#000099#0097ca"

/obj/item/modular_computer/tablet/nano/mime
	name = "mime nanotablet"
	default_cartridge = /obj/item/cartridge/virus/mime
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#e2e2e2#000099#0097ca"

/obj/item/modular_computer/tablet/nano/curator
	name = "curator nanotablet"
	default_cartridge = /obj/item/cartridge/curator
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#e2e2e2#000099#0097ca"

/obj/item/modular_computer/tablet/nano/syndicate
	name = "military nanotablet"
	greyscale_colors = "#891417#80FF80"
	saved_identification = "John Doe"
	saved_job = "Citizen"

/obj/item/modular_computer/tablet/nano/syndicate/Initialize()
	. = ..()

	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]

	if(hard_drive)
		var/datum/computer_file/program/messenger/msg = hard_drive.find_file_by_name("nt_messenger")

		if(msg)
			msg.sAndR = FALSE



