/datum/design/bluebutt
	name = "Butt Of Holding"
	desc = "This butt has bluespace properties, letting you store more items in it. Four tiny items, or two small ones, or one normal one can fit."
	id = "bluebutt"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 500, MAT_SILVER = 500) //quite cheap, for more convenience
	build_path = /obj/item/organ/butt/bluebutt
	category = list("Bluespace Designs")

/datum/design/bluespace_pipe
	name = "Bluespace Pipe"
	desc = "A pipe that teleports gases."
	id = "bluespace_pipe"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1000, MAT_DIAMOND = 750, MAT_URANIUM = 250, MAT_BLUESPACE = 2000)
	build_path = /obj/item/pipe/bluespace
	category = list("Bluespace Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
