#define INSTANT_WOUND_HEAL_STAMINA_DAMAGE 80
#define INSTANT_WOUND_HEAL_LIMB_DAMAGE 25

/obj/item/stack/medical/wound_recovery
	name = "subdermal splint applicator"
	desc = "A roll flexible material dotted with millions of micro-scale injectors on one side. \
		On application to a body part with a damaged bone structure, nanomachines stored within those \
		injectors will surround the wound and form a subdermal, self healing splint. While convenient \
		for keeping appearances and rapid healing, the nanomachines tend to leave their host particularly \
		vulnerable to new damage for several minutes after application."
	icon = 'monkestation/code/modules/blueshift/icons/deforest/stack_items.dmi'
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
	patient.stamina?.adjust(INSTANT_WOUND_HEAL_STAMINA_DAMAGE)
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
	icon = 'monkestation/code/modules/blueshift/icons/deforest/stack_items.dmi'
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
	icon = 'monkestation/code/modules/blueshift/icons/deforest/stack_items.dmi'
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
	icon = 'monkestation/code/modules/blueshift/icons/deforest/stack_items.dmi'
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

// Twitch, because having sandevistans be implants is for losers, just inject it!
/obj/item/reagent_containers/hypospray/medipen/deforest/twitch
	name = "TWitch sensory stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with 'TWitch' among other reagents. This drug is known to make \
		those who take it 'see faster', whatever that means."
	base_icon_state = "twitch"
	icon_state = "twitch"
	list_reagents = list(
		/datum/reagent/drug/twitch = 10,
		/datum/reagent/drug/maint/tar = 5,
		/datum/reagent/medicine/silibinin = 5,
		/datum/reagent/toxin/leadacetate = 5,
	)
	custom_price = PAYCHECK_COMMAND * 3.5

// Demoneye, for when you feel the need to become "fucking invincible"
/obj/item/reagent_containers/hypospray/medipen/deforest/demoneye
	name = "DemonEye steroid injector"
	desc = "A Deforest branded autoinjector, loaded with 'DemonEye' among other reagents. This drug is known to make \
		those who take it numb to all pains and extremely difficult to kill as a result."
	base_icon_state = "demoneye"
	icon_state = "demoneye"
	list_reagents = list(
		/datum/reagent/drug/demoneye = 10,
		/datum/reagent/drug/maint/sludge = 10,
		/datum/reagent/toxin/leadacetate = 5,
	)
	custom_price = PAYCHECK_COMMAND * 3.5

