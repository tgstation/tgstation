/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	locked = 1
	icon_state = "secure"
	health = 200
		user << "<span class='warning'>You have no idea how this thing is supposed to work!</span>"
		user << "<span class='warning'>You can't do that right now!</span>"
				user.visible_message("[user] has [locked ? null : "un"]locked the locker.", "You [locked ? null : "un"]lock the locker.")
		user << "<span class='danger'>Access Denied.</span>"
		user << "<span class='warning'>The locker appears to be broken!</span>"
			O.show_message("<span class='warning'>The locker has been broken by [user] with an electromagnetic card!</span>", 1, "<span class='italics'>You hear a faint electrical spark.</span>", 2)
		user << "<span class='warning'>The locker is locked!</span>"
	secure = 1
