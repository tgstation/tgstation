/obj/effect/mob_spawn/human/hotel_staff
	id_access_list = list(GLOB.access_away_general, GLOB.access_away_maint)
	id_job = "Hotel Staff"
	flavour_text = "You are a staff member of a top-of-the-line space hotel! Cater to guests and remember: You can check out any time you like, but you can never leave."

/datum/outfit/hotelstaff
	id = /obj/item/weapon/card/id
	implants = list(/obj/item/weapon/implant/exile/ghost_role)

/obj/effect/mob_spawn/human/hotel_staff/security
	flavour_text = "You are a peacekeeper assigned to this hotel to protect the interests of the company while keeping the peace between \
		guests and the staff. Remember: You can check out any time you like, but you can never leave."
	id_job = "Hotel Security"
	id_access_list = list(GLOB.access_away_general, GLOB.access_away_maint, GLOB.access_away_sec)
	objectives = "Do not leave your assigned hotel. Try and keep the peace between staff and guests. Non-lethal force is heavily advised if possible."