// Mix of many of the stamina damage regenerating drugs to provide a cocktail no baton could hope to beat
/obj/item/reagent_containers/hypospray/medipen/deforest/aranepaine
	name = "aranepaine combat stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a cocktail of drugs to make any who take it nearly \
		immune to exhaustion while its in their system."
	base_icon_state = "aranepaine"
	icon_state = "aranepaine"
	list_reagents = list(
		/datum/reagent/drug/aranesp = 5,
		/datum/reagent/drug/kronkaine = 5,
		/datum/reagent/drug/pumpup = 5,
		/datum/reagent/medicine/diphenhydramine = 5,
		/datum/reagent/impurity = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5

// Nothing inherently illegal, just a potentially very dangerous mix of chems to be able to inject into people
/obj/item/reagent_containers/hypospray/medipen/deforest/pentibinin
	name = "pentibinin normalizant injector"
	desc = "A Deforest branded autoinjector, loaded with a cocktail of drugs to make any who take it \
		recover from many different types of damages, with many unusual or undocumented side-effects."
	base_icon_state = "pentibinin"
	icon_state = "pentibinin"
	list_reagents = list(
		/datum/reagent/medicine/c2/penthrite = 5,
		/datum/reagent/medicine/polypyr = 5,
		/datum/reagent/medicine/silibinin = 5,
		/datum/reagent/medicine/omnizine = 5,
		/datum/reagent/inverse/healing/tirimol = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5

// Combat stimulant that makes you immune to slowdowns for a bit
/obj/item/reagent_containers/hypospray/medipen/deforest/synalvipitol
	name = "synalvipitol muscle stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a cocktail of drugs to make any who take it \
		nearly immune to the slowing effects of silly things like 'being tired' or 'facing muscle failure'."
	base_icon_state = "synalvipitol"
	icon_state = "synalvipitol"
	list_reagents = list(
		/datum/reagent/medicine/mine_salve = 5,
		/datum/reagent/medicine/synaptizine = 10,
		/datum/reagent/medicine/muscle_stimulant = 5,
		/datum/reagent/impurity = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5

// Pen basetype where the icon is gotten from
/obj/item/reagent_containers/hypospray/medipen/deforest
	name = "non-functional Deforest autoinjector"
	desc = "A Deforest branded autoinjector, though this one seems to be both empty and non-functional."
	icon = 'monkestation/code/modules/blueshift/icons/deforest/injectors.dmi'
	icon_state = "default"
	volume = 25
	list_reagents = list()
	custom_price = PAYCHECK_COMMAND
	/// If this pen has a timer for injecting others with, just for safety with some of the drugs in these
	var/inject_others_time = 1.5 SECONDS

/obj/item/reagent_containers/hypospray/medipen/deforest/Initialize(mapload)
	. = ..()
	amount_per_transfer_from_this = volume

/obj/item/reagent_containers/hypospray/medipen/deforest/inject(mob/living/affected_mob, mob/user)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return FALSE
	if(!iscarbon(affected_mob))
		return FALSE

	//Always log attemped injects for admins
	var/list/injected = list()
	for(var/datum/reagent/injected_reagent in reagents.reagent_list)
		injected += injected_reagent.name
	var/contained = english_list(injected)
	log_combat(user, affected_mob, "attempted to inject", src, "([contained])")

	if((affected_mob != user) && inject_others_time)
		affected_mob.visible_message(span_danger("[user] is trying to inject [affected_mob]!"), \
				span_userdanger("[user] is trying to inject something into you!"))
		if(!do_after(user, CHEM_INTERACT_DELAY(inject_others_time, user), affected_mob))
			return FALSE

	if(reagents.total_volume && (ignore_flags || affected_mob.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))) // Ignore flag should be checked first or there will be an error message.
		to_chat(affected_mob, span_warning("You feel a tiny prick!"))
		to_chat(user, span_notice("You inject [affected_mob] with [src]."))
		if(!stealthy)
			playsound(affected_mob, 'sound/items/hypospray.ogg', 50, TRUE)
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)

		if(affected_mob.reagents)
			var/trans = 0
			if(!infinite)
				trans = reagents.trans_to(affected_mob, amount_per_transfer_from_this, transfered_by = user, methods = INJECT)
			else
				reagents.expose(affected_mob, INJECT, fraction)
				trans = reagents.copy_to(affected_mob, amount_per_transfer_from_this)
			to_chat(user, span_notice("[trans] unit\s injected. [reagents.total_volume] unit\s remaining in [src]."))
			log_combat(user, affected_mob, "injected", src, "([contained])")
		return TRUE
	return FALSE

// Sensory restoration, heals eyes and ears with a bit of impurity
/obj/item/reagent_containers/hypospray/medipen/deforest/occuisate
	name = "occuisate sensory restoration injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of reagents to restore your vision and hearing to operation."
	base_icon_state = "occuisate"
	icon_state = "occuisate"
	list_reagents = list(
		/datum/reagent/medicine/inacusiate = 7,
		/datum/reagent/medicine/oculine = 7,
		/datum/reagent/impurity/inacusiate = 3,
		/datum/reagent/inverse/oculine = 3,
		/datum/reagent/toxin/lipolicide = 5,
	)

// Adrenaline, fills you with determination (and also stimulants)
/obj/item/reagent_containers/hypospray/medipen/deforest/adrenaline
	name = "adrenaline injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of reagents to intentionally give yourself fight or flight on demand."
	base_icon_state = "adrenaline"
	icon_state = "adrenaline"
	list_reagents = list(
		/datum/reagent/medicine/synaptizine = 5,
		/datum/reagent/medicine/inaprovaline = 5,
		/datum/reagent/determination = 10,
		/datum/reagent/toxin/histamine = 5,
	)

// Morpital, heals a small amount of damage and kills pain for a bit
/obj/item/reagent_containers/hypospray/medipen/deforest/morpital
	name = "morpital regenerative stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of reagents to numb pain and repair small amounts of physical damage."
	base_icon_state = "morpital"
	icon_state = "morpital"
	list_reagents = list(
		/datum/reagent/medicine/morphine = 5,
		/datum/reagent/medicine/omnizine/protozine = 15,
		/datum/reagent/toxin/staminatoxin = 5,
	)

// Lipital, heals more damage than morpital but doesnt work much at higher damages
/obj/item/reagent_containers/hypospray/medipen/deforest/lipital
	name = "lipital regenerative stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of reagents to numb pain and repair small amounts of physical damage. \
		Works most effectively against damaged caused by brute attacks."
	base_icon_state = "lipital"
	icon_state = "lipital"
	list_reagents = list(
		/datum/reagent/medicine/lidocaine = 5,
		/datum/reagent/medicine/omnizine = 5,
		/datum/reagent/medicine/c2/probital = 10,
	)

// Anti-poisoning injector, with a little bit of radiation healing as a treat
/obj/item/reagent_containers/hypospray/medipen/deforest/meridine
	name = "meridine antidote injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of reagents to serve as antidote to most galactic toxins. \
		A warning sticker notes it should not be used if the patient is physically damaged, as it may cause complications."
	base_icon_state = "meridine"
	icon_state = "meridine"
	list_reagents = list(
		/datum/reagent/medicine/c2/multiver = 10,
		/datum/reagent/medicine/potass_iodide = 10,
		/datum/reagent/nitrous_oxide = 5,
	)

// Epinephrine and helps a little bit against stuns and stamina damage
/obj/item/reagent_containers/hypospray/medipen/deforest/synephrine
	name = "synephrine emergency stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of reagents to stabilize critical condition and recover from stamina deficits."
	base_icon_state = "synephrine"
	icon_state = "synephrine"
	list_reagents = list(
		/datum/reagent/medicine/epinephrine = 10,
		/datum/reagent/medicine/synaptizine = 5,
		/datum/reagent/medicine/synaphydramine = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5

// Critical condition stabilizer
/obj/item/reagent_containers/hypospray/medipen/deforest/calopine
	name = "calopine emergency stabilizant injector"
	desc = "A Deforest branded autoinjector, loaded with a stabilizing mix of reagents to repair critical conditions."
	base_icon_state = "calopine"
	icon_state = "calopine"
	list_reagents = list(
		/datum/reagent/medicine/atropine = 10,
		/datum/reagent/medicine/coagulant/fabricated = 5,
		/datum/reagent/medicine/salbutamol = 5,
		/datum/reagent/toxin/staminatoxin = 5,
	)

// Coagulant, really not a whole lot more
/obj/item/reagent_containers/hypospray/medipen/deforest/coagulants
	name = "coagulant-S injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of coagulants to prevent and stop bleeding."
	base_icon_state = "coagulant"
	icon_state = "coagulant"
	list_reagents = list(
		/datum/reagent/medicine/coagulant = 5,
		/datum/reagent/medicine/salglu_solution = 15,
		/datum/reagent/impurity = 5,
	)

// Stimulant centered around ondansetron
/obj/item/reagent_containers/hypospray/medipen/deforest/krotozine
	name = "krotozine manipulative stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of stimulants of weak healing agents."
	base_icon_state = "krotozine"
	icon_state = "krotozine"
	list_reagents = list(
		/datum/reagent/drug/kronkaine = 5,
		/datum/reagent/medicine/omnizine/protozine = 10,
		/datum/reagent/drug/maint/tar = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5

// Stuff really good at healing burn stuff and stabilizing temps
/obj/item/reagent_containers/hypospray/medipen/deforest/lepoturi
	name = "lepoturi burn treatment injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of medicines to rapidly treat burns."
	base_icon_state = "lepoturi"
	icon_state = "lepoturi"
	list_reagents = list(
		/datum/reagent/medicine/mine_salve = 5,
		/datum/reagent/medicine/leporazine = 5,
		/datum/reagent/medicine/c2/lenturi = 10,
		/datum/reagent/toxin/staminatoxin = 5,
	)

// Stabilizes a lot of stats like drowsiness, sanity, dizziness, so on
/obj/item/reagent_containers/hypospray/medipen/deforest/psifinil
	name = "psifinil personal recovery injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of medicines to remedy many common ailments, such as drowsiness, pain, instability, the like."
	base_icon_state = "psifinil"
	icon_state = "psifinil"
	list_reagents = list(
		/datum/reagent/medicine/modafinil = 10,
		/datum/reagent/medicine/psicodine = 10,
		/datum/reagent/medicine/leporazine = 5,
	)

// Helps with liver failure and some drugs, also alcohol
/obj/item/reagent_containers/hypospray/medipen/deforest/halobinin
	name = "halobinin soberant injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of medicines to remedy the effects of liver failure and common drugs."
	base_icon_state = "halobinin"
	icon_state = "halobinin"
	list_reagents = list(
		/datum/reagent/medicine/haloperidol = 5,
		/datum/reagent/medicine/antihol = 5,
		/datum/reagent/medicine/higadrite = 5,
		/datum/reagent/medicine/silibinin = 5,
	)

// Medpen for robots that fixes toxin damage and purges synth chems but slows them down for a bit
/obj/item/reagent_containers/hypospray/medipen/deforest/robot_system_cleaner
	name = "synthetic cleaner autoinjector"
	desc = "A Deforest branded autoinjector, loaded with system cleaner for purging synthetics of reagents."
	base_icon_state = "robor"
	icon_state = "robor"
	list_reagents = list(
		/datum/reagent/medicine/system_cleaner = 15,
		/datum/reagent/dinitrogen_plasmide = 5,
	)

// Medpen for robots that fixes brain damage but slows them down for a bit
/obj/item/reagent_containers/hypospray/medipen/deforest/robot_liquid_solder
	name = "synthetic smart-solder autoinjector"
	desc = "A Deforest branded autoinjector, loaded with liquid solder to repair synthetic processor core damage."
	base_icon_state = "robor_brain"
	icon_state = "robor_brain"
	list_reagents = list(
		/datum/reagent/medicine/liquid_solder = 15,
		/datum/reagent/dinitrogen_plasmide = 5,
	)

/atom/movable/screen/alert/status_effect/vulnerable_to_damage
	name = "Vulnerable To Damage"
	desc = "You will take more damage than normal while your body recovers from mending itself!"
	icon_state = "terrified"

/datum/status_effect/vulnerable_to_damage
	id = "vulnerable_to_damage"
	duration = 5 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/vulnerable_to_damage
	remove_on_fullheal = TRUE
	/// The percentage damage modifier we give the mob we're applied to
	var/damage_resistance_subtraction = 50
	/// How much extra bleeding the mob is given
	var/bleed_modifier_addition = 1

/datum/status_effect/vulnerable_to_damage/on_apply()
	to_chat(owner, span_userdanger("Your body suddenly feals weak and fragile!"))
	var/mob/living/carbon/human/carbon_owner = owner
	carbon_owner.physiology.damage_resistance -= damage_resistance_subtraction
	carbon_owner.physiology.bleed_mod += bleed_modifier_addition
	return ..()

/datum/status_effect/vulnerable_to_damage/on_remove()
	to_chat(owner, span_notice("You seem to have recovered from your unnatural fragility!"))
	var/mob/living/carbon/human/carbon_recoverer = owner
	carbon_recoverer.physiology.damage_resistance += damage_resistance_subtraction
	carbon_recoverer.physiology.bleed_mod -= bleed_modifier_addition
	return ..()

// Giant 3x3 tile warning hologram that tells people they should probably stand outside of it

/obj/structure/holosign/treatment_zone_warning
	name = "treatment zone indicator"
	desc = "A massive glowing holosign warning you to keep out of it, there's probably some important stuff happening in there!"
	icon = 'monkestation/code/modules/blueshift/icons/deforest/telegraph_96x96.dmi'
	icon_state = "treatment_zone"
	layer = BELOW_OBJ_LAYER
	pixel_x = -32
	pixel_y = -32
	use_vis_overlay = FALSE

// Projector for the above mentioned treatment zone signs

/obj/item/holosign_creator/medical/treatment_zone
	name = "emergency treatment zone projector"
	desc = "A holographic projector that creates a large, clearly marked treatment zone hologram, which warns outsiders that they ought to stay out of it."
	holosign_type = /obj/structure/holosign/treatment_zone_warning
	creation_time = 1 SECONDS
	max_signs = 1

// Tech design for printing the projectors

/datum/design/treatment_zone_projector
	name = "Emergency Treatment Zone Projector"
	desc = "A holographic projector that creates a large, clearly marked treatment zone hologram, which warns outsiders that they ought to stay out of it."
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/holosign_creator/medical/treatment_zone
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT,
	)
	id = "treatment_zone_projector"
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/techweb_node/biotech/New()
	. = ..()
	design_ids.Add("treatment_zone_projector")

// Adds the funny projector to medical borgs

/obj/item/robot_model/medical/New(loc, ...)
	. = ..()
	var/obj/item/holosign_creator/medical/treatment_zone/new_holosign = new(src)
	basic_modules.Add(new_holosign)


// Synth repair patch, gives the synth a small amount of healing chems
/obj/item/reagent_containers/pill/robotic_patch
	name = "robotic patch"
	desc = "A chemical patch for touch-based applications on synthetics."
	icon = 'monkestation/code/modules/blueshift/icons/deforest/stack_items.dmi'
	icon_state = "synth_patch"
	inhand_icon_state = null
	possible_transfer_amounts = list()
	volume = 40
	apply_type = PATCH
	apply_method = "apply"
	self_delay = 3 SECONDS
	dissolvable = FALSE

/obj/item/reagent_containers/pill/robotic_patch/attack(mob/living/L, mob/user)
	if(ishuman(L))
		var/obj/item/bodypart/affecting = L.get_bodypart(check_zone(user.zone_selected))
		if(!affecting)
			to_chat(user, span_warning("The limb is missing!"))
			return
		if(!IS_ROBOTIC_LIMB(affecting))
			to_chat(user, span_notice("Robotic patches won't work on an organic limb!"))
			return
	return ..()

/obj/item/reagent_containers/pill/robotic_patch/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return FALSE
	return TRUE

// The actual patch
/obj/item/reagent_containers/pill/robotic_patch/synth_repair
	name = "robotic repair patch"
	desc = "A sealed patch with a small nanite swarm along with electrical coagulant reagents to repair small amounts of synthetic damage."
	icon_state = "synth_patch"
	list_reagents = list(
		/datum/reagent/medicine/nanite_slurry = 10,
		/datum/reagent/dinitrogen_plasmide = 5,
		/datum/reagent/medicine/coagulant/fabricated = 10,
	)

// Bottle of painkiller pills
/obj/item/storage/pill_bottle/painkiller
	name = "amollin pill bottle"
	desc = "It's an airtight container for storing medication. This one is all-white and has labels for containing amollin, a blend of Miner's Salve and Lidocaine."
	icon = 'monkestation/code/modules/blueshift/icons/deforest/storage.dmi'
	icon_state = "painkiller_bottle"
	custom_price = PAYCHECK_CREW * 1.5

/obj/item/storage/pill_bottle/painkiller/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/amollin(src)

/obj/item/reagent_containers/pill/amollin
	name = "amollin pill"
	desc = "Neutralizes many common pains and ailments. A blend of Miner's Salve and Lidocaine."
	icon_state = "pill9"
	list_reagents = list(
		/datum/reagent/medicine/mine_salve = 10,
		/datum/reagent/medicine/lidocaine = 5,
		/datum/reagent/consumable/sugar = 5,
	)

// Narcolepsy quirk medicines
/obj/item/storage/pill_bottle/prescription_stimulant
	name = "alifil pill bottle"
	desc = "A special miniaturized pill bottle with an insert resembling a revolver cylinder, fitted for the inside of a 'civil defense'-class shell medkit. Holds five alifil pills, and is designed only to accept their proprietary DeForest(tm) shape. A big, bold yellow warning label on the side reads: 'FOLLOW DOSAGE DIRECTIONS'."
	icon = 'monkestation/code/modules/blueshift/icons/deforest/storage.dmi'
	icon_state = "painkiller_bottle"
	w_class = WEIGHT_CLASS_TINY // this is fine because we hard limit what can go in this thing

/obj/item/storage/pill_bottle/prescription_stimulant/Initialize(mapload)
	. = ..()
	// Make sure we can only hold alifil pills since this is nested inside a symptom support kit
	atom_storage.max_slots = 5
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/pill/prescription_stimulant,
	))

