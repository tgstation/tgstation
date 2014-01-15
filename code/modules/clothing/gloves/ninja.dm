/*
	Dear ninja gloves

	This isn't because I like you
	this is because your father is a bastard

	...
	I guess you're a little cool.
	 -Sayu
*/

/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "s-ninja"
	item_state = "s-ninja"
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	var/draining = 0
	var/candrain = 0
	var/mindrain = 200
	var/maxdrain = 400

/*
	This runs the gamut of what ninja gloves can do
	The other option would be a dedicated ninja touch bullshit proc on everything
	which would probably more efficient, but ninjas are pretty rare.
	This was mostly introduced to keep ninja code from contaminating other code;
	with this in place it would be easier to untangle the rest of it.

	For the drain proc, see events/ninja.dm
*/
/obj/item/clothing/gloves/space_ninja/Touch(var/atom/A,var/proximity)
	if(!candrain || draining) return 0

	var/mob/living/carbon/human/H = loc
	if(!istype(H)) return 0 // what
	var/obj/item/clothing/suit/space/space_ninja/suit = H.wear_suit
	if(!istype(suit)) return 0
	if(isturf(A)) return 0

	if(!proximity) // todo: you could add ninja stars or computer hacking here
		return 0

	// Move an AI into and out of things
	if(istype(A,/mob/living/silicon/ai))
		if(suit.s_control)
			A.add_fingerprint(H)
			suit.transfer_ai("AICORE", "NINJASUIT", A, H)
			return 1
		else
			H << "\red <b>ERROR</b>: \black Remote access channel disabled."
			return 0

	if(istype(A,/obj/structure/AIcore/deactivated))
		if(suit.s_control)
			A.add_fingerprint(H)
			suit.transfer_ai("INACTIVE","NINJASUIT",A, H)
			return 1
		else
			H << "\red <b>ERROR</b>: \black Remote access channel disabled."
			return 0
	if(istype(A,/obj/machinery/computer/aifixer))
		if(suit.s_control)
			A.add_fingerprint(H)
			suit.transfer_ai("AIFIXER","NINJASUIT",A, H)
			return 1
		else
			H << "\red <b>ERROR</b>: \black Remote access channel disabled."
			return 0

	// steal energy from powered things
	if(istype(A,/mob/living/silicon/robot))
		A.add_fingerprint(H)
		drain("CYBORG",A,suit)
		return 1
	if(istype(A,/obj/machinery/power/apc))
		A.add_fingerprint(H)
		drain("APC",A,suit)
		return 1
	if(istype(A,/obj/structure/cable))
		A.add_fingerprint(H)
		drain("WIRE",A,suit)
		return 1
	if(istype(A,/obj/structure/grille))
		var/obj/structure/cable/C = locate() in A.loc
		if(C)
			drain("WIRE",C,suit)
		return 1
	if(istype(A,/obj/machinery/power/smes))
		A.add_fingerprint(H)
		drain("SMES",A,suit)
		return 1
	if(istype(A,/obj/mecha))
		A.add_fingerprint(H)
		drain("MECHA",A,suit)
		return 1

	// download research
	if(istype(A,/obj/machinery/computer/rdconsole))
		A.add_fingerprint(H)
		drain("RESEARCH",A,suit)
		return 1
	if(istype(A,/obj/machinery/r_n_d/server))
		A.add_fingerprint(H)
		var/obj/machinery/r_n_d/server/S = A
		if(S.disabled)
			return 1
		if(S.shocked)
			S.shock(H,50)
			return 1
		drain("RESEARCH",A,suit)
		return 1

