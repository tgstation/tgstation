/datum/round_modifier/anime
	name = "Anime Station"
	permament = TRUE // No going back after this.

/datum/round_modifier/anime/proc/make_anime(mob/living/M)
	// Notifiy.
	SEND_SOUND(M, sound('sound/ai/animes.ogg'))

	// Rename.
	var/list/honorifics = list("[MALE]" = list("kun"), "[FEMALE]" = list("chan","tan"), "[NEUTER]" = list("san")) //John Robust -> Robust-kun

	var/list/names = splittext(M.real_name," ")
	var/forename = names.len > 1 ? names[2] : names[1]
	var/newname = "[forename]-[pick(honorifics["[M.gender]"])]"
	M.fully_replace_character_name(M.real_name, newname)

	// Apply cat to forehead.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		var/obj/item/organ/ears/cat/ears = new
		var/obj/item/organ/tail/cat/tail = new

		ears.Insert(H, drop_if_replaced=FALSE)
		tail.Insert(H, drop_if_replaced=FALSE)

		H.update_mutant_bodyparts()

		// Dress up like a schoolgirl, apparently.
		var/seifuku = pick(typesof(/obj/item/clothing/under/schoolgirl))
		var/obj/item/clothing/under/schoolgirl/I = new seifuku(get_turf(H))
		I.add_trait(TRAIT_NODROP, ADMIN_TRAIT)

		var/olduniform = H.w_uniform
		H.temporarilyRemoveItemFromInventory(H.w_uniform, TRUE, FALSE)
		H.equip_to_slot_or_del(I, SLOT_W_UNIFORM)
		qdel(olduniform)

/datum/round_modifier/anime/on_apply()
	for(var/mob/living/M in GLOB.mob_list)
		make_anime(M)

/datum/round_modifier/anime/on_player_spawn(mob/living/L)
	make_anime(L)
