// pure concentrated antibodies
datum/reagent/antibodies
	data = new/list("antibodies"=0)
	name = "Antibodies"
	id = "antibodies"
	reagent_state = LIQUID
	color = "#0050F0"

	reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
		if(istype(M,/mob/living/carbon))
			if(src.data && method == INGEST)
				if(M:virus2) if(src.data["antibodies"] & M:virus2.antigen)
					M:virus2.dead = 1
					// if the virus is killed this way it immunizes
					M:antibodies |= M:virus2.antigen
		return

// reserving some numbers for later special antigens
var/global/const
	ANTIGEN_A  = 1
	ANTIGEN_B  = 2
	ANTIGEN_RH = 4
	ANTIGEN_Q  = 8
	ANTIGEN_U  = 16
	ANTIGEN_V  = 32
	ANTIGEN_X  = 64
	ANTIGEN_Y  = 128
	ANTIGEN_Z  = 256
	ANTIGEN_M  = 512
	ANTIGEN_N  = 1024
	ANTIGEN_P  = 2048
	ANTIGEN_O  = 4096

var/global/list/ANTIGENS = list("[ANTIGEN_A]" = "A", "[ANTIGEN_B]" = "B", "[ANTIGEN_RH]" = "RH", "[ANTIGEN_Q]" = "Q",
								      "[ANTIGEN_U]" = "U", "[ANTIGEN_V]" = "V", "[ANTIGEN_Z]" = "Z", "[ANTIGEN_M]" = "M",
								      "[ANTIGEN_N]" = "N", "[ANTIGEN_P]" = "P", "[ANTIGEN_O]" = "O")



/obj/item/device/antibody_scanner
	name = "Antibody Scanner"
	desc = "Used to scan living beings for antibodies in their blood."
	icon_state = "health"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | CONDUCT | USEDELAY
	slot_flags = SLOT_BELT

/obj/item/device/antibody_scanner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if(! istype(M, /mob/living/carbon) || !M:antibodies)
		user << "Unable to detect antibodies.."
	else
		// iterate over the list of antigens and see what matches
		var/code = ""
		for(var/V in ANTIGENS) if(text2num(V) & M.antibodies) code += ANTIGENS[V]
		user << text("\blue [src] The antibody scanner displays a cryptic set of data: [code]")