/datum/artifact_origin
	var/type_name = "coder moment"
	var/name = "unknown"
	var/activation_sounds = list()
	var/adjectives = list()
	var/nouns_small = list()
	var/nouns_large = list()
	var/touch_descriptors = list()
	proc/generate_name()
		return "unknown"

/datum/artifact_origin/wizard
	type_name = ORIGIN_WIZARD
	name = "wizard"
	activation_sounds = list('sound/effects/stealthoff.ogg')
	adjectives = list("ornate","imposing","regal","majestic","beautiful","shiny")
	nouns_large = list("jewel","crystal","sculpture","statue","ornament")
	nouns_small = list("staff","pearl","rod","cane","wand","trophy")
	touch_descriptors = list("It feels warm.", "Its pleasant to touch.", "It feels smooth.")
	var/list/mats = list("stone", "pearl", "golden", "ruby", "sapphire", "opal")
	var/list/object = list("crown","trophy","staff","boon","token","amulet")
	var/list/aspect = list("Yendor","wonder","eminence","grace","plenty","mystery")
	generate_name()
		return "[pick(mats)] [pick(object)] of [pick(aspect)]"

/datum/artifact_origin/narsie
	type_name = ORIGIN_NARSIE
	name = "eldritch"
	activation_sounds = list('sound/effects/curse3.ogg','sound/effects/curse1.ogg')
	adjectives = list("imposing","suspicious","terrifying","jagged","dark")
	nouns_large = list("obelisk","altar","sculpture","statue","ornament")
	nouns_small = list("staff","pearl","rod","cane","wand","trophy")
	touch_descriptors = list("It feels warm.", "Its pleasant to touch.", "It feels smooth.")
/datum/artifact_origin/silicon
	type_name = ORIGIN_SILICON
	name = "ancient"
	activation_sounds = list('sound/items/modsuit/loader_charge.ogg')
	adjectives = list("cold","smooth","humming","sharp-edged","droning")
	nouns_large = list("monolith","slab","obelisk","pylon")
	nouns_small = list("implement","device", "apparatus","mechanism")
	touch_descriptors = list("It feels cold.","Touching it makes you feel uneasy..","It feels smooth.")
	generate_name()
		return "Unit-[pick(GLOB.phonetic_alphabet)] [pick(GLOB.phonetic_alphabet)] [rand(0,9000)]"