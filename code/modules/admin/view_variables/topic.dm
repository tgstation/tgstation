//DO NOT ADD MORE TO THIS FILE.
//Use vv_do_topic() for datums!
/client/proc/view_var_Topic(href, href_list, hsrc)
	if(!check_rights_for(src, R_VAREDIT) || !holder.CheckAdminHref(href, href_list))
		return
	var/target = GET_VV_TARGET
	vv_do_basic(target, href_list, href)
	if(isdatum(target))
		var/datum/D = target
		D.vv_do_topic(href_list)
	else if(islist(target))
		vv_do_list(target, href_list)
	if(href_list["Vars"])
		var/datum/vars_target = locate(href_list["Vars"])
		if(href_list["special_varname"]) // Some special vars can't be located even if you have their ref, you have to use this instead
			vars_target = vars_target.vars[href_list["special_varname"]]
		debug_variables(vars_target)

//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).
	if(href_list["rename"])

		var/mob/M = locate(href_list["rename"]) in GLOB.mob_list
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob", confidential = TRUE)
			return

		var/new_name = stripped_input(usr,"What would you like to name this mob?","Input a name",M.real_name,MAX_NAME_LEN)

		// If the new name is something that would be restricted by IC chat filters,
		// give the admin a warning but allow them to do it anyway if they want.
		if(is_ic_filtered(new_name) || is_soft_ic_filtered(new_name) && tgui_alert(usr, "Your selected name contains words restricted by IC chat filters. Confirm this new name?", "IC Chat Filter Conflict", list("Confirm", "Cancel")) == "Cancel")
			return

		if( !new_name || !M )
			return

		message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].")
		M.fully_replace_character_name(M.real_name,new_name)
		vv_update_display(M, "name", new_name)
		vv_update_display(M, "real_name", M.real_name || "No real name")

	else if(href_list["rotatedatum"])

		var/atom/A = locate(href_list["rotatedatum"])
		if(!istype(A))
			to_chat(usr, "This can only be done to instances of type /atom", confidential = TRUE)
			return

		switch(href_list["rotatedir"])
			if("right")
				A.setDir(turn(A.dir, -45))
			if("left")
				A.setDir(turn(A.dir, 45))
		vv_update_display(A, "dir", dir2text(A.dir))


	else if(href_list["adjustDamage"] && href_list["mobToDamage"])

		var/mob/living/L = locate(href_list["mobToDamage"]) in GLOB.mob_list
		if(!istype(L))
			return

		var/Text = href_list["adjustDamage"]

		var/amount = input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num|null

		if (isnull(amount))
			return

		if(!L)
			to_chat(usr, "Mob doesn't exist anymore", confidential = TRUE)
			return

		var/newamt
		switch(Text)
			if("brute")
				L.adjustBruteLoss(amount, forced = TRUE)
				newamt = L.getBruteLoss()
			if("fire")
				L.adjustFireLoss(amount, forced = TRUE)
				newamt = L.getFireLoss()
			if("toxin")
				L.adjustToxLoss(amount, forced = TRUE)
				newamt = L.getToxLoss()
			if("oxygen")
				L.adjustOxyLoss(amount, forced = TRUE)
				newamt = L.getOxyLoss()
			if("brain")
				L.adjustOrganLoss(ORGAN_SLOT_BRAIN, amount)
				newamt = L.get_organ_loss(ORGAN_SLOT_BRAIN)
			if("stamina")
				L.adjustStaminaLoss(amount, forced = TRUE)
				newamt = L.getStaminaLoss()
			else
				to_chat(usr, "You caused an error. DEBUG: Text:[Text] Mob:[L]", confidential = TRUE)
				return

		if(amount != 0)
			var/log_msg = "[key_name(usr)] dealt [amount] amount of [Text] damage to [key_name(L)]"
			message_admins("[key_name(usr)] dealt [amount] amount of [Text] damage to [ADMIN_LOOKUPFLW(L)]")
			log_admin(log_msg)
			admin_ticket_log(L, "<font color='blue'>[log_msg]</font>")
			vv_update_display(L, Text, "[newamt]")

	else if(href_list["item_to_tweak"] && href_list["var_tweak"])

		var/obj/item/editing = locate(href_list["item_to_tweak"])
		if(!istype(editing) || QDELING(editing))
			return

		var/existing_val = -1
		switch(href_list["var_tweak"])
			if("damtype")
				existing_val = editing.damtype
			if("force")
				existing_val = editing.force
			if("wound")
				existing_val = editing.wound_bonus
			if("bare wound")
				existing_val = editing.bare_wound_bonus
			else
				CRASH("Invalid var_tweak passed to item vv set var: [href_list["var_tweak"]]")

		var/new_val
		if(href_list["var_tweak"] == "damtype")
			new_val = input("Enter the new damage type for [editing]","Set Damtype", existing_val) in list(BRUTE, BURN, TOX, OXY, STAMINA, BRAIN)
		else
			new_val = input("Enter the new value for [editing]'s [href_list["var_tweak"]]","Set [href_list["var_tweak"]]", existing_val) as num|null
		if(isnull(new_val) || new_val == existing_val || QDELETED(editing) || !check_rights(R_VAREDIT))
			return

		switch(href_list["var_tweak"])
			if("damtype")
				editing.damtype = new_val
			if("force")
				editing.force = new_val
			if("wound")
				editing.wound_bonus = new_val
			if("bare wound")
				editing.bare_wound_bonus = new_val

		message_admins("[key_name(usr)] set [editing]'s [href_list["var_tweak"]] to [new_val] (was [existing_val])")
		log_admin("[key_name(usr)] set [editing]'s [href_list["var_tweak"]] to [new_val] (was [existing_val])")
		vv_update_display(editing, href_list["var_tweak"], istext(new_val) ? uppertext(new_val) : new_val)

	//Finally, refresh if something modified the list.
	if(href_list["datumrefresh"])
		var/datum/DAT = locate(href_list["datumrefresh"])
		if(isdatum(DAT) || istype(DAT, /client) || islist(DAT))
			debug_variables(DAT)
