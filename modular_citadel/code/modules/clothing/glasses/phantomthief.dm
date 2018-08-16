/obj/item/clothing/glasses/phantomthief
	name = "suspicious paper mask"
	desc = "A cheap, Syndicate-branded paper face mask. They'll never see it coming."
	alternate_worn_icon = 'icons/mob/mask.dmi'
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "s-ninja"
	item_state = "s-ninja"

/obj/item/clothing/glasses/phantomthief/Initialize()
	. = ..()
	AddComponent(/datum/component/phantomthief)

/obj/item/clothing/glasses/phantomthief/syndicate
	name = "suspicious plastic mask"
	desc = "A cheap, bulky, Syndicate-branded plastic face mask. You have to break in to break out."
	var/nextadrenalinepop
	var/datum/component/redirect/combattoggle_redir

/obj/item/clothing/glasses/phantomthief/syndicate/examine(user)
	. = ..()
	if(combattoggle_redir)
		if(world.time >= nextadrenalinepop)
			to_chat(user, "<span class='notice'>The built-in adrenaline injector is ready for use.</span>")
		else
			to_chat(user, "<span class='notice'>[DisplayTimeText(nextadrenalinepop - world.time)] left before the adrenaline injector can be used again.")

/obj/item/clothing/glasses/phantomthief/syndicate/proc/injectadrenaline(mob/user, combatmodestate)
	if(istype(user))
		if(combatmodestate && world.time >= nextadrenalinepop)
			nextadrenalinepop = world.time + 5 MINUTES
			user.reagents.add_reagent("syndicateadrenals", 5)
			user.playsound_local(user, 'modular_citadel/sound/misc/adrenalinject.ogg', 100, 0, pressure_affected = FALSE)

/obj/item/clothing/glasses/phantomthief/syndicate/equipped(mob/user, slot)
	. = ..()
	if(!istype(user))
		return
	if(!combattoggle_redir)
		combattoggle_redir = user.AddComponent(/datum/component/redirect,list(COMSIG_COMBAT_TOGGLED),CALLBACK(src,.proc/injectadrenaline))

/obj/item/clothing/glasses/phantomthief/syndicate/dropped(mob/user)
	. = ..()
	if(!istype(user))
		return
	if(combattoggle_redir)
		QDEL_NULL(combattoggle_redir)
