/obj/item/reagent_containers/applicator/pill
	name = "pill"
	desc = "A tablet or capsule."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "pill"
	inhand_icon_state = "pill"
	worn_icon_state = "nothing"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	volume = 50
	/// How many "layers" we have remaining. Each layer equates to 1 second of digestion
	var/layers_remaining = 3

/obj/item/reagent_containers/applicator/pill/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "pill[rand(1,20)]"
	AddComponent(/datum/component/germ_sensitive, mapload)
	RegisterSignal(src, COMSIG_ATOM_STOMACH_DIGESTED, PROC_REF(on_digestion))
	RegisterSignal(src, COMSIG_ATOM_REAGENT_EXAMINE, PROC_REF(reagent_special_examine))

/obj/item/reagent_containers/applicator/pill/proc/reagent_special_examine(datum/source, mob/user, list/examine_list, can_see_insides = FALSE)
	SIGNAL_HANDLER
	if (layers_remaining)
		examine_list += span_notice("Its sugary shell will last approximately [layers_remaining] seconds in a human stomach.")
	else
		examine_list += span_warning("Its shell is completely dissolved!")

///Runs the consumption code, can be overriden for special effects
/obj/item/reagent_containers/applicator/pill/on_consumption(mob/living/consumer, mob/giver, list/modifiers)
	if(icon_state == "pill4" && prob(5)) //you take the red pill - you stay in Wonderland, and I show you how deep the rabbit hole goes
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), consumer, span_notice("[pick(strings(REDPILL_FILE, "redpill_questions"))]")), 5 SECONDS)
	SEND_SIGNAL(consumer, COMSIG_LIVING_PILL_CONSUMED, src, giver)
	SEND_SIGNAL(src, COMSIG_PILL_CONSUMED, eater = consumer, feeder = giver)

	if (iscarbon(consumer) && layers_remaining)
		var/mob/living/carbon/as_carbon = consumer
		var/obj/item/organ/stomach/stomach = as_carbon.get_organ_by_type(/obj/item/organ/stomach)
		if (stomach)
			if (prob(max(0, 100 * (layers_remaining - PILL_MAX_TASTE_LAYERS))))
				consumer.taste_list(reagents)
			else if (!consumer.check_tasting_blocks())
				consumer.send_taste_message("starchy sugar")
			stomach.consume_thing(src)
			return

	if(reagents.total_volume)
		reagents.trans_to(consumer, reagents.total_volume, transferred_by = giver, methods = INGEST)
	qdel(src)
	return

/obj/item/reagent_containers/applicator/pill/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if (.)
		return

	if(!target.is_refillable())
		return NONE

	if(target.is_drainable() && !target.reagents.total_volume)
		to_chat(user, span_warning("[target] is empty! There's nothing to dissolve [src] in."))
		return ITEM_INTERACT_BLOCKING

	if(target.reagents.holder_full())
		to_chat(user, span_warning("[target] is full."))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(span_warning("[user] slips something into [target]!"), span_notice("You dissolve [src] in [target]."), null, 2)
	reagents.trans_to(target, reagents.total_volume, transferred_by = user)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/applicator/pill/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if (.)
		return

	var/obj/item/reagent_containers/container = null
	var/use_verb = null
	if (istype(tool, /obj/item/reagent_containers/dropper))
		container = tool
		use_verb = "squirt"
	else if (istype(tool, /obj/item/reagent_containers/cup))
		container = tool
		if (!container.is_drainable())
			to_chat(user, span_warning("You cannot pour [container]'s contents onto [src]!"))
			return ITEM_INTERACT_BLOCKING
		use_verb = "pour"

	if (!container)
		return NONE

	var/datum/reagent/consumable/sugar/sugar = container.reagents.has_reagent(/datum/reagent/consumable/sugar)
	if (sugar)
		if (layers_remaining >= PILL_MAX_LAYERS) // Full minute
			to_chat(user, span_warning("[src]'s coating is too thick for you to cover it in any more sugar!"))
			return ITEM_INTERACT_BLOCKING
		var/to_apply = floor(min(container.amount_per_transfer_from_this, sugar.volume, PILL_MAX_LAYERS - layers_remaining))
		container.reagents.remove_reagent(/datum/reagent/consumable/sugar, to_apply)
		layers_remaining += to_apply
		to_chat(user, span_notice("You [use_verb] some of [container]'s contents onto [src], thickening its sugary shell."))
		return ITEM_INTERACT_SUCCESS

	var/datum/reagent/water/water = container.reagents.has_reagent(/datum/reagent/water)
	if (!water)
		return ..()

	if (!layers_remaining) // No coating
		to_chat(user, span_warning("[src] doesn't have any more external layers to dissolve!"))
		return ITEM_INTERACT_BLOCKING

	var/to_apply = floor(min(container.amount_per_transfer_from_this, water.volume, layers_remaining))
	container.reagents.remove_reagent(/datum/reagent/water, to_apply)
	layers_remaining -= to_apply
	to_chat(user, span_notice("You [use_verb] some of [container]'s contents onto [src], dissolving its sugary shell."))
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/applicator/pill/proc/on_digestion(datum/source, obj/item/organ/stomach/stomach, mob/living/carbon/owner, seconds_per_tick)
	SIGNAL_HANDLER
	layers_remaining -= seconds_per_tick
	if (layers_remaining >= seconds_per_tick)
		return COMPONENT_CANCEL_DIGESTION

	// SSmobs.wait is 2 seconds (as of writing this), so we can end up with a delay of 1 second. In this case, use a timer
	if (layers_remaining > 0)
		// Using weakrefs because the mob can get deleted in the meanwhile and leave the pill behind
		addtimer(CALLBACK(src, PROC_REF(finish_digesting), WEAKREF(stomach), WEAKREF(owner)), layers_remaining SECONDS)
		return COMPONENT_CANCEL_DIGESTION

	// I think we should log this in case of horrible shenanigans
	owner.log_message("Had \a [src] pill dissolve in [owner.p_their()] stomach, containing the following reagents: [english_list(reagents.reagent_list)].", LOG_GAME)
	if(reagents.total_volume)
		reagents.trans_to(owner, reagents.total_volume, methods = INGEST, show_message = FALSE)
	qdel(src)
	return COMPONENT_CANCEL_DIGESTION

