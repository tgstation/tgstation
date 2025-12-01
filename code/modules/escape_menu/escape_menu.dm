GLOBAL_LIST_EMPTY(escape_menus)

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
	/// A weakref to the hud this escape menu currently applies to
	var/datum/weakref/our_hud_ref

	VAR_PRIVATE
		ckey

		static/atom/movable/screen/fullscreen/dimmer/dim_screen

		datum/screen_object_holder/base_holder
		datum/screen_object_holder/page_holder

		atom/movable/plane_master_controller/plane_master_controller

		list/resource_panels
		show_resources = FALSE
		menu_page = PAGE_HOME

/datum/escape_menu/New(client/client)
	ASSERT(!(client.ckey in GLOB.escape_menus))

	ckey = client?.ckey
	src.client = client
	refresh_hud()

	base_holder = new(client)
	if(isnull(dim_screen))
		dim_screen = new()
	populate_base_ui()

	page_holder = new(client)
	show_page()

	RegisterSignal(client, COMSIG_QDELETING, PROC_REF(on_client_qdel))
	RegisterSignal(client, COMSIG_CLIENT_MOB_LOGIN, PROC_REF(on_client_mob_login))

	SEND_SOUND(client, 'sound/misc/escape_menu/esc_open.ogg')
	var/sound/esc_middle = sound('sound/misc/escape_menu/esc_middle.ogg', repeat = FALSE, channel = CHANNEL_ESCAPEMENU, volume = 80)
	SEND_SOUND(client, esc_middle)

	if (!isnull(ckey))
		GLOB.escape_menus[ckey] = src

/datum/escape_menu/Destroy(force)
	QDEL_NULL(base_holder)
	QDEL_NULL(page_holder)
	resource_panels = null // list contents were already qdeled in QDEL_NULL(page_holder), so we can safely null this

	var/datum/our_hud = our_hud_ref?.resolve()
	if(our_hud)
		REMOVE_TRAIT(our_hud, TRAIT_ESCAPE_MENU_OPEN, ref(src))

	GLOB.escape_menus -= ckey

	var/sound/esc_clear = sound(null, repeat = FALSE, channel = CHANNEL_ESCAPEMENU) //yes, I'm doing it like this with a null, no its absolutely intentional, cuts off the sound right as needed.
	SEND_SOUND(client, esc_clear)
	SEND_SOUND(client, 'sound/misc/escape_menu/esc_close.ogg')
	client = null

	return ..()

/datum/escape_menu/proc/on_client_qdel()
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	qdel(src)

/datum/escape_menu/proc/on_client_mob_login()
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	if (menu_page == PAGE_LEAVE_BODY)
		qdel(src)
	else
		// Otherwise our client just switched bodies, let's update our hud
		refresh_hud()

/datum/escape_menu/proc/refresh_hud()
	var/datum/old_hud = our_hud_ref?.resolve()
	if(old_hud)
		REMOVE_TRAIT(old_hud, TRAIT_ESCAPE_MENU_OPEN, ref(src))

	var/datum/new_hud = client.mob?.hud_used
	our_hud_ref = WEAKREF(new_hud)
	if(new_hud)
		ADD_TRAIT(new_hud, TRAIT_ESCAPE_MENU_OPEN, ref(src))

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

	base_holder.give_protected_screen_object(dim_screen)
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
	clear_with_screen = FALSE

// The escape menu can be opened before SSatoms
INITIALIZE_IMMEDIATE(/atom/movable/screen/escape_menu)

#undef PAGE_HOME
#undef PAGE_LEAVE_BODY
