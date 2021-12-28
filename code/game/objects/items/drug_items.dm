/obj/item/food/drug
	name = "generic drug"
	desc = "I am error"
	icon = 'icons/obj/drugs.dmi'
	foodtypes = GROSS
	food_flags = FOOD_FINGER_FOOD
	max_volume = 50
	eat_time = 1 SECONDS
	tastes = list("drugs" = 2, "chemicals" = 1)
	eatverbs = list("gnaw" = 1)
	bite_consumption = 10
	atom_size = WEIGHT_CLASS_TINY
	preserved_food = TRUE

/obj/item/food/drug/saturnx
	name = "saturnX glob"
	desc = "A congealed glob of pure saturnX.\nThis compound was first discovered during the infancy of cloaking technology and at the time thought to be a promising candidate agent. It was withdrawn for consideration after the researchers discovered a slew of associated safety issues including thought disorders and hepatoxicity.\nIt has since attained some limited popularity as a street drug."
	icon_state = "saturnx_glob" //tell kryson to sprite two more variants in the future.
	food_reagents = list(/datum/reagent/drug/saturnx = 10)

/obj/item/food/drug/moon_rock
	name = "moon rock"
	desc = "A small hard lump of kronkaine freebase.\nIt is said the average kronkaine addict causes as much criminal damage as four cat burglars, two arsonists and one rabid pit bull terrier combined."
	icon_state = "moon_rock1"
	food_reagents = list(/datum/reagent/drug/kronkaine = 10)

/obj/item/food/drug/moon_rock/Initialize(mapload)
	. = ..()
	icon_state = pick("moon_rock1", "moon_rock2", "moon_rock3")
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOONICORN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/obj/item/reagent_containers/glass/blastoff_ampoule
	name = "bLaSToFF ampoule" //stylized name
	desc = "A small ampoule. The liquid inside appears to be boiling violently.\nYou suspect it contains bLasSToFF; the drug thought to be the cause of the infamous Luna nightclub mass casualty incident."
	icon = 'icons/obj/drugs.dmi'
	icon_state = "blastoff_ampoule"
	base_icon_state = "blastoff_ampoule"
	volume = 20
	reagent_flags = TRANSPARENT
	spillable = FALSE
	list_reagents = list(/datum/reagent/drug/blastoff = 10)

/obj/item/reagent_containers/glass/blastoff_ampoule/update_icon_state()
	. = ..()
	if(!reagents.total_volume)
		icon_state = "[base_icon_state]_empty"
	else if(spillable)
		icon_state = "[base_icon_state]_open"
	else
		icon_state = base_icon_state

/obj/item/reagent_containers/glass/blastoff_ampoule/attack_self(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY) || spillable)
		return ..()
	reagent_flags |= OPENCONTAINER
	spillable = TRUE
	playsound(src, 'sound/items/ampoule_snap.ogg', 40)
	update_appearance()

/obj/item/reagent_containers/glass/blastoff_ampoule/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(.)
		return
	if(QDELING(src) || !hit_atom)	//Invalid loc
		return
	var/obj/item/shard/ampoule_shard = new(drop_location())
	playsound(src, "shatter", 40, TRUE)
	transfer_fingerprints_to(ampoule_shard)
	spillable = TRUE
	SplashReagents(hit_atom, TRUE)
	qdel(src)
	hit_atom.Bumped(ampoule_shard)