/obj/item/storage/pill_bottle/prescription_stimulant/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/prescription_stimulant(src)

/obj/item/reagent_containers/pill/prescription_stimulant
	name = "alifil pill"
	desc = "Used to treat symptoms of drowsiness and sudden loss of consciousness. Contains a mix of sugar, synaptizine and modafinil. A warning label reads: <b>Take in moderation</b>."
	icon_state = "pill15"
	list_reagents = list(
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/medicine/synaptizine = 5,
		/datum/reagent/medicine/modafinil = 3
	)

// Pre-packed civil defense medkit, with items to heal low damages inside
/obj/item/storage/medkit/civil_defense
	name = "civil defense medical kit"
	icon = 'monkestation/code/modules/blueshift/icons/deforest/storage.dmi'
	icon_state = "poisoning_kit"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/deforest/inhands/cases_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/deforest/inhands/cases_righthand.dmi'
	inhand_icon_state = "poisoning_kit"
	desc = "A small medical kit that can only fit autoinjectors in it, these typically come with supplies to treat low level harm."
	w_class = WEIGHT_CLASS_SMALL
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_price = PAYCHECK_COMMAND * 3

/obj/item/storage/medkit/civil_defense/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 4
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/storage/pill_bottle/prescription_stimulant,
		/obj/item/food/cheese/firm_cheese_slice, //It's not called a cheese kit for nothing.
		/obj/item/food/cheese/wedge,
	))

