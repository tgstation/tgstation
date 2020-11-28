/datum/body_marking_set
	///The preview name of the body marking set. HAS to be unique
	var/name
	///List of the body markings in this set
	var/body_marking_list
	///Which species is this marking recommended to. Important for randomisations.
	var/recommended_species = list("mammal", "tajaran", "vulpkanin", "aquatic", "akula")

/datum/body_marking_set/none
	name = "None"
	recommended_species = null
	body_marking_list = list()

/datum/body_marking_set/tajaran
	name = "Tajaran"
	body_marking_list = list("Tajaran")

/datum/body_marking_set/fox
	name = "Fox"
	body_marking_list = list("Fox", "Fox Sock")

/datum/body_marking_set/sergal
	name = "Sergal"
	body_marking_list = list("Sergal")

/datum/body_marking_set/husky
	name = "Husky"
	body_marking_list = list("Husky")

/datum/body_marking_set/fennec
	name = "Fennec"
	body_marking_list = list("Fennec")

/datum/body_marking_set/redpanda
	name = "Red Panda"
	body_marking_list = list("Red Panda", "Red Panda Head")

/datum/body_marking_set/dalmatian
	name = "Dalmatian"
	body_marking_list = list("Dalmatian")

/datum/body_marking_set/shepherd
	name = "Shepherd"
	body_marking_list = list("Shepherd", "Shepherd Spot")

/datum/body_marking_set/wolf
	name = "Wolf"
	body_marking_list = list("Wolf", "Wolf Spot")

/datum/body_marking_set/raccoon
	name = "Raccoon"
	body_marking_list = list("Raccoon")

/datum/body_marking_set/bovine
	name = "Bovine"
	body_marking_list = list("Bovine", "Bovine Spot")

/datum/body_marking_set/possum
	name = "Possum"
	body_marking_list = list("Possum")
	
/datum/body_marking_set/corgi
	name = "Corgi"
	body_marking_list = list("Corgi")

/datum/body_marking_set/skunk
	name = "Skunk"
	body_marking_list = list("Skunk")

/datum/body_marking_set/panther
	name = "Panther"
	body_marking_list = list("Panther")

/datum/body_marking_set/tiger
	name = "Tiger"
	body_marking_list = list("Tiger Spot", "Tiger Stripe")
	
/datum/body_marking_set/otter
	name = "Otter"
	body_marking_list = list("Otter", "Otter Head")

/datum/body_marking_set/otie
	name = "Otie"
	body_marking_list = list("Otie", "Otie Spot")

/datum/body_marking_set/sabresune
	name = "Sabresune"
	body_marking_list = list("Sabresune")

/datum/body_marking_set/orca
	name = "Orca"
	body_marking_list = list("Orca")
	
/datum/body_marking_set/hawk
	name = "Hawk"
	body_marking_list = list("Hawk", "Hawk Talon")

/datum/body_marking_set/corvid
	name = "Corvid"
	body_marking_list = list("Corvid", "Corvid Talon")

/datum/body_marking_set/eevee
	name = "Eevee"
	body_marking_list = list("Eevee")

/datum/body_marking_set/deer
	name = "Deer"
	body_marking_list = list("Deer", "Deer Hoof")

/datum/body_marking_set/hyena
	name = "Hyena"
	body_marking_list = list("Hyena", "Hyena Side")

/datum/body_marking_set/dog
	name = "Dog"
	body_marking_list = list("Dog", "Dog Spot")

/datum/body_marking_set/bat
	name = "Bat"
	body_marking_list = list("Bat Mark", "Bat")

/datum/body_marking_set/goat
	name = "Goat"
	body_marking_list = list("Goat Hoof")

/datum/body_marking_set/floof
	name = "Floof"
	body_marking_list = list("Floof")

/datum/body_marking_set/floofer
	name = "Floofer"
	body_marking_list = list("Floof", "Floofer Sock")

/datum/body_marking_set/rat
	name = "Rat"
	body_marking_list = list("Rat Paw", "Rat Spot")

/datum/body_marking_set/sloth
	name = "Sloth"
	body_marking_list = list("Rat Paw", "Sloth Head") //Yes we're re-using the rat bits as they'd be identical

/datum/body_marking_set/scolipede
	name = "Scolipede"
	body_marking_list = list("Scolipede", "Scolipede Spikes")

