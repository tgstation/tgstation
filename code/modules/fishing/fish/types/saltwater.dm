/obj/item/fish/clownfish
	name = "clownfish"
	fish_id = "clownfish"
	desc = "Clownfish catch prey by swimming onto the reef, attracting larger fish, and luring them back to the anemone. The anemone will sting and eat the larger fish, leaving the remains for the clownfish."
	icon_state = "clownfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	sprite_width = 7
	sprite_height = 4
	average_size = 30
	average_weight = 500
	stable_population = 4
	fish_traits = list(/datum/fish_trait/picky_eater)
	evolution_types = list(/datum/fish_evolution/lubefish)
	compatible_types = list(/obj/item/fish/clownfish/lube)
	required_temperature_min = MIN_AQUARIUM_TEMP+22
	required_temperature_max = MIN_AQUARIUM_TEMP+30

/obj/item/fish/clownfish/get_fish_taste()
	return list("raw fish" = 2, "something funny" = 1)

/obj/item/fish/clownfish/lube
	name = "lubefish"
	fish_id = "lube"
	desc = "A clownfish exposed to cherry-flavored lube for far too long. First discovered the days following a cargo incident around the seas of Europa, when thousands of thousands of thousands..."
	icon_state = "lubefish"
	random_case_rarity = FISH_RARITY_VERY_RARE
	fish_traits = list(/datum/fish_trait/picky_eater, /datum/fish_trait/lubed)
	evolution_types = null
	compatible_types = list(/obj/item/fish/clownfish)
	food = /datum/reagent/lube
	fishing_difficulty_modifier = 5
	beauty = FISH_BEAUTY_GREAT

// become lubeman. but you suicide
/obj/item/fish/clownfish/lube/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] covers themselves in [src]'s residue, then swallows it whole! It looks like [user.p_theyre()] trying to commit lubide!"))
	user.AddComponent(/datum/component/slippery, 8 SECONDS, SLIDE|GALOSHES_DONT_HELP)
	user.AddElement(/datum/element/lube_walking)
	qdel(src)
	return OXYLOSS

/obj/item/fish/cardinal
	name = "cardinalfish"
	fish_id = "cardinal"
	desc = "Cardinalfish are often found near sea urchins, where the fish hide when threatened."
	icon_state = "cardinalfish"
	sprite_width = 6
	sprite_height = 3
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	average_size = 30
	average_weight = 500
	stable_population = 4
	fish_traits = list(/datum/fish_trait/vegan)
	required_temperature_min = MIN_AQUARIUM_TEMP+22
	required_temperature_max = MIN_AQUARIUM_TEMP+30

/obj/item/fish/greenchromis
	name = "green chromis"
	fish_id = "greenchromis"
	desc = "The Chromis can vary in color from blue to green depending on the lighting and distance from the lights."
	icon_state = "greenchromis"
	sprite_width = 5
	sprite_height = 3
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	average_size = 30
	average_weight = 500
	stable_population = 5
	required_temperature_min = MIN_AQUARIUM_TEMP+23
	required_temperature_max = MIN_AQUARIUM_TEMP+28

	fishing_difficulty_modifier = 5 // Bit harder

/obj/item/fish/firefish
	name = "firefish goby"
	fish_id = "firefish"
	desc = "To communicate in the wild, the firefish uses its dorsal fin to alert others of potential danger."
	icon_state = "firefish"
	sprite_width = 5
	sprite_height = 3
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	average_size = 30
	average_weight = 500
	stable_population = 3
	disliked_bait = list(/obj/item/food/bait/worm, /obj/item/food/bait/doughball)
	fish_movement_type = /datum/fish_movement/zippy
	required_temperature_min = MIN_AQUARIUM_TEMP+23
	required_temperature_max = MIN_AQUARIUM_TEMP+28

/obj/item/fish/pufferfish
	name = "pufferfish"
	fish_id = "pufferfish"
	desc = "They say that one pufferfish contains enough toxins to kill 30 people, although in the last few decades they've been genetically engineered en masse to be less poisonous."
	icon_state = "pufferfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	sprite_width = 8
	sprite_height = 6
	average_size = 60
	average_weight = 1000
	stable_population = 3
	required_temperature_min = MIN_AQUARIUM_TEMP+23
	required_temperature_max = MIN_AQUARIUM_TEMP+28
	fillet_type = /obj/item/food/fishmeat/quality //Too bad they're poisonous
	fish_traits = list(/datum/fish_trait/heavy, /datum/fish_trait/toxic)
	beauty = FISH_BEAUTY_GOOD

