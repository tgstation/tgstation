#define BOOK_ADMIN_DELETE "deleted"
#define BOOK_ADMIN_RESTORE "undeleted"
#define BOOK_ADMIN_REPORT "reported"

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker
	/// When a user clicks view, do we display the raw text, or process it with markdown
	var/view_raw = FALSE
	/// If we should show deleted entries or not
	var/show_deleted = TRUE
	/// The current ckey we're looking for
	var/ckey = ""
	/// List mapping requested book ids to a list of their edit logs
	var/list/book_history = list()
	interface_type = "LibraryAdmin"


/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/can_db_request()
	if(sending_request)
		return FALSE
	return TRUE

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/hash_search_info()
	. = ..()
	return "[.]-[ckey]-[show_deleted]"

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/update_page_contents()
	if(sending_request) //Final defense against nerds spamming db requests
		return
	sending_request = TRUE
	search_page = clamp(search_page, 0, page_count)
	var/datum/db_query/query_library_list_books = SSdbcore.NewQuery({"
		SELECT id, author, title, category, ckey, deleted
		FROM [format_table_name("library")]
		[show_deleted ? "" : "WHERE deleted IS NULL"]
			[show_deleted ? "WHERE" : "AND"] author LIKE CONCAT('%',:author,'%')
			AND title LIKE CONCAT('%',:title,'%')
			[book_id ? "AND id LIKE CONCAT('%', :book_id, '%')" : ""]
			AND (:category = 'Any' OR category = :category)
			AND ckey LIKE CONCAT('%',:ckey,'%')
		ORDER BY id DESC
		LIMIT :skip, :take
	"}, list("author" = author, "title" = title, "book_id" = book_id, "category" = category, "ckey" = ckey, "skip" = BOOKS_PER_PAGE * search_page, "take" = BOOKS_PER_PAGE))

	var/query_succeeded = query_library_list_books.Execute()
	sending_request = FALSE
	page_content.Cut()
	if(!query_succeeded)
		qdel(query_library_list_books)
		return
	while(query_library_list_books.NextRow())
		page_content += list(list(
			"id" = query_library_list_books.item[1],
			"author" = html_decode(query_library_list_books.item[2]),
			"title" = html_decode(query_library_list_books.item[3]),
			"category" = query_library_list_books.item[4],
			"author_ckey" = query_library_list_books.item[5],
			"deleted" = query_library_list_books.item[6],
		))
	qdel(query_library_list_books)

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/update_page_count()
	var/bookcount = 0
	var/datum/db_query/query_library_count_books = SSdbcore.NewQuery({"
		SELECT COUNT(id) FROM [format_table_name("library")]
			[show_deleted ? "" : "WHERE deleted IS NULL"]
			[show_deleted ? "WHERE" : "AND"] author LIKE CONCAT('%',:author,'%')
			AND title LIKE CONCAT('%',:title,'%')
			[book_id ? "AND id LIKE CONCAT('%', :book_id, '%')" : ""]
			AND (:category = 'Any' OR category = :category)
			AND ckey LIKE CONCAT('%',:ckey,'%')
	"}, list("author" = author, "title" = title, "book_id" = book_id, "category" = category, "ckey" = ckey))

	if(!query_library_count_books.warn_execute())
		qdel(query_library_count_books)
		return
	if(query_library_count_books.NextRow())
		bookcount = text2num(query_library_count_books.item[1])
	qdel(query_library_count_books)

	page_count = round(max(bookcount - 1, 0) / BOOKS_PER_PAGE) //This is just floor()
	search_page = clamp(search_page, 0, page_count)

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/ui_status(mob/user)
	if(!check_rights_for(user.client, R_BAN))
		return UI_CLOSE
	if(!SSdbcore.Connect())
		can_connect = FALSE
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		// We'll always trigger a search attempt if the parent does something, this ensures the ui is v fast to update
		INVOKE_ASYNC(src, PROC_REF(update_db_info))
		return
	switch(action)
		if("set_search_ckey")
			ckey = params["ckey"]
			INVOKE_ASYNC(src, PROC_REF(update_db_info))
			return TRUE
		if("refresh")
			last_search_hash = ""
			INVOKE_ASYNC(src, PROC_REF(update_db_info))
			return TRUE
		if("hide_book")
			var/reason = params["delete_reason"]
			var/id = params["book_id"]
			var/client/actor = ui.user?.client
			if(!actor)
				return
			INVOKE_ASYNC(src, PROC_REF(hide_book), id, reason, actor)
			return TRUE
		if("unhide_book")
			var/reason = params["free_reason"]
			var/id = params["book_id"]
			var/client/actor = ui.user?.client
			if(!actor)
				return
			INVOKE_ASYNC(src, PROC_REF(unhide_book), id, reason, actor)
			return TRUE
		if("get_history")
			var/id = params["book_id"]
			book_history["[id]"] = get_book_history(id)
			return TRUE
		if("view_book")
			var/id = params["book_id"]
			view_book(id, ui.user)
			return TRUE
		if("toggle_raw")
			view_raw = !view_raw
			return TRUE
		if("toggle_deleted")
			show_deleted = !show_deleted
			INVOKE_ASYNC(src, PROC_REF(update_db_info))
			return TRUE

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/ui_data(mob/user)
	. = ..()
	.["view_raw"] = view_raw
	.["show_deleted"] = show_deleted
	var/list/histories = list()
	for(var/id as anything in book_history)
		var/list/insert = list()
		for(var/datum/book_history_entry/entry in book_history[id])
			insert += list(entry.serialize())
		histories[id] = insert
	.["history"] = histories

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/proc/view_book(id, mob/show_to)
	if (!SSdbcore.Connect())
		can_connect = FALSE
		message_admins("Could not connect to the DB")
		return

	var/datum/db_query/query_library_view = SSdbcore.NewQuery(
		"SELECT * FROM [format_table_name("library")] WHERE id=:id",
		list("id" = id)
	)
	if(!query_library_view.Execute())
		qdel(query_library_view)
		return

	while(query_library_view.NextRow())
		var/datum/admin_book_viewer/viewer = new()
		viewer.set_owner(src)
		viewer.id = query_library_view.item[1]
		viewer.author = query_library_view.item[2]
		viewer.title = query_library_view.item[3]
		viewer.content = query_library_view.item[4]
		viewer.category = query_library_view.item[5]
		viewer.author_ckey = query_library_view.item[6]
		viewer.creation_time = query_library_view.item[7]
		viewer.deleted = query_library_view.item[8]
		viewer.creation_round = query_library_view.item[9]
		viewer.history = get_book_history(id)
		viewer.ui_interact(show_to)
		break
	qdel(query_library_view)

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/proc/get_book_history(id)
	var/datum/db_query/query_book_history = SSdbcore.NewQuery({"
		SELECT id, book, reason, ckey, datetime, action, INET_NTOA(ip_addr)
			FROM [format_table_name("library_action")] WHERE book=:id
		"},
		list("id" = id)
	)
	if(!query_book_history.Execute())
		qdel(query_book_history)
		return list()

	var/list/full_history = list()
	while(query_book_history.NextRow())
		var/datum/book_history_entry/history = new()
		history.id = query_book_history.item[1]
		history.book = query_book_history.item[2]
		history.reason = query_book_history.item[3]
		history.ckey = query_book_history.item[4]
		history.datetime = query_book_history.item[5]
		history.action = query_book_history.item[6]
		history.ip_addr = query_book_history.item[7]
		full_history += history
	qdel(query_book_history)
	return full_history

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/proc/hide_book(id, reason, client/admin)
	if(!SSdbcore.Connect())
		can_connect = FALSE
		message_admins("Could not connect to the DB")
		return
	if(IsAdminAdvancedProcCall())
		stack_trace("Proc call lead to hide_book being called, blocked")
		message_admins("Proc call lead to hide_book being called, blocked")
		return
	if(!check_rights_for(admin, R_BAN))
		stack_trace("[admin.ckey] tried to hide a book without the required perms")
		return

	var/log_reason = "([admin.ckey]) hid book #[id][reason ? ": \"[reason]\"" : ""]"
	log_admin_private(log_reason)
	log_reason = "\[[SQLtime()]\] round #[GLOB.round_id] [log_reason]"

	var/datum/db_query/query_hide_book = SSdbcore.NewQuery({"
		UPDATE [format_table_name("library")]
		SET deleted = 1
		WHERE id = :id
	"}, list("id" = id))
	query_hide_book.warn_execute()
	qdel(query_hide_book)

	var/datum/db_query/query_update_log = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("library_action")] (book, reason, ckey, datetime, action, ip_addr)
		VALUES (:book, :reason, :ckey, Now(), :action, INET_ATON(:ip_addr))
	"}, list("book" = id, "reason" = reason, "ckey" = admin.ckey, "action" = BOOK_ADMIN_DELETE, "ip_addr" = admin.address))
	query_update_log.warn_execute()
	qdel(query_update_log)
	library_updated()
	params_changed = TRUE
	update_db_info()

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/proc/unhide_book(id, reason, client/admin)
	if(!SSdbcore.Connect())
		can_connect = FALSE
		message_admins("Could not connect to the DB")
		return
	if(IsAdminAdvancedProcCall())
		stack_trace("Proc call lead to unhide_book being called, blocked")
		message_admins("Proc call lead to unhide_book being called, blocked")
		return
	if(!check_rights_for(admin, R_BAN))
		stack_trace("[admin.ckey] tried to unhide a book without the required perms")
		return

	log_admin_private("([admin.ckey]) unhid book #[id]")

	var/datum/db_query/query_unhide_book = SSdbcore.NewQuery({"
		UPDATE [format_table_name("library")]
		SET deleted = NULL
		WHERE id = :id
	"}, list("id" = id))

	query_unhide_book.warn_execute()
	qdel(query_unhide_book)

	var/datum/db_query/query_update_log = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("library_action")] (book, reason, ckey, datetime, action, ip_addr)
		VALUES (:book, :reason, :ckey, Now(), :action, INET_ATON(:ip_addr))
	"}, list("book" = id, "reason" = reason, "ckey" = admin.ckey, "action" = BOOK_ADMIN_RESTORE, "ip_addr" = admin.address))
	query_update_log.warn_execute()
	qdel(query_update_log)
	library_updated()
	update_db_info()

/// This mostly exists to document the form of the library_action table, since it doesn't do that good a job on its own
/datum/book_history_entry
	/// The id of this logged action
	var/id
	/// The book id this log applies to
	var/book
	/// The reason this action was enacted
	var/reason
	/// The admin who performed the action
	var/ckey
	/// The time of the action being performed
	var/datetime
	/// The action that occured (BOOK_ADMIN_DELETE, BOOK_ADMIN_RESTORE, and legacy BOOK_ADMIN_REPORT)
	var/action
	/// The ip address of the admin who performed the action
	var/ip_addr

/datum/book_history_entry/proc/serialize()
	var/list/data = list()
	data["id"] = id
	data["book"] = book
	data["reason"] = reason
	data["ckey"] = ckey
	data["datetime"] = datetime
	data["action"] = action
	data["address"] = ip_addr
	return data

/datum/admin_book_viewer
	/// Weakref to the /obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker that spawned us
	var/datum/weakref/owner_ref
	var/view_raw = FALSE
	var/id
	var/author
	var/title
	var/content
	var/category
	var/author_ckey
	var/creation_time
	var/deleted
	var/creation_round
	var/list/datum/book_history_entry/history

/datum/admin_book_viewer/proc/set_owner(obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/owner)
	owner_ref = WEAKREF(owner)
	view_raw = owner.view_raw

/datum/admin_book_viewer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminBookViewer")
		ui.set_autoupdate(FALSE) // Nothing is changing here brother
		ui.open()

/datum/admin_book_viewer/ui_status(mob/user)
	if(!check_rights_for(user.client, R_BAN))
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/admin_book_viewer/ui_data(mob/user)
	var/list/data = list()
	data["view_raw"] = view_raw
	data["id"] = id
	data["author"] = author
	data["title"] = title
	data["content"] = content
	data["category"] = category
	data["author_ckey"] = author_ckey
	data["creation_time"] = creation_time
	data["deleted"] = deleted
	data["creation_round"] = creation_round
	data["history"] = list()
	for(var/datum/book_history_entry/entry as anything in history)
		data["history"] += list(entry.serialize())

	return data
