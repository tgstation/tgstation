//Mail yourself anywhere, yo. ~By Miauw~
/obj/item/clothing/under/syndiemail
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	item_state = "b_suit"
	item_color = "mailman"
	var/sortTag //Disposals code reads this.
	action_button_name = "Set Tag"


/obj/item/clothing/under/syndiemail/Topic(href, href_list)
	if (usr.restrained() || usr.stat)
		return
	add_fingerprint(usr)
	if(href_list["nextTag"])
		var/n = text2num(href_list["nextTag"])
		sortTag = n
	tag_menu(usr, src)

/obj/item/clothing/under/syndiemail/attack_self(mob/user)
	..()
	tag_menu(user, src)

/obj/item/clothing/under/syndiemail/verb/toggle_light()
	set name = "Set Tag"
	set category = "Object"
	set src in usr.contents

	if(!usr.stat)
		attack_self(usr)
