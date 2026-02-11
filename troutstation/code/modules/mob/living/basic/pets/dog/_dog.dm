/obj/item/dog_bone/treet
	name = "\improper Dog's Treet"
	desc = "A tasty femur full of juicy marrow, the perfect gift for you and your best friend."


/obj/item/dog_bone/treet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/examine_lore, \
		lore_hint = span_notice("You can [EXAMINE_HINT("look closer")] to to read the exceptionally long hand-written tag on the [src]."), \
		lore = "Was Anyone Else Offended by Pence's Shirt?<br>\
		His shirt reads 'Dog's Treet' which obviously implies that he eats dog food. There was someone like that on a show that I watched and dog food was not made for human consumption so I'm not sure where he got a shirt like that.<br>\
		My point is, my cousin watched me play KH2 once and noticed this shirt and now he wants to try a dog treat.<br>\
		I feel a disturbance because I don't know why they included this quality in the game. I think Kingdom Hearts encourages people to try dog food, possibly subliminally because of his shirt (that mostly goes unnoticed) and I find that totally unnecessary."\
	)





