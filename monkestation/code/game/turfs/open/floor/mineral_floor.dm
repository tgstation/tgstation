
//BANANIUM

/turf/open/floor/mineral/bananium/no_return
	name = "artificial bananium floor"
	desc = "Designed to replicate a clown's natural habitat."

/turf/open/floor/mineral/bananium/no_return/remove_tile(mob/user, silent, make_tile)
	to_chat(user, "<span class='notice'>The thin artificial plates break into useless dust!</span>")
	return make_plating()

