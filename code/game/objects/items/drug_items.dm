/obj/item/food/drug
	name = "generic drug"
	desc = "I am error"
	icon = 'icons/obj/medical/drugs.dmi'
	abstract_type = /obj/item/food/drug
	foodtypes = GROSS
	food_flags = FOOD_FINGER_FOOD
	max_volume = 50
	eat_time = 1 SECONDS
	tastes = list("drugs" = 2, "chemicals" = 1)
	eatverbs = list("gnaw" = 1)
	bite_consumption = 10
	w_class = WEIGHT_CLASS_TINY
	preserved_food = TRUE

/obj/item/food/drug/saturnx
	name = "saturnX glob"
	desc = "A congealed glob of pure saturnX.\nThis compound was first discovered during the infancy of cloaking technology and at the time thought to be a promising candidate agent. It was withdrawn for consideration after the researchers discovered a slew of associated safety issues including thought disorders and hepatoxicity.\nIt has since attained some limited popularity as a street drug."
	icon_state = "saturnx_glob" //tell kryson to sprite two more variants in the future.
	food_reagents = list(/datum/reagent/drug/saturnx = 10)

/obj/item/food/drug/saturnx/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/food/drug/moon_rock
	name = "moon rock"
	desc = "A small hard lump of kronkaine freebase.\nIt is said the average kronkaine addict causes as much criminal damage as four cat burglars, two arsonists and one rabid pit bull terrier combined.\n\nNotorious in the medical community for causing dangerous interactions with purging meds!"
	icon_state = "moon_rock1"
	food_reagents = list(/datum/reagent/drug/kronkaine = 10)

/obj/item/food/drug/moon_rock/Initialize(mapload)
	. = ..()
	icon_state = pick("moon_rock1", "moon_rock2", "moon_rock3")
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOONICORN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/reagent_containers/cup/blastoff_ampoule
	name = "bLaSToFF ampoule" //stylized name
	desc = "A small ampoule. The liquid inside appears to be boiling violently.\nYou suspect it contains bLasSToFF; the drug thought to be the cause of the infamous Luna nightclub mass casualty incident."
	icon = 'icons/obj/medical/drugs.dmi'
	icon_state = "blastoff_ampoule"
	base_icon_state = "blastoff_ampoule"
	volume = 20
	reagent_flags = TRANSPARENT
	spillable = FALSE
	list_reagents = list(/datum/reagent/drug/blastoff = 10)
	reagent_consumption_method = INHALE
	consumption_sound = 'sound/effects/spray2.ogg'

/obj/item/reagent_containers/cup/blastoff_ampoule/update_icon_state()
	. = ..()
	if(!reagents.total_volume)
		icon_state = "[base_icon_state]_empty"
	else if(spillable)
		icon_state = "[base_icon_state]_open"
	else
		icon_state = base_icon_state

/obj/item/reagent_containers/cup/blastoff_ampoule/attack_self(mob/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY) || spillable)
		return ..()
	reagent_flags |= OPENCONTAINER
	spillable = TRUE
	playsound(src, 'sound/items/ampoule_snap.ogg', 40)
	update_appearance()

/obj/item/reagent_containers/cup/blastoff_ampoule/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum, do_splash = TRUE)
	. = ..()
	if(.)
		return
	if(QDELING(src) || !hit_atom)	//Invalid loc
		return
	var/obj/item/shard/ampoule_shard = new(drop_location())
	playsound(src, SFX_SHATTER, 40, TRUE)
	transfer_fingerprints_to(ampoule_shard)
	spillable = TRUE
	SplashReagents(hit_atom, throwingdatum)
	qdel(src)
	hit_atom.Bumped(ampoule_shard)

/obj/item/reagent_containers/cup/blastoff_ampoule/Initialize(mapload, vol)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/food/drug/meth_crystal
	name = "crystal meth"
	desc = "A clear, sad, fake looking crystal substance."
	icon_state = "meth_crystal1"
	tastes = list("awfulness", "burning")
	force = 3
	throwforce = 4
	embed_type = /datum/embedding/meth

/datum/embedding/meth // lmao
	embed_chance = 9
	rip_time = 2 SECONDS
	COOLDOWN_DECLARE(reagent_message_cd)
	ignore_throwspeed_threshold = TRUE
	var/transfer_per_second = 0.5

/datum/embedding/meth/process_effect(seconds_per_tick)
	var/obj/item/rock = parent
	if(!istype(rock, /obj/item/food/drug/meth_crystal))
		return

	if(!IS_ORGANIC_LIMB(owner_limb))
		return

	if(!owner?.reagents || !rock.reagents?.total_volume)
		return

	rock.reagents.trans_to(
		owner,
		transfer_per_second * seconds_per_tick,
		methods = INJECT,
		show_message = SPT_PROB(15, seconds_per_tick)
	)

/obj/item/food/drug/meth_crystal/Initialize(mapload)
	. = ..()
	icon_state = pick("meth_crystal1", "meth_crystal2", "meth_crystal3", "meth_crystal4", "meth_crystal5")
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)
	reagents.add_reagent(/datum/reagent/drug/methamphetamine, 10)

/obj/item/food/drug/opium
	name = "opium"
	desc = "A little of it, taken as much as a grain of ervum is a pain-easer, and a sleep-causer, and a digester... \
	but being drank too much it hurts, making spacemen lethargical, and it kills."
	icon_state = "opium1"
	tastes = list("amber", "a bitter vanilla")
	food_reagents = list(
		/datum/reagent/medicine/morphine = 10,
		/datum/reagent/consumable/sugar = 1
	)

/obj/item/food/drug/opium/examine()
	. = ..()
	if(reagents.get_reagent_amount(/datum/reagent/medicine/morphine) >= 10)
		. += span_notice("The opium is large and rich in fragrance; it needs no further refinement.")
	else
		. += span_notice("The opium is still small, and can be pressed together with more to increase its potency and richness.")

/obj/item/food/drug/opium/Initialize(mapload) // For narcotics and black market purchases, pure and proper.
	. = ..()
	icon_state = pick("opium1", "opium2", "opium3", "opium4", "opium5")
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/food/drug/opium/raw/Initialize(mapload, potency) // Randomizes amount depending upon potency.
	. = ..()
	reagents.clear_reagents()
	var/mult = max(potency / 20, 1) // 20 = base, 100 = 5x, 200 = 10x
	reagents.add_reagent(/datum/reagent/medicine/morphine, (rand(4, 25) / 10) * mult)
	reagents.add_reagent(/datum/reagent/consumable/sugar, rand(1, 7) / 10)

/obj/item/food/drug/opium/raw/interact_with_atom(obj/item/I, mob/user) // allows for combining opium up to 10u, refining it until rich and fragrant.
	if(istype(I, /obj/item/food/drug/opium/raw))
		var/obj/item/food/drug/opium/raw/other = I

		var/current = reagents.get_reagent_amount(/datum/reagent/medicine/morphine)
		if(current >= 10)
			to_chat(user, span_notice("This chunk can't hold any more."))
			return TRUE

		var/capacity_left = 10 - current
		var/transferred = other.reagents.trans_to(src, capacity_left)

		if(transferred > 0)
			var/overflow = reagents.get_reagent_amount(/datum/reagent/medicine/morphine) - 10
			if(overflow > 0)
				reagents.trans_to(other, overflow)

			to_chat(user, span_notice("You press the chunks of opium together, enriching them."))
			if(!other.reagents.total_volume)
				qdel(other)
		else
			to_chat(user, span_notice("The opium cannot be pressed together further."))

		return TRUE

	return ..()
