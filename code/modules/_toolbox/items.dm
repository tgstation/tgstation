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