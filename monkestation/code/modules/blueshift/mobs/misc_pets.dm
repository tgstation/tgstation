/mob/living/simple_animal/pet/gondola/funky
	name = "Funky"
	real_name = "Funky"
	desc = "Gondola is the silent walker. Having no hands he embodies the Taoist principle of wu-wei (non-action) while his smiling facial expression shows his utter and complete acceptance of the world as it is. Its hide is extremely valuable. This one seems a little skinny and attached to the Theater."
	loot = list(/obj/effect/decal/cleanable/blood/gibs)

/mob/living/basic/pet/dog/dobermann/walter
	name = "Walter"
	real_name = "Walter"
	desc = "It's Walter, he bites criminals just as well as he bites toddlers."

/mob/living/basic/rabbit/daisy
	name = "Daisy"
	real_name = "Daisy"
	desc = "The Curator's pet bnuuy."
	gender = FEMALE

/mob/living/basic/bear/wojtek
	name = "Wojtek"
	real_name = "Wojtek"
	desc = "The bearer of Bluespace Artillery."
	faction = list(FACTION_NEUTRAL)
	gender = MALE

/mob/living/basic/chicken/teshari
	name = "Teshari"
	real_name = "Teshari"
	desc = "A timeless classic."
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 30000

/mob/living/basic/lizard/tegu
	name = "tegu"
	desc = "That's a tegu."
	icon = 'monkestation/code/modules/blueshift/icons/mob/pets.dmi'
	icon_state = "tegu"
	icon_living = "tegu"
	icon_dead = "tegu_dead"
	health = 20
	maxHealth = 20
	melee_damage_lower = 16 //They do have a nasty bite
	melee_damage_upper = 16
	pass_flags = PASSTABLE

/mob/living/basic/lizard/tegu/gus
	name = "Gus"
	real_name = "Gus"
	desc = "The Research Department's beloved pet tegu."
	gender = MALE
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/crab/shuffle
	name = "Shuffle"
	real_name = "Shuffle"
	desc = "Oh no, it's him!"
	color = "#ff0000"
	gender = MALE
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/crab/shuffle/Initialize(mapload)
	. = ..()
	update_transform(0.5)

/mob/living/basic/carp/mega/shorki
	name = "Shorki"
	desc = "A not so ferocious, fang bearing creature that resembles a shark. This one seems a little big for its tank."
	faction = list(FACTION_NEUTRAL)
	gender = MALE
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/carp/pet

/mob/living/basic/pet/dog/markus
	name = "\proper Markus"
	desc = "The supply department's overfed yet still beloved dog."
	icon = 'monkestation/code/modules/blueshift/icons/mob/pets.dmi'
	icon_state = "markus"
	icon_dead = "markus_dead"
	icon_living = "markus"
	butcher_results = list(
		/obj/item/food/burger/cheese = 1,
		/obj/item/food/meat/slab = 2,
		/obj/item/trash/syndi_cakes = 1,
		)
	ai_controller = /datum/ai_controller/basic_controller/dog/corgi
	gender = MALE
	can_be_held = FALSE
	gold_core_spawnable = FRIENDLY_SPAWN
	///can this mob breed?
	var/can_breed = TRUE

	/// List of possible dialogue options. This is both used by the AI and as an override when a sentient Markus speaks.
	var/static/list/markus_speak = list("Borf!", "Boof!", "Bork!", "Bowwow!", "Burg?")

/mob/living/basic/pet/dog/markus/Initialize(mapload)
	. = ..()
	if(!can_breed)
		return
	AddComponent(\
		/datum/component/breed,\
		can_breed_with = typecacheof(list(/mob/living/basic/pet/dog/corgi)),\
		baby_path = /mob/living/basic/pet/dog/corgi/puppy,\
	) // no mixed breed puppies sadly

/mob/living/basic/pet/dog/markus/treat_message(message)
	if(client)
		message = pick(markus_speak) // markus only talks business
	return ..()

/mob/living/basic/pet/dog/markus/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	. = ..()
	speech.speak = markus_speak

/datum/chemical_reaction/mark_reaction
	results = list(/datum/reagent/consumable/liquidgibs = 15)
	required_reagents = list(
		/datum/reagent/blood = 20,
		/datum/reagent/medicine/omnizine = 20,
		/datum/reagent/medicine/c2/synthflesh = 20,
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/ketchup = 5,
		/datum/reagent/consumable/mayonnaise = 5,
		/datum/reagent/colorful_reagent/powder/yellow/crayon = 5,
	)

	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	required_temp = 480

/datum/chemical_reaction/mark_reaction/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	. = ..()
	var/location = get_turf(holder.my_atom)
	new /mob/living/basic/pet/dog/markus(location)
