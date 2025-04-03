
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

/obj/item/storage/pill_bottle/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is trying to get the cap off [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/storage/pill_bottle/multiver
	name = "bottle of multiver pills"
	desc = "Contains pills used to counter toxins."

/obj/item/storage/pill_bottle/multiver/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/applicator/pill/multiver(src)

/obj/item/storage/pill_bottle/multiver/less

/obj/item/storage/pill_bottle/multiver/less/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/applicator/pill/multiver(src)

/obj/item/storage/pill_bottle/epinephrine
	name = "bottle of epinephrine pills"
	desc = "Contains pills used to stabilize patients."

/obj/item/storage/pill_bottle/epinephrine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/applicator/pill/epinephrine(src)

/obj/item/storage/pill_bottle/mutadone
	name = "bottle of mutadone pills"
	desc = "Contains pills used to treat genetic abnormalities."

/obj/item/storage/pill_bottle/mutadone/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/applicator/pill/mutadone(src)

/obj/item/storage/pill_bottle/potassiodide
	name = "bottle of potassium iodide pills"
	desc = "Contains pills used to reduce radiation damage."

/obj/item/storage/pill_bottle/potassiodide/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/applicator/pill/potassiodide(src)

/obj/item/storage/pill_bottle/probital
	name = "bottle of probital pills"
	desc = "Contains pills used to treat brute damage. The tag in the bottle states 'Eat before ingesting, may cause fatigue'."

/obj/item/storage/pill_bottle/probital/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/applicator/pill/probital(src)

/obj/item/storage/pill_bottle/iron
	name = "bottle of iron pills"
	desc = "Contains pills used to reduce blood loss slowly. The tag in the bottle states 'Only take one each five minutes'."

/obj/item/storage/pill_bottle/iron/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/applicator/pill/iron(src)

/obj/item/storage/pill_bottle/mannitol
	name = "bottle of mannitol pills"
	desc = "Contains pills used to treat brain damage."

/obj/item/storage/pill_bottle/mannitol/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/applicator/pill/mannitol(src)

//Contains 4 pills instead of 7, and 5u pills instead of 50u (50u pills heal 250 brain damage, 5u pills heal 25)
/obj/item/storage/pill_bottle/mannitol/braintumor
	desc = "Contains diluted pills used to treat brain tumor symptoms. Take one when feeling lightheaded."

/obj/item/storage/pill_bottle/mannitol/braintumor/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/applicator/pill/mannitol/braintumor(src)

/obj/item/storage/pill_bottle/stimulant
	name = "bottle of stimulant pills"
	desc = "Guaranteed to give you that extra burst of energy during a long shift!"

/obj/item/storage/pill_bottle/stimulant/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/applicator/pill/stimulant(src)

/obj/item/storage/pill_bottle/sansufentanyl
	name = "bottle of experimental medication"
	desc = "A bottle of pills developed by Interdyne Pharmaceuticals. They're used to treat Hereditary Manifold Sickness."

/obj/item/storage/pill_bottle/sansufentanyl/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/applicator/pill/sansufentanyl(src)

/obj/item/storage/pill_bottle/mining
	name = "bottle of patches"
	desc = "Contains patches used to treat brute and burn damage."

/obj/item/storage/pill_bottle/mining/PopulateContents()
	new /obj/item/reagent_containers/applicator/patch/aiuri(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/applicator/patch/libital(src)

/obj/item/storage/pill_bottle/zoom
	name = "suspicious pill bottle"
	desc = "The label is pretty old and almost unreadable, you recognize some chemical compounds."

/obj/item/storage/pill_bottle/zoom/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/applicator/pill/zoom(src)

/obj/item/storage/pill_bottle/happy
	name = "suspicious pill bottle"
	desc = "There is a smiley on the top."

/obj/item/storage/pill_bottle/happy/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/applicator/pill/happy(src)

/obj/item/storage/pill_bottle/lsd
	name = "suspicious pill bottle"
	desc = "There is a crude drawing which could be either a mushroom, or a deformed moon."

/obj/item/storage/pill_bottle/lsd/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/applicator/pill/lsd(src)

/obj/item/storage/pill_bottle/aranesp
	name = "suspicious pill bottle"
	desc = "The label has 'fuck disablers' hastily scrawled in black marker."

/obj/item/storage/pill_bottle/aranesp/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/applicator/pill/aranesp(src)

/obj/item/storage/pill_bottle/psicodine
	name = "bottle of psicodine pills"
	desc = "Contains pills used to treat mental distress and traumas."

/obj/item/storage/pill_bottle/psicodine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/applicator/pill/psicodine(src)

/obj/item/storage/pill_bottle/penacid
	name = "bottle of pentetic acid pills"
	desc = "Contains pills to expunge radiation and toxins."

/obj/item/storage/pill_bottle/penacid/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/applicator/pill/penacid(src)


/obj/item/storage/pill_bottle/neurine
	name = "bottle of neurine pills"
	desc = "Contains pills to treat non-severe mental traumas."

/obj/item/storage/pill_bottle/neurine/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/applicator/pill/neurine(src)

/obj/item/storage/pill_bottle/maintenance_pill
	name = "bottle of maintenance pills"
	desc = "An old pill bottle. It smells musty."

/obj/item/storage/pill_bottle/maintenance_pill/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/applicator/pill/P = locate() in src
	name = "bottle of [P.name]s"

/obj/item/storage/pill_bottle/maintenance_pill/PopulateContents()
	for(var/i in 1 to rand(1,7))
		new /obj/item/reagent_containers/applicator/pill/maintenance(src)

/obj/item/storage/pill_bottle/maintenance_pill/full/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/applicator/pill/maintenance(src)

///////////////////////////////////////// Psychologist inventory pillbottles
/obj/item/storage/pill_bottle/happinesspsych
	name = "happiness pills"
	desc = "Contains pills used as a last resort means to temporarily stabilize depression and anxiety. WARNING: side effects may include slurred speech, drooling, and severe addiction."

/obj/item/storage/pill_bottle/happinesspsych/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/applicator/pill/happinesspsych(src)

/obj/item/storage/pill_bottle/lsdpsych
	name = "mindbreaker toxin pills"
	desc = "!FOR THERAPEUTIC USE ONLY! Contains pills used to alleviate the symptoms of Reality Dissociation Syndrome."

/obj/item/storage/pill_bottle/lsdpsych/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/applicator/pill/lsdpsych(src)

/obj/item/storage/pill_bottle/paxpsych
	name = "pax pills"
	desc = "Contains pills used to temporarily pacify patients that are deemed a harm to themselves or others."

/obj/item/storage/pill_bottle/paxpsych/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/applicator/pill/paxpsych(src)

/obj/item/storage/pill_bottle/naturalbait
	name = "freshness jar"
	desc = "Full of natural fish bait."

/obj/item/storage/pill_bottle/naturalbait/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/food/bait/natural(src)

/obj/item/storage/pill_bottle/ondansetron
	name = "ondansetron patches"
	desc = "A bottle containing patches of ondansetron, a drug used to treat nausea and vomiting. May cause drowsiness."

/obj/item/storage/pill_bottle/ondansetron/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/applicator/patch/ondansetron(src)
