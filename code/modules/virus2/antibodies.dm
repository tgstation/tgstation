//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

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

var/global/list/ANTIGENS = list(
"[ANTIGEN_A]" = "A",
"[ANTIGEN_B]" = "B",
"[ANTIGEN_RH]" = "RH",
"[ANTIGEN_Q]" = "Q",
"[ANTIGEN_U]" = "U",
"[ANTIGEN_V]" = "V",
"[ANTIGEN_Z]" = "Z",
"[ANTIGEN_M]" = "M",
"[ANTIGEN_N]" = "N",
"[ANTIGEN_P]" = "P",
"[ANTIGEN_O]" = "O"
)

// pure concentrated antibodies
datum/reagent/antibodies
	data = list("antibodies"=0)
	name = "Antibodies"
	id = "antibodies"
	reagent_state = LIQUID
	color = "#0050F0"

	reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
		if(istype(M,/mob/living/carbon))
			if(src.data && method == INGEST)
				if(M:virus2) if(src.data["antibodies"] & M:virus2.antigen)
					M:virus2.dead = 1
				M:antibodies |= src.data["antibodies"]
		return

// iterate over the list of antigens and see what matches
/proc/antigens2string(var/antigens)
	var/code = ""
	for(var/V in ANTIGENS) if(text2num(V) & antigens) code += ANTIGENS[V]
	return code