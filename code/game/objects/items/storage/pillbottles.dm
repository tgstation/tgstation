
/*
 * Pill Bottles
 */
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

	///Number of pills to spawn
	VAR_PROTECTED/spawn_count
	///Pill type to spawn
	VAR_PROTECTED/obj/item/reagent_containers/applicator/pill/spawn_type

/obj/item/storage/pill_bottle/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is trying to get the cap off [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/storage/pill_bottle/PopulateContents()
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!spawn_count)
		return

	for(var/i in 1 to spawn_count)
		new spawn_type(src)

/obj/item/storage/pill_bottle/multiver
	name = "bottle of multiver pills"
	desc = "Contains pills used to counter toxins."
	spawn_count = 7
	spawn_type = /obj/item/reagent_containers/applicator/pill/multiver

/obj/item/storage/pill_bottle/multiver/less
	spawn_count = 3

/obj/item/storage/pill_bottle/epinephrine
	name = "bottle of epinephrine pills"
	desc = "Contains pills used to stabilize patients."
	spawn_count = 7
	spawn_type = /obj/item/reagent_containers/applicator/pill/epinephrine

/obj/item/storage/pill_bottle/mutadone
	name = "bottle of mutadone pills"
	desc = "Contains pills used to treat genetic abnormalities."
	spawn_count = 7
	spawn_type = /obj/item/reagent_containers/applicator/pill/mutadone

/obj/item/storage/pill_bottle/potassiodide
	name = "bottle of potassium iodide pills"
	desc = "Contains pills used to reduce radiation damage."
	spawn_count = 3
	spawn_type = /obj/item/reagent_containers/applicator/pill/potassiodide

/obj/item/storage/pill_bottle/probital
	name = "bottle of probital pills"
	desc = "Contains pills used to treat brute damage. The tag in the bottle states 'Eat before ingesting, may cause fatigue'."
	spawn_count = 4
	spawn_type = /obj/item/reagent_containers/applicator/pill/probital

/obj/item/storage/pill_bottle/iron
	name = "bottle of iron pills"
	desc = "Contains pills used to reduce blood loss slowly. The tag in the bottle states 'Only take one each five minutes'."
	spawn_count = 4
	spawn_type = /obj/item/reagent_containers/applicator/pill/iron

/obj/item/storage/pill_bottle/mannitol
	name = "bottle of mannitol pills"
	desc = "Contains pills used to treat brain damage."
	spawn_count = 7
	spawn_type = /obj/item/reagent_containers/applicator/pill/mannitol

//Contains 4 pills instead of 7, and 5u pills instead of 50u (50u pills heal 250 brain damage, 5u pills heal 25)
/obj/item/storage/pill_bottle/mannitol/braintumor
	desc = "Contains diluted pills used to treat brain tumor symptoms. Take one when feeling lightheaded."
	spawn_count = 4
	spawn_type = /obj/item/reagent_containers/applicator/pill/mannitol/braintumor

/obj/item/storage/pill_bottle/stimulant
	name = "bottle of stimulant pills"
	desc = "Guaranteed to give you that extra burst of energy during a long shift!"
	spawn_count = 5
	spawn_type = /obj/item/reagent_containers/applicator/pill/stimulant

/obj/item/storage/pill_bottle/sansufentanyl
	name = "bottle of experimental medication"
	desc = "A bottle of pills developed by Interdyne Pharmaceuticals. They're used to treat Hereditary Manifold Sickness."
	spawn_count = 6
	spawn_type = /obj/item/reagent_containers/applicator/pill/sansufentanyl

/obj/item/storage/pill_bottle/mining
	name = "bottle of patches"
	desc = "Contains patches used to treat brute and burn damage."
	spawn_count = 3
	spawn_type = /obj/item/reagent_containers/applicator/patch/libital

