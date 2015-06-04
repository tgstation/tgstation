/datum/round_event_control/spooky
	name = "2 SPOOKY! (Halloween)"
	holidayID = HALLOWEEN
	typepath = /datum/round_event/spooky
	weight = -1							//forces it to be called, regardless of weight
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/spooky/start()
	..()
	for(var/mob/living/carbon/human/H in mob_list)
		var/obj/item/weapon/storage/backpack/b = locate() in H.contents
		new /obj/item/weapon/storage/spooky(b)
		if(H.dna)
			if(prob(50))
				hardset_dna(H, null, null, null, null, /datum/species/skeleton)
			else
				hardset_dna(H, null, null, null, null, /datum/species/zombie)

	for(var/mob/living/simple_animal/pet/corgi/Ian/Ian in mob_list)
		Ian.place_on_head(new /obj/item/weapon/bedsheet(Ian))

/datum/round_event/spooky/announce()
	priority_announce(pick("RATTLE ME BONES!","THE RIDE NEVER ENDS!", "A SKELETON POPS OUT!", "SPOOKY SCARY SKELETONS!", "CREWMEMBERS BEWARE, YOU'RE IN FOR A SCARE!") , "THE CALL IS COMING FROM INSIDE THE HOUSE")

//Eyeball migration
/datum/round_event_control/carp_migration/eyeballs
	name = "Eyeball Migration"
	typepath = /datum/round_event/carp_migration/eyeballs
	holidayID = HALLOWEEN
	weight = 25
	earliest_start = 0

/datum/round_event/carp_migration/eyeballs/start()
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			new /mob/living/simple_animal/hostile/carp/eyeball(C.loc)

//Pumpking meteors waves
/datum/round_event_control/meteor_wave/spooky
	name = "Pumpkin Wave"
	typepath = /datum/round_event/meteor_wave/spooky
	holidayID = HALLOWEEN
	weight = 20
	max_occurrences = 2

/datum/round_event/meteor_wave/spooky
	endWhen	= 40

/datum/round_event/meteor_wave/spooky/tick()
	if(IsMultiple(activeFor, 4))
		spawn_meteors(3, meteorsSPOOKY) //meteor list types defined in gamemode/meteor/meteors.dm

//spooky foods (you can't actually make these when it's not halloween)
/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookyskull
	name = "skull cookie"
	desc = "Spooky! It's got delicious calcium flavouring!"
	icon = 'icons/obj/halloween_items.dmi'
	icon_state = "skeletoncookie"

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookycoffin
	name = "coffin cookie"
	desc = "Spooky! It's got delicious coffee flavouring!"
	icon = 'icons/obj/halloween_items.dmi'
	icon_state = "coffincookie"


//spooky items

/obj/item/weapon/storage/spooky
	name = "trick-o-treat bag"
	desc = "A Pumpkin shaped bag that holds all sorts of goodies!"
	icon = 'icons/obj/halloween_items.dmi'
	icon_state = "treatbag"

/obj/item/weapon/storage/spooky/New()
	..()
	for(var/distrobuteinbag=0 to 5)
		var/type = pick(/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookyskull,
		/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookycoffin,
		/obj/item/weapon/reagent_containers/food/snacks/candy_corn,
		/obj/item/weapon/reagent_containers/food/snacks/candy,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar)
		new type(src)