/obj/item/fish/pufferfish/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] bites into [src] and starts sucking on it! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/fish/lanternfish
	name = "lanternfish"
	fish_id = "lanternfish"
	desc = "Typically found in areas below 6600 feet below the surface of the ocean, they live in complete darkness."
	icon_state = "lanternfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	random_case_rarity = FISH_RARITY_VERY_RARE
	sprite_width = 6
	sprite_height = 5
	average_size = 50
	average_weight = 1000
	stable_population = 3
	fish_traits = list(/datum/fish_trait/nocturnal)
	required_temperature_min = MIN_AQUARIUM_TEMP+2 //My source is that the water at a depth 6600 feet is pretty darn cold.
	required_temperature_max = MIN_AQUARIUM_TEMP+18
	beauty = FISH_BEAUTY_NULL

/obj/item/fish/stingray
	name = "stingray"
	fish_id = "stingray"
	desc = "A type of ray, most known for its venomous stinger. Despite that, They're normally docile, if not a bit easily frightened."
	icon_state = "stingray"
	stable_population = 4
	sprite_height = 7
	sprite_width = 8
	average_size = 60
	average_weight = 700
	beauty = FISH_BEAUTY_GREAT
	random_case_rarity = FISH_RARITY_RARE
	required_fluid_type = AQUARIUM_FLUID_SALTWATER //Someone ought to add river rays later I guess.
	fish_traits = list(/datum/fish_trait/stinger, /datum/fish_trait/toxic_barbs, /datum/fish_trait/wary, /datum/fish_trait/carnivore, /datum/fish_trait/predator)

/obj/item/fish/swordfish
	name = "swordfish"
	fish_id = "swordfish"
	desc = "A large billfish, most famous for its elongated bill, while also fairly popular for cooking, and as a fearsome weapon in the hands of a veteran spess-fisherman."
	icon = 'icons/obj/aquarium/wide.dmi'
	icon_state = "swordfish"
	inhand_icon_state = "swordfish"
	force = 18
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("slashes", "cuts", "pierces")
	attack_verb_simple = list("slash", "cut", "pierce")
	block_sound = 'sound/items/weapons/parry.ogg'
	hitsound = 'sound/items/weapons/rapierhit.ogg'
	demolition_mod = 0.75
	attack_speed = 1 SECONDS
	block_chance = 50
	wound_bonus = 10
	bare_wound_bonus = 20
	armour_penetration = 75
	base_pixel_w = -18
	pixel_w = -18
	sprite_width = 13
	sprite_height = 6
	stable_population = 3
	average_size = 140
	average_weight = 4000
	breeding_timeout = 4.5 MINUTES
	feeding_frequency = 4 MINUTES
	health = 180
	beauty = FISH_BEAUTY_EXCELLENT
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	fish_movement_type = /datum/fish_movement/plunger
	fishing_difficulty_modifier = 25
	fillet_type = /obj/item/food/fishmeat/quality
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = SEAFOOD,
		),
		/obj/item/fish,
	)
	fish_traits = list(/datum/fish_trait/carnivore, /datum/fish_trait/predator, /datum/fish_trait/stinger)

/obj/item/fish/swordfish/get_force_rank()
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			force -= 11
			attack_speed -= 0.4 SECONDS
			block_chance -= 45
			armour_penetration -= 20
			wound_bonus -= 15
			bare_wound_bonus -= 20
		if(WEIGHT_CLASS_SMALL)
			force -= 8
			attack_speed -= 0.3 SECONDS
			block_chance -= 30
			armour_penetration -= 15
			wound_bonus -= 10
			bare_wound_bonus -= 20
		if(WEIGHT_CLASS_NORMAL)
			force -= 5
			attack_speed -= 0.2 SECONDS
			block_chance -= 20
			armour_penetration -= 10
			wound_bonus -= 10
			bare_wound_bonus -= 15
		if(WEIGHT_CLASS_BULKY)
			force -= 3
			attack_speed -= 0.1 SECONDS
			block_chance -= 10
			armour_penetration -= 5
			wound_bonus -= 5
			bare_wound_bonus -= 10
		if(WEIGHT_CLASS_GIGANTIC)
			force += 5
			attack_speed += 0.2 SECONDS
			demolition_mod += 0.15
			block_chance += 10
			armour_penetration += 5
			wound_bonus += 5
			bare_wound_bonus += 10

	if(status == FISH_DEAD)
		force -= 4 + w_class
		block_chance -= 25
		armour_penetration -= 30
		wound_bonus -= 10
		bare_wound_bonus -= 10

