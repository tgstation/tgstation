/obj/item/seeds/watermelon/gay
	name = "gaywatermelon seed pack"
	desc = "These seeds grow into gaywatermelon plants."
	icon = 'troutstation/icons/obj/service/hydroponics/seeds.dmi'
	growing_icon = 'troutstation/icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_state = "seed-gaywatermelon"
	species = "gaywatermelon"
	plantname = "Gaywatermelon Vines"
	product = /obj/item/food/grown/gaywatermelon
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = null
	reagents_add = list(/datum/reagent/medicine/gaywater = 0.2,
		/datum/reagent/consumable/nutriment/vitamin = 0.04,
		/datum/reagent/consumable/nutriment = 0.2)
	rarity = PLANT_MODERATELY_RARE

/obj/item/food/grown/gaywatermelon
	seed = /obj/item/seeds/watermelon/gay
	name = "gaywatermelon"
	desc = "It's full of gaywatery goodness."
	icon = 'troutstation/icons/obj/service/hydroponics/harvest.dmi'
	throw_drop_sound = 'troutstation/sound/misc/gay.ogg'
	mob_throw_hit_sound = 'troutstation/sound/misc/gay2.ogg'
	hitsound = 'troutstation/sound/misc/gay3.ogg'
	icon = 'troutstation/icons/obj/service/hydroponics/harvest.dmi'
	icon_state = "gaywatermelon"
	juice_typepath = /datum/reagent/medicine/gaywater

/obj/item/food/grown/gaywatermelon/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/gaywatermelonslice, 5, 20, screentip_verb = "Chop")

/obj/item/food/grown/gaywatermelon/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(!istype(I, /obj/item/kitchen/spoon))
		return ..()

	var/gaywatermelon_pulp_count = 1
	if(seed)
		gaywatermelon_pulp_count += round(seed.potency / 25)

	user.balloon_alert(user, "scooped out [gaywatermelon_pulp_count] pulp(s)")
	for(var/i in 1 to gaywatermelon_pulp_count)
		new /obj/item/food/gaywatermelonmush(user.loc)

	var/obj/item/clothing/gaywatermelon_armour
	/// Chance for the armour to be a chestplate instead of the helmet
	var/gaywatermelon_chestplate_chance = (max(0, seed.potency - 50) / 50)
	if (prob(gaywatermelon_chestplate_chance))
		if(seed.resistance_flags & FIRE_PROOF)
			gaywatermelon_armour = new /obj/item/clothing/suit/armor/durability/gaywatermelon/fire_resist
		else
			gaywatermelon_armour = new /obj/item/clothing/suit/armor/durability/gaywatermelon
		to_chat(user, span_notice("You hollow the gaywatermelon into a helmet with [I]."))
	else
		if(seed.resistance_flags & FIRE_PROOF)
			gaywatermelon_armour = new /obj/item/clothing/head/helmet/durability/gaywatermelon/fire_resist
		else
			gaywatermelon_armour = new /obj/item/clothing/head/helmet/durability/gaywatermelon
		to_chat(user, span_notice("You hollow the gaywatermelon into a chestplate with [I]."))

	remove_item_from_storage(user)
	qdel(src)
	user.put_in_hands(gaywatermelon_armour)






