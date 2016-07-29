/mob/living/carbon/proc/has_breathing_mask()
	return istype(wear_mask, /obj/item/clothing/mask)

/mob/living/carbon/proc/internals_candidates() //These are checked IN ORDER.
	return get_all_slots() + held_items

/mob/living/carbon/human/internals_candidates() //Humans have a lot of slots, so let's give priority to some of them
	var/list/priority = list(s_store, back, belt, l_store, r_store)
	return priority | get_all_slots() | held_items //| operator ensures there are no duplicates

/mob/living/carbon/proc/get_internals_tank()
	for(var/obj/item/weapon/tank/T in internals_candidates())
		//We found a tank!
		if(istype(T, /obj/item/weapon/tank/jetpack)) //Oh... But it's a jetpack... We'll use it if we have to, but let's see if we find something better first
			if(!.) //We already had another jetpack
				. = T
			continue
		else //It's the real deal!
			return T

// Set internals on or off.
/mob/living/carbon/proc/toggle_internals(var/mob/living/user, var/obj/item/weapon/tank/T)
	if(internal)
		internal.add_fingerprint(user)
		internal = null
		if(internals) //This is the HUD icon, these variables have WAY too similar names
			internals.icon_state = "internal0"
		if(user != src)
			if(!user.isGoodPickpocket())
				visible_message("<span class='warning'>\The [user] shuts off \the [src]'s internals!</span>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has disabled [src.name]'s ([src.ckey]) internals.</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='red'>Internals disabled by [user.name] ([user.ckey]).</font>")
			log_attack("[user.name] ([user.ckey]) has disabled [src.name]'s ([src.ckey]) internals.")
		else
			to_chat(user, "<span class='notice'>No longer running on internals.</span>")
		return 1
	else
		if(!has_breathing_mask())
			if(user != src)
				to_chat(user, "<span class='warning'>\The [src] is not wearing a breathing mask.</span>")
			else
				to_chat(user, "<span class='warning'>You are not wearing a breathing mask.</span>")
			return
		if(!T || !T.Adjacent()) //We can be given a specific tank to connect to
			T = get_internals_tank()
			if(!T)
				var/breathes = OXYGEN
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					breathes = H.species.breath_type
				if(user != src)
					to_chat(user, "<span class='warning'>\The [src] does not have \an [breathes] tank.</span>")
				else
					to_chat(user, "<span class='warning'>You don't have \an [breathes] tank.</span>")
		internal = T
		T.add_fingerprint(user)
		if(internals)
			internals.icon_state = "internal1"
		if(user != src)
			var/gas_contents = T.air_contents.english_contents_list()
			if(!user.isGoodPickpocket())
				to_chat(user, "<span class='notice'>\The [user] has enabled [src]'s internals.</span>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has enabled [src.name]'s ([src.ckey]) internals (Gas contents: [gas_contents]).</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='red'>Internals enabled by [user.name] ([user.ckey]) (Gas contents: [gas_contents]).</font>")
			log_attack("[user.name] ([user.ckey]) has enabled [src.name]'s ([src.ckey]) internals (Gas contents: [gas_contents]).")
		else
			to_chat(src, "<span class='notice'>You are now running on internals from \the [T].</span>")
		return 1
