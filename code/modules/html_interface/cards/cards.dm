// Used by playing cards; /obj/item/weapon/hand
// Subtype exists because of sendResources; these must be sent when the client connects.

/datum/html_interface/cards/New()
	. = ..()

	src.head = src.head + "<link rel=\"stylesheet\" type=\"text/css\" href=\"cards.css\" />"
	src.updateLayout("<div id=\"headbar\"></div><div class=\"wrapper\"><table><tr><td style=\"vertical-align: middle;\"><div id=\"hand\"></div></td></tr></table></div>")

/datum/html_interface/cards/registerResources()
	register_asset("cards.css", 'cards.css')

/datum/html_interface/cards/sendAssets(var/client/client)
	..()

	send_asset(client, "cards.css")