/obj/item/storage/medkit/civil_defense/stocked

/obj/item/storage/medkit/civil_defense/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/meridine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/halobinin = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lipital = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/calopine = 1,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/medkit/civil_defense/thunderdome
	/// List of random medpens we can pick from
	var/list/random_medpen_options = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/twitch,
		/obj/item/reagent_containers/hypospray/medipen/deforest/demoneye,
		/obj/item/reagent_containers/hypospray/medipen/deforest/aranepaine,
		/obj/item/reagent_containers/hypospray/medipen/deforest/pentibinin,
		/obj/item/reagent_containers/hypospray/medipen/deforest/synalvipitol,
		/obj/item/reagent_containers/hypospray/medipen/deforest/adrenaline,
		/obj/item/reagent_containers/hypospray/medipen/deforest/morpital,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lipital,
		/obj/item/reagent_containers/hypospray/medipen/deforest/synephrine,
		/obj/item/reagent_containers/hypospray/medipen/deforest/calopine,
		/obj/item/reagent_containers/hypospray/medipen/deforest/coagulants,
		/obj/item/reagent_containers/hypospray/medipen/deforest/krotozine,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lepoturi,
	)

/obj/item/storage/medkit/civil_defense/thunderdome/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 6

/obj/item/storage/medkit/civil_defense/thunderdome/PopulateContents()
	for(var/pens in 1 to 6)
		var/new_pen = pick(random_medpen_options)
		new new_pen(src)

