//Some information about how html sanitization is handled
//All book info datums should store sanitized data. This cannot be worked around
//All inputs and outputs from the round (DB calls) need to use sanitized data
//All tgui menus should get unsanitized data, since jsx handles that on its own
//Everything else should use sanitized data. Yes including names, it's an xss vuln because of how chat works
///A datum which contains all the metadata of a book
/datum/book_info
	///The title of the book
	var/title
	///The "author" of the book
	var/author
	///The info inside the book
	var/content

/datum/book_info/New(_title, _author, _content)
	title = _title
	author = _author
	content = _content

/datum/book_info/proc/set_title(_title, trusted = FALSE)  //Trusted should only be used for books read from the db, or in cases that we can be sure the info has already been sanitized
	if(trusted)
		title = _title
		return
	title = reject_bad_text(trim(html_encode(_title), 30))

/datum/book_info/proc/get_title(default="N/A") //Loads in an html decoded version of the title. Only use this for tgui menus, absolutely nothing else.
	return html_decode(title) || "N/A"

/datum/book_info/proc/set_author(_author, trusted = FALSE)
	if(trusted)
		author = _author
		return
	author = trim(html_encode(_author), MAX_NAME_LEN)

/datum/book_info/proc/get_author(default="N/A")
	return html_decode(author) || "N/A"

/datum/book_info/proc/set_content(_content, trusted = FALSE)
	if(trusted)
		content = _content
		return
	content = trim(html_encode(_content), MAX_PAPER_LENGTH)

/datum/book_info/proc/set_content_using_paper(obj/item/paper/paper)
	// Just the paper's raw data.
	var/raw_content = ""
	for(var/datum/paper_input/text_input as anything in paper.raw_text_inputs)
		raw_content += text_input.to_raw_html()

	content = trim(html_encode(raw_content), MAX_PAPER_LENGTH)

/datum/book_info/proc/get_content(default="N/A")
	return html_decode(content) || "N/A"

///Returns a copy of the book_info datum
/datum/book_info/proc/return_copy()
	var/datum/book_info/copycat = new(title, author, content)
	return copycat

///Modify an existing book_info datum to match your data
/datum/book_info/proc/copy_into(datum/book_info/copycat)
	copycat.set_title(title, trusted = TRUE)
	copycat.set_author(author, trusted = TRUE)
	copycat.set_content(content, trusted = TRUE)
	return copycat

/datum/book_info/proc/compare(datum/book_info/cmp_with)
	if(author != cmp_with.author)
		return FALSE
	if(title != cmp_with.title)
		return FALSE
	if(content != cmp_with.content)
		return FALSE
	return TRUE
