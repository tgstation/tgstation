//traits with no real impact that can be taken freely
//MAKE SURE THESE DO NOT MAJORLY IMPACT GAMEPLAY. those should be positive or negative traits.

/datum/quirk/extrovert
	name = "Extrovert"
	desc = "You are energized by talking to others, and enjoy spending your free time in the bar."
	icon = "users"
	value = 0
	mob_trait = TRAIT_EXTROVERT
	gain_text = "<span class='notice'>You feel like hanging out with other people.</span>"
	lose_text = "<span class='danger'>You feel like you're over the bar scene.</span>"
	medical_record_text = "Patient will not shut the hell up."

/datum/quirk/introvert
	name = "Introvert"
	desc = "You are energized by having time to yourself, and enjoy spending your free time in the library."
	icon = "book-reader"
	value = 0
	mob_trait = TRAIT_INTROVERT
	gain_text = "<span class='notice'>You feel like reading a good book quietly.</span>"
	lose_text = "<span class='danger'>You feel like libraries are boring.</span>"
	medical_record_text = "Patient doesn't seem to say much."

/datum/quirk/no_taste
	name = "Ageusia"
	desc = "You can't taste anything! Toxic food will still poison you."
	icon = "meh-blank"
	value = 0
	mob_trait = TRAIT_AGEUSIA
	gain_text = "<span class='notice'>You can't taste anything!</span>"
	lose_text = "<span class='notice'>You can taste again!</span>"
	medical_record_text = "Patient suffers from ageusia and is incapable of tasting food or reagents."

/datum/quirk/foreigner
	name = "Foreigner"
	desc = "You're not from around here. You don't know Galactic Common!"
	icon = "language"
	value = 0
	gain_text = "<span class='notice'>The words being spoken around you don't make any sense."
	lose_text = "<span class='notice'>You've developed fluency in Galactic Common."
	medical_record_text = "Patient does not speak Galactic Common and may require an interpreter."

/datum/quirk/foreigner/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.add_blocked_language(/datum/language/common)
	if(ishumanbasic(human_holder))
		human_holder.grant_language(/datum/language/uncommon)

/datum/quirk/foreigner/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.remove_blocked_language(/datum/language/common)
	if(ishumanbasic(human_holder))
		human_holder.remove_language(/datum/language/uncommon)

/datum/quirk/vegetarian
	name = "Vegetarian"
	desc = "You find the idea of eating meat morally and physically repulsive."
	icon = "carrot"
	value = 0
	gain_text = "<span class='notice'>You feel repulsion at the idea of eating meat.</span>"
	lose_text = "<span class='notice'>You feel like eating meat isn't that bad.</span>"
	medical_record_text = "Patient reports a vegetarian diet."

/datum/quirk/vegetarian/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/datum/species/species = human_holder.dna.species
	species.liked_food &= ~MEAT
	species.disliked_food |= MEAT
	RegisterSignal(human_holder, COMSIG_SPECIES_GAIN, .proc/on_species_gain)

/datum/quirk/vegetarian/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER
	new_species.liked_food &= ~MEAT
	new_species.disliked_food |= MEAT

/datum/quirk/vegetarian/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder

	var/datum/species/species = human_holder.dna.species
	if(initial(species.liked_food) & MEAT)
		species.liked_food |= MEAT
	if(!(initial(species.disliked_food) & MEAT))
		species.disliked_food &= ~MEAT
	UnregisterSignal(human_holder, COMSIG_SPECIES_GAIN)

/datum/quirk/snob
	name = "Snob"
	desc = "You care about the finer things, if a room doesn't look nice its just not really worth it, is it?"
	icon = "user-tie"
	value = 0
	gain_text = "<span class='notice'>You feel like you understand what things should look like.</span>"
	lose_text = "<span class='notice'>Well who cares about deco anyways?</span>"
	medical_record_text = "Patient seems to be rather stuck up."
	mob_trait = TRAIT_SNOB

