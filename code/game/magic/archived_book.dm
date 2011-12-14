#define BOOK_VERSION_MIN	1
#define BOOK_VERSION_MAX	1
#define BOOK_PATH			"data/books/"

var/global/datum/book_manager/book_mgr = new()

datum/book_manager/proc/path(id)
	if(isnum(id)) // kill any path exploits
		return "[BOOK_PATH][id].sav"

datum/book_manager/proc/getall()
	var/list/paths = flist(BOOK_PATH)
	var/list/books = new()

	for(var/path in paths)
		var/datum/archived_book/B = new(BOOK_PATH + path)
		books += B

	return books

datum/book_manager/proc/freeid()
	var/list/paths = flist(BOOK_PATH)
	var/id = paths.len + 101

	// start at 101+number of books, which will be correct id if none have been deleted, etc
	// otherwise, keep moving forward until we find an open id
	while(fexists(path(id)))
		id++

	return id

// delete a book
datum/book_manager/proc/remove(var/id)
	fdel(path(id))

datum/archived_book
	var
		author		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
		title		 // The real name of the book.
		category	 // The category/genre of the book
		id			 // the id of the book (like an isbn number)
		dat			 // Actual page content

// loads the book corresponding by the specified id
datum/archived_book/New(var/path)
	if(isnull(path))
		return

	var/savefile/F = new(path)

	var/version
	F["version"] >> version

	if (isnull(version) || version < BOOK_VERSION_MIN || version > BOOK_VERSION_MAX)
		fdel(path)
		usr << "What book?"
		return 0

	F["author"] >> author
	F["title"] >> title
	F["category"] >> category
	F["id"] >> id
	F["dat"] >> dat

datum/archived_book/proc/save()
	var/savefile/F = new(book_mgr.path(id))

	F["version"] << BOOK_VERSION_MAX
	F["author"] << author
	F["title"] << title
	F["category"] << category
	F["id"] << id
	F["dat"] << dat

#undef BOOK_VERSION_MIN
#undef BOOK_VERSION_MAX
#undef BOOK_PATH
