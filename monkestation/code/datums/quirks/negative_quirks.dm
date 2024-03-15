/datum/quirk/jailbird
	name = "Jailbird"
	desc = "You're a ex-criminal! You start the round set to parole for a random crime."
	value = 0
	icon = FA_ICON_CROW

/datum/quirk/jailbird/add_to_holder(mob/living/new_holder, quirk_transfer, client/client_source)
	// Don't bother adding to ghost players
	if(istype(new_holder, /mob/living/carbon/human/ghost))
		qdel(src)
		return FALSE
	return ..()

/datum/quirk/jailbird/post_add()
	. = ..()
	var/mob/living/carbon/human/jailbird = quirk_holder
	var/quirk_crime	= pick(world.file2list("monkestation/strings/random_crimes.txt"))
	to_chat(jailbird, "<span class='boldnotice'>You are on parole for the crime of: [quirk_crime]!</span>")
	addtimer(CALLBACK(src, PROC_REF(apply_arrest), quirk_crime), 10 SECONDS)


/datum/quirk/jailbird/proc/apply_arrest(crime_name)
	var/mob/living/carbon/human/jailbird = quirk_holder
	jailbird.mind.memories += "You have the law on your back because of your crime of: [crime_name]!"
	var/crime = "[pick(world.file2list("monkestation/strings/random_police.txt"))] [(rand(9)+1)] [pick("days", "weeks", "months", "years")] ago"
	var/perpname = jailbird.real_name
	var/datum/record/crew/jailbird_record = find_record(perpname)
	// remove quirk if we don't even have a record
	if(QDELETED(jailbird_record))
		qdel(src)
		return
	var/datum/crime/new_crime = new(name = crime_name, details = crime, author = "Nanotrasen Bounty Department")
	jailbird_record.crimes += new_crime
	jailbird_record.wanted_status = WANTED_PAROLE
	jailbird.sec_hud_set_security_status()

/datum/quirk/stowaway
	name = "Stowaway"
	desc = "You wake up up inside a random locker with only a crude fake for an ID card."
	value = -2
	icon = FA_ICON_SUITCASE

/datum/quirk/stowaway/add_unique()
	. = ..()
	var/mob/living/carbon/human/stowaway = quirk_holder
	stowaway.Sleeping(5 SECONDS, TRUE, TRUE) //This is both flavorful and gives time for the rest of the code to work.
	var/obj/item/card/id/trashed = stowaway.get_item_by_slot(ITEM_SLOT_ID) //No ID
	qdel(trashed)

	var/obj/item/card/id/fake_card/card = new(get_turf(quirk_holder)) //a fake ID with two uses for maint doors
	quirk_holder.equip_to_slot_if_possible(card, ITEM_SLOT_ID)
	card.register_name(quirk_holder.real_name)

	if(prob(20))
		stowaway.adjust_drunk_effect(50) //What did I DO last night?
	var/obj/structure/closet/selected_closet = get_unlocked_closed_locker() //Find your new home
	if(selected_closet)
		stowaway.forceMove(selected_closet) //Move in

/datum/quirk/stowaway/post_add()
	. = ..()
	to_chat(quirk_holder, span_boldnotice("You've awoken to find yourself inside [GLOB.station_name] without real identification!"))
	addtimer(CALLBACK(src, PROC_REF(datacore_deletion)), 5 SECONDS)

/datum/quirk/stowaway/proc/datacore_deletion()
	var/mob/living/carbon/human/stowaway = quirk_holder
	var/perpname = stowaway.name
	var/datum/record/crew/record_deletion = find_record(perpname, GLOB.manifest.general)
	SSjob.FreeRole(quirk_holder.mind.assigned_role)  //open their job slot back up
	qdel(record_deletion)

/obj/item/card/id/fake_card //not a proper ID but still shares a lot of functions
	name = "\"ID Card\""
	desc = "Definitely a legitimate ID card and not a piece of notebook paper with a magnetic strip drawn on it. You'd have to stuff this in a card reader by hand for it to work."
	icon = 'icons/obj/card.dmi'
	icon_state = "counterfeit"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	resistance_flags = FIRE_PROOF | ACID_PROOF
	registered_account = null
	accepts_accounts = FALSE
	registered_name = "Nohbdy"
	access = list(ACCESS_MAINT_TUNNELS)
	var/uses = 2

