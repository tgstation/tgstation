#define INSTANT_WOUND_HEAL_STAMINA_DAMAGE 80
#define INSTANT_WOUND_HEAL_LIMB_DAMAGE 25

/obj/item/stack/medical/wound_recovery
	name = "subdermal splint applicator"
	desc = "A roll flexible material dotted with millions of micro-scale injectors on one side. \
		On application to a body part with a damaged bone structure, nanomachines stored within those \
		injectors will surround the wound and form a subdermal, self healing splint. While convenient \
		for keeping appearances and rapid healing, the nanomachines tend to leave their host particularly \
		vulnerable to new damage for several minutes after application."
	icon = 'modular_doppler/deforest_medical_items/icons/stack_items.dmi'
	icon_state = "subsplint"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	inhand_icon_state = "sampler"
	gender = PLURAL
	singular_name = "subdermal splint applicator"
	self_delay = 10 SECONDS
	other_delay = 5 SECONDS
	novariants = TRUE
	max_amount = 3
	amount = 3
	merge_type = /obj/item/stack/medical/wound_recovery
	custom_price = PAYCHECK_COMMAND * 2.5
	/// If this checks for pain, used for synthetic repair foam
	var/causes_pain = TRUE
	/// The types of wounds that we work on, in list format
	var/list/applicable_wounds = list(
		/datum/wound/blunt/bone,
		/datum/wound/muscle,
	)
	/// The sound we play upon successfully treating the wound
	var/treatment_sound = 'sound/items/duct_tape_rip.ogg'