// Variant on the civil defense medkit for spacer planetside personnel (or other people suffering from chronic illnesses)
/obj/item/storage/medkit/civil_defense/comfort
	name = "civil defense symptom support kit"
	desc = "A small, pocket-sized kit that can typically only fit autoinjectors in it. This variant on the classic 'cheese' civil defense kit contains supplies to address hindering symptomatic burden associated with common chronic diseases or adaptation syndromes, such as gravity sickness."
	icon_state = "symptom_kit"

/obj/item/storage/medkit/civil_defense/comfort/stocked

/obj/item/storage/medkit/civil_defense/comfort/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/psifinil = 3,
		/obj/item/storage/pill_bottle/prescription_stimulant = 1,
	)
	generate_items_inside(items_inside, src)

// Pre-packed frontier medkit, with supplies to repair most common frontier health issues
/obj/item/storage/medkit/frontier
	name = "frontier medical kit"
	desc = "A handy roll-top waterproof medkit often seen alongside those on the frontier, where medical support is less than optimal. \
		It has a clip for hooking onto your belt, handy!"
	icon = 'monkestation/code/modules/blueshift/icons/deforest/storage.dmi'
	icon_state = "frontier"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/deforest/inhands/cases_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/deforest/inhands/cases_righthand.dmi'
	inhand_icon_state = "frontier"
	worn_icon = 'monkestation/code/modules/blueshift/icons/deforest/worn/worn.dmi'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	slot_flags = ITEM_SLOT_BELT

