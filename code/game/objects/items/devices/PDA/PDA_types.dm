//Clown PDA is slippery.
/obj/item/pda/clown
	name = "clown PDA"
	default_cartridge = /obj/item/cartridge/virus/clown
	inserted_item = /obj/item/toy/crayon/rainbow
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
	inserted_item = /obj/item/toy/crayon/mime
	greyscale_config = /datum/greyscale_config/pda/mime
	greyscale_colors = "#e2e2e2#cc4242"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The hardware has been modified for compliance with the vows of silence."
	allow_emojis = TRUE
	silent = TRUE
	ttone = "silence"

/obj/item/pda/mime/msg_input(mob/living/U = usr)
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

/obj/item/pda/ai/Initialize()
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
	greyscale_colors = "#e2e2e2#00cc00#789876"

/obj/item/pda/engineering
	name = "engineering PDA"
	default_cartridge = /obj/item/cartridge/engineering
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#ceca2b#a92323#cc4242"

/obj/item/pda/security
	name = "security PDA"
	default_cartridge = /obj/item/cartridge/security
	greyscale_colors = "#cc4242#339900"

/obj/item/pda/detective
	name = "detective PDA"
	default_cartridge = /obj/item/cartridge/detective
	greyscale_colors = "#97670e#990202"

/obj/item/pda/warden
	name = "warden PDA"
	default_cartridge = /obj/item/cartridge/security
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#cc4242#339900#cccc00"

/obj/item/pda/janitor
	name = "janitor PDA"
	default_cartridge = /obj/item/cartridge/janitor
	greyscale_colors = "#933ea8#a92323"
	ttone = "slip"

/obj/item/pda/science
	name = "scientist PDA"
	default_cartridge = /obj/item/cartridge/signal/ordnance
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#e2e2e2#000099#9e00ea"
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
	greyscale_colors = "#cc4242#339900"

/obj/item/pda/heads/ce
	name = "chief engineer PDA"
	default_cartridge = /obj/item/cartridge/ce
	greyscale_colors = "#ceca2b#339900"

/obj/item/pda/heads/cmo
	name = "chief medical officer PDA"
	default_cartridge = /obj/item/cartridge/cmo
	greyscale_config = /datum/greyscale_config/pda/stripe_thick/head
	greyscale_colors = "#e2e2e2#000099#5d99be"

/obj/item/pda/heads/rd
	name = "research director PDA"
	default_cartridge = /obj/item/cartridge/rd
	inserted_item = /obj/item/pen/fountain
	greyscale_config = /datum/greyscale_config/pda/stripe_thick/head
	greyscale_colors = "#e2e2e2#000099#9e00ea"

/obj/item/pda/captain
	name = "captain PDA"
	default_cartridge = /obj/item/cartridge/captain
	inserted_item = /obj/item/pen/fountain/captain
	greyscale_colors = "#aa9100#0060b8"

/obj/item/pda/captain/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_PDA_CHECK_DETONATE, .proc/pda_no_detonate)

/obj/item/pda/cargo
	name = "cargo technician PDA"
	default_cartridge = /obj/item/cartridge/quartermaster
	greyscale_colors = "#e39751#a92323"

/obj/item/pda/quartermaster
	name = "quartermaster PDA"
	default_cartridge = /obj/item/cartridge/quartermaster
	inserted_item = /obj/item/pen/fountain
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#e39751#a92323#a23e3e"

/obj/item/pda/shaftminer
	name = "shaft miner PDA"
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#af9366#8f36c6#8f36c6"

/obj/item/pda/syndicate
	default_cartridge = /obj/item/cartridge/virus/syndicate
	greyscale_colors = "#891417#000099"
	name = "military PDA"
	owner = "John Doe"
	hidden = 1

/obj/item/pda/chaplain
	name = "chaplain PDA"
	greyscale_config = /datum/greyscale_config/pda/chaplain
	greyscale_colors = "#333333#000099"
	ttone = "holy"

/obj/item/pda/lawyer
	name = "lawyer PDA"
	default_cartridge = /obj/item/cartridge/lawyer
	inserted_item = /obj/item/pen/fountain
	greyscale_colors = "#6f6192#f7e062"
	ttone = "objection"

/obj/item/pda/botanist
	name = "botanist PDA"
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#44843c#e29652#00cc35"

/obj/item/pda/roboticist
	name = "roboticist PDA"
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#484848#8b2400#d33725"
	default_cartridge = /obj/item/cartridge/roboticist

/obj/item/pda/curator
	name = "curator PDA"
	greyscale_config = null
	greyscale_colors = null
	icon_state = "pda-library"
	icon_alert = "pda-r-library"
	default_cartridge = /obj/item/cartridge/curator
	inserted_item = /obj/item/pen/fountain
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This model is a WGW-11 series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	silent = TRUE //Quiet in the library!
	overlays_x_offset = -3

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
	inserted_item = /obj/item/pen/fountain

/obj/item/pda/atmos
	name = "atmospherics PDA"
	default_cartridge = /obj/item/cartridge/atmos
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#ceca2b#a92323#3c94c5"

/obj/item/pda/chemist
	name = "chemist PDA"
	default_cartridge = /obj/item/cartridge/chemistry
	greyscale_config = /datum/greyscale_config/pda/stripe_thick
	greyscale_colors = "#e2e2e2#a92323#ea6400"

/obj/item/pda/geneticist
	name = "geneticist PDA"
	default_cartridge = /obj/item/cartridge/medical
	greyscale_config = /datum/greyscale_config/pda/stripe_split
	greyscale_colors = "#e2e2e2#000099#0097ca"
