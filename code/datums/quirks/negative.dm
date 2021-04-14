//predominantly negative traits

/// Defines for locations of items being added to your inventory on spawn
#define LOCATION_LPOCKET "in your left pocket"
#define LOCATION_RPOCKET "in your right pocket"
#define LOCATION_BACKPACK "in your backpack"
#define LOCATION_HANDS "in your hands"

/datum/quirk/badback
	name = "Bad Back"
	desc = "Thanks to your poor posture, backpacks and other bags never sit right on your back. More evently weighted objects are fine, though."
	value = -8
	mood_quirk = TRUE
	gain_text = "<span class='danger'>Your back REALLY hurts!</span>"
	lose_text = "<span class='notice'>Your back feels better.</span>"
	medical_record_text = "Patient scans indicate severe and chronic back pain."
	hardcore_value = 4

/datum/quirk/badback/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(H.back && istype(H.back, /obj/item/storage/backpack))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "back_pain", /datum/mood_event/back_pain)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "back_pain")

/datum/quirk/blooddeficiency
	name = "Blood Deficiency"
	desc = "Your body can't produce enough blood to sustain itself."
	value = -8
	gain_text = "<span class='danger'>You feel your vigor slowly fading away.</span>"
	lose_text = "<span class='notice'>You feel vigorous again.</span>"
	medical_record_text = "Patient requires regular treatment for blood loss due to low production of blood."
	hardcore_value = 8

/datum/quirk/blooddeficiency/on_process(delta_time)
	var/mob/living/carbon/human/H = quirk_holder
	if(NOBLOOD in H.dna.species.species_traits) //can't lose blood if your species doesn't have any
		return

	if (H.blood_volume > (BLOOD_VOLUME_SAFE - 25)) // just barely survivable without treatment
		H.blood_volume -= 0.275 * delta_time

/datum/quirk/blindness
	name = "Blind"
	desc = "You are completely blind, nothing can counteract this."
	value = -16
	gain_text = "<span class='danger'>You can't see anything.</span>"
	lose_text = "<span class='notice'>You miraculously gain back your vision.</span>"
	medical_record_text = "Patient has permanent blindness."
	hardcore_value = 15

/datum/quirk/blindness/add()
	quirk_holder.become_blind(ROUNDSTART_TRAIT)

/datum/quirk/blindness/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/blindfold/white/B = new(get_turf(H))
	if(!H.equip_to_slot_if_possible(B, ITEM_SLOT_EYES, bypass_equip_delay_self = TRUE)) //if you can't put it on the user's eyes, put it in their hands, otherwise put it on their eyes
		H.put_in_hands(B)

	/* A couple of brain tumor stats for anyone curious / looking at this quirk for balancing:
	 * - It takes less 16 minute 40 seconds to die from brain death due to a brain tumor.
	 * - It takes 1 minutes 40 seconds to take 10% (20 organ damage) brain damage.
	 * - 5u mannitol will heal 12.5% (25 organ damage) brain damage
	 */
/datum/quirk/brainproblems
	name = "Brain Tumor"
	desc = "You have a little friend in your brain that is slowly destroying it. Better bring some mannitol!"
	value = -12
	gain_text = "<span class='danger'>You feel smooth.</span>"
	lose_text = "<span class='notice'>You feel wrinkled again.</span>"
	medical_record_text = "Patient has a tumor in their brain that is slowly driving them to brain death."
	hardcore_value = 12
	/// Location of the bottle of pills on spawn
	var/where

/datum/quirk/brainproblems/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/pills = new /obj/item/storage/pill_bottle/mannitol/braintumor()
	var/list/slots = list(
		LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
		LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
		LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
		LOCATION_HANDS = ITEM_SLOT_HANDS
	)
	where = H.equip_in_one_of_slots(pills, slots, FALSE) || "at your feet"

/datum/quirk/brainproblems/post_add()
	if(where == LOCATION_BACKPACK)
		var/mob/living/carbon/human/H = quirk_holder
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

	to_chat(quirk_holder, "<span class='boldnotice'>There is a bottle of mannitol pills [where] to keep you alive until you can secure a supply of medication. Don't rely on it too much!</span>")

