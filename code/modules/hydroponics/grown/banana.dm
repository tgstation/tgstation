// Banana
/obj/item/seeds/banana
	name = "banana seed pack"
	desc = "They're seeds that grow into banana trees. When grown, keep away from clown."
	icon_state = "seed-banana"
	species = "banana"
	plantname = "Banana Tree"
	product = /obj/item/food/grown/banana
	lifespan = 50
	endurance = 30
	instability = 10
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_dead = "banana-dead"
	genes = list(/datum/plant_gene/trait/slip, /datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/banana/mime, /obj/item/seeds/banana/bluespace)
	reagents_add = list(/datum/reagent/consumable/banana = 0.1, /datum/reagent/potassium = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.02)
	graft_gene = /datum/plant_gene/trait/slip

/obj/item/food/grown/banana
	seed = /obj/item/seeds/banana
	name = "banana"
	desc = "It's an excellent prop for a clown."
	icon_state = "banana"
	inhand_icon_state = "banana_peel"
	trash_type = /obj/item/grown/bananapeel
	bite_consumption_mod = 3
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/banana
	distill_reagent = /datum/reagent/consumable/ethanol/bananahonk

/obj/item/food/grown/banana/make_edible()
	. = ..()
	AddComponent(/datum/component/edible, check_liked = CALLBACK(src, PROC_REF(check_liked)))

/obj/item/food/grown/banana/Initialize(mapload)
	. = ..()
	if(prob(1))
		AddComponent(/datum/component/boomerang, boomerang_throw_range = throw_range + 4, thrower_easy_catch_enabled = TRUE, examine_message = span_green("The curve on this one looks particularly acute."))

///Clowns will always like bananas.
/obj/item/food/grown/banana/proc/check_liked(mob/living/carbon/human/consumer)
	var/obj/item/organ/internal/liver/liver = consumer.get_organ_slot(ORGAN_SLOT_LIVER)
	if (!HAS_TRAIT(consumer, TRAIT_AGEUSIA) && liver && HAS_TRAIT(liver, TRAIT_COMEDY_METABOLISM))
		return FOOD_LIKED

/obj/item/food/grown/banana/generate_trash(atom/location)
	. = ..()
	var/obj/item/grown/bananapeel/peel = .
	if(istype(peel))
		peel.grind_results = list(/datum/reagent/medicine/coagulant/banana_peel = peel.seed.potency * 0.2)

/obj/item/food/grown/banana/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is aiming [src] at [user.p_them()]self! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/items/bikehorn.ogg', 50, TRUE, -1)
	sleep(2.5 SECONDS)
	if(!user)
		return OXYLOSS
	user.say("BANG!", forced = /datum/reagent/consumable/banana)
	sleep(2.5 SECONDS)
	if(!user)
		return OXYLOSS
	user.visible_message("<B>[user]</B> laughs so hard they begin to suffocate!")
	return OXYLOSS

//Banana Peel
/obj/item/grown/bananapeel
	seed = /obj/item/seeds/banana
	name = "banana peel"
	desc = "A peel from a banana."
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	icon_state = "banana_peel"
	inhand_icon_state = "banana_peel"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7

/obj/item/grown/bananapeel/Initialize(mapload)
	. = ..()
	if(prob(40))
		if(prob(60))
			icon_state = "[icon_state]_2"
		else
			icon_state = "[icon_state]_3"

/obj/item/grown/bananapeel/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is deliberately slipping on [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/misc/slip.ogg', 50, TRUE, -1)
	return BRUTELOSS

// Mimana - invisible sprites are totally a feature!
/obj/item/seeds/banana/mime
	name = "mimana seed pack"
	desc = "They're seeds that grow into mimana trees. When grown, keep away from mime."
	icon_state = "seed-mimana"
	species = "mimana"
	plantname = "Mimana Tree"
	product = /obj/item/food/grown/banana/mime
	growthstages = 4
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nothing = 0.1, /datum/reagent/toxin/mutetoxin = 0.1, /datum/reagent/consumable/nutriment = 0.02)
	rarity = 15

/obj/item/food/grown/banana/mime
	seed = /obj/item/seeds/banana/mime
	name = "mimana"
	desc = "It's an excellent prop for a mime."
	icon_state = "mimana"
	trash_type = /obj/item/grown/bananapeel/mimanapeel
	distill_reagent = /datum/reagent/consumable/ethanol/silencer

