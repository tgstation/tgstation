/mob/living/silicon/robot/proc/borg_clear_radio()

	if(!istype(radio.keyslot)) //sanity
		return FALSE

	if(!istype(radio.keyslot, /obj/item/encryptionkey/borg)) //We only delete if we have a borg encryption key; eject otherwise.
		var/atom/T = drop_location()//To hopefully prevent run time errors.
		radio.keyslot.forceMove(T)
		radio.keyslot = null
		radio.recalculateChannels()
		return FALSE

	QDEL_NULL(radio.keyslot)
	radio.keyslot = null
	radio.recalculateChannels()

	return TRUE

/obj/item/robot_module/proc/borg_set_radio(radio_channel) //We add the appropriate encryption key and subspace channels
	if(!loc || !istype(loc, /mob/living/silicon/robot)) //Sanity
		return

	var/mob/living/silicon/robot/R = loc

	if(!istype(R, /mob/living/silicon/robot))
		return

	if(R.radio.keyslot) //If there's already something there, abort.
		return

	if(!radio_channel) //If we don't have a channel, get one
		radio_channel = R.borg_determine_channel()

	if(!radio_channel) //If we somehow still don't have a channel abort.
		return

	R.radio.keyslot = new /obj/item/encryptionkey/borg
	R.radio.keyslot.channels = list(radio_channel)
	R.radio.keyslot.channels[radio_channel] |= 1
	desc = "A standard encryption key for a cyborg. Typically programmed with an appropriate departmental access."

	R.radio.subspace_transmission = TRUE
	R.radio.recalculateChannels()
	return TRUE

/mob/living/silicon/robot/proc/borg_determine_channel()
	if(!module) //sanity
		return FALSE

	if(istype(module, /obj/item/robot_module/medical))
		return RADIO_CHANNEL_MEDICAL
	if(istype(module, /obj/item/robot_module/engineering))
		return RADIO_CHANNEL_ENGINEERING
	if(istype(module, /obj/item/robot_module/security))
		return RADIO_CHANNEL_SECURITY
	if(istype(module, /obj/item/robot_module/peacekeeper))
		return RADIO_CHANNEL_SECURITY
	if(istype(module, /obj/item/robot_module/miner))
		return RADIO_CHANNEL_SUPPLY
	if(istype(module, /obj/item/robot_module/standard))
		return RADIO_CHANNEL_SERVICE
	if(istype(module, /obj/item/robot_module/janitor))
		return RADIO_CHANNEL_SERVICE
	if(istype(module, /obj/item/robot_module/clown))
		return RADIO_CHANNEL_SERVICE
	if(istype(module, /obj/item/robot_module/butler))
		return RADIO_CHANNEL_SERVICE
	if(istype(module, /obj/item/robot_module/syndicate))
		return RADIO_CHANNEL_SYNDICATE
	if(istype(module, /obj/item/robot_module/syndicate_medical))
		return RADIO_CHANNEL_SYNDICATE
	if(istype(module, /obj/item/robot_module/saboteur))
		return RADIO_CHANNEL_SYNDICATE

/obj/item/radio/borg/proc/reactivate_integrated_borg_key(user)

	var/mob/living/silicon/robot/R = loc
	var/message = "<span class='warning'>This radio doesn't have any encryption keys!</span>"
	if(istype(R, /mob/living/silicon/robot) && R.module)
		var/obj/item/robot_module/M = R.module
		if(M.borg_set_radio())
			message = "<span class='notice'>You reactivate [R]'s integrated encryption key.</span>"

	to_chat(user, "[message]")

/obj/item/radio/borg/proc/deactivate_integrated_borg_key(user)
	var/mob/living/silicon/robot/R = loc
	if(!R)
		return FALSE
	if(R.borg_clear_radio())
		to_chat(user, "<span class='notice'>You deactivate the integrated encryption key.</span>")
		return TRUE

/obj/item/encryptionkey/borg
	name = "borg general encryption key"
	icon_state = "bin_cypherkey"