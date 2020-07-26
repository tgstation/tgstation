//every quirk in this folder should be coded around being applied on spawn
//these are NOT "mob quirks" like GOTTAGOFAST, but exist as a medium to apply them and other different effects
/datum/quirk
	var/name = "Test Quirk"
	var/desc = "This is a test quirk."
	var/value = 0
	var/human_only = TRUE
	var/gain_text
	var/lose_text
	var/medical_record_text //This text will appear on medical records for the trait. Not yet implemented
	var/mood_quirk = FALSE //if true, this quirk affects mood and is unavailable if moodlets are disabled
	var/mob_trait //if applicable, apply and remove this mob trait
	///Amount of points this trait is worth towards the hardcore character mode; minus points implies a positive quirk, positive means its hard. This is used to pick the quirks assigned to a hardcore character. 0 means its not available to hardcore draws.
	var/hardcore_value = 0
	var/mob/living/quirk_holder

/datum/quirk/New(mob/living/quirk_mob, spawn_effects)
	..()
	if(!quirk_mob || (human_only && !ishuman(quirk_mob)) || quirk_mob.has_quirk(type))
		qdel(src)
		return
	quirk_holder = quirk_mob
	SSquirks.quirk_objects += src
	to_chat(quirk_holder, gain_text)
	quirk_holder.roundstart_quirks += src
	if(mob_trait)
		ADD_TRAIT(quirk_holder, mob_trait, ROUNDSTART_TRAIT)
	START_PROCESSING(SSquirks, src)
	add()
	if(spawn_effects)
		on_spawn()
	if(quirk_holder.client)
		post_add()
	else
		RegisterSignal(quirk_holder, COMSIG_MOB_LOGIN, .proc/on_quirk_holder_first_login)


/**
  * On client connection set quirk preferences.
  *
  * Run post_add to set the client preferences for the quirk.
  * Clear the attached signal for login.
  * Used when the quirk has been gained and no client is attached to the mob.
  */
/datum/quirk/proc/on_quirk_holder_first_login(mob/living/source)
		UnregisterSignal(source, COMSIG_MOB_LOGIN)
		post_add()

/datum/quirk/Destroy()
	STOP_PROCESSING(SSquirks, src)
	remove()
	if(quirk_holder)
		to_chat(quirk_holder, lose_text)
		quirk_holder.roundstart_quirks -= src
		if(mob_trait)
			REMOVE_TRAIT(quirk_holder, mob_trait, ROUNDSTART_TRAIT)
	SSquirks.quirk_objects -= src
	return ..()

/datum/quirk/proc/transfer_mob(mob/living/to_mob)
	quirk_holder.roundstart_quirks -= src
	to_mob.roundstart_quirks += src
	if(mob_trait)
		REMOVE_TRAIT(quirk_holder, mob_trait, ROUNDSTART_TRAIT)
		ADD_TRAIT(to_mob, mob_trait, ROUNDSTART_TRAIT)
	quirk_holder = to_mob
	on_transfer()

/datum/quirk/proc/add() //special "on add" effects
/datum/quirk/proc/on_spawn() //these should only trigger when the character is being created for the first time, i.e. roundstart/latejoin
/datum/quirk/proc/remove() //special "on remove" effects
/datum/quirk/proc/on_process() //process() has some special checks, so this is the actual process
/datum/quirk/proc/post_add() //for text, disclaimers etc. given after you spawn in with the trait
/datum/quirk/proc/on_transfer() //code called when the trait is transferred to a new mob

/datum/quirk/process()
	if(QDELETED(quirk_holder))
		quirk_holder = null
		qdel(src)
		return
	if(quirk_holder.stat == DEAD)
		return
	on_process()

/**
  * get_quirk_string() is used to get a printable string of all the quirk traits someone has for certain criteria
  *
  * Arguments:
  * * Medical- If we want the long, fancy descriptions that show up in medical records, or if not, just the name
  * * Category- Which types of quirks we want to print out. Defaults to everything
  */
/mob/living/proc/get_quirk_string(medical, category = CAT_QUIRK_ALL) //helper string. gets a string of all the quirks the mob has
	var/list/dat = list()
	switch(category)
		if(CAT_QUIRK_ALL)
			for(var/V in roundstart_quirks)
				var/datum/quirk/T = V
				dat += medical ? T.medical_record_text : T.name
		//Major Disabilities
		if(CAT_QUIRK_MAJOR_DISABILITY)
			for(var/V in roundstart_quirks)
				var/datum/quirk/T = V
				if(T.value < -1)
					dat += medical ? T.medical_record_text : T.name
		//Minor Disabilities
		if(CAT_QUIRK_MINOR_DISABILITY)
			for(var/V in roundstart_quirks)
				var/datum/quirk/T = V
				if(T.value == -1)
					dat += medical ? T.medical_record_text : T.name
		//Neutral and Positive quirks
		if(CAT_QUIRK_NOTES)
			for(var/V in roundstart_quirks)
				var/datum/quirk/T = V
				if(T.value > -1)
					dat += medical ? T.medical_record_text : T.name
	if(!dat.len)
		return medical ? "No issues have been declared." : "None"
	return medical ?  dat.Join("<br>") : dat.Join(", ")

/mob/living/proc/cleanse_trait_datums() //removes all trait datums
	for(var/V in roundstart_quirks)
		var/datum/quirk/T = V
		qdel(T)

/mob/living/proc/transfer_trait_datums(mob/living/to_mob)
	for(var/V in roundstart_quirks)
		var/datum/quirk/T = V
		T.transfer_mob(to_mob)

/*

Commented version of Nearsighted to help you add your own traits
Use this as a guideline

/datum/quirk/nearsighted
	name = "Nearsighted"
	///The trait's name

	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	///Short description, shows next to name in the trait panel

	value = -1
	///If this is above 0, it's a positive trait; if it's not, it's a negative one; if it's 0, it's a neutral

	mob_trait = TRAIT_NEARSIGHT
	///This define is in __DEFINES/traits.dm and is the actual "trait" that the game tracks
	///You'll need to use "HAS_TRAIT_FROM(src, X, sources)" checks around the code to check this; for instance, the Ageusia trait is checked in taste code
	///If you need help finding where to put it, the declaration finder on GitHub is the best way to locate it

	gain_text = "<span class='danger'>Things far away from you start looking blurry.</span>"
	lose_text = "<span class='notice'>You start seeing faraway things normally again.</span>"
	medical_record_text = "Subject has permanent nearsightedness."
	///These three are self-explanatory

/datum/quirk/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/regular/glasses = new(get_turf(H))
	H.put_in_hands(glasses)
	H.equip_to_slot(glasses, ITEM_SLOT_EYES)
	H.regenerate_icons()

//This whole proc is called automatically
//It spawns a set of prescription glasses on the user, then attempts to put it into their hands, then attempts to make them equip it.
//This means that if they fail to equip it, they glasses spawn in their hands, and if they fail to be put into the hands, they spawn on the ground
//Hooray for fallbacks!
//If you don't need any special effects like spawning glasses, then you don't need an add()

*/
