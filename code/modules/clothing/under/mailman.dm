//Mail yourself anywhere, yo.
/obj/item/clothing/under/syndiemail
	name = "mailrider jumpsuit"
	desc = "This state-of-the-art jumpsuit allows you to ride pneumatic disposal tubes like space horses!"
	icon_state = "mailman"
	item_state = "b_suit"
	item_color = "mailman"
	var/sortTag //Disposals code reads this.

/obj/item/clothing/under/syndiemail/proc/openwindow(mob/user)
	var/dat = "<tt><center><h1><b>MailRider 0.3</b></h1></center>"

	dat += "<table style='width:100%; padding:4px;'><tr>"
	for (var/i = 1, i <= TAGGERLOCATIONS.len, i++)
		dat += "<td><a href='?src=\ref[src];nextTag=[i]'>[TAGGERLOCATIONS[i]]</a></td>"

		if(i%4==0)
			dat += "</tr><tr>"

	dat += "</tr></table><br>Current Selection: [sortTag ? TAGGERLOCATIONS[sortTag] : "None"]</tt>"

	user << browse(dat, "window=destTagScreen;size=450x350")
	onclose(user, "destTagScreen")

/obj/item/clothing/under/syndiemail/Topic(href, href_list)
	if ((usr.restrained() || usr.stat || usr.get_active_hand() != src)) //Balancing: you have to take your jumpsuit off to change the destination tags. Until somebody makes instant jumpsuit changing.
		return
	add_fingerprint(usr)
	if(href_list["nextTag"])
		var/n = text2num(href_list["nextTag"])
		sortTag = n
	openwindow(usr)

/obj/item/clothing/under/syndiemail/attack_self(mob/user)
	..()
	openwindow(user)
