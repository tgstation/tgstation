// Tomato
/obj/item/seeds/tomato
	name = "pack of tomato seeds"
	desc = "These seeds grow into tomato plants."
	icon_state = "seed-tomato"
	species = "tomato"
	plantname = "Tomato Plants"
	product = /obj/item/food/grown/tomato
	maturation = 8
	instability = 25
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "tomato-grow"
	icon_dead = "tomato-dead"
	genes = list(/datum/plant_gene/trait/squash, /datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/tomato/blue, /obj/item/seeds/tomato/blood, /obj/item/seeds/tomato/killer)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	graft_gene = /datum/plant_gene/trait/squash

/obj/item/food/grown/tomato
	seed = /obj/item/seeds/tomato
	name = "tomato"
	desc = "I say to-mah-to, you say tom-mae-to."
	icon_state = "tomato"
	splat_type = /obj/effect/decal/cleanable/food/tomato_smudge
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/ketchup = 0)
	juice_results = list(/datum/reagent/consumable/tomatojuice = 0)
	distill_reagent = /datum/reagent/consumable/enzyme

// Blood Tomato
/obj/item/seeds/tomato/blood
	name = "pack of blood-tomato seeds"
	desc = "These seeds grow into blood-tomato plants."
	icon_state = "seed-bloodtomato"
	species = "bloodtomato"
	plantname = "Blood-Tomato Plants"
	product = /obj/item/food/grown/tomato/blood
	mutatelist = list()
	reagents_add = list(/datum/reagent/blood = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 20

/obj/item/food/grown/tomato/blood
	seed = /obj/item/seeds/tomato/blood
	name = "blood-tomato"
	desc = "So bloody...so...very...bloody....AHHHH!!!!"
	icon_state = "bloodtomato"
	bite_consumption_mod = 3
	splat_type = /obj/effect/gibspawner/generic
	foodtypes = FRUIT | GROSS
	grind_results = list(/datum/reagent/consumable/ketchup = 0, /datum/reagent/blood = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/bloody_mary

// Blue Tomato
/obj/item/seeds/tomato/blue
	name = "pack of blue-tomato seeds"
	desc = "These seeds grow into blue-tomato plants."
	icon_state = "seed-bluetomato"
	species = "bluetomato"
	plantname = "Blue-Tomato Plants"
	product = /obj/item/food/grown/tomato/blue
	yield = 2
	icon_grow = "bluetomato-grow"
	mutatelist = list(/obj/item/seeds/tomato/blue/bluespace)
	genes = list(/datum/plant_gene/trait/slip, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/lube = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 20
	graft_gene = /datum/plant_gene/trait/slip

/obj/item/food/grown/tomato/blue
	seed = /obj/item/seeds/tomato/blue
	name = "blue-tomato"
	desc = "I say blue-mah-to, you say blue-mae-to."
	icon_state = "bluetomato"
	bite_consumption_mod = 2
	splat_type = /obj/effect/decal/cleanable/oil
	distill_reagent = /datum/reagent/consumable/laughter

// Bluespace Tomato
/obj/item/seeds/tomato/blue/bluespace
	name = "pack of bluespace tomato seeds"
	desc = "These seeds grow into bluespace tomato plants."
	icon_state = "seed-bluespacetomato"
	species = "bluespacetomato"
	plantname = "Bluespace Tomato Plants"
	product = /obj/item/food/grown/tomato/blue/bluespace
	yield = 2
	mutatelist = list()
	genes = list(/datum/plant_gene/trait/squash, /datum/plant_gene/trait/slip, /datum/plant_gene/trait/teleport, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/lube = 0.2, /datum/reagent/bluespace = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 50
	graft_gene = /datum/plant_gene/trait/teleport

/obj/item/food/grown/tomato/blue/bluespace
	seed = /obj/item/seeds/tomato/blue/bluespace
	name = "\improper bluespace tomato"
	desc = "So lubricated, you might slip through space-time."
	icon_state = "bluespacetomato"
	bite_consumption_mod = 3
	distill_reagent = null
	wine_power = 80

/obj/item/food/grown/tomato/blue/bluespace/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	AddElement(/datum/element/plant_backfire, /obj/item/food/grown/tomato/blue/bluespace.proc/splat_user, extra_genes = list(/datum/plant_gene/trait/squash))

/*
 * Splat our tomato on our user. Called from [/datum/element/plant_backfire]
 *
 * user - the mob handling the bluespace tomato
 */
/obj/item/food/grown/tomato/blue/bluespace/proc/splat_user(mob/living/carbon/user)
	if(prob(50))
		to_chat(user, "<span class='danger'>[src] slips out of your hand!</span>")
		attack_self(user)

// Killer Tomato
/obj/item/seeds/tomato/killer
	name = "pack of killer-tomato seeds"
	desc = "These seeds grow into killer-tomato plants."
	icon_state = "seed-killertomato"
	species = "killertomato"
	plantname = "Killer-Tomato Plants"
	product = /obj/item/food/grown/tomato/killer
	yield = 2
	genes = list(/datum/plant_gene/trait/squash)
	growthstages = 2
	icon_grow = "killertomato-grow"
	icon_harvest = "killertomato-harvest"
	icon_dead = "killertomato-dead"
	mutatelist = list()
	rarity = 30

/obj/item/food/grown/tomato/killer
	seed = /obj/item/seeds/tomato/killer
	name = "\improper killer-tomato"
	desc = "I say to-mah-to, you say tom-mae-to... OH GOD IT'S EATING MY LEGS!!"
	icon_state = "killertomato"
	var/awakening = 0
	distill_reagent = /datum/reagent/consumable/ethanol/demonsblood

/obj/item/food/grown/tomato/killer/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	AddElement(/datum/element/plant_backfire, /obj/item/food/grown/tomato/killer.proc/early_awaken)

/obj/item/food/grown/tomato/killer/attack(mob/M, mob/user, def_zone)
	if(awakening)
		to_chat(user, "<span class='warning'>[src] is twitching and shaking, preventing you from eating it.</span>")
		return
	..()

/obj/item/food/grown/tomato/killer/attack_self(mob/user)
	if(awakening || isspaceturf(user.loc))
		return
	to_chat(user, "<span class='notice'>You begin to awaken [src]...</span>")
	begin_awaken(3 SECONDS)
	log_game("[key_name(user)] awakened a killer tomato at [AREACOORD(user)].")

/*
 * Begin the process of awakening the killer tomato.
 *
 * awaken_time - the time, in seconds, it will take for the tomato to spawn.
 */
/obj/item/food/grown/tomato/killer/proc/begin_awaken(awaken_time)
	awakening = TRUE
	addtimer(CALLBACK(src, .proc/awaken), awaken_time)

/*
 * Actually awaken the killer tomato, spawning the killer tomato mob.
 */
/obj/item/food/grown/tomato/killer/proc/awaken()
	if(QDELETED(src))
		return
	var/mob/living/simple_animal/hostile/killertomato/K = new /mob/living/simple_animal/hostile/killertomato(get_turf(src.loc))
	K.maxHealth += round(seed.endurance / 3)
	K.melee_damage_lower += round(seed.potency / 10)
	K.melee_damage_upper += round(seed.potency / 10)
	K.move_to_delay -= round(seed.production / 50)
	K.health = K.maxHealth
	K.visible_message("<span class='notice'>[src] growls as it suddenly awakens.</span>")
	qdel(src)

/*
 * Wakes up our tomato early. Called from [/datum/element/plant_backfire]
 *
 * user - the mob handling the killer tomato
 */
/obj/item/food/grown/tomato/killer/proc/early_awaken(mob/living/carbon/user)
	if(!awakening && prob(25))
		to_chat(user, "<span class='danger'>[src] begins to growl and shake!</span>")
		begin_awaken(1 SECONDS)
