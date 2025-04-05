/obj/item/virgin_mary
	name = "\proper a picture of the virgin mary"
	desc = "A small, cheap icon depicting the virgin mother."
	icon = 'icons/obj/devices/blackmarket.dmi'
	icon_state = "madonna"
	resistance_flags = FLAMMABLE
	///Has this item been used already.
	var/used_up = FALSE

#define NICKNAME_CAP (MAX_NAME_LEN/2)
/obj/item/virgin_mary/attackby(obj/item/potential_lighter, mob/living/user, params)
	. = ..()
	if(resistance_flags & ON_FIRE)
		return
	if(!istype(user) || !user.mind) //A sentient mob needs to be burning it, ya cheezit.
		return

	if(HAS_TRAIT(user, TRAIT_MAFIAINITIATE)) //Only one nickname fuckhead
		to_chat(user, span_warning("You have already been initiated into the mafioso life."))
		return

	if(!burn_paper_product_attackby_check(potential_lighter, user, TRUE))
		return
	if(used_up)
		return

	ADD_TRAIT(user, TRAIT_MAFIAINITIATE, TRAIT_GENERIC) // Adding the trait early because you could burn multiple at once for a very long name
	to_chat(user, span_notice("As you burn the picture, a nickname comes to mind..."))
	var/nickname = tgui_input_text(user, "Pick a nickname", "Mafioso Nicknames", max_length = NICKNAME_CAP)
	nickname = reject_bad_name(nickname, allow_numbers = FALSE, max_length = NICKNAME_CAP, ascii_only = TRUE)
	if(!nickname)
		REMOVE_TRAIT(user, TRAIT_MAFIAINITIATE, TRAIT_GENERIC)
		return
	var/new_name
	var/space_position = findtext(user.real_name, " ")
	if(space_position)//Can we find a space?
		new_name = "[copytext(user.real_name, 1, space_position)] \"[nickname]\" [copytext(user.real_name, space_position)]"
	else //Append otherwise
		new_name = "[user.real_name] \"[nickname]\""
	user.real_name = new_name
	used_up = TRUE
	user.say("My soul will burn like this saint if I betray my family. I enter alive and I will have to get out dead.", forced = /obj/item/virgin_mary)
	to_chat(user, span_userdanger("Being inducted into the mafia does not grant antagonist status."))

#undef NICKNAME_CAP

/obj/item/virgin_mary/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] starts saying their Hail Mary's at a terrifying pace! It looks like [user.p_theyre()] trying to enter the afterlife!"))
	user.say("Hail Mary, full of grace, the Lord is with thee. Blessed are thou amongst women, and blessed is the fruit of thy womb, Jesus. Holy Mary, mother of God, pray for us sinners, now and at the hour of our death. Amen. ", forced = /obj/item/virgin_mary)
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), 7.5 SECONDS)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/atom/movable, say), "O my Mother, preserve me this day from mortal sin..."), 5 SECONDS)
	return MANUAL_SUICIDE

/obj/item/virgin_mary/proc/manual_suicide(mob/living/user)
	user.adjustOxyLoss(200)
	user.death(FALSE)
