/datum/artifact_origin
	var/type_name = "coder moment"
	var/name = "unknown"
	var/activation_sounds = list()
	var/adjectives = list()
	var/nouns_small = list()
	var/nouns_large = list()
	var/touch_descriptors = list()
	var/destroy_message = ""
	var/deactivation_sounds = list()
	var/max_icons = 1 // amount of sprites we have for this origin
	var/max_item_icons = 1 // amount of sprites we have for this origins items
	var/overlay_red_minimum = 225
	var/overlay_red_maximum = 255
	var/overlay_green_minimum = 225
	var/overlay_green_maximum = 255
	var/overlay_blue_minimum = 225
	var/overlay_blue_maximum = 255
	var/overlay_alpha_minimum = 225
	var/overlay_alpha_maximum = 255

/datum/artifact_origin/proc/generate_name()
		return FALSE

/datum/artifact_origin/wizard
	type_name = ORIGIN_WIZARD
	name = "Wizard"
	activation_sounds = list('sound/effects/stealthoff.ogg')
	adjectives = list("imposing","regal","majestic","beautiful","shiny")
	nouns_large = list("jewel","crystal","sculpture","statue","ornament")
	nouns_small = list("staff","pearl","rod","cane","wand","trophy")
	touch_descriptors = list("It feels warm.", "Its pleasant to touch.", "It feels smooth.")
	destroy_message = "shatters, and disintegrates!"
	overlay_red_minimum = 40
	overlay_red_maximum = 130
	overlay_green_minimum = 130
	overlay_green_maximum = 255
	overlay_blue_minimum = 130
	overlay_blue_maximum = 255
	overlay_alpha_minimum = 130
	var/list/mats = list("stone", "pearl", "golden", "ruby", "sapphire", "opal")
	var/list/object = list("crown","trophy","staff","boon","token","amulet")
	var/list/aspect = list("Yendor","wonder","eminence","grace","plenty","mystery")

/datum/artifact_origin/wizard/generate_name()
		return "[pick(mats)] [pick(object)] of [pick(aspect)]"

/datum/artifact_origin/narsie
	type_name = ORIGIN_NARSIE
	name = "Eldritch"
	activation_sounds = list('sound/effects/curse3.ogg','sound/effects/curse1.ogg')
	adjectives = list("imposing","sharp-edged","terrifying","jagged","dark")
	nouns_large = list("obelisk","altar","sculpture","statue","ornament")
	nouns_small = list("staff","pearl","rod","cane","wand","trophy")
	touch_descriptors = list("It feels cold.", "Its rough to the touch.", "You prick yourself on its rough surface!")
	destroy_message = "warps on itself, vanishing from sight!"
	overlay_red_minimum = 40
	overlay_red_maximum = 255
	overlay_green_minimum = 40
	overlay_green_maximum = 255
	overlay_blue_minimum = 40
	overlay_blue_maximum = 255

/datum/artifact_origin/silicon
	type_name = ORIGIN_SILICON
	name = "Ancient"
	activation_sounds = list('sound/items/modsuit/loader_charge.ogg')
	adjectives = list("cold","smooth","humming","droning")
	nouns_large = list("monolith","slab","obelisk","pylon")
	nouns_small = list("implement","device", "apparatus","mechanism")
	touch_descriptors = list("It feels cold.","Touching it makes you feel uneasy..","It feels smooth.")
	destroy_message = "sputters violently, falling apart!"
	max_icons = 3
	max_item_icons = 3

/datum/artifact_origin/silicon/generate_name()
		return "Unit-[pick(GLOB.phonetic_alphabet)] [pick(GLOB.phonetic_alphabet)] [rand(0,9000)]"
