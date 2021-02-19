/obj/item/book/manual/random
	icon_state = "random_book"

/obj/item/book/manual/random/Initialize()
	..()
	var/static/banned_books = list(/obj/item/book/manual/random, /obj/item/book/manual/nuclear, /obj/item/book/manual/wiki)
	var/newtype = pick(subtypesof(/obj/item/book/manual) - banned_books)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/book/random
	icon_state = "random_book"
	/// The category of books to pick from when creating this book.
	var/random_category = null
	/// If this book has already been 'generated' yet.
	var/random_loaded = FALSE

/obj/item/book/random/Initialize(mapload)
	. = ..()
	icon_state = "book[rand(1,8)]"

/obj/item/book/random/attack_self()
	if(!random_loaded)
		create_random_books(1, loc, TRUE, random_category, src)
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

/proc/create_random_books(amount, location, fail_loud = FALSE, category = null, obj/item/book/existing_book)
	. = list()
	if(!isnum(amount) || amount<1)
		return
	if (!SSdbcore.Connect())
		if(existing_book && (fail_loud || prob(5)))
			existing_book.author = "???"
			existing_book.title = "Strange book"
			existing_book.name = "Strange book"
			existing_book.dat = "There once was a book from Nantucket<br>But the database failed us, so f*$! it.<br>I tried to be good to you<br>Now this is an I.O.U<br>If you're feeling entitled, well, stuff it!<br><br><font color='gray'>~</font>"
		return
	if(prob(25))
		category = null
	var/datum/db_query/query_get_random_books = SSdbcore.NewQuery({"
		SELECT author, title, content
		FROM [format_table_name("library")]
		WHERE isnull(deleted) AND (:category IS NULL OR category = :category)
		ORDER BY rand() LIMIT :limit
	"}, list("category" = category, "limit" = amount))
	if(query_get_random_books.Execute())
		while(query_get_random_books.NextRow())
			var/obj/item/book/B
			B = existing_book ? existing_book : new(location)
			B.author = query_get_random_books.item[1]
			B.title = query_get_random_books.item[2]
			B.dat = query_get_random_books.item[3]
			B.name = "Book: [B.title]"
			if(!existing_book)
				B.icon_state= "book[rand(1,8)]"
	qdel(query_get_random_books)

/obj/structure/bookcase/random/fiction
	name = "bookcase (Fiction)"
	random_category = "Fiction"
/obj/structure/bookcase/random/nonfiction
	name = "bookcase (Non-Fiction)"
	random_category = "Non-fiction"
/obj/structure/bookcase/random/religion
	name = "bookcase (Religion)"
	random_category = "Religion"
/obj/structure/bookcase/random/adult
	name = "bookcase (Adult)"
	random_category = "Adult"

/obj/structure/bookcase/random/reference
	name = "bookcase (Reference)"
	random_category = "Reference"
	var/ref_book_prob = 20

/obj/structure/bookcase/random/reference/Initialize(mapload)
	. = ..()
	while(books_to_load > 0 && prob(ref_book_prob))
		books_to_load--
		new /obj/item/book/manual/random(src)
