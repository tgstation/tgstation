/obj/item/grenade/spawnergrenade
	desc = "It will unleash an unspecified anomaly in the surrounding vicinity."
	name = "delivery grenade"
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "delivery"
	inhand_icon_state = "flashbang"
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver

/obj/item/grenade/spawnergrenade/apply_grenade_fantasy_bonuses(quality)
	deliveryamt = modify_fantasy_variable("deliveryamt", deliveryamt, quality)

/obj/item/grenade/spawnergrenade/remove_grenade_fantasy_bonuses(quality)
	deliveryamt = reset_fantasy_variable("deliveryamt", deliveryamt)

/obj/item/grenade/spawnergrenade/detonate(mob/living/lanced_by) // Prime now just handles the two loops that query for people in lockers and people who can see it.
	. = ..()
	if(!.)
		return

	update_mob()
	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/target_turf = get_turf(src)
		playsound(target_turf, 'sound/effects/phasein.ogg', 100, TRUE)
		for(var/mob/living/carbon/target_carbon in viewers(target_turf, null))
			target_carbon.flash_act()

		// Spawn some hostile syndicate critters and spread them out
		var/list/spawned = spawn_and_random_walk(spawner_type, target_turf, deliveryamt, walk_chance = 50, admin_spawn = ((flags_1 & ADMIN_SPAWNED_1) ? TRUE : FALSE))
		afterspawn(spawned)
		for(var/mob/living/created as anything in spawned)
			ADD_TRAIT(created, TRAIT_SPAWNED_MOB, INNATE_TRAIT)

	qdel(src)

/obj/item/grenade/spawnergrenade/proc/afterspawn(list/mob/spawned)
	return

/obj/item/grenade/spawnergrenade/manhacks
	name = "viscerator delivery grenade"
	spawner_type = /mob/living/basic/viscerator
	deliveryamt = 10

/obj/item/grenade/spawnergrenade/spesscarp
	name = "carp delivery grenade"
	spawner_type = /mob/living/basic/carp
	deliveryamt = 5

/obj/item/grenade/spawnergrenade/syndiesoap
	name = "Mister Scrubby"
	spawner_type = /obj/item/soap/syndie

/obj/item/grenade/spawnergrenade/buzzkill
	name = "Buzzkill grenade"
	desc = "The label reads: \"WARNING: DEVICE WILL RELEASE LIVE SPECIMENS UPON ACTIVATION. SEAL SUIT BEFORE USE.\" It is warm to the touch and vibrates faintly."
	icon_state = "holy_grenade"
	spawner_type = /mob/living/basic/bee/toxin
	deliveryamt = 10

/obj/item/grenade/spawnergrenade/clown
	name = "C.L.U.W.N.E."
	desc = "A sleek device often given to clowns on their 10th birthdays for protection. You can hear faint scratching coming from within."
	icon_state = "clown_ball"
	inhand_icon_state = null
	spawner_type = list(/mob/living/basic/clown/fleshclown, /mob/living/basic/clown/clownhulk, /mob/living/basic/clown/longface, /mob/living/basic/clown/clownhulk/chlown, /mob/living/basic/clown/clownhulk/honkmunculus, /mob/living/basic/clown/mutant/glutton, /mob/living/basic/clown/banana, /mob/living/basic/clown/honkling, /mob/living/basic/clown/lube)
	deliveryamt = 1

/obj/item/grenade/spawnergrenade/clown_broken
	name = "stuffed C.L.U.W.N.E."
	desc = "A sleek device often given to clowns on their 10th birthdays for protection. While a typical C.L.U.W.N.E only holds one creature, sometimes foolish young clowns try to cram more in, often to disastrous effect."
	icon_state = "clown_broken"
	inhand_icon_state = null
	spawner_type = /mob/living/basic/clown/mutant
	deliveryamt = 5

/obj/item/grenade/spawnergrenade/cat
	name = "Catnade"
	desc = "You can hear faint meowing and the sounds of claws on metal coming from within."
	spawner_type = /mob/living/basic/pet/cat/feral
	deliveryamt = 5