/obj/item/storage/medkit/frontier/stocked

/obj/item/storage/medkit/frontier/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/meridine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/morpital = 1,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/medical/suture/coagulant = 1,
		/obj/item/stack/medical/gauze/sterilized = 1,
		/obj/item/storage/pill_bottle/painkiller = 1,
	)
	generate_items_inside(items_inside,src)

// Pre-packed combat surgeon medkit, with items for fixing more specific injuries and wounds
/obj/item/storage/medkit/combat_surgeon
	name = "combat surgeon medical kit"
	desc = "A folding kit that is ideally filled with surgical tools and specialized treatment options for many harder-to-treat wounds."
	icon = 'monkestation/code/modules/blueshift/icons/deforest/storage.dmi'
	icon_state = "surgeon"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/deforest/inhands/cases_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/deforest/inhands/cases_righthand.dmi'
	inhand_icon_state = "surgeon"
	worn_icon = 'monkestation/code/modules/blueshift/icons/deforest/worn/worn.dmi'
	worn_icon_state = "frontier"
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'

/obj/item/storage/medkit/combat_surgeon/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

/obj/item/storage/medkit/combat_surgeon/stocked

/obj/item/storage/medkit/combat_surgeon/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/bonesetter = 1,
		/obj/item/hemostat = 1,
		/obj/item/cautery = 1,
		/obj/item/stack/medical/wound_recovery = 1,
		/obj/item/stack/medical/wound_recovery/rapid_coagulant = 1,
		/obj/item/stack/medical/gauze/sterilized = 1,
		/obj/item/healthanalyzer/simple = 1,
	)
	generate_items_inside(items_inside,src)

// Big medical kit that can be worn like a bag, holds a LOT of medical items but works like a duffelbag
/obj/item/storage/backpack/duffelbag/deforest_medkit
	name = "satchel medical kit"
	desc = "A large orange satchel able to hold just about any piece of small medical equipment you could think of, you can even wear it on your back or belt!"
	icon = 'monkestation/code/modules/blueshift/icons/deforest/storage.dmi'
	icon_state = "satchel"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/deforest/inhands/cases_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/deforest/inhands/cases_righthand.dmi'
	inhand_icon_state = "satchel"
	worn_icon = 'monkestation/code/modules/blueshift/icons/deforest/worn/worn.dmi'
	equip_sound = 'sound/items/equip/jumpsuit_equip.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	storage_type = /datum/storage/duffel/deforest_medkit

