GLOBAL_LIST_EMPTY(escape_menus)

// PRTODO: Protect from F12
// PRTODO: Protect from Observe

/// Opens the escape menu.
/// Verb, hardcoded to Escape, set in the client skin.
/client/verb/open_escape_menu()
	set name = "Open Escape Menu"
	set hidden = TRUE

	var/current_escape_menu = GLOB.escape_menus[ckey]
	if (!isnull(current_escape_menu))
		qdel(current_escape_menu)
		return

	reset_held_keys()

	new /datum/escape_menu(src)

#define PAGE_HOME "PAGE_HOME"
#define PAGE_LEAVE_BODY "PAGE_LEAVE_BODY"

/datum/escape_menu
	/// The client that owns this escape menu
	var/client/client

	VAR_PRIVATE
		ckey

		datum/screen_object_holder/base_holder
		datum/screen_object_holder/page_holder

		menu_page = PAGE_HOME

/datum/escape_menu/New(client/client)
	ASSERT(!(client.ckey in GLOB.escape_menus))

	ckey = client?.ckey
	src.client = client

	base_holder = new(client)
	populate_base_ui()

	page_holder = new(client)
	show_page()

	RegisterSignal(client, COMSIG_PARENT_QDELETING, PROC_REF(on_client_qdel))

	if (!isnull(ckey))
		GLOB.escape_menus[ckey] = src

/datum/escape_menu/Destroy(force, ...)
	QDEL_NULL(base_holder)
	QDEL_NULL(page_holder)

	GLOB.escape_menus -= ckey

	return ..()

/datum/escape_menu/proc/on_client_qdel()
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	qdel(src)

/datum/escape_menu/proc/show_page()
	PRIVATE_PROC(TRUE)

	page_holder.clear()

	switch (menu_page)
		if (PAGE_HOME)
			show_home_page()
		if (PAGE_LEAVE_BODY)
			show_leave_body_page()
		else
			CRASH("Unknown escape menu page: [menu_page]")

/datum/escape_menu/proc/populate_base_ui()
	PRIVATE_PROC(TRUE)

	base_holder.give_screen_object(new /atom/movable/screen/fullscreen/dimmer)

	base_holder.give_protected_screen_object(give_escape_menu_title())
	base_holder.give_protected_screen_object(give_escape_menu_details())

/datum/escape_menu/proc/open_home_page()
	PRIVATE_PROC(TRUE)

	menu_page = PAGE_HOME
	show_page()

/datum/escape_menu/proc/open_leave_body()
	PRIVATE_PROC(TRUE)

	menu_page = PAGE_LEAVE_BODY
	show_page()

/atom/movable/screen/escape_menu
	plane = ESCAPE_MENU_PLANE

#undef PAGE_HOME
#undef PAGE_LEAVE_BODY
