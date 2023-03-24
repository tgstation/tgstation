/datum/action/cooldown/spell/summonspear
	name = "Призвать Оружие"
	desc = "Призывает оружие через время и пространство."
	button_icon = 'massmeta/icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "ratvarian_spear"
	background_icon_state = "bg_clock"
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 2 SECONDS
	invocation = INVOCATION_NONE
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	///The obj marked for recall
	var/obj/marked_item

/datum/action/cooldown/spell/summonspear/cast(list/targets, mob/user)
	. = ..()
	if(QDELETED(marked_item))
		qdel(src)

	if(!is_servant_of_ratvar(user))
		return

	var/obj/item_to_retrieve = marked_item
	var/infinite_recursion = 0

	if(item_to_retrieve?.loc)
		while(!isturf(item_to_retrieve.loc) && infinite_recursion < 10) //if it's in something you get the whole thing.
			if(isitem(item_to_retrieve.loc))
				var/obj/item/I = item_to_retrieve.loc
				if(I.item_flags & ABSTRACT) //Being able to summon abstract things because your item happened to get placed there is a no-no
					break
			if(ismob(item_to_retrieve.loc)) //If its on someone, properly drop it
				var/mob/M = item_to_retrieve.loc

				if(issilicon(M)) //Items in silicons warp the whole silicon
					M.loc.visible_message(span_warning("[user] пропадает!"))
					M.forceMove(user.loc)
					M.loc.visible_message(span_caution("[user] появляется!"))
					item_to_retrieve = null
					break
				M.dropItemToGround(item_to_retrieve)

				if(iscarbon(M)) //Edge case housekeeping
					var/mob/living/carbon/C = M
					for(var/X in C.bodyparts)
						var/obj/item/bodypart/part = X
						if(item_to_retrieve in part.embedded_objects)
							part.embedded_objects -= item_to_retrieve
							to_chat(C, span_warning("Ого, [item_to_retrieve], который застрял в [user], внезапно исчезает. Чудо!"))
							break

			else
				if(istype(item_to_retrieve.loc, /obj/machinery/portable_atmospherics/)) //Edge cases for moved machinery
					var/obj/machinery/portable_atmospherics/P = item_to_retrieve.loc
					P.disconnect()
					P.update_icon()

				item_to_retrieve = item_to_retrieve.loc

			infinite_recursion += 1

	if(!item_to_retrieve)
		return

	if(item_to_retrieve.loc)
		item_to_retrieve.loc.visible_message(span_warning("[capitalize(item_to_retrieve.name)] исчезает!"))
	if(!user.put_in_hands(item_to_retrieve))
		item_to_retrieve.forceMove(user.drop_location())
		item_to_retrieve.loc.visible_message(span_caution("[capitalize(item_to_retrieve.name)] появляется!"))
		playsound(get_turf(user), 'sound/magic/summonitems_generic.ogg', 50, 1)
	else
		item_to_retrieve.loc.visible_message(span_caution("[capitalize(item_to_retrieve.name)] появляется в руке [user]!"))
		playsound(get_turf(user), 'sound/magic/summonitems_generic.ogg', 50, 1)
