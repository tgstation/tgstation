/obj/item/bikehorn/rubberducky
	attack_verb = list("QUACKED")

/obj/item/bikehorn/rubberducky/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('hippiestation/sound/misc/quack.ogg'=1), 80)