// This is only relevant for the types of wounds defined, we can't work if there are none
/obj/item/stack/medical/wound_recovery/try_heal(mob/living/patient, mob/user, silent, looping)

	if(patient.has_status_effect(/datum/status_effect/vulnerable_to_damage))
		patient.balloon_alert(user, "still recovering from last use!")
		return

	var/treatment_delay = (user == patient ? self_delay : other_delay)

	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(user.zone_selected))
	if(!limb)
		patient.balloon_alert(user, "missing limb!")
		return
	if(!LAZYLEN(limb.wounds))
		patient.balloon_alert(user, "no wounds!")
		return

	var/splintable_wound = FALSE
	var/datum/wound/woundies
	for(var/found_wound in limb.wounds)
		woundies = found_wound
		if((woundies.wound_flags & ACCEPTS_GAUZE) && is_type_in_list(woundies, applicable_wounds))
			splintable_wound = TRUE
			break
	if(!splintable_wound)
		patient.balloon_alert(user, "can't heal those!")
		return

	if(HAS_TRAIT(woundies, TRAIT_WOUND_SCANNED))
		treatment_delay *= 0.5
		if(user == patient)
			to_chat(user, span_notice("You keep in mind the indications from the holo-image about your injury, and expertly begin applying [src]."))
		else
			user.visible_message(span_warning("[user] begins expertly treating the wounds on [patient]'s [limb.plaintext_zone] with [src]..."), span_warning("You begin quickly treating the wounds on [patient]'s [limb.plaintext_zone] with [src], keeping the holo-image indications in mind..."))
	else
		user.visible_message(span_warning("[user] begins treating the wounds on [patient]'s [limb.plaintext_zone] with [src]..."), span_warning("You begin treating the wounds on [user == patient ? "your" : "[patient]'s"] [limb.plaintext_zone] with [src]..."))

	if(!do_after(user, treatment_delay, target = patient))
		return

	user.visible_message(span_green("[user] applies [src] to [patient]'s [limb.plaintext_zone]."), span_green("You treat the wounds on [user == patient ? "your" : "[patient]'s"] [limb.plaintext_zone]."))
	playsound(patient, treatment_sound, 50, TRUE)
	woundies.remove_wound()
	if(!HAS_TRAIT(patient, TRAIT_ANALGESIA) || !causes_pain)
		patient.emote("scream")
		to_chat(patient, span_userdanger("Your [limb.plaintext_zone] burns like hell as the wounds on it are rapidly healed, fuck!"))
		patient.add_mood_event("severe_surgery", /datum/mood_event/rapid_wound_healing)
	limb.receive_damage(brute = INSTANT_WOUND_HEAL_LIMB_DAMAGE, wound_bonus = CANT_WOUND)
	patient.adjustStaminaLoss(INSTANT_WOUND_HEAL_STAMINA_DAMAGE)
	patient.apply_status_effect(/datum/status_effect/vulnerable_to_damage)
	use(1)

/datum/mood_event/rapid_wound_healing
	description = "The wound is gone, but that pain was unbearable!\n"
	mood_change = -3
	timeout = 5 MINUTES

// Helps recover bleeding
/obj/item/stack/medical/wound_recovery/rapid_coagulant
	name = "rapid coagulant applicator"
	singular_name = "rapid coagulant applicator"
	desc = "A small device filled with a fast acting coagulant of some type. \
		When used on a bleeding area, will nearly instantly stop all bleeding. \
		This rapid clotting action may result in temporary vulnerability to further \
		damage after application."
	icon_state = "clotter"
	inhand_icon_state = "implantcase"
	applicable_wounds = list(
		/datum/wound/slash/flesh,
		/datum/wound/pierce/bleed,
	)
	merge_type = /obj/item/stack/medical/wound_recovery/rapid_coagulant

/obj/item/stack/medical/wound_recovery/rapid_coagulant/post_heal_effects(amount_healed, mob/living/carbon/healed_mob, mob/user)
	. = ..()
	healed_mob.reagents.add_reagent(/datum/reagent/medicine/coagulant/fabricated, 5)

// Helps recover burn wounds much faster, while not healing much damage directly
/obj/item/stack/medical/ointment/red_sun
	name = "red sun balm"
	singular_name = "red sun balm"
	desc = "A popular brand of ointment for handling anything under the red sun, which tends to be terrible burns. \
		Which red sun may this be referencing? Not even the producers of the balm are sure."
	icon = 'modular_doppler/deforest_medical_items/icons/stack_items.dmi'
	icon_state = "balm"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	inhand_icon_state = "bandage"
	gender = PLURAL
	novariants = TRUE
	amount = 12
	max_amount = 12
	self_delay = 4 SECONDS
	other_delay = 2 SECONDS
	heal_burn = 5
	heal_brute = 5
	flesh_regeneration = 5
	sanitization = 3
	grind_results = list(/datum/reagent/medicine/oxandrolone = 3)
	merge_type = /obj/item/stack/medical/ointment/red_sun
	custom_price = PAYCHECK_LOWER * 1.5

/obj/item/stack/medical/ointment/red_sun/post_heal_effects(amount_healed, mob/living/carbon/healed_mob, mob/user)
	. = ..()
	healed_mob.reagents.add_reagent(/datum/reagent/medicine/lidocaine, 2)

// Gauze that are especially good at treating burns, but are terrible splints
/obj/item/stack/medical/gauze/sterilized
	name = "sealed aseptic gauze"
	singular_name = "sealed aseptic gauze"
	desc = "A small roll of elastic material specially treated to be entirely sterile, and sealed in plastic just to be sure. \
		These make excellent treatment against burn wounds, but due to their small nature are sub-par for serving as \
		bone wound wrapping."
	icon = 'modular_doppler/deforest_medical_items/icons/stack_items.dmi'
	icon_state = "burndaid"
	inhand_icon_state = null
	novariants = TRUE
	max_amount = 6
	amount = 6
	splint_factor = 1.2
	burn_cleanliness_bonus = 0.1
	merge_type = /obj/item/stack/medical/gauze/sterilized
	custom_price = PAYCHECK_LOWER * 1.5

/obj/item/stack/medical/gauze/sterilized/post_heal_effects(amount_healed, mob/living/carbon/healed_mob, mob/user)
	. = ..()
	healed_mob.reagents.add_reagent(/datum/reagent/space_cleaner/sterilizine, 5)
	healed_mob.reagents.expose(healed_mob, TOUCH, 1)

// Works great at sealing bleed wounds, but does little to actually heal them
/obj/item/stack/medical/suture/coagulant
	name = "coagulant-F packet"
	singular_name = "coagulant-F packet"
	desc = "A small packet of fabricated coagulant for bleeding. Not as effective as some \
		other methods of coagulating wounds, but is more effective than plain sutures. \
		The downsides? It repairs less of the actual damage that's there."
	icon = 'modular_doppler/deforest_medical_items/icons/stack_items.dmi'
	icon_state = "clotter_slow"
	inhand_icon_state = null
	novariants = TRUE
	amount = 12
	max_amount = 12
	repeating = FALSE
	heal_brute = 0
	stop_bleeding = 2
	merge_type = /obj/item/stack/medical/suture/coagulant
	custom_price = PAYCHECK_LOWER * 1.5

#undef INSTANT_WOUND_HEAL_STAMINA_DAMAGE
#undef INSTANT_WOUND_HEAL_LIMB_DAMAGE