/datum/quirk/brainproblems/on_process(delta_time)
	if(HAS_TRAIT(quirk_holder, TRAIT_TUMOR_SUPPRESSED))
		return
	quirk_holder.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2 * delta_time)

/datum/quirk/deafness
	name = "Deaf"
	desc = "You are incurably deaf."
	value = -8
	mob_trait = TRAIT_DEAF
	gain_text = "<span class='danger'>You can't hear anything.</span>"
	lose_text = "<span class='notice'>You're able to hear again!</span>"
	medical_record_text = "Patient's cochlear nerve is incurably damaged."
	hardcore_value = 12

/datum/quirk/depression
	name = "Depression"
	desc = "You sometimes just hate life."
	mob_trait = TRAIT_DEPRESSION
	value = -3
	gain_text = "<span class='danger'>You start feeling depressed.</span>"
	lose_text = "<span class='notice'>You no longer feel depressed.</span>" //if only it were that easy!
	medical_record_text = "Patient has a mild mood disorder causing them to experience acute episodes of depression."
	mood_quirk = TRUE
	hardcore_value = 2

/datum/quirk/family_heirloom
	name = "Family Heirloom"
	desc = "You are the current owner of an heirloom, passed down for generations. You have to keep it safe!"
	value = -2
	mood_quirk = TRUE
	medical_record_text = "Patient demonstrates an unnatural attachment to a family heirloom."
	hardcore_value = 1
	/// A reference to our heirloom.
	var/obj/item/heirloom
	/// Where our heirloom is spawning.
	var/heirloom_spawn_loc

/datum/quirk/family_heirloom/on_spawn()
	/// The quirk holder, casted to human
	var/mob/living/carbon/human/human_holder = quirk_holder
	/// The heirloom we will spawn
	var/obj/item/heirloom_type

	/// The quirk holder's species - we have a 50% chance, if we have a species with a set heirloom, to choose a species heirloom.
	var/datum/species/holder_species = human_holder.dna?.species
	if(holder_species && LAZYLEN(holder_species.family_heirlooms) && prob(50))
		heirloom_type = pick(holder_species.family_heirlooms)
	else
		/// Our quirk holder's job
		var/datum/job/holder_job = SSjob.GetJob(human_holder.mind?.assigned_role)
		if(holder_job && LAZYLEN(holder_job.family_heirlooms))
			heirloom_type = pick(holder_job.family_heirlooms)

	// If we didn't find an heirloom somehow, throw them a generic one
	if(!heirloom_type)
		heirloom_type = pick(/obj/item/toy/cards/deck, /obj/item/lighter, /obj/item/dice/d20)

	heirloom = new heirloom_type(get_turf(quirk_holder))
	var/list/slots = list(
		LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
		LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
		LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
		LOCATION_HANDS = ITEM_SLOT_HANDS
	)
	heirloom_spawn_loc = human_holder.equip_in_one_of_slots(heirloom, slots, FALSE) || "at your feet"

/datum/quirk/family_heirloom/post_add()
	if(heirloom_spawn_loc == LOCATION_BACKPACK)
		var/mob/living/carbon/human/H = quirk_holder
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

	to_chat(quirk_holder, "<span class='boldnotice'>There is a precious family [heirloom.name] [heirloom_spawn_loc], passed down from generation to generation. Keep it safe!</span>")

	var/list/names = splittext(quirk_holder.real_name, " ")
	var/family_name = names[names.len]

	heirloom.AddComponent(/datum/component/heirloom, quirk_holder.mind, family_name)

/datum/quirk/family_heirloom/on_process()
	if(heirloom in quirk_holder.GetAllContents())
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom_missing")
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "family_heirloom", /datum/mood_event/family_heirloom)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom")
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "family_heirloom_missing", /datum/mood_event/family_heirloom_missing)

/datum/quirk/family_heirloom/remove()
	if(quirk_holder) // if the holder is still exists lets remove moods
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom_missing")
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom")