/obj/item/storage/backpack/duffelbag/deforest_medkit/stocked

/obj/item/storage/backpack/duffelbag/deforest_medkit/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/morpital = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lepoturi = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lipital = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/meridine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/calopine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/coagulants = 1,
		/obj/item/bonesetter = 1,
		/obj/item/hemostat = 1,
		/obj/item/cautery = 1,
		/obj/item/stack/medical/wound_recovery = 1,
		/obj/item/stack/medical/wound_recovery/rapid_coagulant = 1,
		/obj/item/stack/medical/suture/coagulant = 1,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/stack/medical/gauze/sterilized = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/ointment/red_sun = 1,
		/obj/item/storage/pill_bottle/painkiller = 1,
		/obj/item/healthanalyzer/simple = 1,
	)
	generate_items_inside(items_inside,src)

/datum/storage/duffel/deforest_medkit
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = 21 * WEIGHT_CLASS_SMALL
	max_slots = 21

/datum/storage/duffel/deforest_medkit/New()
	. = ..()

	can_hold = typecacheof(list(
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/muzzle,
		/obj/item/clothing/mask/surgical,
		/obj/item/dnainjector,
		/obj/item/extinguisher/mini,
		/obj/item/flashlight/pen,
		/obj/item/geiger_counter,
		/obj/item/healthanalyzer,
		/obj/item/hemostat,
		/obj/item/holosign_creator/medical,
		/obj/item/implant,
		/obj/item/implantcase,
		/obj/item/implanter,
		/obj/item/lazarus_injector,
		/obj/item/lighter,
		/obj/item/pinpointer/crew,
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/medigel,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/stack/sticky_tape,
		/obj/item/sensor_device,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/bodybag,
	))

// Big surgical kit that can be worn like a bag, holds 14 normal items (more than what a backpack can do!) but works like a duffelbag
/obj/item/storage/backpack/duffelbag/deforest_surgical
	name = "first responder surgical kit"
	desc = "A large bag able to hold all the surgical tools and first response healing equipment you can think of, you can even wear it!"
	icon = 'monkestation/code/modules/blueshift/icons/deforest/storage.dmi'
	icon_state = "super_surgery"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/deforest/inhands/cases_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/deforest/inhands/cases_righthand.dmi'
	inhand_icon_state = "super_surgery"
	worn_icon = 'monkestation/code/modules/blueshift/icons/deforest/worn/worn.dmi'
	equip_sound = 'sound/items/equip/jumpsuit_equip.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	storage_type = /datum/storage/duffel/deforest_big_surgery

/obj/item/storage/backpack/duffelbag/deforest_surgical/stocked

/obj/item/storage/backpack/duffelbag/deforest_surgical/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/scalpel = 1,
		/obj/item/hemostat = 1,
		/obj/item/retractor = 1,
		/obj/item/circular_saw = 1,
		/obj/item/bonesetter = 1,
		/obj/item/cautery = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/blood_filter = 1,
		/obj/item/roller = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/gauze/sterilized = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/medical/bone_gel = 1,
	)
	generate_items_inside(items_inside,src)

/datum/storage/duffel/deforest_big_surgery
	max_total_storage = 14 * WEIGHT_CLASS_NORMAL
	max_slots = 14

/datum/storage/duffel/deforest_big_surgery/New()
	. = ..()

	can_hold = typecacheof(list(
		/obj/item/blood_filter,
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/clothing/glasses,
		/obj/item/clothing/gloves,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/muzzle,
		/obj/item/clothing/mask/surgical,
		/obj/item/construction/plumbing,
		/obj/item/dnainjector,
		/obj/item/extinguisher/mini,
		/obj/item/flashlight/pen,
		/obj/item/geiger_counter,
		/obj/item/gun/syringe/syndicate,
		/obj/item/healthanalyzer,
		/obj/item/hemostat,
		/obj/item/holosign_creator/medical,
		/obj/item/implant,
		/obj/item/implantcase,
		/obj/item/implanter,
		/obj/item/lazarus_injector,
		/obj/item/lighter,
		/obj/item/pinpointer/crew,
		/obj/item/plunger,
		/obj/item/radio,
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/medigel,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/syringe,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/shears,
		/obj/item/stack/medical,
		/obj/item/stack/sticky_tape,
		/obj/item/stamp,
		/obj/item/sensor_device,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/surgical_drapes,
		/obj/item/surgicaldrill,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/handheld_soulcatcher,
		/obj/item/wrench/medical,
		/obj/item/roller,
		/obj/item/bodybag,
	))

