
/// Pill Bottles
/obj/item/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/medical/chemical.dmi'
	inhand_icon_state = "contsolid"
	worn_icon_state = "nothing"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	pickup_sound = 'sound/items/handling/pill_bottle_pickup.ogg'
	drop_sound = 'sound/items/handling/pill_bottle_place.ogg'
	storage_type = /datum/storage/pillbottle

/obj/item/storage/pill_bottle/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is trying to get the cap off [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/storage/pill_bottle/multiver
	name = "bottle of multiver pills"
	desc = "Contains pills used to counter toxins."

/obj/item/storage/pill_bottle/multiver/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/applicator/pill/multiver

/obj/item/storage/pill_bottle/multiver/less

/obj/item/storage/pill_bottle/multiver/less/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/reagent_containers/applicator/pill/multiver

/obj/item/storage/pill_bottle/epinephrine
	name = "bottle of epinephrine pills"
	desc = "Contains pills used to stabilize patients."

/obj/item/storage/pill_bottle/epinephrine/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/applicator/pill/epinephrine

/obj/item/storage/pill_bottle/mutadone
	name = "bottle of mutadone pills"
	desc = "Contains pills used to treat genetic abnormalities."

/obj/item/storage/pill_bottle/mutadone/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/applicator/pill/mutadone

/obj/item/storage/pill_bottle/potassiodide
	name = "bottle of potassium iodide pills"
	desc = "Contains pills used to reduce radiation damage."

/obj/item/storage/pill_bottle/potassiodide/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/reagent_containers/applicator/pill/potassiodide

/obj/item/storage/pill_bottle/probital
	name = "bottle of probital pills"
	desc = "Contains pills used to treat brute damage. The tag in the bottle states 'Eat before ingesting, may cause fatigue'."

/obj/item/storage/pill_bottle/probital/PopulateContents()
	. = list()
	for(var/i in 1 to 4)
		. += /obj/item/reagent_containers/applicator/pill/probital

/obj/item/storage/pill_bottle/iron
	name = "bottle of iron pills"
	desc = "Contains pills used to reduce blood loss slowly. The tag in the bottle states 'Only take one each five minutes'."

/obj/item/storage/pill_bottle/iron/PopulateContents()
	. = list()
	for(var/i in 1 to 4)
		. += /obj/item/reagent_containers/applicator/pill/iron

/obj/item/storage/pill_bottle/mannitol
	name = "bottle of mannitol pills"
	desc = "Contains pills used to treat brain damage."

/obj/item/storage/pill_bottle/mannitol/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/applicator/pill/mannitol

//Contains 4 pills instead of 7, and 5u pills instead of 50u (50u pills heal 250 brain damage, 5u pills heal 25)
/obj/item/storage/pill_bottle/mannitol/braintumor
	desc = "Contains diluted pills used to treat brain tumor symptoms. Take one when feeling lightheaded."

/obj/item/storage/pill_bottle/mannitol/braintumor/PopulateContents()
	. = list()
	for(var/i in 1 to 4)
		. += /obj/item/reagent_containers/applicator/pill/mannitol/braintumor

/obj/item/storage/pill_bottle/stimulant
	name = "bottle of stimulant pills"
	desc = "Guaranteed to give you that extra burst of energy during a long shift!"

/obj/item/storage/pill_bottle/stimulant/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/applicator/pill/stimulant

/obj/item/storage/pill_bottle/sansufentanyl
	name = "bottle of experimental medication"
	desc = "A bottle of pills developed by Interdyne Pharmaceuticals. They're used to treat Hereditary Manifold Sickness."

/obj/item/storage/pill_bottle/sansufentanyl/PopulateContents()
	. = list()
	for(var/i in 1 to 6)
		. += /obj/item/reagent_containers/applicator/pill/sansufentanyl

/obj/item/storage/pill_bottle/mining
	name = "bottle of patches"
	desc = "Contains patches used to treat brute and burn damage."

/obj/item/storage/pill_bottle/mining/PopulateContents()
	return flatten_quantified_list(list(
		/obj/item/reagent_containers/applicator/patch/aiuri = 1,
		/obj/item/reagent_containers/applicator/patch/libital = 3,
	))

/obj/item/storage/pill_bottle/zoom
	name = "suspicious pill bottle"
	desc = "The label is pretty old and almost unreadable, you recognize some chemical compounds."

/obj/item/storage/pill_bottle/zoom/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/applicator/pill/zoom

/obj/item/storage/pill_bottle/happy
	name = "suspicious pill bottle"
	desc = "There is a smiley on the top."

/obj/item/storage/pill_bottle/happy/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/applicator/pill/happy

/obj/item/storage/pill_bottle/lsd
	name = "suspicious pill bottle"
	desc = "There is a crude drawing which could be either a mushroom, or a deformed moon."

/obj/item/storage/pill_bottle/lsd/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/applicator/pill/lsd

/obj/item/storage/pill_bottle/aranesp
	name = "suspicious pill bottle"
	desc = "The label has 'fuck disablers' hastily scrawled in black marker."

/obj/item/storage/pill_bottle/aranesp/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/applicator/pill/aranesp

/obj/item/storage/pill_bottle/psicodine
	name = "bottle of psicodine pills"
	desc = "Contains pills used to treat mental distress and traumas."

/obj/item/storage/pill_bottle/psicodine/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/applicator/pill/psicodine

/obj/item/storage/pill_bottle/penacid
	name = "bottle of pentetic acid pills"
	desc = "Contains pills to expunge radiation and toxins."

/obj/item/storage/pill_bottle/penacid/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/reagent_containers/applicator/pill/penacid


/obj/item/storage/pill_bottle/neurine
	name = "bottle of neurine pills"
	desc = "Contains pills to treat non-severe mental traumas."

/obj/item/storage/pill_bottle/neurine/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/applicator/pill/neurine

/obj/item/storage/pill_bottle/maintenance_pill
	name = "bottle of maintenance pills"
	desc = "An old pill bottle. It smells musty."

/obj/item/storage/pill_bottle/maintenance_applicator/pill/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/applicator/pill/P = locate() in src
	name = "bottle of [P.name]s"

/obj/item/storage/pill_bottle/maintenance_applicator/pill/PopulateContents()
	. = list()
	for(var/i in 1 to rand(1,7))
		. += /obj/item/reagent_containers/applicator/pill/maintenance

/obj/item/storage/pill_bottle/maintenance_applicator/pill/full/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/applicator/pill/maintenance

///////////////////////////////////////// Psychologist inventory pillbottles
/obj/item/storage/pill_bottle/happinesspsych
	name = "happiness pills"
	desc = "Contains pills used as a last resort means to temporarily stabilize depression and anxiety. WARNING: side effects may include slurred speech, drooling, and severe addiction."

/obj/item/storage/pill_bottle/happinesspsych/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/applicator/pill/happinesspsych

/obj/item/storage/pill_bottle/lsdpsych
	name = "mindbreaker toxin pills"
	desc = "!FOR THERAPEUTIC USE ONLY! Contains pills used to alleviate the symptoms of Reality Dissociation Syndrome."

/obj/item/storage/pill_bottle/lsdpsych/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/applicator/pill/lsdpsych

/obj/item/storage/pill_bottle/paxpsych
	name = "pax pills"
	desc = "Contains pills used to temporarily pacify patients that are deemed a harm to themselves or others."

/obj/item/storage/pill_bottle/paxpsych/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/applicator/pill/paxpsych

/obj/item/storage/pill_bottle/naturalbait
	name = "freshness jar"
	desc = "Full of natural fish bait."

/obj/item/storage/pill_bottle/naturalbait/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/food/bait/natural

/obj/item/storage/pill_bottle/ondansetron
	name = "ondansetron patches"
	desc = "A bottle containing patches of ondansetron, a drug used to treat nausea and vomiting. May cause drowsiness."

/obj/item/storage/pill_bottle/ondansetron/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/applicator/patch/ondansetron

/obj/item/storage/pill_bottle/maintenance_pill
	name = "bottle of maintenance pills"
	desc = "An old pill bottle. It smells musty."

/obj/item/storage/pill_bottle/maintenance_pill/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/applicator/pill/P = locate() in src
	name = "bottle of [P.name]s"

/obj/item/storage/pill_bottle/maintenance_pill/PopulateContents()
	. = list()
	for(var/i in 1 to rand(1, 7))
		. += /obj/item/reagent_containers/applicator/pill/maintenance

/obj/item/storage/pill_bottle/maintenance_pill/full/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/applicator/pill/maintenance