/obj/item/storage/pill_bottle/zoom
	name = "suspicious pill bottle"
	desc = "The label is pretty old and almost unreadable, you recognize some chemical compounds."
	spawn_count = 5
	spawn_type = /obj/item/reagent_containers/applicator/pill/zoom

/obj/item/storage/pill_bottle/happy
	name = "suspicious pill bottle"
	desc = "There is a smiley on the top."
	spawn_count = 5
	spawn_type = /obj/item/reagent_containers/applicator/pill/happy

/obj/item/storage/pill_bottle/lsd
	name = "suspicious pill bottle"
	desc = "There is a crude drawing which could be either a mushroom, or a deformed moon."
	spawn_count = 5
	spawn_type = /obj/item/reagent_containers/applicator/pill/lsd

/obj/item/storage/pill_bottle/aranesp
	name = "suspicious pill bottle"
	desc = "The label has 'fuck disablers' hastily scrawled in black marker."
	spawn_count = 5
	spawn_type = /obj/item/reagent_containers/applicator/pill/aranesp

/obj/item/storage/pill_bottle/psicodine
	name = "bottle of psicodine pills"
	desc = "Contains pills used to treat mental distress and traumas."
	spawn_count = 7
	spawn_type = /obj/item/reagent_containers/applicator/pill/psicodine

/obj/item/storage/pill_bottle/penacid
	name = "bottle of pentetic acid pills"
	desc = "Contains pills to expunge radiation and toxins."
	spawn_count = 3
	spawn_type = /obj/item/reagent_containers/applicator/pill/penacid

/obj/item/storage/pill_bottle/neurine
	name = "bottle of neurine pills"
	desc = "Contains pills to treat non-severe mental traumas."
	spawn_count = 5
	spawn_type = /obj/item/reagent_containers/applicator/pill/neurine

/obj/item/storage/pill_bottle/maintenance_pill
	name = "bottle of maintenance pills"
	desc = "An old pill bottle. It smells musty."
	spawn_type = /obj/item/reagent_containers/applicator/pill/maintenance

/obj/item/storage/pill_bottle/maintenance_pill/Initialize(mapload)
	if(!spawn_count)
		spawn_count = rand(1,7)
	. = ..()
	var/obj/item/reagent_containers/applicator/pill/P = locate() in src
	name = "bottle of [P.name]s"

/obj/item/storage/pill_bottle/maintenance_pill/full
	spawn_count = 7

///////////////////////////////////////// Psychologist inventory pillbottles
/obj/item/storage/pill_bottle/happinesspsych
	name = "happiness pills"
	desc = "Contains pills used as a last resort means to temporarily stabilize depression and anxiety. WARNING: side effects may include slurred speech, drooling, and severe addiction."
	spawn_count = 5
	spawn_type = /obj/item/reagent_containers/applicator/pill/happinesspsych

/obj/item/storage/pill_bottle/lsdpsych
	name = "mindbreaker toxin pills"
	desc = "!FOR THERAPEUTIC USE ONLY! Contains pills used to alleviate the symptoms of Reality Dissociation Syndrome."
	spawn_count = 5
	spawn_type = /obj/item/reagent_containers/applicator/pill/lsdpsych

/obj/item/storage/pill_bottle/paxpsych
	name = "pax pills"
	desc = "Contains pills used to temporarily pacify patients that are deemed a harm to themselves or others."
	spawn_count = 5
	spawn_type = /obj/item/reagent_containers/applicator/pill/paxpsych

/obj/item/storage/pill_bottle/naturalbait
	name = "freshness jar"
	desc = "Full of natural fish bait."
	spawn_count = 7
	spawn_type = /obj/item/food/bait/natural

/obj/item/storage/pill_bottle/ondansetron
	name = "ondansetron patches"
	desc = "A bottle containing patches of ondansetron, a drug used to treat nausea and vomiting. May cause drowsiness."
	spawn_count = 5
	spawn_type = /obj/item/reagent_containers/applicator/patch/ondansetron
