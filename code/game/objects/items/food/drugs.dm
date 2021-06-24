/obj/item/food/drug
	name = "generic drug"
	desc =  "I am error"
	//icon = 'icons/obj/drugs.dmi'
	food_flags = TOXIC
	max_volume = 50
	eat_time = 1 SECONDS
	tastes = list("drugs" = 1)
	eatverbs = list("gnaws" = 1)
	item_flags = ABSTRACT
	bite_consumption = 10

/obj/item/food/drug/saturnx
	name = "saturnX glob"
	desc = "A congealed glob of pure saturnX.\nThis compound was first discovered during the infancy of cloaking technology and at the time thought to be a promising cloaking agent cadidate. It was withdrawn for consideration after the researchers discovered a slew of associated safety issues including thought disorders and hepatoxicity.\nIt has since attained some limited popularity as a street drug."
	icon_state = "saturnx_glob" //tell kryson to sprite two more variants in the future.
	food_reagents = list() //add saturnX here. ANTLION

/obj/item/food/drug/moon_rock
	name = "moon rock"
	desc = "A small hard lump of kronkaine freebase.\nIt is said the average kronkaine addict causes as much criminal damage as four cat burglars, two arsonists and one rabid pit bull terrier combined."
	icon_state = "moon_rock1"
	food_reagents = list() //add kronkcaine here. ANTLION

/obj/item/food/drug/moon_rock/Initialize()
	. = ..()
	icon_state = pick("moon_rock1", "moon_rock2", "moon_rock3")

/obj/item/reagent_containers/glass/blastoff_ampoule
	name = "bLaSToFF ampoule" //stylized name
	desc = "A small ampoule. The liquid inside appears to be boiling violently.\nYou suspect it contains bLasSToFF; the drug thought to be the cause of the infamous Luna nightclub mass casuality incident."
	icon_state = "blastoff_ampoule"
	volume = 20
	reagent_flags = TRANSPARENT
	spillable = FALSE
	list_reagents = list() // add blastoff here ANTLION

/obj/item/reagent_containers/glass/blastoff_ampoule/update_icon_state()
	if(!reagents.total_volume)
		icon_state = "blastoff_empty"
	else if(is_open_container())
		icon_state = "blastoff_open"
	else
		icon_state = "blastoff_ampoule"

/obj/item/reagent_containers/glass/blastoff_ampoule/attack_self(mob/user)
	. = ..()
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY) && !is_open_container())
		reagent_flags = OPENCONTAINER
		spillable = TRUE
		return update_icon()

/obj/item/reagent_containers/food/drinks/blastoff_ampoule/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!.) //if the bottle wasn't caught
		if(QDELING(src) || !hit_atom)		//Invalid loc
			return
		var/obj/item/shard/ampoule_shard = new(drop_location())
		playsound(src, "shatter", 40, TRUE)
		transfer_fingerprints_to(ampoule_shard)
		spillable = TRUE
		SplashReagents(hit_atom, TRUE)
		qdel(src)
		hit_atom.Bumped(ampoule_shard)