/datum/quirk/frail
	name = "Frail"
	desc = "You have skin of paper and bones of glass! You suffer wounds much more easily than most."
	value = -6
	mob_trait = TRAIT_EASILY_WOUNDED
	gain_text = "<span class='danger'>You feel frail.</span>"
	lose_text = "<span class='notice'>You feel sturdy again.</span>"
	medical_record_text = "Patient is absurdly easy to injure. Please take all due dilligence to avoid possible malpractice suits."
	hardcore_value = 4

/datum/quirk/heavy_sleeper
	name = "Heavy Sleeper"
	desc = "You sleep like a rock! Whenever you're put to sleep or knocked unconscious, you take a little bit longer to wake up."
	value = -2
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = "<span class='danger'>You feel sleepy.</span>"
	lose_text = "<span class='notice'>You feel awake again.</span>"
	medical_record_text = "Patient has abnormal sleep study results and is difficult to wake up."
	hardcore_value = 2

/datum/quirk/hypersensitive
	name = "Hypersensitive"
	desc = "For better or worse, everything seems to affect your mood more than it should."
	value = -2
	gain_text = "<span class='danger'>You seem to make a big deal out of everything.</span>"
	lose_text = "<span class='notice'>You don't seem to make a big deal out of everything anymore.</span>"
	medical_record_text = "Patient demonstrates a high level of emotional volatility."
	hardcore_value = 3

/datum/quirk/hypersensitive/add()
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier += 0.5

/datum/quirk/hypersensitive/remove()
	if(quirk_holder)
		var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
		if(mood)
			mood.mood_modifier -= 0.5

/datum/quirk/light_drinker
	name = "Light Drinker"
	desc = "You just can't handle your drinks and get drunk very quickly."
	value = -2
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = "<span class='notice'>Just the thought of drinking alcohol makes your head spin.</span>"
	lose_text = "<span class='danger'>You're no longer severely affected by alcohol.</span>"
	medical_record_text = "Patient demonstrates a low tolerance for alcohol. (Wimp)"
	hardcore_value = 3

/datum/quirk/nearsighted //t. errorage
	name = "Nearsighted"
	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	value = -1
	gain_text = "<span class='danger'>Things far away from you start looking blurry.</span>"
	lose_text = "<span class='notice'>You start seeing faraway things normally again.</span>"
	medical_record_text = "Patient requires prescription glasses in order to counteract nearsightedness."
	hardcore_value = 5

/datum/quirk/nearsighted/add()
	quirk_holder.become_nearsighted(ROUNDSTART_TRAIT)

/datum/quirk/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/regular/glasses = new(get_turf(H))
	if(!H.equip_to_slot_if_possible(glasses, ITEM_SLOT_EYES, bypass_equip_delay_self = TRUE))
		H.put_in_hands(glasses)

/datum/quirk/nyctophobia
	name = "Nyctophobia"
	desc = "As far as you can remember, you've always been afraid of the dark. While in the dark without a light source, you instinctually act careful, and constantly feel a sense of dread."
	value = -3
	medical_record_text = "Patient demonstrates a fear of the dark. (Seriously?)"
	hardcore_value = 5

/datum/quirk/nyctophobia/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(H.dna.species.id in list("shadow", "nightmare"))
		return //we're tied with the dark, so we don't get scared of it; don't cleanse outright to avoid cheese
	var/turf/T = get_turf(quirk_holder)
	var/lums = T.get_lumcount()
	if(lums <= 0.2)
		if(quirk_holder.m_intent == MOVE_INTENT_RUN)
			to_chat(quirk_holder, "<span class='warning'>Easy, easy, take it slow... you're in the dark...</span>")
			quirk_holder.toggle_move_intent()
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "nyctophobia", /datum/mood_event/nyctophobia)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "nyctophobia")

/datum/quirk/nonviolent
	name = "Pacifist"
	desc = "The thought of violence makes you sick. So much so, in fact, that you can't hurt anyone."
	value = -8
	mob_trait = TRAIT_PACIFISM
	gain_text = "<span class='danger'>You feel repulsed by the thought of violence!</span>"
	lose_text = "<span class='notice'>You think you can defend yourself again.</span>"
	medical_record_text = "Patient is unusually pacifistic and cannot bring themselves to cause physical harm."
	hardcore_value = 6

