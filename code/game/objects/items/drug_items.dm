/obj/item/food/drug
	name = "generic drug"
	desc =  "I am error"
	icon = 'icons/obj/drugs.dmi'
	food_flags = TOXIC
	max_volume = 50
	eat_time = 1 SECONDS
	tastes = list("drugs" = 1)
	eatverbs = list("gnaws" = 1)
	bite_consumption = 10

/obj/item/food/drug/saturnx
	name = "saturnX glob"
	desc = "A congealed glob of pure saturnX.\nIt was first discovered a long time ago during the infancy of cloaking technology and was once thought to be a promising candidate due to its unusual optical properties. It was withdrawn for consideration after the researchers discovered a slew of safety issues in animals including thought disorders and hepatoxicity.\nIt has since attained some limited popularity as a street drug."
	icon_state = "saturnx_glob" //tell kryson to sprite two more variants in the future.
	food_reagents = list() //add saturnX here. ANTLION

/obj/item/food/drug/moon_rock
	name = "moon rock"
	desc = "A small hard lump of kronkaine freebase."
	ícon_state = "moon_rock1"
	food_reagents = list() //add kronkcaine here. ANTLION

/obj/item/food/drug/moon_rock/Initialize()
	. = ..()
	icon_state = pick("moon_rock1", "moon_rock2", "moon_rock3")

/obj/item/reagent_containers/glass/blaztoff_ampoule
	name = "bLaSToFF ampoule" //stylized name
	desc = "" //ANTLION
	icon_state = "blastoff_ampoule"
	volume = 20
	reagent_flags = TRANSPARENT
	spillable = FALSE
	list_reagents = list() // add blastoff here ANTLION

/obj/item/reagent_containers/glass/blaztoff_ampoule/update_icon_state()
	if(!reagents.total_volume)
		icon_state = "blastoff_empty"
	else if(reagent_flags & OPEN_CONTAINER)
		icon_state = "blastoff_open"
	else
		icon_state = "blastoff_ampoule"

/obj/item/reagent_containers/glass/blaztoff_ampoule/attack_self(mob/user)
	. = ..()
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY) && !(reagent_flags & OPEN_CONTAINER))
		reagent_flags = OPEN_CONTAINER
		spillable = TRUE
		return update_icon()

/obj/item/reagent_containers/food/drinks/blaztoff_ampoule/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!.) //if the bottle wasn't caught
		if(QDELING(src) || !target)		//Invalid loc
			return
		var/obj/item/shard/ampoule_shard = new(drop_location())
		playsound(src, "shatter", 40, TRUE)
		transfer_fingerprints_to(ampoule_shard)
		spillable = TRUE
		SplashReagents(hit_atom, TRUE)
		qdel(src)
		target.Bumped(ampoule_shard)