/datum/quirk/pineapple_liker
	name = "Ananas Affinity"
	desc = "You find yourself greatly enjoying fruits of the ananas genus. You can't seem to ever get enough of their sweet goodness!"
	icon = "thumbs-up"
	value = 0
	gain_text = "<span class='notice'>You feel an intense craving for pineapple.</span>"
	lose_text = "<span class='notice'>Your feelings towards pineapples seem to return to a lukewarm state.</span>"
	medical_record_text = "Patient demonstrates a pathological love of pineapple."

/datum/quirk/pineapple_liker/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/datum/species/species = human_holder.dna.species
	species.liked_food |= PINEAPPLE
	RegisterSignal(human_holder, COMSIG_SPECIES_GAIN, .proc/on_species_gain)

/datum/quirk/pineapple_liker/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER
	new_species.liked_food |= PINEAPPLE

/datum/quirk/pineapple_liker/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/datum/species/species = human_holder.dna.species
	species.liked_food &= ~PINEAPPLE
	UnregisterSignal(human_holder, COMSIG_SPECIES_GAIN)

/datum/quirk/pineapple_hater
	name = "Ananas Aversion"
	desc = "You find yourself greatly detesting fruits of the ananas genus. Serious, how the hell can anyone say these things are good? And what kind of madman would even dare putting it on a pizza!?"
	icon = "thumbs-down"
	value = 0
	gain_text = "<span class='notice'>You find yourself pondering what kind of idiot actually enjoys pineapples...</span>"
	lose_text = "<span class='notice'>Your feelings towards pineapples seem to return to a lukewarm state.</span>"
	medical_record_text = "Patient is correct to think that pineapple is disgusting."

/datum/quirk/pineapple_hater/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/datum/species/species = human_holder.dna.species
	species.disliked_food |= PINEAPPLE
	RegisterSignal(human_holder, COMSIG_SPECIES_GAIN, .proc/on_species_gain)

/datum/quirk/pineapple_hater/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER
	new_species.disliked_food |= PINEAPPLE

/datum/quirk/pineapple_hater/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/datum/species/species = human_holder.dna.species
	species.disliked_food &= ~PINEAPPLE
	UnregisterSignal(human_holder, COMSIG_SPECIES_GAIN)

/datum/quirk/deviant_tastes
	name = "Deviant Tastes"
	desc = "You dislike food that most people enjoy, and find delicious what they don't."
	icon = "grin-tongue-squint"
	value = 0
	gain_text = "<span class='notice'>You start craving something that tastes strange.</span>"
	lose_text = "<span class='notice'>You feel like eating normal food again.</span>"
	medical_record_text = "Patient demonstrates irregular nutrition preferences."

/datum/quirk/deviant_tastes/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/datum/species/species = human_holder.dna.species
	var/liked = species.liked_food
	species.liked_food = species.disliked_food
	species.disliked_food = liked
	RegisterSignal(human_holder, COMSIG_SPECIES_GAIN, .proc/on_species_gain)

/datum/quirk/deviant_tastes/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER
	var/liked = new_species.liked_food
	new_species.liked_food = new_species.disliked_food
	new_species.disliked_food = liked

/datum/quirk/deviant_tastes/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/datum/species/species = human_holder.dna.species
	species.liked_food = initial(species.liked_food)
	species.disliked_food = initial(species.disliked_food)
	UnregisterSignal(human_holder, COMSIG_SPECIES_GAIN)

/datum/quirk/monochromatic
	name = "Monochromacy"
	desc = "You suffer from full colorblindness, and perceive nearly the entire world in blacks and whites."
	icon = "adjust"
	value = 0
	medical_record_text = "Patient is afflicted with almost complete color blindness."

/datum/quirk/monochromatic/add()
	quirk_holder.add_client_colour(/datum/client_colour/monochrome)