/datum/quirk/paraplegic
	name = "Paraplegic"
	desc = "Your legs do not function. Nothing will ever fix this. But hey, free wheelchair!"
	value = -12
	human_only = TRUE
	gain_text = null // Handled by trauma.
	lose_text = null
	medical_record_text = "Patient has an untreatable impairment in motor function in the lower extremities."
	hardcore_value = 15

/datum/quirk/paraplegic/add()
	var/datum/brain_trauma/severe/paralysis/paraplegic/T = new()
	var/mob/living/carbon/human/H = quirk_holder
	H.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/paraplegic/on_spawn()
	if(quirk_holder.buckled) // Handle late joins being buckled to arrival shuttle chairs.
		quirk_holder.buckled.unbuckle_mob(quirk_holder)

	var/turf/T = get_turf(quirk_holder)
	var/obj/structure/chair/spawn_chair = locate() in T

	var/obj/vehicle/ridden/wheelchair/wheels
	if(quirk_holder.client?.get_award_status(HARDCORE_RANDOM_SCORE) >= 5000) //More than 5k score? you unlock the gamer wheelchair.
		wheels = new /obj/vehicle/ridden/wheelchair/gold(T)
	else
		wheels = new(T)
	if(spawn_chair) // Makes spawning on the arrivals shuttle more consistent looking
		wheels.setDir(spawn_chair.dir)

	wheels.buckle_mob(quirk_holder)

	// During the spawning process, they may have dropped what they were holding, due to the paralysis
	// So put the things back in their hands.

	for(var/obj/item/I in T)
		if(I.fingerprintslast == quirk_holder.ckey)
			quirk_holder.put_in_hands(I)

/datum/quirk/poor_aim
	name = "Stormtrooper Aim"
	desc = "You've never hit anything you were aiming for in your life."
	value = -4
	mob_trait = TRAIT_POOR_AIM
	medical_record_text = "Patient possesses a strong tremor in both hands."
	hardcore_value = 3

/datum/quirk/prosopagnosia
	name = "Prosopagnosia"
	desc = "You have a mental disorder that prevents you from being able to recognize faces at all."
	value = -4
	mob_trait = TRAIT_PROSOPAGNOSIA
	medical_record_text = "Patient suffers from prosopagnosia and cannot recognize faces."
	hardcore_value = 5

/datum/quirk/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "An accident caused you to lose one of your limbs. Because of this, you now have a random prosthetic!"
	value = -4
	var/slot_string = "limb"
	medical_record_text = "During physical examination, patient was found to have a prosthetic limb."
	hardcore_value = 3

/datum/quirk/prosthetic_limb/on_spawn()
	var/limb_slot = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/bodypart/old_part = H.get_bodypart(limb_slot)
	var/obj/item/bodypart/prosthetic
	switch(limb_slot)
		if(BODY_ZONE_L_ARM)
			prosthetic = new/obj/item/bodypart/l_arm/robot/surplus(quirk_holder)
			slot_string = "left arm"
		if(BODY_ZONE_R_ARM)
			prosthetic = new/obj/item/bodypart/r_arm/robot/surplus(quirk_holder)
			slot_string = "right arm"
		if(BODY_ZONE_L_LEG)
			prosthetic = new/obj/item/bodypart/l_leg/robot/surplus(quirk_holder)
			slot_string = "left leg"
		if(BODY_ZONE_R_LEG)
			prosthetic = new/obj/item/bodypart/r_leg/robot/surplus(quirk_holder)
			slot_string = "right leg"
	prosthetic.replace_limb(H)
	qdel(old_part)
	H.regenerate_icons()

/datum/quirk/prosthetic_limb/post_add()
	to_chat(quirk_holder, "<span class='boldannounce'>Your [slot_string] has been replaced with a surplus prosthetic. It is fragile and will easily come apart under duress. Additionally, \
	you need to use a welding tool and cables to repair it, instead of bruise packs and ointment.</span>")

