/**
  * # Ninja Gloves
  *
  * Space ninja's gloves.  Gives access to a number of special interactions.
  *
  * Gloves only found from space ninjas.  Allows the wearer to access special interactions with various objects.
  * These interactions are detailed in ninjaDrainAct.dm in the suit file.
  * These interactions are toggled by an action tied to the gloves.  The interactions will not activate if the user is also not wearing a ninja suit.
  *
  */
/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "s-ninja"
	inhand_icon_state = "s-ninja"
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 120
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	actions_types = list(/datum/action/item_action/toggle_glove)
	var/draining = FALSE
	var/candrain = FALSE
	var/mindrain = 200
	var/maxdrain = 400
	var/cyborg_hyjacks = 1
	var/security_console_hacks = 1
	var/communication_console_hacks = 1
	var/door_hack_counter = 0


/obj/item/clothing/gloves/space_ninja/Touch(atom/A,proximity)
	if(!candrain || draining)
		return FALSE
	if(!ishuman(loc))
		return FALSE	//Only works while worn

	var/mob/living/carbon/human/wearer = loc

	var/obj/item/clothing/suit/space/space_ninja/suit = wearer.wear_suit
	if(!istype(suit))
		return FALSE
	if(isturf(A))
		return FALSE

	if(!proximity)
		return FALSE

	A.add_fingerprint(wearer)

	draining = TRUE
	. = A.ninjadrain_act(suit,wearer,src)
	draining = FALSE

	if(isnum(.)) //Numerical values of drained handle their feedback here, Alpha values handle it themselves (Research hacking)
		if(.)
			to_chat(wearer, "<span class='notice'>Gained <B>[DisplayEnergy(.)]</B> of energy from [A].</span>")
		else
			to_chat(wearer, "<span class='danger'>\The [A] has run dry of energy, you must find another source!</span>")
	else
		. = FALSE	//as to not cancel attack_hand()

/obj/item/clothing/gloves/space_ninja/examine(mob/user)
	. = ..()
	if(HAS_TRAIT_FROM(src, TRAIT_NODROP, NINJA_SUIT_TRAIT))
		. += "[p_their(TRUE)] energy drain mechanism is <B>[candrain?"active":"inactive"]</B>."

/obj/item/clothing/gloves/space_ninja/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_glove))
		toggledrain()
		return TRUE
	return FALSE
