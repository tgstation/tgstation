//SKYRAT GOOD TRAITS

/datum/quirk/hard_soles
	name = "Hardened Soles"
	desc = "You're used to walking barefoot, and won't receive the negative effects of doing so."
	value = 2
	mob_trait = TRAIT_HARD_SOLES
	gain_text = "<span class='notice'>The ground doesn't feel so rough on your feet anymore.</span>"
	lose_text = "<span class='danger'>You start feeling the ridges and imperfections on the ground.</span>"
	medical_record_text = "Patient's feet are more resilient against traction."
	icon = "boot"

/datum/quirk/linguist
	name = "Linguist"
	desc = "You're a student of numerous languages and come with an additional language point."
	value = 4
	mob_trait = QUIRK_LINGUIST
	gain_text = span_notice("Your brain seems more equipped to handle different modes of conversation.")
	lose_text = span_danger("Your grasp of the finer points of Draconic idioms fades away.")
	medical_record_text = "Patient demonstrates a high brain plasticity in regards to language learning."
	icon = "globe"

//AdditionalEmotes *turf quirks
/datum/quirk/water_aspect
	name = "Water aspect (Emotes)"
	desc = "(Aquatic innate) Underwater societies are home to you, space ain't much different. (Say *turf to cast)"
	value = 0
	mob_trait = TRAIT_WATER_ASPECT
	gain_text = "<span class='notice'>You feel like you can control water.</span>"
	lose_text = "<span class='danger'>Somehow, you've lost your ability to control water!</span>"
	medical_record_text = "Patient holds a collection of nanobots designed to synthesize H2O."
	icon = "water"

/datum/quirk/webbing_aspect
	name = "Webbing aspect (Emotes)"
	desc = "(Insect innate) Insect folk capable of weaving aren't unfamiliar with receiving envy from those lacking a natural 3D printer. (Say *turf to cast)"
	value = 0
	mob_trait = TRAIT_WEBBING_ASPECT
	gain_text = "<span class='notice'>You could easily spin a web.</span>"
	lose_text = "<span class='danger'>Somehow, you've lost your ability to weave.</span>"
	medical_record_text = "Patient has the ability to weave webs with naturally synthesized silk."
	icon = "spider-web"

/datum/quirk/floral_aspect
	name = "Floral aspect (Emotes)"
	desc = "(Podperson innate) Kudzu research isn't pointless, rapid photosynthesis technology is here! (Say *turf to cast)"
	value = 0
	mob_trait = TRAIT_FLORAL_ASPECT
	gain_text = "<span class='notice'>You feel like you can grow vines.</span>"
	lose_text = "<span class='danger'>Somehow, you've lost your ability to rapidly photosynthesize.</span>"
	medical_record_text = "Patient can rapidly photosynthesize to grow vines."
	icon = "seedling"

/datum/quirk/ash_aspect
	name = "Ash aspect (Emotes)"
	desc = "(Lizard innate) The ability to forge ash and flame, a mighty power - yet mostly used for theatrics. (Say *turf to cast)"
	value = 0
	mob_trait = TRAIT_ASH_ASPECT
	gain_text = "<span class='notice'>There is a forge smouldering inside of you.</span>"
	lose_text = "<span class='danger'>Somehow, you've lost your ability to breathe fire.</span>"
	medical_record_text = "Patients possess a fire breathing gland commonly found in lizard folk."
	icon = "fire"

/datum/quirk/sparkle_aspect
	name = "Sparkle aspect (Emotes)"
	desc = "(Moth innate) Sparkle like the dust off of a moth's wing, or like a cheap red-light hook-up. (Say *turf to cast)"
	value = 0
	mob_trait = TRAIT_SPARKLE_ASPECT
	gain_text = "<span class='notice'>You're covered in sparkling dust!</span>"
	lose_text = "<span class='danger'>Somehow, you've completely cleaned yourself of glitter..</span>"
	medical_record_text = "Patient seems to be looking fabulous."
	icon = "hand-sparkles"