/datum/quirk/pushover
	name = "Pushover"
	desc = "Your first instinct is always to let people push you around. Resisting out of grabs will take conscious effort."
	value = -8
	mob_trait = TRAIT_GRABWEAKNESS
	gain_text = "<span class='danger'>You feel like a pushover.</span>"
	lose_text = "<span class='notice'>You feel like standing up for yourself.</span>"
	medical_record_text = "Patient presents a notably unassertive personality and is easy to manipulate."
	hardcore_value = 4

/datum/quirk/insanity
	name = "Reality Dissociation Syndrome"
	desc = "You suffer from a severe disorder that causes very vivid hallucinations. Mindbreaker toxin can suppress its effects, and you are immune to mindbreaker's hallucinogenic properties. <b>This is not a license to grief.</b>"
	value = -8
	//no mob trait because it's handled uniquely
	gain_text = "<span class='userdanger'>...</span>"
	lose_text = "<span class='notice'>You feel in tune with the world again.</span>"
	medical_record_text = "Patient suffers from acute Reality Dissociation Syndrome and experiences vivid hallucinations."
	hardcore_value = 6

/datum/quirk/insanity/on_process(delta_time)
	if(quirk_holder.reagents.has_reagent(/datum/reagent/toxin/mindbreaker, needs_metabolizing = TRUE))
		quirk_holder.hallucination = 0
		return
	if(DT_PROB(2, delta_time)) //we'll all be mad soon enough
		madness()

/datum/quirk/insanity/proc/madness()
	quirk_holder.hallucination += rand(10, 25)

/datum/quirk/insanity/post_add() //I don't /think/ we'll need this but for newbies who think "roleplay as insane" = "license to kill" it's probably a good thing to have
	if(!quirk_holder.mind || quirk_holder.mind.special_role)
		return
	to_chat(quirk_holder, "<span class='big bold info'>Please note that your dissociation syndrome does NOT give you the right to attack people or otherwise cause any interference to \
	the round. You are not an antagonist, and the rules will treat you the same as other crewmembers.</span>")

/datum/quirk/social_anxiety
	name = "Social Anxiety"
	desc = "Talking to people is very difficult for you, and you often stutter or even lock up."
	value = -3
	gain_text = "<span class='danger'>You start worrying about what you're saying.</span>"
	lose_text = "<span class='notice'>You feel easier about talking again.</span>" //if only it were that easy!
	medical_record_text = "Patient is usually anxious in social encounters and prefers to avoid them."
	hardcore_value = 4
	mob_trait = TRAIT_ANXIOUS
	var/dumb_thing = TRUE

/datum/quirk/social_anxiety/add()
	RegisterSignal(quirk_holder, COMSIG_MOB_EYECONTACT, .proc/eye_contact)
	RegisterSignal(quirk_holder, COMSIG_MOB_EXAMINATE, .proc/looks_at_floor)

/datum/quirk/social_anxiety/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_MOB_EYECONTACT, COMSIG_MOB_EXAMINATE))

/datum/quirk/social_anxiety/on_process(delta_time)
	if(HAS_TRAIT(quirk_holder, TRAIT_FEARLESS))
		return
	var/nearby_people = 0
	for(var/mob/living/carbon/human/H in oview(3, quirk_holder))
		if(H.client)
			nearby_people++
	var/mob/living/carbon/human/H = quirk_holder
	if(DT_PROB(2 + nearby_people, delta_time))
		H.stuttering = max(3, H.stuttering)
	else if(DT_PROB(min(3, nearby_people), delta_time) && !H.silent)
		to_chat(H, "<span class='danger'>You retreat into yourself. You <i>really</i> don't feel up to talking.</span>")
		H.silent = max(10, H.silent)
	else if(DT_PROB(0.5, delta_time) && dumb_thing)
		to_chat(H, "<span class='userdanger'>You think of a dumb thing you said a long time ago and scream internally.</span>")
		dumb_thing = FALSE //only once per life
		if(prob(1))
			new/obj/item/food/spaghetti/pastatomato(get_turf(H)) //now that's what I call spaghetti code

