//Clown PDA is slippery.
/obj/item/device/pda/clown
	name = "clown PDA"
	default_cartridge = /obj/item/cartridge/virus/clown
	inserted_item = /obj/item/toy/crayon/rainbow
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/device/pda/clown/Initialize()
	. = ..()
	AddComponent(/datum/component/slippery, 120, NO_SLIP_WHEN_WALKING)

/obj/item/device/pda/clown/ComponentActivated(datum/component/C)
	..()
	var/datum/component/slippery/S = C
	if(!istype(S))
		return
	var/mob/living/carbon/human/M = S.slip_victim
	if (istype(M) && (M.real_name != src.owner))
		var/obj/item/cartridge/virus/clown/cart = cartridge
		if(istype(cart) && cart.charges < 5)
			cart.charges++

// Special AI/pAI PDAs that cannot explode.
/obj/item/device/pda/ai
	icon_state = "NONE"
	ttone = "data"
	fon = 0
	detonatable = FALSE

/obj/item/device/pda/ai/attack_self(mob/user)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	return

/obj/item/device/pda/ai/pai
	ttone = "assist"



/obj/item/device/pda/medical
	name = "medical PDA"
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-medical"

/obj/item/device/pda/viro
	name = "virology PDA"
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-virology"

/obj/item/device/pda/engineering
	name = "engineering PDA"
	default_cartridge = /obj/item/cartridge/engineering
	icon_state = "pda-engineer"

/obj/item/device/pda/security
	name = "security PDA"
	default_cartridge = /obj/item/cartridge/security
	icon_state = "pda-security"

/obj/item/device/pda/detective
	name = "detective PDA"
	default_cartridge = /obj/item/cartridge/detective
	icon_state = "pda-detective"

/obj/item/device/pda/warden
	name = "warden PDA"
	default_cartridge = /obj/item/cartridge/security
	icon_state = "pda-warden"

/obj/item/device/pda/janitor
	name = "janitor PDA"
	default_cartridge = /obj/item/cartridge/janitor
	icon_state = "pda-janitor"
	ttone = "slip"

/obj/item/device/pda/toxins
	name = "scientist PDA"
	default_cartridge = /obj/item/cartridge/signal/toxins
	icon_state = "pda-science"
	ttone = "boom"

/obj/item/device/pda/mime
	name = "mime PDA"
	default_cartridge = /obj/item/cartridge/virus/mime
	inserted_item = /obj/item/toy/crayon/mime
	icon_state = "pda-mime"
	silent = 1
	ttone = "silence"

/obj/item/device/pda/heads
	default_cartridge = /obj/item/cartridge/head
	icon_state = "pda-hop"

/obj/item/device/pda/heads/hop
	name = "head of personnel PDA"
	default_cartridge = /obj/item/cartridge/hop
	icon_state = "pda-hop"

/obj/item/device/pda/heads/hos
	name = "head of security PDA"
	default_cartridge = /obj/item/cartridge/hos
	icon_state = "pda-hos"

/obj/item/device/pda/heads/ce
	name = "chief engineer PDA"
	default_cartridge = /obj/item/cartridge/ce
	icon_state = "pda-ce"

/obj/item/device/pda/heads/cmo
	name = "chief medical officer PDA"
	default_cartridge = /obj/item/cartridge/cmo
	icon_state = "pda-cmo"

/obj/item/device/pda/heads/rd
	name = "research director PDA"
	default_cartridge = /obj/item/cartridge/rd
	inserted_item = /obj/item/pen/fountain
	icon_state = "pda-rd"

/obj/item/device/pda/captain
	name = "captain PDA"
	default_cartridge = /obj/item/cartridge/captain
	inserted_item = /obj/item/pen/fountain/captain
	icon_state = "pda-captain"
	detonatable = FALSE

/obj/item/device/pda/cargo
	name = "cargo technician PDA"
	default_cartridge = /obj/item/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/device/pda/quartermaster
	name = "quartermaster PDA"
	default_cartridge = /obj/item/cartridge/quartermaster
	inserted_item = /obj/item/pen/fountain
	icon_state = "pda-qm"

/obj/item/device/pda/shaftminer
	name = "shaft miner PDA"
	icon_state = "pda-miner"

/obj/item/device/pda/syndicate
	default_cartridge = /obj/item/cartridge/virus/syndicate
	icon_state = "pda-syndi"
	name = "military PDA"
	owner = "John Doe"
	hidden = 1

/obj/item/device/pda/chaplain
	name = "chaplain PDA"
	icon_state = "pda-chaplain"
	ttone = "holy"

/obj/item/device/pda/lawyer
	name = "lawyer PDA"
	default_cartridge = /obj/item/cartridge/lawyer
	inserted_item = /obj/item/pen/fountain
	icon_state = "pda-lawyer"
	ttone = "objection"

/obj/item/device/pda/botanist
	name = "botanist PDA"
	//default_cartridge = /obj/item/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/device/pda/roboticist
	name = "roboticist PDA"
	icon_state = "pda-roboticist"
	default_cartridge = /obj/item/cartridge/roboticist

/obj/item/device/pda/curator
	name = "curator PDA"
	icon_state = "pda-library"
	icon_alert = "pda-r-library"
	default_cartridge = /obj/item/cartridge/curator
	inserted_item = /obj/item/pen/fountain
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This model is a WGW-11 series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	silent = 1 //Quiet in the library!
	overlays_x_offset = -3

/obj/item/device/pda/clear
	name = "clear PDA"
	icon_state = "pda-clear"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This model is a special edition with a transparent case."
	note = "Congratulations, you have chosen the Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"

/obj/item/device/pda/cook
	name = "cook PDA"
	icon_state = "pda-cook"

/obj/item/device/pda/bar
	name = "bartender PDA"
	icon_state = "pda-bartender"
	inserted_item = /obj/item/pen/fountain

/obj/item/device/pda/atmos
	name = "atmospherics PDA"
	default_cartridge = /obj/item/cartridge/atmos
	icon_state = "pda-atmos"

/obj/item/device/pda/chemist
	name = "chemist PDA"
	default_cartridge = /obj/item/cartridge/chemistry
	icon_state = "pda-chemistry"

/obj/item/device/pda/geneticist
	name = "geneticist PDA"
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-genetics"
