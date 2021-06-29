/**
 * ## merchant datum!!
 *
 * Holds information for their ship names, their map template for their ship spawning, and more
 */
/datum/merchant
	///name of the person sending communications
	var/name = "discord gremlin"
	///this is the map template to load in.
	var/map_template_path
	///this message is sent when the merchant first contacts the station. it will cost [INITIAL_VISIT_COST] credits to dock, so add %VISITCOST to add that
	var/message_greet = "oml hiiii i am big github idiot and i want YOUER wares :PP PAY ME %VISITCOST DOUBLEOONS FIRST doe..."
	///this message is sent when the merchant is sucessfully paid and is now docking with the station
	var/message_docking = "babe im on my way over right now ;))) jk lol but i am docking at escape doe 4 reals"
	///this message is sent when the emergency shuttle has become unrecallable, and the merchant is leaving.
	var/message_leaving = "ok! im outties x.O see you later guise (babe naysh, here i come!)"

	//fail messages

	///this message is sent when the station invites the merchant, but does not have enough money.
	var/message_too_poor = "HAHAHAH YoU DONT EVEN HAVE NEOGUH CREDITS 4 ME 2 DOCK"
	///this message is sent when the station responds to the merchant, but it is too late to dock.
	var/message_too_late = "bruhhh i am NOT diggedy docking with a station on da way out............"

/datum/merchant/New()
	. = ..()
	message_greet = replacetext(message_greet, "%VISITCOST", INITIAL_VISIT_COST)

/datum/merchant/amorphous
	name = "Amorphous"
	map_template_path = /datum/map_template/shuttle/merchant/amorphous
	message_greet = "HELLO. I AM AMORPHOUS. I HAVE MANY ROBOTIC WARES FOR YOU. PLEASE PAY %VISITCOST CREDITS AND I WILL DOCK TO TRADE."
	message_docking = "THANK YOU FOR THE CREDITS. I AM NOW DOCKING AT ESCAPE."
	message_leaving = "OUR TIME HAS COME TO AN END. GOODBYE MEATBAGS."
	message_too_poor = "THIS STATION HAS NO CREDITS FOR ME TO BARTER. THIS IS A WASTE OF MY TIME."
	message_too_late = "YOU ARE RUNNING FROM ME. I AM NOT GOING TO BE BELITTLED BY MEATBAGS."