/obj/item/grown/bananapeel/mimanapeel
	seed = /obj/item/seeds/banana/mime
	name = "mimana peel"
	desc = "A mimana peel."
	icon_state = "mimana_peel"
	inhand_icon_state = "mimana_peel"

// Bluespace Banana
/obj/item/seeds/banana/bluespace
	name = "bluespace banana seed pack"
	desc = "They're seeds that grow into bluespace banana trees. When grown, keep away from bluespace clown."
	icon_state = "seed-banana-blue"
	species = "bluespacebanana"
	icon_grow = "banana-grow"
	plantname = "Bluespace Banana Tree"
	instability = 40
	product = /obj/item/food/grown/banana/bluespace
	mutatelist = null
	genes = list(/datum/plant_gene/trait/slip, /datum/plant_gene/trait/teleport, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/bluespace = 0.2, /datum/reagent/consumable/banana = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.02, /datum/reagent/liquid_dark_matter = 0.2)
	rarity = 30
	graft_gene = /datum/plant_gene/trait/teleport

/obj/item/food/grown/banana/bluespace
	seed = /obj/item/seeds/banana/bluespace
	name = "bluespace banana"
	icon_state = "bluenana"
	inhand_icon_state = "bluespace_peel"
	trash_type = /obj/item/grown/bananapeel/bluespace
	tastes = list("banana" = 1, "antimatter" = 1)
	wine_power = 60
	wine_flavor = "slippery hypercubes"

/obj/item/grown/bananapeel/bluespace
	seed = /obj/item/seeds/banana/bluespace
	name = "bluespace banana peel"
	desc = "A peel from a bluespace banana."
	icon_state = "bluenana_peel"
	inhand_icon_state = "bluespace_peel"

// Other
/obj/item/grown/bananapeel/specialpeel //used by /obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "synthesized banana peel"
	desc = "A synthetic banana peel."

/obj/item/grown/bananapeel/specialpeel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 40)

/obj/item/food/grown/banana/bunch
	name = "banana bunch"
	desc = "Am exquisite bunch of bananas. The almost otherwordly plumpness steers the mind any discening entertainer towards the divine."
	icon_state = "banana_bunch"
	bite_consumption_mod = 4
	var/is_ripening = FALSE

/obj/item/food/grown/banana/bunch/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent(/datum/reagent/consumable/monkey_energy, 10)
	reagents.add_reagent(/datum/reagent/consumable/banana, 10)

/obj/item/food/grown/banana/bunch/proc/start_ripening()
	if(is_ripening)
		return
	playsound(src, 'sound/effects/fuse.ogg', 80)

	animate(src, time = 1, pixel_z = 12, easing = ELASTIC_EASING)
	animate(time = 1, pixel_z = 0, easing = BOUNCE_EASING)
	addtimer(CALLBACK(src, PROC_REF(explosive_ripening)), 3 SECONDS)
	for(var/i in 1 to 32)
		animate(color = (i % 2) ? "#ffffff": "#ff6739", time = 1, easing = QUAD_EASING)

/obj/item/food/grown/banana/bunch/proc/explosive_ripening()
	honkerblast(src, light_range = 3, medium_range = 1)
	for(var/mob/shook_boi in range(6, loc))
		shake_camera(shook_boi, 3, 5)
	var/obj/effect/decal/cleanable/food/plant_smudge/banana_smudge = new(loc)
	banana_smudge.color = "#ffe02f"
	qdel(src)

/obj/item/food/grown/banana/bunch/monkeybomb
	desc = "Am exquisite bunch of bananas. Their otherwordly plumpness seems to be hiding something."

/obj/item/food/grown/banana/bunch/monkeybomb/examine(mob/user)
	. = ..()
	if(!is_simian(user))
		. += span_notice("There's a banana label on one of the 'nanas you can't quite make out the details of.")
		return
	. += span_notice("The banana label on this bunch indicates that monkeys can use this as a sonic grenade with a 3 second timer!")

/obj/item/food/grown/banana/bunch/monkeybomb/attack_self(mob/user, modifiers)
	if(!is_simian(user))
		return to_chat(user, span_notice("You don't really know what to do with this."))
	else start_ripening()
