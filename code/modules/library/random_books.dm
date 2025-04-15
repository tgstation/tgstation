/obj/item/book/manual/random
	icon_state = "random_book"

/obj/item/book/manual/random/Initialize(mapload)
	..()
	var/static/banned_books = list(/obj/item/book/manual/random, /obj/item/book/manual/nuclear, /obj/item/book/manual/wiki)
	var/newtype = pick(subtypesof(/obj/item/book/manual) - banned_books)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/book/random
	icon_state = "random_book"
	/// The category of books to pick from when creating this book.
	var/random_category = BOOK_CATEGORY_RANDOM
	/// If this book has already been 'generated' yet.
	var/random_loaded = FALSE

/obj/item/book/random/Initialize(mapload)
	. = ..()
	gen_random_icon_state()

/obj/item/book/random/attack_self()
	if(!random_loaded)
		// Adult books are excluded unless explicitly set
		var/loaded_category = random_category == BOOK_CATEGORY_RANDOM ? pick(BOOK_CATEGORY_FICTION, BOOK_CATEGORY_NONFICTION, BOOK_CATEGORY_RELIGION, BOOK_CATEGORY_REFERENCE) : random_category
		create_random_books(amount = 1, location = loc, fail_loud = TRUE,  category = loaded_category, existing_book = src)
		random_loaded = TRUE
	return ..()

/obj/structure/bookcase/random
	load_random_books = TRUE
	books_to_load = 2
	icon_state = "random_bookcase"

/obj/structure/bookcase/random/Initialize(mapload)
	. = ..()
	if(books_to_load && isnum(books_to_load))
		books_to_load += pick(-1,-1,0,1,1)
	update_appearance()

/**
 * Create a random book or books.
 *
 * * amount: How many books to create.
 * * location: Where to create the books.
 * * fail_loud: If TRUE, will create a book with an error message if the database fails.
 * * category: The category of books to pick from.
 * If null or BOOK_CATEGORY_RANDOM, will pick from any category on a per-book basis.
 * * existing_book: If set, will use this book object instead of creating a new one.
 * Note passing any amount above 1 with an existing_book will still only create one book.
 */
/proc/create_random_books(amount = 1, atom/location, fail_loud = FALSE, category = BOOK_CATEGORY_RANDOM, obj/item/book/existing_book)
	. = list()
	if(!isnum(amount) || amount<1)
		return
	if (!SSdbcore.Connect())
		if(existing_book && (fail_loud || prob(5)))
			var/error_text = "There once was a book from Nantucket<br>But the database failed us, so f*$! it.<br>I tried to be good to you<br>Now this is an I.O.U<br>If you're feeling entitled, well, stuff it!<br><br><font color='gray'>~</font>"
			existing_book.book_data = new("Strange Book", "???", error_text)
		return
	if(category == BOOK_CATEGORY_RANDOM)
		category = null
	var/datum/db_query/query_get_random_books = SSdbcore.NewQuery({"
		SELECT title, author, content
		FROM [format_table_name("library")]
		WHERE isnull(deleted) AND (:category IS NULL OR category = :category)
		ORDER BY rand() LIMIT :limit
	"}, list("category" = category, "limit" = amount))
	if(query_get_random_books.Execute())
		while(query_get_random_books.NextRow())
			var/list/book_deets = query_get_random_books.item
			var/obj/item/book/to_randomize = existing_book ? existing_book : new(location)

			to_randomize.book_data = new()
			var/datum/book_info/data = to_randomize.book_data
			data.set_title(book_deets[1], trusted = TRUE)
			data.set_author(book_deets[2], trusted = TRUE)
			data.set_content(book_deets[3], trusted = TRUE)
			to_randomize.name = "Book: [to_randomize.book_data.title]"
			if(!existing_book)
				to_randomize.gen_random_icon_state()
	qdel(query_get_random_books)

/obj/structure/bookcase/random/fiction
	name = "bookcase (Fiction)"
	random_category = BOOK_CATEGORY_FICTION
	///have we spawned the chuuni granter
	var/static/chuuni_book_spawned = FALSE

/obj/structure/bookcase/random/fiction/after_random_load()
	if(!chuuni_book_spawned && is_station_level(z))
		chuuni_book_spawned = TRUE
		new /obj/item/book/granter/chuunibyou(src)

/obj/structure/bookcase/random/nonfiction
	name = "bookcase (Non-Fiction)"
	random_category = BOOK_CATEGORY_NONFICTION

/obj/structure/bookcase/random/religion
	name = "bookcase (Religion)"
	random_category = BOOK_CATEGORY_RELIGION

/obj/structure/bookcase/random/adult
	name = "bookcase (Adult)"
	random_category = BOOK_CATEGORY_ADULT

/obj/structure/bookcase/random/reference
	name = "bookcase (Reference)"
	random_category = BOOK_CATEGORY_REFERENCE
	///Chance to spawn a random manual book
	var/ref_book_prob = 20

/obj/structure/bookcase/random/reference/Initialize(mapload)
	. = ..()
	while(books_to_load > 0 && prob(ref_book_prob))
		books_to_load--
		new /obj/item/book/manual/random(src)

/obj/structure/bookcase/random/reference/wizard
	desc = "It reeks of cheese..."
	///Whether this shelf has spawned a cheese granter
	var/static/cheese_granter_spawned = FALSE

/obj/structure/bookcase/random/reference/wizard/after_random_load()
	if(cheese_granter_spawned)
		return
	cheese_granter_spawned = TRUE
	new /obj/item/book/granter/action/spell/summon_cheese(src)
	new /obj/item/book/manual/ancient_parchment(src)