/datum/body_marking_set/guilmon
	name = "Guilmon"
	body_marking_list = list("Guilmon", "Guilmon Mark")

/datum/body_marking_set/xeno
	name = "Xeno"
	body_marking_list = list("Xeno", "Xeno Head")

/datum/body_marking_set/datashark
	name = "Datashark"
	body_marking_list = list("Datashark")

/datum/body_marking_set/shark
	name = "Shark"
	body_marking_list = list("Shark")

/datum/body_marking_set/belly
	name = "Belly"
	body_marking_list = list("Belly")

/datum/body_marking_set/belly_slim
	name = "Belly Slim"
	body_marking_list = list("Belly Slim")

/datum/body_marking_set/hands_feet
	name = "Hands Feet"
	body_marking_list = list("Hands Feet")

/datum/body_marking_set/frog
	name = "Frog"
	body_marking_list = list("Frog")

/datum/body_marking_set/bee
	name = "Bee"
	body_marking_list = list("Bee")

/datum/body_marking_set/gradient
	name = "Gradient"
	body_marking_list = list("Gradient")

/datum/body_marking_set/harlequin
	name = "Harlequin"
	body_marking_list = list("Harlequin")

/datum/body_marking_set/harlequin_reversed
	name = "Harlequin Reversed"
	body_marking_list = list("Harlequin Reversed")

/datum/body_marking_set/plain
	name = "Plain"
	body_marking_list = list("Plain")

//VOX MARKINGS
/datum/body_marking_set/vox
	recommended_species = list("vox")

/datum/body_marking_set/vox/vox
	name = "Vox"
	body_marking_list = list("Vox Talon")

/datum/body_marking_set/vox/vox_tiger
	name = "Vox Tiger"
	body_marking_list = list("Vox Talon", "Vox Tiger Tattoo")

/datum/body_marking_set/vox/vox_hive
	name = "Vox Hive"
	body_marking_list = list("Vox Talon", "Vox Hive Tattoo")

/datum/body_marking_set/vox/vox_nightling
	name = "Vox Nightling"
	body_marking_list = list("Vox Talon", "Vox Nightling Tattoo")

/datum/body_marking_set/vox/vox_heart
	name = "Vox Heart"
	body_marking_list = list("Vox Talon", "Vox Heart Tattoo")

/datum/body_marking_set/synthliz
	recommended_species = list("synthliz")

/datum/body_marking_set/synthliz/scutes
	name = "Synth Scutes"
	body_marking_list = list("Synth Scutes")

/datum/body_marking_set/synthliz/pecs
	name = "Synth Pecs"
	body_marking_list = list("Synth Pecs")

/datum/body_marking_set/synthliz/pecs_light
	name = "Synth Pecs Lights"
	body_marking_list = list("Synth Pecs", "Synth Collar Lights")

//MOTH

/datum/body_marking_set/moth
	recommended_species = list("moth")

/datum/body_marking_set/moth/reddish
	name = "Reddish"
	body_marking_list = list("Reddish")

/datum/body_marking_set/moth/royal
	name = "Royal"
	body_marking_list = list("Royal")

/datum/body_marking_set/moth/gothic
	name = "Gothic"
	body_marking_list = list("Gothic")

/datum/body_marking_set/moth/whitefly
	name = "Whitefly"
	body_marking_list = list("Whitefly")

/datum/body_marking_set/moth/burnt_off
	name = "Burnt Off"
	body_marking_list = list("Burnt Off")

/datum/body_marking_set/moth/deathhead
	name = "Deathhead"
	body_marking_list = list("Deathhead")

/datum/body_marking_set/moth/poison
	name = "Poison"
	body_marking_list = list("Poison")

/datum/body_marking_set/moth/ragged
	name = "Ragged"
	body_marking_list = list("Ragged")

/datum/body_marking_set/moth/moonfly
	name = "Moonfly"
	body_marking_list = list("Moonfly")

/datum/body_marking_set/moth/oakworm
	name = "Oakworm"
	body_marking_list = list("Oakworm")

/datum/body_marking_set/moth/jungle
	name = "Jungle"
	body_marking_list = list("Jungle")

/datum/body_marking_set/moth/witchwing
	name = "Witchwing"
	body_marking_list = list("Witchwing")

/datum/body_marking_set/moth/lovers
	name = "Lovers"
	body_marking_list = list("Lovers")