// small chance to make eye contact with inanimate objects/mindless mobs because of nerves
/datum/quirk/social_anxiety/proc/looks_at_floor(datum/source, atom/A)
	SIGNAL_HANDLER

	var/mob/living/mind_check = A
	if(prob(85) || (istype(mind_check) && mind_check.mind))
		return

	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, quirk_holder, "<span class='smallnotice'>You make eye contact with [A].</span>"), 3)

/datum/quirk/social_anxiety/proc/eye_contact(datum/source, mob/living/other_mob, triggering_examiner)
	SIGNAL_HANDLER

	if(prob(75))
		return
	var/msg
	if(triggering_examiner)
		msg = "You make eye contact with [other_mob], "
	else
		msg = "[other_mob] makes eye contact with you, "

	switch(rand(1,3))
		if(1)
			quirk_holder.Jitter(10)
			msg += "causing you to start fidgeting!"
		if(2)
			quirk_holder.stuttering = max(3, quirk_holder.stuttering)
			msg += "causing you to start stuttering!"
		if(3)
			quirk_holder.Stun(2 SECONDS)
			msg += "causing you to freeze up!"

	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "anxiety_eyecontact", /datum/mood_event/anxiety_eyecontact)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, quirk_holder, "<span class='userdanger'>[msg]</span>"), 3) // so the examine signal has time to fire and this will print after
	return COMSIG_BLOCK_EYECONTACT

/datum/mood_event/anxiety_eyecontact
	description = "<span class='warning'>Sometimes eye contact makes me so nervous...</span>\n"
	mood_change = -5
	timeout = 3 MINUTES

/datum/quirk/junkie
	name = "Junkie"
	desc = "You can't get enough of hard drugs."
	value = -6
	gain_text = "<span class='danger'>You suddenly feel the craving for drugs.</span>"
	medical_record_text = "Patient has a history of hard drugs."
	hardcore_value = 4
	var/drug_list = list(/datum/reagent/drug/crank, /datum/reagent/drug/krokodil, /datum/reagent/medicine/morphine, /datum/reagent/drug/happiness, /datum/reagent/drug/methamphetamine) //List of possible IDs
	var/datum/reagent/reagent_type //!If this is defined, reagent_id will be unused and the defined reagent type will be instead.
	var/datum/reagent/reagent_instance //! actual instanced version of the reagent
	var/where_drug //! Where the drug spawned
	var/obj/item/drug_container_type //! If this is defined before pill generation, pill generation will be skipped. This is the type of the pill bottle.
	var/where_accessory //! where the accessory spawned
	var/obj/item/accessory_type //! If this is null, an accessory won't be spawned.
	var/process_interval = 30 SECONDS //! how frequently the quirk processes
	var/next_process = 0 //! ticker for processing

/datum/quirk/junkie/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	if (!reagent_type)
		reagent_type = pick(drug_list)
	reagent_instance = new reagent_type()
	for(var/addiction in reagent_instance.addiction_types)
		H.mind.add_addiction_points(addiction, 1000) ///Max that shit out
	var/current_turf = get_turf(quirk_holder)
	if (!drug_container_type)
		drug_container_type = /obj/item/storage/pill_bottle
	var/obj/item/drug_instance = new drug_container_type(current_turf)
	if (istype(drug_instance, /obj/item/storage/pill_bottle))
		var/pill_state = "pill[rand(1,20)]"
		for(var/i in 1 to 7)
			var/obj/item/reagent_containers/pill/P = new(drug_instance)
			P.icon_state = pill_state
			P.reagents.add_reagent(reagent_type, 1)

	var/obj/item/accessory_instance
	if (accessory_type)
		accessory_instance = new accessory_type(current_turf)
	var/list/slots = list(
		LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
		LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
		LOCATION_BACKPACK = ITEM_SLOT_BACKPACK
	)
	where_drug = H.equip_in_one_of_slots(drug_instance, slots, FALSE) || "at your feet"
	if (accessory_instance)
		where_accessory = H.equip_in_one_of_slots(accessory_instance, slots, FALSE) || "at your feet"
	announce_drugs()

/datum/quirk/junkie/post_add()
	if(where_drug == LOCATION_BACKPACK || where_accessory == LOCATION_BACKPACK)
		var/mob/living/carbon/human/H = quirk_holder
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

