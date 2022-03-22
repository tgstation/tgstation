//Clown PDA is slippery.
/obj/item/pda/clown
	name = "clown PDA"
	default_cartridge = /obj/item/cartridge/virus/clown
	insert_type = /obj/item/toy/crayon/rainbow
	icon_state = "pda-clown"
	greyscale_config = null
	greyscale_config = null
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/pda/clown/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery/clowning, 120, NO_SLIP_WHEN_WALKING, CALLBACK(src, .proc/AfterSlip), slot_whitelist = list(ITEM_SLOT_ID, ITEM_SLOT_BELT))
	AddComponent(/datum/component/wearertargeting/sitcomlaughter, CALLBACK(src, .proc/after_sitcom_laugh))

/obj/item/pda/clown/proc/AfterSlip(mob/living/carbon/human/M)
	if (istype(M) && (M.real_name != owner))
		var/obj/item/cartridge/virus/clown/cart = cartridge
		if(istype(cart) && cart.charges < 5)
			cart.charges++
			playsound(src,'sound/machines/ping.ogg',30,TRUE)

/obj/item/pda/clown/proc/after_sitcom_laugh(mob/victim)
	victim.visible_message("[src] lets out a burst of laughter!")

//Mime PDA sends "silent" messages.
/obj/item/pda/mime
	name = "mime PDA"
	default_cartridge = /obj/item/cartridge/virus/mime
	insert_type = /obj/item/toy/crayon/mime
	greyscale_config = /datum/greyscale_config/pda/mime
	greyscale_colors = "#e2e2e2#cc4242"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The hardware has been modified for compliance with the vows of silence."
	allow_emojis = TRUE
	silent = TRUE
	ttone = "silence"

/obj/item/pda/mime/msg_input(mob/living/U = usr, rigged = FALSE)
	if(rigged)
		return ..()
	if(emped || toff)
		return
	var/emojis = emoji_sanitize(stripped_input(U, "Please enter emojis", name))
	if(!emojis)
		return
	if(!U.canUseTopic(src, BE_CLOSE))
		return
	return emojis

// Special AI/pAI PDAs that cannot explode.
/obj/item/pda/ai
	icon = null
	greyscale_config = null
	greyscale_colors = null
	ttone = "data"


/obj/item/pda/ai/attack_self(mob/user)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, TRUE)
	return

/obj/item/pda/ai/pai
	ttone = "assist"

/obj/item/pda/ai/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PDA_CHECK_DETONATE, .proc/pda_no_detonate)

/obj/item/pda/medical
	name = "medical PDA"
	default_cartridge = /obj/item/cartridge/medical
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#e2e2e2#000099#5d99be"

/obj/item/pda/viro
	name = "virology PDA"
	default_cartridge = /obj/item/cartridge/medical
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#e2e2e2#355FAC#789876"

/obj/item/pda/engineering
	name = "engineering PDA"
	default_cartridge = /obj/item/cartridge/engineering
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#C5994C#69DBF3#D9D65B"

/obj/item/pda/security
	name = "security PDA"
	default_cartridge = /obj/item/cartridge/security
	greyscale_colors = "#cc4242#0000cc"

/obj/item/pda/detective
	name = "detective PDA"
	default_cartridge = /obj/item/cartridge/detective
	greyscale_colors = "#90714F#990202"

/obj/item/pda/warden
	name = "warden PDA"
	default_cartridge = /obj/item/cartridge/security
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#cc4242#0000cc#666666"

/obj/item/pda/janitor
	name = "janitor PDA"
	default_cartridge = /obj/item/cartridge/janitor
	greyscale_colors = "#933ea8#235AB2"
	ttone = "slip"

/obj/item/pda/science
	name = "scientist PDA"
	default_cartridge = /obj/item/cartridge/signal/ordnance
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#e2e2e2#000099#9F5CA5"
	ttone = "boom"


/obj/item/pda/heads
	default_cartridge = /obj/item/cartridge/head
	greyscale_config = /datum/greyscale_config/pda/head
	greyscale_colors = "#789876#a92323"

/obj/item/pda/heads/hop
	name = "head of personnel PDA"
	default_cartridge = /obj/item/cartridge/hop

/obj/item/pda/heads/hos
	name = "head of security PDA"
	default_cartridge = /obj/item/cartridge/hos
	greyscale_config = /datum/greyscale_config/pda/head
	greyscale_colors = "#cc4242#0000cc"