/obj/item/fish/swordfish/calculate_fish_force_bonus(bonus_malus)
	. = ..()
	armour_penetration += bonus_malus * 5
	wound_bonus += bonus_malus * 3
	bare_wound_bonus += bonus_malus * 5
	block_chance += bonus_malus * 7

/obj/item/fish/squid
	name = "squid"
	fish_id = "squid"
	desc = "An elongated mollusk with eight tentacles, natural camouflage and ink clouds to spray at predators. One of the most intelligent, well-equipped invertebrates out there."
	icon_state = "squid"
	sprite_width = 4
	sprite_height = 5
	stable_population = 6
	weight_size_deviation = 0.5 // They vary greatly in size.
	average_weight = 500 //They're quite lighter than they're long.
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	beauty = FISH_BEAUTY_GOOD
	required_temperature_min = MIN_AQUARIUM_TEMP+5
	required_temperature_max = MIN_AQUARIUM_TEMP+26
	fish_traits = list(/datum/fish_trait/heavy, /datum/fish_trait/carnivore, /datum/fish_trait/predator, /datum/fish_trait/ink, /datum/fish_trait/camouflage, /datum/fish_trait/wary)

/obj/item/fish/squid/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] points [src]'s ink glands at their face and presses INCREDIBLY hard! It looks like [user.p_theyre()] trying to commit squidcide!"))

	// No head? Bozo.
	var/obj/item/bodypart/head = user.get_bodypart(BODY_ZONE_HEAD)
	if(isnull(head))
		user.visible_message(span_suicide("[user] has no head! The ink goes flying by!"))
		return SHAME

	// get inked.
	user.visible_message(span_warning("[user] is inked by [src]!"), span_userdanger("You've been inked by [src]!"))
	user.AddComponent(/datum/component/face_decal/splat, \
		color = COLOR_NEARLY_ALL_BLACK, \
		memory_type = /datum/memory/witnessed_inking, \
		mood_event_type = /datum/mood_event/inked, \
	)
	playsound(user, SFX_DESECRATION, 50, TRUE)

	if(!HAS_TRAIT(user, TRAIT_STRENGTH) && !HAS_TRAIT(user, TRAIT_HULK))
		return OXYLOSS

	head.dismember(silent = FALSE)
	user.visible_message(span_suicide("[user]'s head goes FLYING OFF from the overpressurized ink jet!"))
	return MANUAL_SUICIDE

/obj/item/fish/squid/get_fish_taste()
	return list("raw mollusk" = 2)

/obj/item/fish/squid/get_fish_taste_cooked()
	return list("cooked mollusk" = 2, "tenderness" = 0.5)

/obj/item/fish/monkfish
	name = "monkfish"
	fish_id = "monkfish"
	desc = "A member of the Lophiid family of anglerfish. It goes by several different names, however none of them will make it look any prettier, nor be any less delicious."
	icon_state = "monkfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	sprite_height = 7
	sprite_width = 7
	beauty = FISH_BEAUTY_UGLY
	required_temperature_min = MIN_AQUARIUM_TEMP+2
	required_temperature_max = MIN_AQUARIUM_TEMP+23
	average_size = 60
	average_weight = 1400
	stable_population = 4
	fish_traits = list(/datum/fish_trait/heavy)
	fillet_type = /obj/item/food/fishmeat/quality
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = SEAFOOD|BUGS,
		),
	)

/obj/item/fish/monkfish/Initialize(mapload, apply_qualities = TRUE)
	. = ..()
	name = pick("monkfish", "fishing-frog", "frog-fish", "sea-devil", "goosefish")

/obj/item/fish/plaice
	name = "plaice"
	fish_id = "plaice"
	desc = "Perhaps the most prominent flatfish in the space-market. Nature really pulled out the rolling pin on this one."
	icon_state = "plaice"
	sprite_height = 7
	sprite_width = 6
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	required_temperature_min = MIN_AQUARIUM_TEMP+2
	required_temperature_max = MIN_AQUARIUM_TEMP+18
	average_size = 40
	average_weight = 700
	stable_population = 5
	fish_traits = list(/datum/fish_trait/heavy)
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = SEAFOOD|BUGS,
		),
	)

