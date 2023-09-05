/obj/item/proc/monkestation_vv_do_topic(list/href_list)
	if(href_list[VV_HK_POSSESS_ITEM] && check_rights(R_FUN))

		var/mob/living/basic/possession_holder/created = new(get_turf(src), src)

		var/choice = tgui_alert(usr, "Take Control of newly created mob?", "Possession", list("Yes", "No"))
		if(!choice)
			return
		if(choice == "Yes")
			usr.client.cmd_assume_direct_control(created)