/obj/item/pda/heads/ce
	name = "chief engineer PDA"
	default_cartridge = /obj/item/cartridge/ce
	greyscale_config = /datum/greyscale_config/pda/stripe_thick/head
	greyscale_colors = "#C4A56D#69DBF3#e2e2e2"

/obj/item/pda/heads/cmo
	name = "chief medical officer PDA"
	default_cartridge = /obj/item/cartridge/cmo
	greyscale_config = /datum/greyscale_config/pda/stripe_thick/head
	greyscale_colors = "#e2e2e2#000099#5d99be"

/obj/item/pda/heads/rd
	name = "research director PDA"
	default_cartridge = /obj/item/cartridge/rd
	insert_type = /obj/item/pen/fountain
	greyscale_config = /datum/greyscale_config/pda/stripe_thick/head
	greyscale_colors = "#e2e2e2#000099#9F5CA5"

/obj/item/pda/captain
	name = "captain PDA"
	default_cartridge = /obj/item/cartridge/captain
	insert_type = /obj/item/pen/fountain/captain
	greyscale_config = /datum/greyscale_config/pda/captain
	greyscale_colors = "#2C7CB2#FF0000#FFFFFF#F5D67B"

/obj/item/pda/captain/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PDA_CHECK_DETONATE, .proc/pda_no_detonate)

/obj/item/pda/cargo
	name = "cargo technician PDA"
	default_cartridge = /obj/item/cartridge/quartermaster
	greyscale_colors = "#D6B328#6506ca"

/obj/item/pda/quartermaster
	name = "quartermaster PDA"
	default_cartridge = /obj/item/cartridge/quartermaster
	insert_type = /obj/item/pen/survival
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#D6B328#6506ca#927444"

/obj/item/pda/shaftminer
	name = "shaft miner PDA"
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#927444#D6B328#6C3BA1"

/obj/item/pda/syndicate
	default_cartridge = /obj/item/cartridge/virus/syndicate
	greyscale_colors = "#891417#80FF80"
	name = "military PDA"
	owner = "John Doe"
	hidden = 1

/obj/item/pda/chaplain
	name = "chaplain PDA"
	greyscale_config = /datum/greyscale_config/pda/chaplain
	greyscale_colors = "#333333#d11818"
	ttone = "holy"

/obj/item/pda/lawyer
	name = "lawyer PDA"
	default_cartridge = /obj/item/cartridge/lawyer
	insert_type = /obj/item/pen/fountain
	greyscale_colors = "#5B74A5#f7e062"
	ttone = "objection"

/obj/item/pda/botanist
	name = "botanist PDA"
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#50E193#E26F41#71A7CA"

/obj/item/pda/roboticist
	name = "roboticist PDA"
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#484848#0099cc#d33725"
	default_cartridge = /obj/item/cartridge/roboticist

/obj/item/pda/curator
	name = "curator PDA"
	greyscale_config = null
	greyscale_colors = null
	icon_state = "pda-library"
	icon_alert = "pda-r-library"
	icon_pai = "pai_overlay_library"
	icon_inactive_pai = "pai_off_overlay_library"
	default_cartridge = /obj/item/cartridge/curator
	insert_type = /obj/item/pen/fountain
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This model is a WGW-11 series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	silent = TRUE //Quiet in the library!

/obj/item/pda/clear
	name = "clear PDA"
	icon_state = "pda-clear"
	greyscale_config = null
	greyscale_colors = null
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This model is a special edition with a transparent case."
	note = "Congratulations, you have chosen the Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"

/obj/item/pda/cook
	name = "cook PDA"
	greyscale_colors = "#e2e2e2#a92323"

/obj/item/pda/bar
	name = "bartender PDA"
	greyscale_colors = "#333333#c7c7c7"
	insert_type = /obj/item/pen/fountain

/obj/item/pda/atmos
	name = "atmospherics PDA"
	default_cartridge = /obj/item/cartridge/atmos
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#ceca2b#00E5DA#727272"

/obj/item/pda/chemist
	name = "chemist PDA"
	default_cartridge = /obj/item/cartridge/chemistry
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#e2e2e2#355FAC#ea6400"

/obj/item/pda/geneticist
	name = "geneticist PDA"
	default_cartridge = /obj/item/cartridge/medical
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#e2e2e2#000099#0097ca"
