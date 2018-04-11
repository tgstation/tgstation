//every trait in this folder should be coded around being applied on spawn
//these are NOT "mob traits" like GOTTAGOFAST, but exist as a medium to apply them and other different effects
/datum/trait
	var/name = "Test Trait"
	var/desc = "This is a test trait."
	var/value = 0
	var/human_only = TRUE
	var/gain_text
	var/lose_text
	var/medical_record_text //This text will appear on medical records for the trait. Not yet implemented
	var/mood_trait = FALSE //if true, this trait affects mood and is unavailable if moodlets are disabled
	var/mob_trait //if applicable, apply and remove this mob trait
	var/mob/living/trait_holder

/datum/trait/New(mob/living/trait_mob, spawn_effects)
	..()
	if(!trait_mob || (human_only && !ishuman(trait_mob)) || trait_mob.has_trait_datum(type))
		qdel(src)
	trait_holder = trait_mob
	SStraits.trait_objects += src
	to_chat(trait_holder, gain_text)
	trait_holder.roundstart_traits += src
	if(mob_trait)
		trait_holder.add_trait(mob_trait, ROUNDSTART_TRAIT)
	START_PROCESSING(SStraits, src)
	add()
	if(spawn_effects)
		on_spawn()
		addtimer(CALLBACK(src, .proc/post_add), 30)

/datum/trait/Destroy()
	STOP_PROCESSING(SStraits, src)
	remove()
	if(trait_holder)
		to_chat(trait_holder, lose_text)
		trait_holder.roundstart_traits -= src
		if(mob_trait)
			trait_holder.remove_trait(mob_trait, ROUNDSTART_TRAIT, TRUE)
	SStraits.trait_objects -= src
	return ..()

/datum/trait/proc/transfer_mob(mob/living/to_mob)
	trait_holder.roundstart_traits -= src
	to_mob.roundstart_traits += src
	if(mob_trait)
		trait_holder.remove_trait(mob_trait, ROUNDSTART_TRAIT)
		to_mob.add_trait(mob_trait, ROUNDSTART_TRAIT)
	trait_holder = to_mob
	on_transfer()

/datum/trait/proc/add() //special "on add" effects
/datum/trait/proc/on_spawn() //these should only trigger when the character is being created for the first time, i.e. roundstart/latejoin
/datum/trait/proc/remove() //special "on remove" effects
/datum/trait/proc/on_process() //process() has some special checks, so this is the actual process
/datum/trait/proc/post_add() //for text, disclaimers etc. given after you spawn in with the trait
/datum/trait/proc/on_transfer() //code called when the trait is transferred to a new mob

/datum/trait/process()
	if(QDELETED(trait_holder))
		trait_holder = null
		qdel(src)
		return
	if(trait_holder.stat == DEAD)
		return
	on_process()

/mob/living/proc/get_trait_string(medical) //helper string. gets a string of all the traits the mob has
	var/list/dat = list()
	if(!medical)
		for(var/V in roundstart_traits)
			var/datum/trait/T = V
			dat += T.name
		if(!dat.len)
			return "None"
		return dat.Join(", ")
	else
		for(var/V in roundstart_traits)
			var/datum/trait/T = V
			dat += T.medical_record_text
		if(!dat.len)
			return "None"
		return dat.Join("<br>")

/mob/living/proc/cleanse_trait_datums() //removes all trait datums
	for(var/V in roundstart_traits)
		var/datum/trait/T = V
		qdel(T)

/mob/living/proc/transfer_trait_datums(mob/living/to_mob)
	for(var/V in roundstart_traits)
		var/datum/trait/T = V
		T.transfer_mob(to_mob)

/*

Commented version of Nearsighted to help you add your own traits
Use this as a guideline

/datum/trait/nearsighted
	name = "Nearsighted"
	///The trait's name

	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	///Short description, shows next to name in the trait panel

	value = -1
	///If this is above 0, it's a positive trait; if it's not, it's a negative one; if it's 0, it's a neutral

	mob_trait = TRAIT_NEARSIGHT
	///This define is in __DEFINES/traits.dm and is the actual "trait" that the game tracks
	///You'll need to use "has_trait(X, sources)" checks around the code to check this; for instance, the Ageusia trait is checked in taste code
	///If you need help finding where to put it, the declaration finder on GitHub is the best way to locate it

	gain_text = "<span class='danger'>Things far away from you start looking blurry.</span>"
	lose_text = "<span class='notice'>You start seeing faraway things normally again.</span>"
	medical_record_text = "Subject has permanent nearsightedness."
	///These three are self-explanatory

/datum/trait/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = trait_holder
	var/obj/item/clothing/glasses/regular/glasses = new(get_turf(H))
	H.put_in_hands(glasses)
	H.equip_to_slot(glasses, slot_glasses)
	H.regenerate_icons()

//This whole proc is called automatically
//It spawns a set of prescription glasses on the user, then attempts to put it into their hands, then attempts to make them equip it.
//This means that if they fail to equip it, they glasses spawn in their hands, and if they fail to be put into the hands, they spawn on the ground
//Hooray for fallbacks!
//If you don't need any special effects like spawning glasses, then you don't need an add()

*/
