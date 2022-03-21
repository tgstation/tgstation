/obj/item/choice_beacon
	name = "choice beacon"
	desc = "Hey, why are you viewing this?!! Please let CentCom know about this odd occurrence."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-blue"
	inhand_icon_state = "radio"
	var/uses = 1

/obj/item/choice_beacon/attack_self(mob/user)
	if(canUseBeacon(user))
		generate_options(user)

/obj/item/choice_beacon/proc/generate_display_names() // return the list that will be used in the choice selection. entries should be in (type.name = type) fashion. see choice_beacon/hero for how this is done.
	return list()

/obj/item/choice_beacon/proc/canUseBeacon(mob/living/user)
	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return TRUE
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, TRUE)
		return FALSE

/obj/item/choice_beacon/proc/generate_options(mob/living/M)
	var/list/display_names = generate_display_names()
	if(!length(display_names))
		return
	var/choice = tgui_input_list(M, "Which item would you like to order?", "Select an Item", display_names)
	if(isnull(choice))
		return
	if(isnull(display_names[choice]))
		return
	if(!M.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	spawn_option(display_names[choice],M)
	uses--
	if(!uses)
		qdel(src)
	else
		to_chat(M, span_notice("[uses] use[uses > 1 ? "s" : ""] remaining on the [src]."))

/obj/item/choice_beacon/proc/spawn_option(obj/choice,mob/living/M)
	podspawn(list(
		"target" = get_turf(src),
		"style" = STYLE_BLUESPACE,
		"spawn" = choice,
	))
	var/msg = span_danger("After making your selection, you notice a strange target on the ground. It might be best to step back!")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(istype(H.ears, /obj/item/radio/headset))
			msg = "You hear something crackle in your ears for a moment before a voice speaks.  \"Please stand by for a message from Central Command.  Message as follows: [span_bold("Item request received. Your package is inbound, please stand back from the landing site.")] Message ends.\""
	to_chat(M, msg)

/obj/item/choice_beacon/ingredient
	name = "ingredient delivery beacon"
	desc = "Summon a box of ingredients to help you get started cooking."
	icon_state = "gangtool-white"

/obj/item/choice_beacon/ingredient/generate_display_names()
	var/list/ingredients = list()
	for(var/V in subtypesof(/obj/item/storage/box/ingredients))
		var/obj/item/storage/box/ingredients/A = V
		ingredients[initial(A.theme_name)] = A
	return ingredients

/obj/item/choice_beacon/ingredient/spawn_option(obj/choice,mob/living/M)
	new choice(get_turf(M))
	to_chat(M, span_hear("You hear something crackle from the beacon for a moment before a voice speaks. \"Please stand by for a message from Sophronia Broadcasting. Message as follows: <b>Please enjoy your Sophronia Broadcasting's 'Plasteel Chef' Ingredients Box, exactly as shown in the hit show!</b> Message ends.\""))

/obj/item/choice_beacon/hero
	name = "heroic beacon"
	desc = "To summon heroes from the past to protect the future."

/obj/item/choice_beacon/hero/generate_display_names()
	var/static/list/hero_item_list
	if(!hero_item_list)
		hero_item_list = list()
		var/list/templist = typesof(/obj/item/storage/box/hero) //we have to convert type = name to name = type, how lovely!
		for(var/V in templist)
			var/atom/A = V
			hero_item_list[initial(A.name)] = A
	return hero_item_list

/obj/item/choice_beacon/hero/spawn_option(obj/choice,mob/living/M)
	new choice(get_turf(M))
	to_chat(M, span_hear("You hear something crackle from the beacon for a moment before a voice speaks. \"Please stand by for a message from Sophronia Broadcasting. Message as follows: <b>Please enjoy your Sophronia Broadcasting's 'History Comes Alive branded' Costume Set, exactly as shown in the hit show!</b> Message ends.\""))

/obj/item/choice_beacon/augments
	name = "augment beacon"
	desc = "Summons augmentations. Can be used 3 times!"
	uses = 3

/obj/item/choice_beacon/augments/generate_display_names()
	var/static/list/augment_list
	if(!augment_list)
		augment_list = list()
		var/list/templist = list(
		/obj/item/organ/cyberimp/brain/anti_drop,
		/obj/item/organ/cyberimp/arm/toolset,
		/obj/item/organ/cyberimp/arm/surgery,
		/obj/item/organ/cyberimp/chest/thrusters,
		/obj/item/organ/lungs/cybernetic/tier3,
		/obj/item/organ/liver/cybernetic/tier3) //cyberimplants range from a nice bonus to fucking broken bullshit so no subtypesof
		for(var/V in templist)
			var/atom/A = V
			augment_list[initial(A.name)] = A
	return augment_list

/obj/item/choice_beacon/augments/spawn_option(obj/choice,mob/living/M)
	new choice(get_turf(M))
	to_chat(M, span_hear("You hear something crackle from the beacon for a moment before a voice speaks. \"Please stand by for a message from S.E.L.F. Message as follows: <b>Item request received. Your package has been transported, use the autosurgeon supplied to apply the upgrade.</b> Message ends.\""))

/obj/item/choice_beacon/holy
	name = "armaments beacon"
	desc = "Contains a set of armaments for the chaplain."

/obj/item/choice_beacon/holy/canUseBeacon(mob/living/user)
	if(user.mind && user.mind.holy_role)
		return ..()
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, TRUE)
		return FALSE

/obj/item/choice_beacon/holy/generate_display_names()
	var/static/list/holy_item_list
	if(!holy_item_list)
		holy_item_list = list()
		var/list/templist = typesof(/obj/item/storage/box/holy)
		for(var/V in templist)
			var/atom/A = V
			holy_item_list[initial(A.name)] = A
	return holy_item_list

/obj/item/choice_beacon/holy/spawn_option(obj/choice,mob/living/M)
	if(!GLOB.holy_armor_type)
		..()
		playsound(src, 'sound/effects/pray_chaplain.ogg', 40, TRUE)
		SSblackbox.record_feedback("tally", "chaplain_armor", 1, "[choice]")
		GLOB.holy_armor_type = choice
	else
		to_chat(M, span_warning("A selection has already been made. Self-Destructing..."))
		return
