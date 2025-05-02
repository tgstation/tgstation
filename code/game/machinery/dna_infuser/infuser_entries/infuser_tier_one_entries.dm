/*
 * Tier one entries are unlocked at the start, and are for dna mutants that are:
 * - easy to acquire (rats)
 * - have a bonus for getting past a threshold
 * - might serve a job purpose for others (goliath) and thus should be gainable early enough
*/
/datum/infuser_entry/goliath
	name = "Goliath"
	infuse_mob_name = "goliath"
	desc = "The guy who said 'Whoever fights monsters should see to it that in the process he does not become a monster' clearly didn't see what a goliath miner can do!"
	threshold_desc = "you can walk on lava!"
	qualities = list(
		"can breathe both the station and lavaland air, but be careful around pure oxygen",
		"immune to ashstorms",
		"eyes that can see in the dark",
		"a tendril hand can easily dig through basalt and obliterate hostile fauna, but your glove-wearing days are behind you...",
	)
	input_obj_or_mob = list(
		/mob/living/basic/mining/goliath,
	)
	output_organs = list(
		/obj/item/organ/brain/goliath,
		/obj/item/organ/eyes/night_vision/goliath,
		/obj/item/organ/heart/goliath,
		/obj/item/organ/lungs/lavaland/goliath,
	)
	infusion_desc = "armored tendril-like"
	tier = DNA_MUTANT_TIER_ONE
	status_effect_type = /datum/status_effect/organ_set_bonus/goliath

/datum/infuser_entry/carp
	name = "Carp"
	infuse_mob_name = "space-cyprinidae"
	desc = "Carp-mutants are very well-prepared for long term deep space exploration. In fact, they can't stand not doing it!"
	threshold_desc = "you learn how to propel yourself through space. Like a fish!"
	qualities = list(
		"big jaws, big teeth",
		"swim through space, no problem",
		"face every problem when you go back on station",
		"always wants to travel",
	)
	input_obj_or_mob = list(
		/mob/living/basic/carp,
	)
	output_organs = list(
		/obj/item/organ/brain/carp,
		/obj/item/organ/heart/carp,
		/obj/item/organ/lungs/carp,
		/obj/item/organ/tongue/carp,
	)
	infusion_desc = "nomadic"
	tier = DNA_MUTANT_TIER_ONE
	status_effect_type = /datum/status_effect/organ_set_bonus/carp

/datum/infuser_entry/rat
	name = "Rat"
	infuse_mob_name = "rodent"
	desc = "Frail, small, positively cheesed to face the world. Easy to stuff yourself full of rat DNA, but perhaps not the best choice?"
	threshold_desc = "you become lithe enough to crawl through ventilation."
	qualities = list(
		"cheesy lines",
		"will eat anything",
		"wants to eat anything, constantly",
		"frail but quick",
	)
	input_obj_or_mob = list(
		/obj/item/food/deadmouse,
	)
	output_organs = list(
		/obj/item/organ/eyes/night_vision/rat,
		/obj/item/organ/heart/rat,
		/obj/item/organ/stomach/rat,
		/obj/item/organ/tongue/rat,
	)
	infusion_desc = "skittish"
	tier = DNA_MUTANT_TIER_ONE
	status_effect_type = /datum/status_effect/organ_set_bonus/rat

/datum/infuser_entry/roach
	name = "Roach"
	infuse_mob_name = "cockroach"
	desc = "It seems as if you're a fan of ancient literature by your interest in this. Assuredly, merging cockroach DNA into your genome \
		will not cause you to become incapable of leaving your bed. These creatures are incredibly resilient against many things \
		humans are weak to, and we can use that! Who wouldn't like to survive a nuclear blast? \
		NOTE: Squished roaches will not work for the infuser, if that wasn't obvious. Try spraying them with some pestkiller from botany!"
	threshold_desc = "you will no longer be gibbed by explosions, and gain incredible resistance to viruses and radiation."
	qualities = list(
		"resilience to attacks from behind",
		"healthier organs",
		"get over disgust very quickly",
		"the ability to survive a nuclear apocalypse",
		"harder to pick yourself up from falling over",
		"avoid toxins at all costs",
		"always down to find a snack",
	)
	input_obj_or_mob = list(
		/mob/living/basic/cockroach,
	)
	output_organs = list(
		/obj/item/organ/heart/roach,
		/obj/item/organ/stomach/roach,
		/obj/item/organ/liver/roach,
		/obj/item/organ/appendix/roach,
	)
	infusion_desc = "kafkaesque" // Gregor Samsa !!
	tier = DNA_MUTANT_TIER_ONE
	status_effect_type = /datum/status_effect/organ_set_bonus/roach

