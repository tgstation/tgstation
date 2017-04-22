


/*
	Dear ninja gloves

	This isn't because I like you
	this is because your father is a bastard

	...
	I guess you're a little cool.
	 -Sayu


	see ninjaDrainAct.dm for ninjadrain_act()
	Touch() simply calls this on it's target now
	Ninja's electricuting people when?
	-Remie

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
	strip_delay = 120
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/draining = 0
	var/candrain = 0
	var/mindrain = 200
	var/maxdrain = 400


/obj/item/clothing/gloves/space_ninja/Touch(atom/A,proximity)
	if(!candrain || draining)
		return 0
	if(!ishuman(loc))
		return 0 //Only works while worn

	var/mob/living/carbon/human/H = loc

	var/obj/item/clothing/suit/space/space_ninja/suit = H.wear_suit
	if(!istype(suit))
		return 0
	if(isturf(A))
		return 0

	if(!proximity)
		return 0

	A.add_fingerprint(H)

	draining = 1
	var/drained = A.ninjadrain_act(suit,H,src)
	draining = 0

	if(isnum(drained)) //Numerical values of drained handle their feedback here, Alpha values handle it themselves (Research hacking)
		if(drained)
			to_chat(H, "<span class='notice'>Gained <B>[drained]</B> energy from \the [A].</span>")
		else
			to_chat(H, "<span class='danger'>\The [A] has run dry of power, you must find another source!</span>")
	else
		drained = 0 //as to not cancel attack_hand()

	return drained


/obj/item/clothing/gloves/space_ninja/proc/toggled()
	set name = "Toggle Interaction"
	set desc = "Toggles special interaction on or off."
	set category = "Ninja Equip"

	var/mob/living/carbon/human/U = loc
	to_chat(U, "You <b>[candrain?"disable":"enable"]</b> special interaction.")
	candrain=!candrain


/obj/item/clothing/gloves/space_ninja/examine(mob/user)
	..()
	if(flags & NODROP)
		to_chat(user, "The energy drain mechanism is: <B>[candrain?"active":"inactive"]</B>.")
