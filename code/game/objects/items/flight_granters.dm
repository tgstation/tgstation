//Potion of Flight
/obj/item/reagent_containers/glass/bottle/potion
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "potionflask"

/obj/item/reagent_containers/glass/bottle/potion/flight
	name = "strange elixir"
	desc = "A flask with an almost-holy aura emitting from it. The label on the bottle says: 'erqo'hyy tvi'rf lbh jv'atf'."
	list_reagents = list(/datum/reagent/flightpotion = 5)

/obj/item/reagent_containers/glass/bottle/potion/update_icon_state()
	icon_state = "potionflask[reagents.total_volume ? null : "_empty"]"
	return ..()

/datum/reagent/flightpotion
	name = "Flight Potion"
	description = "Strange mutagenic compound of unknown origins."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/flightpotion/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE)
	. = ..()
	if(iscarbon(exposed_mob) && exposed_mob.stat != DEAD)
		var/mob/living/carbon/exposed_carbon = exposed_mob
		var/holycheck = ishumanbasic(exposed_carbon)
		if(!HAS_TRAIT(exposed_carbon, TRAIT_CAN_USE_FLIGHT_POTION) || reac_volume < 5)
			if((methods & INGEST) && show_message)
				to_chat(exposed_carbon, span_notice("<i>You feel nothing but a terrible aftertaste.</i>"))
			return
		if(exposed_carbon.dna.species.has_innate_wings)
			to_chat(exposed_carbon, span_userdanger("A terrible pain travels down your back as your wings change shape!"))
		else
			to_chat(exposed_carbon, span_userdanger("A terrible pain travels down your back as wings burst out!"))
		exposed_carbon.dna.species.GiveSpeciesFlight(exposed_carbon)
		if(holycheck)
			to_chat(exposed_carbon, span_notice("You feel blessed!"))
			ADD_TRAIT(exposed_carbon, TRAIT_HOLY, SPECIES_TRAIT)
		playsound(exposed_carbon.loc, 'sound/items/poster_ripped.ogg', 50, TRUE, -1)
		exposed_carbon.adjustBruteLoss(20)
		exposed_carbon.emote("scream")

/obj/item/wing_mods
	name = "android wing mods"
	desc = "Some unattached robotic wings."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "wing_mods"

/obj/item/wing_mods/examine(mob/user)
	. = ..()
	. += span_notice("You can attach them to yourself by hitting yourself with them, if you're an android.")

/obj/item/wing_mods/attack(mob/living/used_on, mob/living/user, params)
	if(used_on != user)
		return ..()
	if(!isandroid(user))
		user.balloon_alert(user, "androids only!")
		return
	var/mob/living/carbon/human/android = user
	if(android.dna.species.flying_species)
		user.balloon_alert(user, "you can already fly!")
		return
	user.balloon_alert(user, "wings attached")
	android.dna.species.grant_flight(android)
	qdel(src)
