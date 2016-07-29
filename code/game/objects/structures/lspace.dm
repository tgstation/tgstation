
/obj/structure/lspacewall
	name = "stack of books"
	desc = "Large pile of books."
	icon_state = "lspacewall"
	density = 1
	anchored = 1
	var/book_type

/obj/structure/lspacewall/New()
	..()
	if(!book_type)
		book_type = pick( list("1","2","3","4") )
	icon_state = "lspacewall[book_type]"
