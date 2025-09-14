// A very special plant, deserving its own file.

/obj/item/seeds/kudzu
	name = "kudzu seed pack"
	desc = "These seeds grow into a weed that grows incredibly fast."
	icon_state = "seed-kudzu"
	plant_icon_offset = 2
	species = "kudzu"
	plantname = "Kudzu"
	product = /obj/item/food/grown/kudzupod
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy)
	lifespan = 20
	endurance = 10
	yield = 4
	instability = 55
	growthstages = 4
	rarity = 30
	var/list/mutations = list()
	reagents_add = list(/datum/reagent/medicine/c2/multiver = 0.04, /datum/reagent/consumable/nutriment = 0.02)
	graft_gene = /datum/plant_gene/trait/plant_type/weed_hardy

/obj/item/seeds/kudzu/Copy()
	var/obj/item/seeds/kudzu/S = ..()
	S.mutations = mutations.Copy()
	return S

/obj/item/seeds/kudzu/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] swallows the pack of kudzu seeds! It looks like [user.p_theyre()] trying to commit suicide!"))
	plant(user)
	return BRUTELOSS

/obj/item/seeds/kudzu/proc/plant(mob/user)
	if(isspaceturf(user.loc))
		return
	if(!isturf(user.loc))
		to_chat(user, span_warning("You need more space to plant [src]."))
		return FALSE
	if(locate(/obj/structure/spacevine) in user.loc)
		to_chat(user, span_warning("There is too much kudzu here to plant [src]."))
		return FALSE
	to_chat(user, span_notice("You plant [src]."))
	message_admins("Kudzu planted by [ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(user)]")
	investigate_log("was planted by [key_name(user)] at [AREACOORD(user)]", INVESTIGATE_BOTANY)
	new /datum/spacevine_controller(get_turf(user), mutations, potency, production)
	qdel(src)

/obj/item/seeds/kudzu/attack_self(mob/user)
	user.visible_message(span_danger("[user] begins throwing seeds on the ground..."))
	if(do_after(user, 5 SECONDS, target = user.drop_location(), progress = TRUE))
		plant(user)
		to_chat(user, span_notice("You plant the kudzu. You monster."))

/obj/item/seeds/kudzu/get_unique_analyzer_data()
	var/list/all_mutations = list()
	for(var/datum/spacevine_mutation/vine_trait in mutations)
		all_mutations[vine_trait.name] = vine_trait.description

	return list("Kudzu Traits" = all_mutations)

/obj/item/seeds/kudzu/on_chem_reaction(datum/reagents/reagents)
	var/list/temp_mut_list = list()

	if(reagents.has_reagent(/datum/reagent/space_cleaner/sterilizine, 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == NEGATIVE)
				temp_mut_list += SM
		if(prob(20) && temp_mut_list.len)
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()

	if(reagents.has_reagent(/datum/reagent/fuel, 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == POSITIVE)
				temp_mut_list += SM
		if(prob(20) && temp_mut_list.len)
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()

	if(reagents.has_reagent(/datum/reagent/phenol, 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == MINOR_NEGATIVE)
				temp_mut_list += SM
		if(prob(20) && temp_mut_list.len)
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()

	if(reagents.has_reagent(/datum/reagent/blood, 15))
		adjust_production(rand(15, -5))

	if(reagents.has_reagent(/datum/reagent/toxin/amatoxin, 5))
		adjust_production(rand(5, -15))

	if(reagents.has_reagent(/datum/reagent/toxin/plasma, 5))
		adjust_potency(rand(5, -15))

	if(reagents.has_reagent(/datum/reagent/water/holywater, 10))
		adjust_potency(rand(15, -5))


/obj/item/food/grown/kudzupod
	seed = /obj/item/seeds/kudzu
	name = "kudzu pod"
	desc = "<I>Pueraria Virallis</I>: An invasive species with vines that rapidly creep and wrap around whatever they contact."
	icon_state = "kudzupod"
	foodtypes = VEGETABLES | GROSS
	tastes = list("kudzu" = 1)
	wine_power = 20