/datum/quirk/monochromatic/post_add()
	if(is_detective_job(quirk_holder.mind.assigned_role))
		to_chat(quirk_holder, span_boldannounce("Mmm. Nothing's ever clear on this station. It's all shades of gray..."))
		quirk_holder.playsound_local(quirk_holder, 'sound/ambience/ambidet1.ogg', 50, FALSE)

/datum/quirk/monochromatic/remove()
	quirk_holder.remove_client_colour(/datum/client_colour/monochrome)

/datum/quirk/phobia
	name = "Phobia"
	desc = "You are irrationally afraid of something."
	icon = "spider"
	value = 0
	medical_record_text = "Patient has an irrational fear of something."
	var/phobia

/datum/quirk/phobia/add()
	phobia = phobia || quirk_holder.client?.prefs?.read_preference(/datum/preference/choiced/phobia)

	if(phobia)
		var/mob/living/carbon/human/human_holder = quirk_holder
		human_holder.gain_trauma(new /datum/brain_trauma/mild/phobia(phobia), TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/phobia/post_add()
	if(!phobia)
		var/mob/living/carbon/human/human_holder = quirk_holder
		phobia = human_holder.client.prefs.read_preference(/datum/preference/choiced/phobia)
		human_holder.gain_trauma(new /datum/brain_trauma/mild/phobia(phobia), TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/phobia/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/mild/phobia, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/item_quirk/needswayfinder
	name = "Navigationally Challenged"
	desc = "Lacking familiarity with certain stations, you start with a wayfinding pinpointer where available."
	icon = "route"
	value = 0
	medical_record_text = "Patient demonstrates a keen ability to get lost."

/datum/quirk/item_quirk/needswayfinder/add_unique()
	if(!GLOB.wayfindingbeacons.len)
		return

	var/mob/living/carbon/human/human_holder = quirk_holder

	var/obj/item/pinpointer/wayfinding/wayfinder = new(get_turf(quirk_holder))
	wayfinder.owner = human_holder.real_name
	wayfinder.from_quirk = TRUE

	give_item_to_holder(wayfinder, list(LOCATION_LPOCKET = ITEM_SLOT_LPOCKET, LOCATION_RPOCKET = ITEM_SLOT_RPOCKET, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/shifty_eyes
	name = "Shifty Eyes"
	desc = "Your eyes tend to wander all over the place, whether you mean to or not, causing people to sometimes think you're looking directly at them when you aren't."
	icon = "far fa-eye"
	value = 0
	medical_record_text = "Fucking creep kept staring at me the whole damn checkup. I'm only diagnosing this because it's less awkward than thinking it was on purpose."
	mob_trait = TRAIT_SHIFTY_EYES

/datum/quirk/item_quirk/bald
	name = "Smooth-Headed"
	desc = "You have no hair and are quite insecure about it! Keep your wig on, or at least your head covered up."
	icon = "egg"
	value = 0
	mob_trait = TRAIT_BALD
	gain_text = "<span class='notice'>Your head is as smooth as can be, it's terrible.</span>"
	lose_text = "<span class='notice'>Your head itches, could it be... growing hair?!</span>"
	medical_record_text = "Patient starkly refused to take off headwear during examination."
	/// The user's starting hairstyle
	var/old_hair

/datum/quirk/item_quirk/bald/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	old_hair = human_holder.hairstyle
	human_holder.hairstyle = "Bald"
	human_holder.update_hair()
	RegisterSignal(human_holder, COMSIG_CARBON_EQUIP_HAT, .proc/equip_hat)
	RegisterSignal(human_holder, COMSIG_CARBON_UNEQUIP_HAT, .proc/unequip_hat)

/datum/quirk/item_quirk/bald/add_unique()
	var/obj/item/clothing/head/wig/natural/baldie_wig = new(get_turf(quirk_holder))

	if (old_hair == "Bald")
		baldie_wig.hairstyle = pick(GLOB.hairstyles_list - "Bald")
	else
		baldie_wig.hairstyle = old_hair

	baldie_wig.update_appearance()

	give_item_to_holder(baldie_wig, list(LOCATION_HEAD = ITEM_SLOT_HEAD, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/bald/remove()
	. = ..()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.hairstyle = old_hair
	human_holder.update_hair()
	UnregisterSignal(human_holder, list(COMSIG_CARBON_EQUIP_HAT, COMSIG_CARBON_UNEQUIP_HAT))
	SEND_SIGNAL(human_holder, COMSIG_CLEAR_MOOD_EVENT, "bad_hair_day")

///Checks if the headgear equipped is a wig and sets the mood event accordingly
/datum/quirk/item_quirk/bald/proc/equip_hat(mob/user, obj/item/hat)
	SIGNAL_HANDLER

	if(istype(hat, /obj/item/clothing/head/wig))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "bad_hair_day", /datum/mood_event/confident_mane) //Our head is covered, but also by a wig so we're happy.
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "bad_hair_day") //Our head is covered

///Applies a bad moodlet for having an uncovered head
/datum/quirk/item_quirk/bald/proc/unequip_hat(mob/user, obj/item/clothing, force, newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER

	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "bad_hair_day", /datum/mood_event/bald)

/datum/quirk/item_quirk/tongue_tied
	name = "Tongue Tied"
	desc = "Due to a past incident, your ability to communicate has been relegated to your hands."
	icon = "sign-language"
	value = 0
	medical_record_text = "During physical examination, patient's tongue was found to be uniquely damaged."

/datum/quirk/item_quirk/tongue_tied/add_unique()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/tongue/old_tongue = human_holder.getorganslot(ORGAN_SLOT_TONGUE)
	old_tongue.Remove(human_holder)
	qdel(old_tongue)

	var/obj/item/organ/tongue/tied/new_tongue = new(get_turf(human_holder))
	new_tongue.Insert(human_holder)
	// Only tongues of people with this quirk can't be removed. Manually spawned or found tongues can be.
	new_tongue.organ_flags |= ORGAN_UNREMOVABLE

	give_item_to_holder(/obj/item/clothing/gloves/radio, list(LOCATION_GLOVES = ITEM_SLOT_GLOVES, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/tongue_tied/post_add()
	to_chat(quirk_holder, span_boldannounce("Because you speak with your hands, having them full hinders your ability to communicate!"))

/datum/quirk/item_quirk/photographer
	name = "Photographer"
	desc = "You carry your camera and personal photo album everywhere you go, and your scrapbooks are legendary among your coworkers."
	icon = "camera"
	value = 0
	mob_trait = TRAIT_PHOTOGRAPHER
	gain_text = "<span class='notice'>You know everything about photography.</span>"
	lose_text = "<span class='danger'>You forget how photo cameras work.</span>"
	medical_record_text = "Patient mentions photography as a stress-relieving hobby."

/datum/quirk/item_quirk/photographer/add_unique()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/storage/photo_album/personal/photo_album = new(get_turf(human_holder))
	photo_album.persistence_id = "personal_[human_holder.last_mind?.key]" // this is a persistent album, the ID is tied to the account's key to avoid tampering
	photo_album.persistence_load()
	photo_album.name = "[human_holder.real_name]'s photo album"

	give_item_to_holder(photo_album, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
	give_item_to_holder(
		/obj/item/camera,
		list(
			LOCATION_NECK = ITEM_SLOT_NECK,
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS
		)
	)

/datum/quirk/item_quirk/colorist
	name = "Colorist"
	desc = "You like carrying around a hair dye spray to quickly apply color patterns to your hair."
	icon = "fill-drip"
	value = 0
	medical_record_text = "Patient enjoys dyeing their hair with pretty colors."

/datum/quirk/item_quirk/colorist/add_unique()
	give_item_to_holder(/obj/item/dyespray, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
