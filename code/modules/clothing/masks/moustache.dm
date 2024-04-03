/obj/item/clothing/mask/fakemoustache
	name = "fake moustache"
	desc = "Warning: moustache is fake."
	icon_state = "fake-moustache"
	alternate_worn_layer = ABOVE_BODY_FRONT_HEAD_LAYER
	w_class = WEIGHT_CLASS_TINY
	flags_inv = HIDEFACE
	species_exception = list(/datum/species/golem)

/obj/item/clothing/mask/fakemoustache/italian
	name = "italian moustache"
	desc = "Made from authentic Italian moustache hairs. Gives the wearer an irresistable urge to gesticulate wildly."
	modifies_speech = TRUE

/obj/item/clothing/mask/fakemoustache/italian/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/italian_words = strings("italian_replacement.json", "italian")

		for(var/key in italian_words)
			var/value = italian_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		if(prob(3))
			message += pick(" Ravioli, ravioli, give me the formuoli!"," Mamma-mia!"," Mamma-mia! That's a spicy meat-ball!", " La la la la la funiculi funicula!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/obj/item/clothing/mask/gas/fakemoustache/syndicate
	name = "fake moustache"
	desc = "Warning: moustache is fake."
	icon_state = "fake-moustache"
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/fakemoustache/syndicate
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = PEPPERPROOF
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	//var/obj/item/clothing/mask/cigarette/cig
	has_fov = FALSE
	var/voice_change = TRUE

/obj/item/clothing/mask/gas/fakemoustache/syndicate/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(!isinhands && cig)
		. += cig.build_worn_icon(default_layer = FACEMASK_LAYER, default_icon_file = 'icons/mob/clothing/mask.dmi')

/obj/item/clothing/mask/gas/fakemoustache/syndicate/equipped(mob/equipee, slot)
	cig?.equipped(equipee, slot)
	return ..()

/obj/item/clothing/mask/gas/fakemoustache/syndicate/examine(mob/user)
	. = ..()
	if(cig)
		. += span_notice("There is a [cig.name] jammed into the filter slot.")

/obj/item/clothing/mask/gas/fakemoustache/syndicate/Exited(atom/movable/gone)
	. = ..()
	if(gone == cig)
		cig = null
		if(ismob(loc))
			var/mob/wearer = loc
			wearer.update_worn_mask()

/obj/item/clothing/mask/gas/fakemoustache/syndicate/attackby(obj/item/tool, mob/user)
	var/valid_wearer = ismob(loc)
	var/mob/wearer = loc
	if(istype(tool, /obj/item/clothing/mask/cigarette))
		if(flags_cover & MASKCOVERSMOUTH)
			balloon_alert(user, "The stache' is in the way!")
			return ..()

		cig = tool
		if(valid_wearer)
			cig.equipped(loc, wearer.get_slot_by_item(cig))

		cig.forceMove(src)
		if(valid_wearer)
			wearer.update_worn_mask()
		return TRUE

	if(cig)
		var/cig_attackby = cig.attackby(tool, user)
		if(valid_wearer)
			wearer.update_worn_mask()
		return cig_attackby
	return TRUE

/obj/item/clothing/mask/gas/fakemoustache/syndicate/attack_hand_secondary(mob/user, list/modifiers)
	if(cig)
		user.put_in_hands(cig)
		cig = null
		if(ismob(loc))
			var/mob/wearer = loc
			wearer.update_worn_mask()
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/mask/gas/fakemoustache/syndicate/attack_self(mob/user)
	voice_change = !voice_change
	to_chat(user, span_notice("The voice changer is now [voice_change ? "on" : "off"]!"))

/datum/armor/fakemoustache/syndicate
	melee = 20
	bullet = 20
	laser = 20
	bio = 60
	fire = 60
	acid = 60