/datum/quirk/junkie/remove()
	if(quirk_holder && reagent_instance)
		for(var/addiction_type in subtypesof(/datum/addiction))
			quirk_holder.mind.remove_addiction_points(addiction_type, MAX_ADDICTION_POINTS) //chat feedback here. No need of lose_text.

/datum/quirk/junkie/proc/announce_drugs()
	to_chat(quirk_holder, "<span class='boldnotice'>There is a [initial(drug_container_type.name)] of [initial(reagent_type.name)] [where_drug]. Better hope you don't run out...</span>")

/datum/quirk/junkie/on_process()
	if(HAS_TRAIT(quirk_holder, TRAIT_NOMETABOLISM))
		return
	var/mob/living/carbon/human/H = quirk_holder
	if(world.time > next_process)
		next_process = world.time + process_interval
		var/deleted = QDELETED(reagent_instance)
		var/missing_addiction = FALSE
		for(var/addiction_type in reagent_instance.addiction_types)
			if(!LAZYACCESS(H.mind.active_addictions, addiction_type))
				missing_addiction = TRUE
		if(deleted || missing_addiction)
			if(deleted)
				reagent_instance = new reagent_type()
			to_chat(quirk_holder, "<span class='danger'>You thought you kicked it, but you feel like you're falling back onto bad habits..</span>")
			for(var/addiction in reagent_instance.addiction_types)
				H.mind.add_addiction_points(addiction, 1000) ///Max that shit out


/datum/quirk/junkie/smoker
	name = "Smoker"
	desc = "Sometimes you just really want a smoke. Probably not great for your lungs."
	value = -4
	gain_text = "<span class='danger'>You could really go for a smoke right about now.</span>"
	medical_record_text = "Patient is a current smoker."
	reagent_type = /datum/reagent/drug/nicotine
	accessory_type = /obj/item/lighter/greyscale
	hardcore_value = 1

/datum/quirk/junkie/smoker/on_spawn()
	drug_container_type = pick(/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/fancy/cigarettes/cigpack_midori,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
		/obj/item/storage/fancy/cigarettes/cigpack_carp)
	quirk_holder?.mind?.store_memory("Your favorite cigarette packets are [initial(drug_container_type.name)]s.")
	. = ..()

/datum/quirk/junkie/smoker/announce_drugs()
	to_chat(quirk_holder, "<span class='boldnotice'>There is a [initial(drug_container_type.name)] [where_drug], and a lighter [where_accessory]. Make sure you get your favorite brand when you run out.</span>")


/datum/quirk/junkie/smoker/on_process()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/I = H.get_item_by_slot(ITEM_SLOT_MASK)
	if (istype(I, /obj/item/clothing/mask/cigarette))
		var/obj/item/storage/fancy/cigarettes/C = drug_container_type
		if(istype(I, initial(C.spawn_type)))
			SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "wrong_cigs")
			return
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "wrong_cigs", /datum/mood_event/wrong_brand)

/datum/quirk/unstable
	name = "Unstable"
	desc = "Due to past troubles, you are unable to recover your sanity if you lose it. Be very careful managing your mood!"
	value = -10
	mob_trait = TRAIT_UNSTABLE
	gain_text = "<span class='danger'>There's a lot on your mind right now.</span>"
	lose_text = "<span class='notice'>Your mind finally feels calm.</span>"
	medical_record_text = "Patient's mind is in a vulnerable state, and cannot recover from traumatic events."
	hardcore_value = 9

/datum/quirk/allergic
	name = "Extreme Medicine Allergy"
	desc = "Ever since you were a kid, you've been allergic to certain chemicals..."
	value = -6
	gain_text = "<span class='danger'>You feel your immune system shift.</span>"
	lose_text = "<span class='notice'>You feel your immune system phase back into perfect shape.</span>"
	medical_record_text = "Patient's immune system responds violently to certain chemicals."
	hardcore_value = 3
	var/list/allergies = list()
	var/list/blacklist = list(/datum/reagent/medicine/c2,/datum/reagent/medicine/epinephrine,/datum/reagent/medicine/adminordrazine,/datum/reagent/medicine/omnizine/godblood,/datum/reagent/medicine/cordiolis_hepatico,/datum/reagent/medicine/synaphydramine,/datum/reagent/medicine/diphenhydramine)