/obj/item/reagent_containers/applicator/pill/proc/finish_digesting(datum/weakref/stomach_ref, datum/weakref/owner_ref)
	var/obj/item/organ/stomach/stomach = stomach_ref.resolve()
	var/mob/living/carbon/owner = owner_ref.resolve()
	if (!owner || !stomach)
		return

	// Whenever stomach is inside of a mob, its contents are also moved to the mob, so we check for owner as our loc
	if (loc != owner || stomach.owner != owner || stomach.loc != owner)
		return

	owner.log_message("Had \a [src] pill dissolve in [owner.p_their()] stomach, containing the following reagents: [english_list(reagents.reagent_list)].", LOG_GAME)
	if(reagents.total_volume)
		reagents.trans_to(owner, reagents.total_volume, methods = INGEST)
	qdel(src)

/*
 * On accidental consumption, consume the pill
 */
/obj/item/reagent_containers/applicator/pill/on_accidental_consumption(mob/living/carbon/victim, mob/living/carbon/user, obj/item/source_item, discover_after = FALSE)
	to_chat(victim, span_warning("You swallow something small. [source_item ? "Was that in [source_item]?" : ""]"))
	on_consumption(victim, user)
	return FALSE

/obj/item/reagent_containers/applicator/pill/tox
	name = "toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"
	list_reagents = list(/datum/reagent/toxin = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/cyanide
	name = "cyanide pill"
	desc = "Don't swallow this."
	icon_state = "pill5"
	list_reagents = list(/datum/reagent/toxin/cyanide = 50)

/obj/item/reagent_containers/applicator/pill/adminordrazine
	name = "adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pill16"
	list_reagents = list(/datum/reagent/medicine/adminordrazine = 50)

/obj/item/reagent_containers/applicator/pill/morphine
	name = "morphine pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill8"
	list_reagents = list(/datum/reagent/medicine/morphine = 30)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/stimulant
	name = "stimulant pill"
	desc = "Often taken by overworked employees, athletes, and the inebriated. You'll snap to attention immediately!"
	icon_state = "pill19"
	list_reagents = list(/datum/reagent/medicine/ephedrine = 10, /datum/reagent/medicine/antihol = 10, /datum/reagent/consumable/coffee = 30)

/obj/item/reagent_containers/applicator/pill/salbutamol
	name = "salbutamol pill"
	desc = "Used to treat oxygen deprivation."
	icon_state = "pill16"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 30)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/multiver
	name = "multiver pill"
	desc = "Neutralizes many common toxins and scales with unique medicine in the system. Diluted with granibitaluri."
	icon_state = "pill17"
	list_reagents = list(/datum/reagent/medicine/c2/multiver = 5, /datum/reagent/medicine/granibitaluri = 5)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/epinephrine
	name = "epinephrine pill"
	desc = "Used to stabilize patients."
	icon_state = "pill5"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/mannitol
	name = "mannitol pill"
	desc = "Used to treat brain damage."
	icon_state = "pill17"
	list_reagents = list(/datum/reagent/medicine/mannitol = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/sansufentanyl
	name = "sansufentanyl pill"
	desc = "Used to treat Hereditary Manifold Sickness. Temporary side effects include - nausea, dizziness, impaired motor coordination."
	icon_state = "pill19"
	list_reagents = list(/datum/reagent/medicine/sansufentanyl = 5)

//Lower quantity mannitol pills (50u pills heal 250 brain damage, 5u pills heal 25)
/obj/item/reagent_containers/applicator/pill/mannitol/braintumor
	desc = "Used to treat symptoms for brain tumors."
	list_reagents = list(/datum/reagent/medicine/mannitol = 5)

/obj/item/reagent_containers/applicator/pill/mutadone
	name = "mutadone pill"
	desc = "Used to treat genetic damage."
	icon_state = "pill20"
	list_reagents = list(/datum/reagent/medicine/mutadone = 5)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/salicylic
	name = "salicylic acid pill"
	desc = "Used to dull pain."
	icon_state = "pill9"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 24)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/oxandrolone
	name = "oxandrolone pill"
	desc = "Used to stimulate burn healing."
	icon_state = "pill11"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 24)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/insulin
	name = "insulin pill"
	desc = "Handles hyperglycaemic coma."
	icon_state = "pill18"
	list_reagents = list(/datum/reagent/medicine/insulin = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/psicodine
	name = "psicodine pill"
	desc = "Used to treat mental instability and phobias."
	list_reagents = list(/datum/reagent/medicine/psicodine = 10)
	icon_state = "pill22"
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/penacid
	name = "pentetic acid pill"
	desc = "Used to expunge radiation and toxins."
	list_reagents = list(/datum/reagent/medicine/pen_acid = 10)
	icon_state = "pill22"
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/neurine
	name = "neurine pill"
	desc = "Used to treat non-severe mental traumas."
	list_reagents = list(/datum/reagent/medicine/neurine = 10)
	icon_state = "pill22"
	rename_with_volume = TRUE

///////////////////////////////////////// this pill is used only in a legion mob drop
/obj/item/reagent_containers/applicator/pill/shadowtoxin
	name = "black pill"
	desc = "I wouldn't eat this if I were you."
	icon_state = "pill9"
	color = "#454545"
	list_reagents = list(/datum/reagent/mutationtoxin/shadow = 10)

///////////////////////////////////////// Psychologist inventory pills
/obj/item/reagent_containers/applicator/pill/happinesspsych
	name = "mood stabilizer pill"
	desc = "Used to temporarily alleviate anxiety and depression, take only as prescribed."
	list_reagents = list(/datum/reagent/drug/happiness = 5)
	icon_state = "pill_happy"
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/paxpsych
	name = "pacification pill"
	desc = "Used to temporarily suppress violent, homicidal, or suicidal behavior in patients."
	list_reagents = list(/datum/reagent/pax = 5)
	icon_state = "pill12"
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/lsdpsych
	name = "antipsychotic pill"
	desc = "Talk to your healthcare provider immediately if hallucinations worsen or new hallucinations emerge."
	list_reagents = list(/datum/reagent/toxin/mindbreaker = 5)
	icon_state = "pill14"
	rename_with_volume = TRUE

//////////////////////////////////////// drugs
/obj/item/reagent_containers/applicator/pill/zoom
	name = "yellow pill"
	desc = "A poorly made canary-yellow pill; it is slightly crumbly."
	list_reagents = list(/datum/reagent/medicine/synaptizine = 10, /datum/reagent/drug/nicotine = 10, /datum/reagent/drug/methamphetamine = 1)
	icon_state = "pill7"


/obj/item/reagent_containers/applicator/pill/happy
	name = "happy pill"
	desc = "They have little happy faces on them, and they smell like marker pens."
	list_reagents = list(/datum/reagent/consumable/sugar = 10, /datum/reagent/drug/space_drugs = 10)
	icon_state = "pill_happy"


/obj/item/reagent_containers/applicator/pill/lsd
	name = "sunshine pill"
	desc = "Engraved on this split-coloured pill is a half-sun, half-moon."
	list_reagents = list(/datum/reagent/drug/mushroomhallucinogen = 15, /datum/reagent/toxin/mindbreaker = 15)
	icon_state = "pill14"


/obj/item/reagent_containers/applicator/pill/aranesp
	name = "smooth pill"
	desc = "This blue pill feels slightly moist."
	list_reagents = list(/datum/reagent/drug/aranesp = 10)
	icon_state = "pill3"

///Black and white pills that spawn in maintenance and have random reagent contents
/obj/item/reagent_containers/applicator/pill/maintenance
	name = "maintenance pill"
	desc = "A strange pill found in the depths of maintenance."
	icon_state = "pill21"
	var/static/list/names = list("maintenance pill", "floor pill", "mystery pill", "suspicious pill", "strange pill", "lucky pill", "ominous pill", "eerie pill")
	var/static/list/descs = list("Your feeling is telling you no, but...","Drugs are expensive, you can't afford not to eat any pills that you find."\
	, "Surely, there's no way this could go bad.", "Winners don't do dr- oh what the heck!", "Free pills? At no cost, how could I lose?")

/obj/item/reagent_containers/applicator/pill/maintenance/Initialize(mapload)
	list_reagents = list(get_random_reagent_id() = rand(10,50)) //list_reagents is called before init, because init generates the reagents using list_reagents
	. = ..()
	name = pick(names)
	if(prob(30))
		desc = pick(descs)

/obj/item/reagent_containers/applicator/pill/maintenance/achievement/on_consumption(mob/consumer, mob/user)
	. = ..()
	consumer.client?.give_award(/datum/award/score/maintenance_pill, consumer)

/obj/item/reagent_containers/applicator/pill/potassiodide
	name = "potassium iodide pill"
	desc = "Used to reduce low radiation damage very effectively."
	icon_state = "pill11"
	list_reagents = list(/datum/reagent/medicine/potass_iodide = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/probital
	name = "Probital pill"
	desc = "Used to treat brute damage of minor and moderate severity.The carving in the pill says 'Eat before ingesting'. Causes fatigue and diluted with granibitaluri."
	icon_state = "pill12"
	list_reagents = list(/datum/reagent/medicine/c2/probital = 5, /datum/reagent/medicine/granibitaluri = 10)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/iron
	name = "iron pill"
	desc = "Used to reduce bloodloss slowly."
	icon_state = "pill8"
	list_reagents = list(/datum/reagent/iron = 30)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/gravitum
	name = "gravitum pill"
	desc = "Used in weight loss. In a way."
	icon_state = "pill8"
	list_reagents = list(/datum/reagent/gravitum = 5)
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/ondansetron
	name = "ondansetron pill"
	desc = "Alleviates nausea. May cause drowsiness."
	icon_state = "pill11"
	list_reagents = list(/datum/reagent/medicine/ondansetron = 10)

// Pill styles for chem master

/obj/item/reagent_containers/applicator/pill/style
	icon_state = "pill0"
/obj/item/reagent_containers/applicator/pill/style/purplered
	icon_state = "pill1"
/obj/item/reagent_containers/applicator/pill/style/greenwhite
	icon_state = "pill2"
/obj/item/reagent_containers/applicator/pill/style/teal
	icon_state = "pill3"
/obj/item/reagent_containers/applicator/pill/style/red
	icon_state = "pill4"
/obj/item/reagent_containers/applicator/pill/style/redwhite
	icon_state = "pill5"
/obj/item/reagent_containers/applicator/pill/style/tealbrown
	icon_state = "pill6"
/obj/item/reagent_containers/applicator/pill/style/yellowflat
	icon_state = "pill7"
/obj/item/reagent_containers/applicator/pill/style/tealflat
	icon_state = "pill8"
/obj/item/reagent_containers/applicator/pill/style/whiteflat
	icon_state = "pill9"
/obj/item/reagent_containers/applicator/pill/style/purpleflat
	icon_state = "pill10"
/obj/item/reagent_containers/applicator/pill/style/limelat
	icon_state = "pill11"
/obj/item/reagent_containers/applicator/pill/style/redflat
	icon_state = "pill12"
/obj/item/reagent_containers/applicator/pill/style/greenpurpleflat
	icon_state = "pill13"
/obj/item/reagent_containers/applicator/pill/style/yellowpurpleflat
	icon_state = "pill14"
/obj/item/reagent_containers/applicator/pill/style/redyellowflat
	icon_state = "pill15"
/obj/item/reagent_containers/applicator/pill/style/bluetealflat
	icon_state = "pill16"
/obj/item/reagent_containers/applicator/pill/style/greenlimeflat
	icon_state = "pill17"
/obj/item/reagent_containers/applicator/pill/style/white
	icon_state = "pill18"
/obj/item/reagent_containers/applicator/pill/style/whitered
	icon_state = "pill19"
/obj/item/reagent_containers/applicator/pill/style/purpleyellow
	icon_state = "pill20"
/obj/item/reagent_containers/applicator/pill/style/blackwhite
	icon_state = "pill21"
/obj/item/reagent_containers/applicator/pill/style/limewhite
	icon_state = "pill22"
/obj/item/reagent_containers/applicator/pill/style/happy
	icon_state = "pill_happy"
