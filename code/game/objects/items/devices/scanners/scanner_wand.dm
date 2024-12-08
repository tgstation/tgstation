/obj/item/scanner_wand
	name = "kiosk scanner wand"
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "scanner_wand"
	inhand_icon_state = "healthanalyzer"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A wand that medically scans people. Inserting it into a medical kiosk makes it able to perform a health scan on the patient."
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_BULKY
	var/selected_target = null

/obj/item/scanner_wand/attack(mob/living/M, mob/living/carbon/human/user)
	flick("[icon_state]_active", src) //nice little visual flash when scanning someone else.

	if((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(25))
		user.visible_message(span_warning("[user] targets himself for scanning."), \
		to_chat(user, span_info("You try scanning [M], before realizing you're holding the scanner backwards. Whoops.")))
		selected_target = user
		return

	if(!ishuman(M))
		to_chat(user, span_info("You can only scan human-like, non-robotic beings."))
		selected_target = null
		return

	user.visible_message(span_notice("[user] targets [M] for scanning."), \
						span_notice("You target [M] vitals."))
	selected_target = M
	return

/obj/item/scanner_wand/attack_self(mob/user)
	to_chat(user, span_info("You clear the scanner's target."))
	selected_target = null

/obj/item/scanner_wand/proc/return_patient()
	var/returned_target = selected_target
	return returned_target