// Pre-packed medkit for healing synths and repairing their wounds rapidly in the field
/obj/item/storage/medkit/robotic_repair
	name = "robotic repair equipment kit"
	desc = "An industrial-strength plastic box filled with supplies for repairing synthetics from critical damage."
	icon = 'monkestation/code/modules/blueshift/icons/deforest/storage.dmi'
	icon_state = "synth_medkit"
	inhand_icon_state = "medkit"
	worn_icon = 'monkestation/code/modules/blueshift/icons/deforest/worn/worn.dmi'
	worn_icon_state = "frontier"
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'

/obj/item/storage/medkit/robotic_repair/Initialize(mapload)
	. = ..()
	var/static/list/list_of_everything_mechanical_medkits_can_hold = list_of_everything_medkits_can_hold + list(
		/obj/item/stack/cable_coil,
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/multitool,
		/obj/item/plunger,
		/obj/item/clothing/head/utility/welding,
		/obj/item/clothing/glasses/welding,
	)
	var/static/list/exception_cache = typecacheof(
		/obj/item/clothing/head/utility/welding,
	)

	atom_storage.set_holdable(list_of_everything_mechanical_medkits_can_hold)
	LAZYINITLIST(atom_storage.exception_hold)
	atom_storage.exception_hold = atom_storage.exception_hold + exception_cache
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

/obj/item/storage/medkit/robotic_repair/stocked

/obj/item/storage/medkit/robotic_repair/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/reagent_containers/pill/robotic_patch/synth_repair = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/robot_system_cleaner = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/coagulants = 1, // Coagulants help electrical damage
		/obj/item/healthanalyzer/simple = 1,
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/robotic_repair/preemo
	name = "premium robotic repair equipment kit"
	desc = "An industrial-strength plastic box filled with supplies for repairing synthetics from critical damage. \
		This one has extra storage on the sides for even more equipment than the standard medkit model."
	icon_state = "synth_medkit_super"

/obj/item/storage/medkit/robotic_repair/preemo/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_slots = 12
	atom_storage.max_total_storage = 12 * WEIGHT_CLASS_NORMAL

/obj/item/storage/medkit/robotic_repair/preemo/stocked

/obj/item/storage/medkit/robotic_repair/preemo/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze/twelve = 1,
		/obj/item/stack/cable_coil/five = 1,
		/obj/item/reagent_containers/pill/robotic_patch/synth_repair = 4,
		/obj/item/reagent_containers/hypospray/medipen/deforest/robot_system_cleaner = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/robot_liquid_solder = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/coagulants = 1,
		/obj/item/healthanalyzer/simple = 1,
	)
	generate_items_inside(items_inside,src)

/obj/machinery/biogenerator/medstation
	name = "wall med-station"
	desc = "An advanced machine seen in frontier outposts and colonies capable of turning organic plant matter into \
		various emergency medical supplies and injectors. You can find one of these in the medical sections of just about \
		any frontier installation."
	icon = 'monkestation/code/modules/blueshift/icons/deforest/medstation.dmi'
	circuit = null
	anchored = TRUE
	density = FALSE
	efficiency = 1
	productivity = 1
	show_categories = list(
		RND_CATEGORY_DEFOREST_MEDICAL,
		RND_CATEGORY_DEFOREST_BLOOD,
	)
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/wallframe/frontier_medstation

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/biogenerator/medstation, 29)

/obj/machinery/biogenerator/medstation/RefreshParts()
	. = ..()
	efficiency = 1
	productivity = 1

/obj/machinery/biogenerator/medstation/default_unfasten_wrench(mob/user, obj/item/wrench/tool, time)
	user.balloon_alert(user, "deconstructing...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 1 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)
		return

/obj/machinery/biogenerator/medstation/on_deconstruction(disassembled)
	if(disassembled)
		new repacked_type(drop_location())

/obj/machinery/biogenerator/medstation/default_deconstruction_crowbar()
	return

// Deployable item for cargo for the medstation

/obj/item/wallframe/frontier_medstation
	name = "unmounted wall med-station"
	desc = "The innovative technology of a biogenerator to print medical supplies, but able to be mounted neatly on a wall out of the way."
	icon = 'monkestation/code/modules/blueshift/icons/deforest/medstation.dmi'
	icon_state = "biogenerator_parts"
	w_class = WEIGHT_CLASS_NORMAL
	result_path = /obj/machinery/biogenerator/medstation
	pixel_shift = 29
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)
