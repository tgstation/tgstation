// Degeneral's Makeshift armor
/obj/item/clothing/suit/armor/makeshift
	name = "makeshift armor"
	desc = "A makeshift armor that provides decent protection against most types of damage."
	icon = 'icons/oldschool/clothing/suititem.dmi'
	icon_state = "makeshift_armor"
	item_state = "armor"
	alternate_worn_icon = 'icons/oldschool/clothing/suitmob.dmi'
	blood_overlay_type = "armor"
	max_integrity = 200
	armor = list(melee = 25, bullet = 25, laser = 25, energy = 10, bomb = 20, bio = 0, rad = 0, fire = 40, acid = 40)

//stealth hypo

/obj/item/reagent_containers/hypospray/stealthinjector
	name = "one use injector"
	desc = null
	icon_state = "medipen"
	item_state = "medipen"
	amount_per_transfer_from_this = 10
	volume = 10
	ignore_flags = 0 //can you itch through hardsuits
	container_type = null
	flags_1 = null
	list_reagents = list()
	var/injecttext = "cover"

/obj/item/reagent_containers/hypospray/stealthinjector/attack(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	if(!iscarbon(M))
		return
	if(reagents.total_volume && (ignore_flags || M.can_inject(user, 1)))
		to_chat(user, "<span class='notice'>You [injecttext] [M] with [src].</span>")
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
		reagents.reaction(M, INJECT, fraction)
		if(M.reagents)
			var/list/injected = list()
			for(var/datum/reagent/R in reagents.reagent_list)
				injected += R.name
			if(!infinite)
				reagents.trans_to(M, amount_per_transfer_from_this)
			else
				reagents.copy_to(M, amount_per_transfer_from_this)
			var/contained = english_list(injected)
			add_logs(user, M, "injected", src, "([contained])")

// Degeneral's Itch Powder

/obj/item/reagent_containers/hypospray/stealthinjector/itchingpowder
	name = "itching powder"
	desc = "Itching powder in a bag."
	icon = 'icons/oldschool/objects.dmi'
	icon_state = "itchingpowder"
	item_state = "candy"
	amount_per_transfer_from_this = 10
	volume = 10
	ignore_flags = 0 //can you itch through hardsuits
	container_type = null
	flags_1 = null
	list_reagents = list("itching_powder" = 10)

/obj/item/reagent_containers/hypospray/stealthinjector/itchingpowder/attack(mob/living/M, mob/user)
	. = ..()
	update_icon()

/obj/item/reagent_containers/hypospray/stealthinjector/itchingpowder/update_icon()
	if(reagents.total_volume > 0)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]0"

// Rollie Cannabis

/obj/item/clothing/mask/cigarette/rollie/cannabis
	desc = "Dried cannabis leaf rolled up in a thin piece of paper."
	smoketime = 120
	list_reagents = list("space_drugs" = 30, "lipolicide" = 5, "omnizine" = 2)

// Holy Rollie

/obj/item/clothing/mask/cigarette/rollie/cannabis/holy
	name = "holy rollie"
	desc = "Holy healing cannabis leaf grown in heaven rolled up in a thin piece of paper."
	chem_volume = 60
	list_reagents = list("space_drugs" = 30, "omnizine" = 15, "mannitol" = 15)


// N-word pass

/obj/item/nwordpass
	name = "N-word pass"
	desc = "Official pass to say the N-word."
	icon = 'icons/obj/card.dmi'
	icon_state = "gold"
	item_state = "gold_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/obj/item/nwordpass/attack_self(mob/user)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.dna)
			var/success = 0
			if(istype(H.dna.species, /datum/species/human))
				var/list/skin_tones_b = list("african1","african2")
				if(!(H.skin_tone in skin_tones_b))
					H.skin_tone = pick(skin_tones_b)
					success = 1
				else
					to_chat(H, "<span class='warning'>You can already say the N-word legally.</span>")
			else if(istype(H.dna.species, /datum/species/lizard))
				var/datum/dna/L = H.dna
				if(L.features["mcolor"] != "804200")
					L.features["mcolor"] = "804200"
					success = 1
				else
					to_chat(H, "<span class='warning'>You can already say the N-word legally.</span>")
			else
				to_chat(H, "<span class='warning'>That would be cultural appropriation.</span>")
			if(success)
				to_chat(H, "<span class='notice'>Now you can legally say the N-word. Congratulations!</span>")
				H.regenerate_icons()

//bughunter
/obj/item/bughunter
	name = "The Bug Hunter"
	desc = "Reward for the Bug Hunter"
	icon = 'icons/mob/animal.dmi'
	icon_state = "cockroach"
	var/used = 0

/obj/item/bughunter/attack_self(mob/user)
	if(!used)
		to_chat(user,"You activate the [src].")
		new /mob/living/simple_animal/cockroach(get_turf(src))
		used = 1
	qdel(src)