//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

// pure concentrated antibodies
datum/reagent/antibodies
	data = new/list("antibodies"=0)
	name = "Antibodies"
	id = "antibodies"
	reagent_state = LIQUID
	color = "#0050F0"

	reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
		if(istype(M,/mob/living/carbon/human))
			if(src.data && method == INGEST)
				if(src.data["antibodies"] & M:virus2.antigen)
					M:virus2.dead = 1
		return

// reserving some numbers for later special antigens
var/global/const/ANTIGEN_A  = 1
var/global/const/ANTIGEN_B  = 2
var/global/const/ANTIGEN_RH = 4
var/global/const/ANTIGEN_Q  = 8
var/global/const/ANTIGEN_U  = 16
var/global/const/ANTIGEN_V  = 32
var/global/const/ANTIGEN_X  = 64
var/global/const/ANTIGEN_Y  = 128
var/global/const/ANTIGEN_Z  = 256
var/global/const/ANTIGEN_M  = 512
var/global/const/ANTIGEN_N  = 1024
var/global/const/ANTIGEN_P  = 2048
var/global/const/ANTIGEN_O  = 4096

var/global/list/ANTIGENS = list("[ANTIGEN_A]" = "A", "[ANTIGEN_B]" = "B", "[ANTIGEN_RH]" = "RH", "[ANTIGEN_Q]" = "Q",
								      "[ANTIGEN_U]" = "U", "[ANTIGEN_V]" = "V", "[ANTIGEN_Z]" = "Z", "[ANTIGEN_M]" = "M",
								      "[ANTIGEN_N]" = "N", "[ANTIGEN_P]" = "P", "[ANTIGEN_O]" = "O")



/obj/item/device/antibody_scanner
	name = "Antibody Scanner"
	desc = "Used to scan living beings for antibodies in their blood."
	icon_state = "health"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT | USEDELAY


/obj/item/device/antibody_scanner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if(! istype(M, /mob/living/carbon) || !M:antibodies)
		user << "Unable to detect antibodies.."
	else
		// iterate over the list of antigens and see what matches
		var/code = ""
		for(var/V in ANTIGENS) if(text2num(V) & M.antibodies) code += ANTIGENS[V]
		user << text("\blue [src] The antibody scanner displays a cryptic set of data: [code]")
