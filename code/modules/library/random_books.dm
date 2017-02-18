/obj/item/weapon/book/manual/random/New()
	var/static/banned_books = list(/obj/item/weapon/book/manual/random,/obj/item/weapon/book/manual/nuclear,/obj/item/weapon/book/manual/wiki)
	var/newtype = pick(subtypesof(/obj/item/weapon/book/manual) - banned_books)
	new newtype(loc)
	qdel(src)

/obj/item/weapon/book/random
	var/amount = 1
	var/category = null

/obj/item/weapon/book/random/New()
	create_random_books(amount, src.loc, TRUE, category)
	qdel(src)

/obj/item/weapon/book/random/triple
	amount = 3

/obj/structure/bookcase/random
	var/category = null
	var/book_count = 2
	anchored = 1
	state = 2

/obj/structure/bookcase/random/Initialize(mapload)
	..()
	if(!book_count || !isnum(book_count))
		update_icon()
		return
	book_count += pick(-1,-1,0,1,1)
	create_random_books(book_count, src, FALSE, category)
	update_icon()

/proc/create_random_books(amount = 2, location, fail_loud = FALSE, category = null)
	. = list()
	if(!isnum(amount) || amount<1)
		return
	if(!establish_db_connection())
		if(fail_loud || prob(5))
			var/obj/item/weapon/paper/P = new(location)
			P.info = "There once was a book from Nantucket<br>But the database failed us, so f*$! it.<br>I tried to be good to you<br>Now this is an I.O.U<br>If you're feeling entitled, well, stuff it!<br><br><font color='gray'>~</font>"
			P.update_icon()
		return
	if(prob(25))
		category = null
	var/c = category? " AND category='[sanitizeSQL(category)]'" :""
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("library")] WHERE isnull(deleted)[c] GROUP BY title ORDER BY rand() LIMIT [amount];") // isdeleted copyright (c) not me
	if(query.Execute())
		while(query.NextRow())
			var/obj/item/weapon/book/B = new(location)
			. += B
			B.author	=	query.item[2]
			B.title		=	query.item[3]
			B.dat		=	query.item[4]
			B.name		=	"Book: [B.title]"
			B.icon_state=	"book[rand(1,8)]"
	else
		log_game("SQL ERROR populating library bookshelf.  Category: \[[category]\], Count: [amount], Error: \[[query.ErrorMsg()]\]\n")


/obj/structure/bookcase/random/fiction
	name = "bookcase (Fiction)"
	category = "Fiction"
/obj/structure/bookcase/random/nonfiction
	name = "bookcase (Non-Fiction)"
	category = "Non-fiction"
/obj/structure/bookcase/random/religion
	name = "bookcase (Religion)"
	category = "Religion"
/obj/structure/bookcase/random/adult
	name = "bookcase (Adult)"
	category = "Adult"

/obj/structure/bookcase/random/reference
	name = "bookcase (Reference)"
	category = "Reference"
	var/ref_book_prob = 20

/obj/structure/bookcase/random/reference/Initialize(mapload)
	..()
	while(book_count > 0 && prob(ref_book_prob))
		book_count--
		new /obj/item/weapon/book/manual/random(src)