/datum/quirk/allergic/on_spawn()
	var/list/chem_list = subtypesof(/datum/reagent/medicine) - blacklist
	for(var/i in 0 to 5)
		var/chem = pick(chem_list)
		chem_list -= chem
		allergies += chem

/datum/quirk/allergic/post_add()
	var/display = ""
	for(var/C in allergies)
		var/datum/reagent/chemical = C
		display += initial(chemical.name) + ", "
	name = "Extreme " + display +"Allergies"
	medical_record_text = "Patient's immune system responds violently to [display]"
	quirk_holder?.mind.store_memory("You are allergic to [display]")
	to_chat(quirk_holder, "<span class='boldnotice'>You are allergic to [display]make sure not to consume any of it!</span>")
	if(!ishuman(quirk_holder))
		return
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/clothing/accessory/allergy_dogtag/dogtag = new(get_turf(human_holder))
	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"hands" = ITEM_SLOT_HANDS
	)
	dogtag.display = display
	human_holder.equip_in_one_of_slots(dogtag, slots , qdel_on_fail = TRUE)

/datum/quirk/allergic/on_process(delta_time)
	. = ..()
	if(!iscarbon(quirk_holder))
		return
	if(IS_IN_STASIS(quirk_holder))
		return
	var/mob/living/carbon/carbon_quirk_holder = quirk_holder
	for(var/M in allergies)
		var/datum/reagent/instantiated_med = carbon_quirk_holder.reagents.has_reagent(M)
		if(!instantiated_med)
			continue
		//Just halts the progression, I'd suggest you run to medbay asap to get it fixed
		if(carbon_quirk_holder.reagents.has_reagent(/datum/reagent/medicine/epinephrine))
			instantiated_med.reagent_removal_skip_list |= ALLERGIC_REMOVAL_SKIP
			return //intentionally stops the entire proc so we avoid the organ damage after the loop
		instantiated_med.reagent_removal_skip_list -= ALLERGIC_REMOVAL_SKIP
		carbon_quirk_holder.adjustToxLoss(3 * delta_time)
		carbon_quirk_holder.reagents.add_reagent(/datum/reagent/toxin/histamine, 3 * delta_time)
		if(DT_PROB(10, delta_time))
			carbon_quirk_holder.vomit()
			carbon_quirk_holder.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_APPENDIX,ORGAN_SLOT_LUNGS,ORGAN_SLOT_HEART,ORGAN_SLOT_LIVER,ORGAN_SLOT_STOMACH),10)

/datum/quirk/bad_touch
	name = "Bad Touch"
	desc = "You don't like hugs. You'd really prefer if people just left you alone."
	mob_trait = TRAIT_BADTOUCH
	value = -1
	gain_text = "<span class='danger'>You just want people to leave you alone.</span>"
	lose_text = "<span class='notice'>You could use a big hug.</span>"
	medical_record_text = "Patient has disdain for being touched. Potentially has undiagnosed haphephobia."
	mood_quirk = TRUE
	hardcore_value = 1

/datum/quirk/bad_touch/add()
	RegisterSignal(quirk_holder, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HUGGED, COMSIG_CARBON_HEADPAT), .proc/uncomfortable_touch)

/datum/quirk/bad_touch/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HUGGED, COMSIG_CARBON_HEADPAT))

/datum/quirk/bad_touch/proc/uncomfortable_touch()
	SIGNAL_HANDLER

	new /obj/effect/temp_visual/annoyed(quirk_holder.loc)
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	if(mood.sanity <= SANITY_NEUTRAL)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "bad_touch", /datum/mood_event/very_bad_touch)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "bad_touch", /datum/mood_event/bad_touch)

#undef LOCATION_LPOCKET
#undef LOCATION_RPOCKET
#undef LOCATION_BACKPACK
#undef LOCATION_HANDS
