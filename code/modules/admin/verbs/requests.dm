
ADMIN_VERB(requests, R_NONE, "Requests Manager", "Open the request manager panel to view all requests during this round", ADMIN_CATEGORY_PLAYERS)
	GLOB.requests.ui_interact(usr)
	BLACKBOX_LOG_ADMIN_VERB("Request Manager")
