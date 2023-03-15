/datum/quirk/jailbird
	name = "Jailbird"
	desc = "You're a wanted criminal! You start the round set to arrest for a random crime."
	value = -1

/datum/quirk/jailbird/post_add()
	. = ..()
	var/mob/living/carbon/human/jailbird = quirk_holder
	var/quirk_crime	= pick(world.file2list("monkestation/strings/random_crimes.txt"))
	to_chat(jailbird, "<span class='boldnotice'>You are on the run for your crime of: [quirk_crime]!</span>")
	addtimer(CALLBACK(src, .proc/apply_arrest, quirk_crime), 5 SECONDS)


/datum/quirk/jailbird/proc/apply_arrest(crime_name)
	var/mob/living/carbon/human/jailbird = quirk_holder
	jailbird.mind.store_memory("You have the law on your back because of your crime of: [crime_name]!")
	var/crime = GLOB.data_core.createCrimeEntry(crime_name, "Galactic Crime Broadcast", "[pick(world.file2list("monkestation/strings/random_police.txt"))]", "[(rand(9)+1)] [pick("days", "weeks", "months", "years")] ago", 0)
	var/perpname = jailbird.name
	var/datum/data/record/jailbird_record = find_record("name", perpname, GLOB.data_core.security)

	GLOB.data_core.addCrime(jailbird_record.fields["id"], crime)
	jailbird_record.fields["criminal"] = "Arrest"
	jailbird.sec_hud_set_security_status()

/datum/quirk/stowaway
	name = "Stowaway"
	desc = "You wake up up inside a random locker with only a crude fake for an ID card."
	value = -2

/datum/quirk/stowaway/on_spawn()
	. = ..()
	var/mob/living/carbon/human/stowaway = quirk_holder
	stowaway.Sleeping(5 SECONDS, TRUE, TRUE) //This is both flavorful and gives time for the rest of the code to work.
	var/obj/item/card/id/trashed = stowaway.get_item_by_slot(ITEM_SLOT_ID) //No ID
	qdel(trashed)

	var/obj/item/card/id/fake_card/card = new(get_turf(quirk_holder)) //a fake ID with two uses for maint doors
	quirk_holder.equip_to_slot_if_possible(card, ITEM_SLOT_ID)
	card.register_name(quirk_holder.real_name)

	if(prob(20))
		stowaway.drunkenness = 50 //What did I DO last night?
	var/obj/structure/closet/selected_closet = get_unlocked_closed_locker() //Find your new home
	if(selected_closet)
		stowaway.forceMove(selected_closet) //Move in

/datum/quirk/stowaway/post_add()
	. = ..()
	to_chat(quirk_holder, "<span class='boldnotice'>You've awoken to find yourself inside [GLOB.station_name] without real identification!</span>")
	addtimer(CALLBACK(src, .proc/datacore_deletion), 5 SECONDS)

/datum/quirk/stowaway/proc/datacore_deletion()
	var/mob/living/carbon/human/stowaway = quirk_holder
	var/perpname = stowaway.name
	var/datum/data/record/record_deletion = find_record("name", perpname, GLOB.data_core.general)
	SSjob.FreeRole(quirk_holder.mind.assigned_role)  //open their job slot back up
	qdel(record_deletion)

/datum/quirk/unstable_ass
	name = "Unstable Rear"
	desc = "For reasons unknown, your posterior is unstable and will fall off more often."
	value = -1
	//All effects are handled directly in butts.dm

/datum/quirk/kleptomaniac
	name = "Kleptomaniac"
	desc = "The station's just full of free stuff!  Nobody would notice if you just... took it, right?"
	mob_trait = TRAIT_KLEPTOMANIAC
	value = -2

/datum/quirk/kleptomaniac/add()
	var/datum/brain_trauma/mild/kleptomania/T = new()
	var/mob/living/carbon/human/H = quirk_holder
	H.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/kleptomaniac/remove()
	var/mob/living/carbon/human/H = quirk_holder
	H.cure_trauma_type(/datum/brain_trauma/mild/kleptomania, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/fluffy_tongue
	name = "Fluffy Tongue"
	desc = "After spending too much time watching anime you have developed a horrible speech impediment."
	value = 5

/datum/quirk/fluffy_tongue/on_spawn()
	RegisterSignal(quirk_holder, COMSIG_MOB_SAY, .proc/handle_speech)

/datum/quirk/fluffy_tongue/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_SAY)


/datum/quirk/fluffy_tongue/proc/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = replacetext(message, "ne", "nye")
		message = replacetext(message, "nu", "nyu")
		message = replacetext(message, "na", "nya")
		message = replacetext(message, "no", "nyo")
		message = replacetext(message, "ove", "uv")
		message = replacetext(message, "r", "w")
		message = replacetext(message, "l", "w")
	speech_args[SPEECH_MESSAGE] = message

/datum/quirk/no_soul
	name = "No Soul"
	desc = "For some reason electronics and sensors tend not to respond to you.  You have to open airlocks by hand."
	value = -1
	//Effects are handled directly in door.dm