/obj/item/card/id/fake_card/proc/register_name(new_name)
	registered_name = new_name
	name = "[new_name]'s \"ID Card\""

/obj/item/card/id/fake_card/proc/used()
	uses -= 1
	switch(uses)
		if(0)
			icon_state = "counterfeit_torn2"
		if(1)
			icon_state = "counterfeit_torn"
		else
			icon_state = "counterfeit" //in case you somehow repair it to 3+

/obj/item/card/id/fake_card/AltClick(mob/living/user)
	return //no accounts on fake cards

/obj/item/card/id/fake_card/examine(mob/user)
	. = ..()
	switch(uses)
		if(0)
			. += "It's too shredded to fit in a scanner!"
		if(1)
			. += "It's falling apart!"
		else
			. += "It looks frail!"

//Used to get a random closed and non-secure locker on the station z-level, created for the Stowaway trait.
/proc/get_unlocked_closed_locker() //I've seen worse proc names
	var/list/picked_lockers = list()
	var/turf/object_location
	for(var/obj/structure/closet/find_closet in world)
		if(!istype(find_closet,/obj/structure/closet/secure_closet))
			object_location = get_turf(find_closet)
			if(object_location) //If it can't read a Z on the next step, it will error out. Needs a separate check.
				if(is_station_level(object_location.z) && !find_closet.opened) //On the station and closed.
					picked_lockers += find_closet
	if(picked_lockers)
		return pick(picked_lockers)
	return FALSE

/datum/quirk/kleptomaniac
	name = "Kleptomaniac"
	desc = "The station's just full of free stuff!  Nobody would notice if you just... took it, right?"
	mob_trait = TRAIT_KLEPTOMANIAC
	value = -2
	icon = FA_ICON_BAG_SHOPPING

/datum/quirk/kleptomaniac/add()
	var/datum/brain_trauma/mild/kleptomania/T = new()
	var/mob/living/carbon/human/H = quirk_holder
	H.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/kleptomaniac/remove()
	var/mob/living/carbon/human/H = quirk_holder
	H.cure_trauma_type(/datum/brain_trauma/mild/kleptomania, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/unstable_ass
	name = "Unstable Rear"
	desc = "For reasons unknown, your posterior is unstable and will fall off more often."
	value = -1
	icon = FA_ICON_BOMB
	//All effects are handled directly in butts.dm

//IPC PUNISHMENT SYSTEM//
/datum/quirk/frail/add()
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	if(isipc(quirk_holder))
		human_quirk_holder.physiology.brute_mod *= 1.3
		human_quirk_holder.physiology.burn_mod *= 1.3

/datum/quirk/frail/post_add()
	if(isipc(quirk_holder))
		to_chat(quirk_holder, span_boldnotice("Your chassis feels frail."))

/datum/quirk/light_drinker/add()
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	if(isipc(quirk_holder))
		human_quirk_holder.physiology.brute_mod *= 1.1
		human_quirk_holder.physiology.burn_mod *= 1.1

/datum/quirk/light_drinker/post_add()
	if(isipc(quirk_holder))
		to_chat(quirk_holder, span_boldnotice("Your chassis feels very slightly weaker."))

/datum/quirk/prosthetic_limb/add()
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	if(isipc(quirk_holder))
		human_quirk_holder.physiology.brute_mod *= 1.15
		human_quirk_holder.physiology.burn_mod *= 1.15

/datum/quirk/prosthetic_limb/post_add()
	if(isipc(quirk_holder))
		to_chat(quirk_holder, span_boldnotice("Your chassis feels slightly weaker."))

/datum/quirk/quadruple_amputee/add() //monkestation addition
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	if(isipc(quirk_holder))
		human_quirk_holder.physiology.brute_mod *= 1.3
		human_quirk_holder.physiology.burn_mod *= 1.3

/datum/quirk/quadruple_amputee/post_add()
	if(isipc(quirk_holder)) //monkestation addition
		to_chat(quirk_holder, span_boldnotice("Your chassis feels frail."))

/datum/quirk/item_quirk/allergic/add() //monkestation addition
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	if(isipc(quirk_holder))
		human_quirk_holder.physiology.brute_mod *= 1.3
		human_quirk_holder.physiology.burn_mod *= 1.3

/datum/quirk/item_quirk/allergic/post_add()
	if(isipc(quirk_holder)) //monkestation addition
		to_chat(quirk_holder, span_boldnotice("Your chassis feels frail."))