/datum/infuser_entry/fish
	name = "Fish"
	infuse_mob_name = "fish"
	desc = "Aquatic life comes in several forms. A fisherman could tell you more about it, but that's beside the point. \
		This infusion comes with many benefits and one potential major drawback being fish-mutated lungs, with \
		additional organs depending on the traits of the fish used for the infusion."
	threshold_desc = "While wet, you're slightly sturdier, immune to slips, and both slippery and faster while crawling. \
		Drinking water and showers heal you, and it takes longer to dry out, however you're weaker when dry. \
		Finally, you resist high pressures and are better at fishing. "
	qualities = list(
		"faster in water",
		"resistant to food diseases",
		"enjoy eating raw fish",
		"flopping and waddling",
		"fishing is easier",
		"Need water. badly!",
		"possibly more",
	)
	input_obj_or_mob = list(
		/obj/item/fish,
	)
	output_organs = list(
		/obj/item/organ/lungs/fish,
		/obj/item/organ/stomach/fish,
		/obj/item/organ/tail/fish,
	)
	infusion_desc = "piscine"
	tier = DNA_MUTANT_TIER_ONE
	status_effect_type = /datum/status_effect/organ_set_bonus/fish

/datum/infuser_entry/fish/get_output_organs(mob/living/carbon/human/target, obj/item/fish/infused_from)
	if(!istype(infused_from))
		return ..()

	///Get a list of possible alternatives to the standard fish infusion. We prioritize special infusions over it.
	var/list/possible_alt_infusions = list()
	for(var/type in infused_from.fish_traits)
		var/datum/fish_trait/trait = GLOB.fish_traits[type]
		if(!trait.infusion_entry)
			continue
		var/datum/infuser_entry/entry = GLOB.infuser_entries[trait.infusion_entry]
		for(var/organ in entry.output_organs)
			if(!target.get_organ_by_type(organ))
				possible_alt_infusions |= entry
				break

	if(length(possible_alt_infusions))
		var/datum/infuser_entry/chosen = pick(possible_alt_infusions)
		return chosen.get_output_organs(target, infused_from)

	var/list/organs = ..()
	if(infused_from.required_fluid_type == AQUARIUM_FLUID_AIR || HAS_TRAIT(infused_from, TRAIT_FISH_AMPHIBIOUS))
		organs -= /obj/item/organ/lungs/fish
	return organs


/datum/infuser_entry/squid
	name = "Ink Production"
	infuse_mob_name = "ink-producing sealife"
	desc = "Some marine mollusks like cuttlefish, squids and octopus release ink when threatened as a smokescreen for their escape. \
		This kind of infusion enhances the salivary glands, producing excessive quantities of ink which can later be spat to blind foes."
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"spit ink to blind foes",
	)
	output_organs = list(
		/obj/item/organ/tongue/inky
	)
	tier = DNA_MUTANT_TIER_ONE

/datum/infuser_entry/ttx_healing
	name = "TTX healing"
	infuse_mob_name = "Tetraodontiformes"
	desc = "Fish of the Tetraodontiformes (pufferfish etc.) order are known for the highly poisonous tetrodotoxin (TTX) in their bodies. \
		Extracting their DNA can provide a way to utilize it for healing instead. It also enables better alcohol metabolization."
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"TTX healing",
		"drink like a fish",
	)
	output_organs = list(
		/obj/item/organ/liver/fish
	)
	tier = DNA_MUTANT_TIER_ONE
	unreachable_effect = TRUE
	status_effect_type = /datum/status_effect/organ_set_bonus/fish

/datum/infuser_entry/amphibious
	name = "Amphibious"
	infuse_mob_name = "Semi-aquatic critters"
	desc = "Some animals breathe air, some breath water, a few can breath both, even if none (at least on Earth) can breathe in space."
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"no need to breathe while wet",
		"can beathe water vapor",
	)
	input_obj_or_mob = list(
		/mob/living/basic/frog,
		/mob/living/basic/axolotl,
		/mob/living/basic/crab,
	)
	output_organs = list(
		/obj/item/organ/lungs/fish/amphibious,
	)
	infusion_desc = "semi-aquatic"
	tier = DNA_MUTANT_TIER_ONE
	unreachable_effect = TRUE
	status_effect_type = /datum/status_effect/organ_set_bonus/fish
