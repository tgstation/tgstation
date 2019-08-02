/datum/design/bluebutt
	name = "Butt Of Holding"
	desc = "This butt has bluespace properties, letting you store more items in it. Four tiny items, or two small ones, or one normal one can fit."
	id = "bluebutt"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 500, /datum/material/silver = 500) //quite cheap, for more convenience
	build_path = /obj/item/organ/butt/bluebutt
	category = list("Bluespace Designs")

/datum/design/bluespace_pipe
	name = "Bluespace Pipe"
	desc = "A pipe that teleports gases."
	id = "bluespace_pipe"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 1000, /datum/material/diamond = 750, /datum/material/uranium = 250, /datum/material/bluespace = 2000)
	build_path = /obj/item/pipe/bluespace
	category = list("Bluespace Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
