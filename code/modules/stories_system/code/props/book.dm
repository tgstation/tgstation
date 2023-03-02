/obj/item/book/authors_book
	unique = TRUE
	starting_author = "Bob Newbie"
	starting_content = "The text is so dense, so unending, that you can't make sense of a single word."
	starting_title = "Variable Defaults And You - A Shocking Tale Of Broken Code"

/obj/item/book/inspectors_book
	unique = TRUE
	starting_author = "Regulatory Space Academy"
	starting_content = "This thick, 3876-page monster of a tome is so heavy, you can't even open it. Its regulatory secrets remain a mystery to the uninitiated."
	starting_title = "Space Structure Regulations - Pocket Edition"

/obj/item/paper/inspector_letter
	icon_state = "paper_words"
	throw_range = 3
	throw_speed = 3
	item_flags = NOBLUDGEON

/obj/item/paper/inspector_letter/Initialize(mapload)
	. = ..()
	name = "letter to the esteemed inspector"
	add_raw_text("<center>Dear <del>dumbass</del> Inspector</center>\
	<BR><BR>\
	In light of your <del>annoying</del> mind-numbing dedication to your craft, you have been gifted with a <del>hilarious</del> incredible opportunity. \
	You've been assigned the position of Inspector at one of Nanotrasen's <del>horrifying</del> reputable facilities. \
	Your task is to carefully inspect the structure, make a note of <del>every</del> any regulatory violation, and present the captain with your report.<BR><BR>\
	<center>Good luck <del>you're gonna need it</del>,<BR><BR>\
	Regards,<BR>\
	Regulatory Space Academy, Board of Directors</center>")

/obj/item/paper/fugitive_newspaper
	name = "newspaper clipping"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	inhand_icon_state = "newspaper"
	lefthand_file = 'icons/mob/inhands/items/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/books_righthand.dmi'
	throw_range = 3
	throw_speed = 3
	item_flags = NOBLUDGEON

/obj/item/paper/fugitive_newspaper/Initialize(mapload)
	. = ..()
	add_raw_text("<center><b>Tragedy at Pick 'n Dig Corporation! Seventeen dead in chemical explosion!</b></center>\
	<BR><BR>\
	Markets and families were rocked today (physically and spiritually) with an explosion at a Pick 'n Dig Corporation mining facility on Festan IV. \
	The foreman expressed his sadness at the untimely deaths of seventeen workers, apparently caused due to a miasma leak. Alongside thirty-seven injuries, \
	there still remains one miner unaccounted for…")
