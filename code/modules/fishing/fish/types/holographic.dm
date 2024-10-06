
/obj/item/fish/holo
	name = "holographic goldfish"
	desc = "A holographic representation of a common goldfish, slowly flickering out, removed from its holo-habitat."
	icon_state = /obj/item/fish/goldfish::icon_state
	fish_flags = parent_type::fish_flags & ~(FISH_FLAG_SHOW_IN_CATALOG|FISH_FLAG_EXPERIMENT_SCANNABLE)
	random_case_rarity = FISH_RARITY_NOPE
	dedicated_in_aquarium_icon_state = /obj/item/fish/goldfish::dedicated_in_aquarium_icon_state
	aquarium_vc_color = /obj/item/fish/goldfish::aquarium_vc_color
	sprite_width = /obj/item/fish/goldfish::sprite_width
	sprite_height = /obj/item/fish/goldfish::sprite_height
	stable_population = 1
	average_size = /obj/item/fish/goldfish::average_size
	average_weight = /obj/item/fish/goldfish::average_weight
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	fillet_type = null
	death_text = "%SRC gently disappears."
	fish_traits = list(/datum/fish_trait/no_mating) //just to be sure, these shouldn't reproduce
	beauty = /obj/item/fish/goldfish::beauty

/obj/item/fish/holo/Initialize(mapload, apply_qualities = TRUE)
	. = ..()
	var/area/station/holodeck/holo_area = get_area(src)
	if(!istype(holo_area))
		addtimer(CALLBACK(src, PROC_REF(set_status), FISH_DEAD), 1 MINUTES)
		return
	holo_area.linked.add_to_spawned(src)

/obj/item/fish/holo/make_edible(weight_val)
	return

/obj/item/fish/holo/set_status(new_status, silent = FALSE)
	. = ..()
	if(status == FISH_DEAD)
		animate(src, alpha = 0, 3 SECONDS, easing = SINE_EASING)
		QDEL_IN(src, 3 SECONDS)

/obj/item/fish/holo/crab
	name = "holographic crab"
	desc = "A holographic represantion of a soul-crushingly soulless crab, unlike the cuter ones occasionally roaming around. It stares at you, with empty, beady eyes."
	icon_state = "crab"
	dedicated_in_aquarium_icon_state = null
	aquarium_vc_color = null
	average_size = 30
	average_weight = 1000
	sprite_height = 6
	sprite_width = 10
	beauty = FISH_BEAUTY_GOOD

/obj/item/fish/holo/puffer
	name = "holographic pufferfish"
	desc ="A holographic representation of 100% safe-to-eat pufferfish... that is, if holographic fishes were even edible."
	icon_state = /obj/item/fish/pufferfish::icon_state
	dedicated_in_aquarium_icon_state = /obj/item/fish/pufferfish::dedicated_in_aquarium_icon_state
	aquarium_vc_color = /obj/item/fish/pufferfish::aquarium_vc_color
	average_size = /obj/item/fish/pufferfish::average_size
	average_weight = /obj/item/fish/pufferfish::average_weight
	sprite_height = /obj/item/fish/pufferfish::sprite_height
	sprite_width = /obj/item/fish/pufferfish::sprite_width
	beauty = /obj/item/fish/pufferfish::beauty

/obj/item/fish/holo/angel
	name = "holographic angelfish"
	desc = "A holographic representation of a angelfish. I got nothing snarky to say about this one."
	icon_state = /obj/item/fish/angelfish::icon_state
	dedicated_in_aquarium_icon_state = /obj/item/fish/angelfish::dedicated_in_aquarium_icon_state
	aquarium_vc_color = /obj/item/fish/angelfish::aquarium_vc_color
	average_size = /obj/item/fish/angelfish::average_size
	average_weight = /obj/item/fish/angelfish::average_weight
	sprite_height = /obj/item/fish/angelfish::sprite_height
	sprite_width = /obj/item/fish/angelfish::sprite_width
	beauty = /obj/item/fish/angelfish::beauty

/obj/item/fish/holo/clown
	name = "holographic clownfish"
	icon_state = "holo_clownfish"
	desc = "A holographic representation of a clownfish, or at least how they used to look like five centuries ago."
	dedicated_in_aquarium_icon_state = null
	aquarium_vc_color = /obj/item/fish/clownfish::aquarium_vc_color
	average_size = /obj/item/fish/clownfish::average_size
	average_weight = /obj/item/fish/clownfish::average_weight
	sprite_height = /obj/item/fish/clownfish::sprite_height
	sprite_width = /obj/item/fish/clownfish::sprite_width
	required_fluid_type = /obj/item/fish/clownfish::required_fluid_type
	beauty = /obj/item/fish/clownfish::beauty

/obj/item/fish/holo/checkered
	name = "unrendered holographic fish"
	desc = "A checkered silhoutte of searing purple and pitch black presents itself before your eyes, like a tear in fabric of reality. It hurts to watch."
	icon_state = "checkered" //it's a meta joke, buddy.
	dedicated_in_aquarium_icon_state = null
	aquarium_vc_color = null
	average_size = 30
	average_weight = 500
	sprite_width = 4
	sprite_height = 3
	beauty = FISH_BEAUTY_NULL

/obj/item/fish/holo/halffish
	name = "holographic half-fish"
	desc = "A holographic representation of... a fish reduced to all bones, except for its head. Isn't it supposed to be dead? Ehr, holo-dead?"
	icon_state = "half_fish"
	dedicated_in_aquarium_icon_state = null
	aquarium_vc_color = null
	sprite_height = 4
	sprite_width = 10
	average_size = 50
	average_weight = 500
	beauty = FISH_BEAUTY_UGLY
