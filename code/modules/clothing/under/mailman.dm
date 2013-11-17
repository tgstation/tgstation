//Mail yourself anywhere, yo. ~By Miauw~
/obj/item/clothing/under/syndiemail
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	item_state = "b_suit"
	item_color = "mailman"
	var/sortTag //Disposals code reads this.
	action_button_name = "Set Tag"

/obj/item/clothing/under/syndiemail/openwindow(mob/user)
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
	if (usr.restrained() || usr.stat)
		return
	add_fingerprint(usr)
	if(href_list["nextTag"])
		var/n = text2num(href_list["nextTag"])
		sortTag = n
	openwindow(usr)

/obj/item/clothing/under/syndiemail/attack_self(mob/user)
	..()
	openwindow(user)

/obj/item/clothing/under/syndiemail/verb/toggle_light()
	set name = "Set Tag"
	set category = "Object"
	set src in usr.contents

	if(!usr.stat)
		attack_self(usr)
