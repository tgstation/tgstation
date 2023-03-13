/obj/item/scanner_wand
	name = "kiosk scanner wand"
	desc = "A wand that medically scans people. Inserting it into a medical kiosk makes it able to perform a health scan on the patient."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner_wand"
	inhand_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	force = 0
	throwforce = 0
	hitsound = 'sound/machines/ping.ogg'
	w_class = WEIGHT_CLASS_BULKY
	var/datum/weakref/selected_target

/obj/item/scanner_wand/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CUSTOM_TAP_SOUND, INNATE_TRAIT)
	return INITIALIZE_HINT_LATELOAD

/obj/item/scanner_wand/LateInitialize()
	. = ..()
	AddComponent(
		/datum/component/experiment_handler, \
		allowed_experiments = list(/datum/experiment/scanning/points/people), \
		config_mode = EXPERIMENT_CONFIG_ALTCLICK, \
		disallowed_traits = EXPERIMENT_TRAIT_DESTRUCTIVE, \
	)

/obj/item/scanner_wand/attack(mob/living/M, mob/living/carbon/human/user)
	. = ..()
	if(.)
		return

	flick("[icon_state]_active", src) //nice little visual flash when scanning someone else.

	if((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(25))
		user.visible_message(
			span_warning("[user] targets himself for scanning."),
			span_warning("You try scanning [M], before realizing you're holding the scanner backwards. Whoops."),
		)
		selected_target = WEAKREF(user)
		return TRUE

	if(!ishuman(M))
		to_chat(user, span_info("You can only scan human-like, non-robotic beings."))
		selected_target = null
		return

	user.visible_message(
		span_notice("[user] targets [M] for scanning."),
		span_notice("You target [M] vitals."),
	)
	selected_target = WEAKREF(M)
	return TRUE

/obj/item/scanner_wand/attack_self(mob/user)
	if(selected_target)
		to_chat(user, span_info("You clear the scanner's target."))
		selected_target = null
		return

	return ..()

/obj/item/scanner_wand/proc/return_patient()
	return selected_target
