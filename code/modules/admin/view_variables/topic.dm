//DO NOT ADD MORE TO THIS FILE.
//Use vv_do_topic() for datums!
/client/proc/view_var_Topic(href, href_list, hsrc)
	if( (usr.client != src) || !src.holder || !holder.CheckAdminHref(href, href_list))
		return
	var/target = GET_VV_TARGET
	vv_do_basic(target, href_list, href)
	if(istype(target, /datum))
		var/datum/D = target
		D.vv_do_topic(href_list)
	else if(islist(target))
		vv_do_list(target, href_list)
	if(href_list["Vars"])
		debug_variables(locate(href_list["Vars"]))

	//rest of this should proabbly be eventually moved to vv_do_topic in datums

	if(href_list["mob_player_panel"])
		if(!check_rights(NONE))
			return

		var/mob/M = locate(href_list["mob_player_panel"]) in GLOB.mob_list
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.holder.show_player_panel(M)

	else if(href_list["godmode"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["godmode"]) in GLOB.mob_list
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_godmode(M)


	else if(href_list["osay"])
		if(!check_rights(R_FUN, 0))
			return
		usr.client.object_say(locate(href_list["osay"]))

	else if(href_list["regenerateicons"])
		if(!check_rights(NONE))
			return

		var/mob/M = locate(href_list["regenerateicons"]) in GLOB.mob_list
		if(!ismob(M))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		M.regenerate_icons()

//Needs +VAREDIT past this point

	else if(check_rights(R_VAREDIT))


	//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).

		if(href_list["rename"])
			if(!check_rights(NONE))
				return

			var/mob/M = locate(href_list["rename"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			var/new_name = stripped_input(usr,"What would you like to name this mob?","Input a name",M.real_name,MAX_NAME_LEN)
			if( !new_name || !M )
				return

			message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].")
			M.fully_replace_character_name(M.real_name,new_name)
			vv_update_display(M, "name", new_name)
			vv_update_display(M, "real_name", M.real_name || "No real name")

		else if(href_list["give_spell"])
			if(!check_rights(NONE))
				return

			var/mob/M = locate(href_list["give_spell"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			src.give_spell(M)

		else if(href_list["remove_spell"])
			if(!check_rights(NONE))
				return

			var/mob/M = locate(href_list["remove_spell"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			remove_spell(M)

		else if(href_list["give_disease"])
			if(!check_rights(NONE))
				return

			var/mob/M = locate(href_list["give_disease"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			src.give_disease(M)

		else if(href_list["gib"])
			if(!check_rights(R_FUN))
				return

			var/mob/M = locate(href_list["gib"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			src.cmd_admin_gib(M)

		else if(href_list["build_mode"])
			if(!check_rights(R_BUILD))
				return

			var/mob/M = locate(href_list["build_mode"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			togglebuildmode(M)

		else if(href_list["drop_everything"])
			if(!check_rights(NONE))
				return

			var/mob/M = locate(href_list["drop_everything"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			if(usr.client)
				usr.client.cmd_admin_drop_everything(M)

		else if(href_list["direct_control"])
			if(!check_rights(NONE))
				return

			var/mob/M = locate(href_list["direct_control"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			if(usr.client)
				usr.client.cmd_assume_direct_control(M)

		else if(href_list["offer_control"])
			if(!check_rights(NONE))
				return

			var/mob/M = locate(href_list["offer_control"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return
			offer_control(M)

		else if (href_list["modarmor"])
			if(!check_rights(NONE))
				return

			var/obj/O = locate(href_list["modarmor"])
			if(!istype(O))
				to_chat(usr, "This can only be used on instances of type /obj")
				return

			var/list/pickerlist = list()
			var/list/armorlist = O.armor.getList()

			for (var/i in armorlist)
				pickerlist += list(list("value" = armorlist[i], "name" = i))

			var/list/result = presentpicker(usr, "Modify armor", "Modify armor: [O]", Button1="Save", Button2 = "Cancel", Timeout=FALSE, inputtype = "text", values = pickerlist)

			if (islist(result))
				if (result["button"] == 2) // If the user pressed the cancel button
					return
				// text2num conveniently returns a null on invalid values
				O.armor = O.armor.setRating(melee = text2num(result["values"]["melee"]),\
			                  bullet = text2num(result["values"]["bullet"]),\
			                  laser = text2num(result["values"]["laser"]),\
			                  energy = text2num(result["values"]["energy"]),\
			                  bomb = text2num(result["values"]["bomb"]),\
			                  bio = text2num(result["values"]["bio"]),\
			                  rad = text2num(result["values"]["rad"]),\
			                  fire = text2num(result["values"]["fire"]),\
			                  acid = text2num(result["values"]["acid"]))
				log_admin("[key_name(usr)] modified the armor on [O] ([O.type]) to melee: [O.armor.melee], bullet: [O.armor.bullet], laser: [O.armor.laser], energy: [O.armor.energy], bomb: [O.armor.bomb], bio: [O.armor.bio], rad: [O.armor.rad], fire: [O.armor.fire], acid: [O.armor.acid]")
				message_admins("<span class='notice'>[key_name_admin(usr)] modified the armor on [O] ([O.type]) to melee: [O.armor.melee], bullet: [O.armor.bullet], laser: [O.armor.laser], energy: [O.armor.energy], bomb: [O.armor.bomb], bio: [O.armor.bio], rad: [O.armor.rad], fire: [O.armor.fire], acid: [O.armor.acid]</span>")
			else
				return

		else if(href_list["delall"])
			if(!check_rights(R_DEBUG|R_SERVER))
				return

			var/obj/O = locate(href_list["delall"])
			if(!isobj(O))
				to_chat(usr, "This can only be used on instances of type /obj")
				return

			var/action_type = alert("Strict type ([O.type]) or type and all subtypes?",,"Strict type","Type and subtypes","Cancel")
			if(action_type == "Cancel" || !action_type)
				return

			if(alert("Are you really sure you want to delete all objects of type [O.type]?",,"Yes","No") != "Yes")
				return

			if(alert("Second confirmation required. Delete?",,"Yes","No") != "Yes")
				return

			var/O_type = O.type
			switch(action_type)
				if("Strict type")
					var/i = 0
					for(var/obj/Obj in world)
						if(Obj.type == O_type)
							i++
							qdel(Obj)
						CHECK_TICK
					if(!i)
						to_chat(usr, "No objects of this type exist")
						return
					log_admin("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) ")
					message_admins("<span class='notice'>[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) </span>")
				if("Type and subtypes")
					var/i = 0
					for(var/obj/Obj in world)
						if(istype(Obj,O_type))
							i++
							qdel(Obj)
						CHECK_TICK
					if(!i)
						to_chat(usr, "No objects of this type exist")
						return
					log_admin("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) ")
					message_admins("<span class='notice'>[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) </span>")

		else if(href_list["addreagent"])
			if(!check_rights(NONE))
				return

			var/atom/A = locate(href_list["addreagent"])

			if(!A.reagents)
				var/amount = input(usr, "Specify the reagent size of [A]", "Set Reagent Size", 50) as num
				if(amount)
					A.create_reagents(amount)

			if(A.reagents)
				var/chosen_id
				var/list/reagent_options = sortList(GLOB.chemical_reagents_list)
				switch(alert(usr, "Choose a method.", "Add Reagents", "Enter ID", "Choose ID"))
					if("Enter ID")
						var/valid_id
						while(!valid_id)
							chosen_id = stripped_input(usr, "Enter the ID of the reagent you want to add.")
							if(!chosen_id) //Get me out of here!
								break
							for(var/ID in reagent_options)
								if(ID == chosen_id)
									valid_id = 1
							if(!valid_id)
								to_chat(usr, "<span class='warning'>A reagent with that ID doesn't exist!</span>")
					if("Choose ID")
						chosen_id = input(usr, "Choose a reagent to add.", "Choose a reagent.") as null|anything in reagent_options
				if(chosen_id)
					var/amount = input(usr, "Choose the amount to add.", "Choose the amount.", A.reagents.maximum_volume) as num
					if(amount)
						A.reagents.add_reagent(chosen_id, amount)
						log_admin("[key_name(usr)] has added [amount] units of [chosen_id] to \the [A]")
						message_admins("<span class='notice'>[key_name(usr)] has added [amount] units of [chosen_id] to \the [A]</span>")

		else if(href_list["explode"])
			if(!check_rights(R_FUN))
				return

			var/atom/A = locate(href_list["explode"])
			if(!isobj(A) && !ismob(A) && !isturf(A))
				to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
				return

			src.cmd_admin_explosion(A)

		else if(href_list["emp"])
			if(!check_rights(R_FUN))
				return

			var/atom/A = locate(href_list["emp"])
			if(!isobj(A) && !ismob(A) && !isturf(A))
				to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
				return

			src.cmd_admin_emp(A)

		else if(href_list["modtransform"])
			if(!check_rights(R_DEBUG))
				return

			var/atom/A = locate(href_list["modtransform"])
			if(!istype(A))
				to_chat(usr, "This can only be done to atoms.")
				return

			var/result = input(usr, "Choose the transformation to apply","Transform Mod") as null|anything in list("Scale","Translate","Rotate")
			var/matrix/M = A.transform
			switch(result)
				if("Scale")
					var/x = input(usr, "Choose x mod","Transform Mod") as null|num
					var/y = input(usr, "Choose y mod","Transform Mod") as null|num
					if(!isnull(x) && !isnull(y))
						A.transform = M.Scale(x,y)
				if("Translate")
					var/x = input(usr, "Choose x mod","Transform Mod") as null|num
					var/y = input(usr, "Choose y mod","Transform Mod") as null|num
					if(!isnull(x) && !isnull(y))
						A.transform = M.Translate(x,y)
				if("Rotate")
					var/angle = input(usr, "Choose angle to rotate","Transform Mod") as null|num
					if(!isnull(angle))
						A.transform = M.Turn(angle)

		else if(href_list["rotatedatum"])
			if(!check_rights(NONE))
				return

			var/atom/A = locate(href_list["rotatedatum"])
			if(!istype(A))
				to_chat(usr, "This can only be done to instances of type /atom")
				return

			switch(href_list["rotatedir"])
				if("right")
					A.setDir(turn(A.dir, -45))
				if("left")
					A.setDir(turn(A.dir, 45))
			vv_update_display(A, "dir", dir2text(A.dir))

		else if(href_list["editorgans"])
			if(!check_rights(NONE))
				return

			var/mob/living/carbon/C = locate(href_list["editorgans"]) in GLOB.mob_list
			if(!istype(C))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
				return

			manipulate_organs(C)

		else if(href_list["givemartialart"])
			if(!check_rights(NONE))
				return

			var/mob/living/carbon/C = locate(href_list["givemartialart"]) in GLOB.carbon_list
			if(!istype(C))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
				return

			var/list/artpaths = subtypesof(/datum/martial_art)
			var/list/artnames = list()
			for(var/i in artpaths)
				var/datum/martial_art/M = i
				artnames[initial(M.name)] = M

			var/result = input(usr, "Choose the martial art to teach","JUDO CHOP") as null|anything in artnames
			if(!usr)
				return
			if(QDELETED(C))
				to_chat(usr, "Mob doesn't exist anymore")
				return

			if(result)
				var/chosenart = artnames[result]
				var/datum/martial_art/MA = new chosenart
				MA.teach(C)
				log_admin("[key_name(usr)] has taught [MA] to [key_name(C)].")
				message_admins("<span class='notice'>[key_name_admin(usr)] has taught [MA] to [key_name_admin(C)].</span>")

		else if(href_list["givetrauma"])
			if(!check_rights(NONE))
				return

			var/mob/living/carbon/C = locate(href_list["givetrauma"]) in GLOB.mob_list
			if(!istype(C))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
				return

			var/list/traumas = subtypesof(/datum/brain_trauma)
			var/result = input(usr, "Choose the brain trauma to apply","Traumatize") as null|anything in traumas
			if(!usr)
				return
			if(QDELETED(C))
				to_chat(usr, "Mob doesn't exist anymore")
				return

			if(!result)
				return

			var/datum/brain_trauma/BT = C.gain_trauma(result)
			if(BT)
				log_admin("[key_name(usr)] has traumatized [key_name(C)] with [BT.name]")
				message_admins("<span class='notice'>[key_name_admin(usr)] has traumatized [key_name_admin(C)] with [BT.name].</span>")

		else if(href_list["curetraumas"])
			if(!check_rights(NONE))
				return

			var/mob/living/carbon/C = locate(href_list["curetraumas"]) in GLOB.mob_list
			if(!istype(C))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
				return

			C.cure_all_traumas(TRAUMA_RESILIENCE_ABSOLUTE)
			log_admin("[key_name(usr)] has cured all traumas from [key_name(C)].")
			message_admins("<span class='notice'>[key_name_admin(usr)] has cured all traumas from [key_name_admin(C)].</span>")

		else if(href_list["hallucinate"])
			if(!check_rights(NONE))
				return

			var/mob/living/carbon/C = locate(href_list["hallucinate"]) in GLOB.mob_list
			if(!istype(C))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
				return

			var/list/hallucinations = subtypesof(/datum/hallucination)
			var/result = input(usr, "Choose the hallucination to apply","Send Hallucination") as null|anything in hallucinations
			if(!usr)
				return
			if(QDELETED(C))
				to_chat(usr, "Mob doesn't exist anymore")
				return

			if(result)
				new result(C, TRUE)

		else if(href_list["makehuman"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/monkey/Mo = locate(href_list["makehuman"]) in GLOB.mob_list
			if(!istype(Mo))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/monkey")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!Mo)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("humanone"=href_list["makehuman"]))

		else if(href_list["makemonkey"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["makemonkey"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("monkeyone"=href_list["makemonkey"]))

		else if(href_list["makerobot"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["makerobot"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("makerobot"=href_list["makerobot"]))

		else if(href_list["makealien"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["makealien"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("makealien"=href_list["makealien"]))

		else if(href_list["makeslime"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["makeslime"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("makeslime"=href_list["makeslime"]))

		else if(href_list["makeai"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/H = locate(href_list["makeai"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("makeai"=href_list["makeai"]))

		else if(href_list["setspecies"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["setspecies"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return

			var/result = input(usr, "Please choose a new species","Species") as null|anything in GLOB.species_list

			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return

			if(result)
				var/newtype = GLOB.species_list[result]
				admin_ticket_log("[key_name_admin(usr)] has modified the bodyparts of [H] to [result]")
				H.set_species(newtype)

		else if(href_list["editbodypart"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/C = locate(href_list["editbodypart"]) in GLOB.mob_list
			if(!istype(C))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
				return

			var/edit_action = input(usr, "What would you like to do?","Modify Body Part") as null|anything in list("add","remove", "augment")
			if(!edit_action)
				return
			var/list/limb_list = list()
			if(edit_action == "remove" || edit_action == "augment")
				for(var/obj/item/bodypart/B in C.bodyparts)
					limb_list += B.body_zone
				if(edit_action == "remove")
					limb_list -= BODY_ZONE_CHEST
			else
				limb_list = list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
				for(var/obj/item/bodypart/B in C.bodyparts)
					limb_list -= B.body_zone

			var/result = input(usr, "Please choose which body part to [edit_action]","[capitalize(edit_action)] Body Part") as null|anything in limb_list

			if(!C)
				to_chat(usr, "Mob doesn't exist anymore")
				return

			if(result)
				var/obj/item/bodypart/BP = C.get_bodypart(result)
				switch(edit_action)
					if("remove")
						if(BP)
							BP.drop_limb()
						else
							to_chat(usr, "[C] doesn't have such bodypart.")
					if("add")
						if(BP)
							to_chat(usr, "[C] already has such bodypart.")
						else
							if(!C.regenerate_limb(result))
								to_chat(usr, "[C] cannot have such bodypart.")
					if("augment")
						if(ishuman(C))
							if(BP)
								BP.change_bodypart_status(BODYPART_ROBOTIC, TRUE, TRUE)
							else
								to_chat(usr, "[C] doesn't have such bodypart.")
						else
							to_chat(usr, "Only humans can be augmented.")
			admin_ticket_log("[key_name_admin(usr)] has modified the bodyparts of [C]")


		else if(href_list["purrbation"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["purrbation"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return
			if(!ishumanbasic(H))
				to_chat(usr, "This can only be done to the basic human species at the moment.")
				return

			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return

			var/success = purrbation_toggle(H)
			if(success)
				to_chat(usr, "Put [H] on purrbation.")
				log_admin("[key_name(usr)] has put [key_name(H)] on purrbation.")
				var/msg = "<span class='notice'>[key_name_admin(usr)] has put [key_name(H)] on purrbation.</span>"
				message_admins(msg)
				admin_ticket_log(H, msg)

			else
				to_chat(usr, "Removed [H] from purrbation.")
				log_admin("[key_name(usr)] has removed [key_name(H)] from purrbation.")
				var/msg = "<span class='notice'>[key_name_admin(usr)] has removed [key_name(H)] from purrbation.</span>"
				message_admins(msg)
				admin_ticket_log(H, msg)

		else if(href_list["adjustDamage"] && href_list["mobToDamage"])
			if(!check_rights(NONE))
				return

			var/mob/living/L = locate(href_list["mobToDamage"]) in GLOB.mob_list
			if(!istype(L))
				return

			var/Text = href_list["adjustDamage"]

			var/amount =  input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num

			if(!L)
				to_chat(usr, "Mob doesn't exist anymore")
				return

			var/newamt
			switch(Text)
				if("brute")
					L.adjustBruteLoss(amount)
					newamt = L.getBruteLoss()
				if("fire")
					L.adjustFireLoss(amount)
					newamt = L.getFireLoss()
				if("toxin")
					L.adjustToxLoss(amount)
					newamt = L.getToxLoss()
				if("oxygen")
					L.adjustOxyLoss(amount)
					newamt = L.getOxyLoss()
				if("brain")
					L.adjustBrainLoss(amount)
					newamt = L.getBrainLoss()
				if("clone")
					L.adjustCloneLoss(amount)
					newamt = L.getCloneLoss()
				if("stamina")
					L.adjustStaminaLoss(amount)
					newamt = L.getStaminaLoss()
				else
					to_chat(usr, "You caused an error. DEBUG: Text:[Text] Mob:[L]")
					return

			if(amount != 0)
				var/log_msg = "[key_name(usr)] dealt [amount] amount of [Text] damage to [key_name(L)]"
				message_admins("[key_name(usr)] dealt [amount] amount of [Text] damage to [ADMIN_LOOKUPFLW(L)]")
				log_admin(log_msg)
				admin_ticket_log(L, "<font color='blue'>[log_msg]</font>")
				vv_update_display(L, Text, "[newamt]")
		else if(href_list["copyoutfit"])
			if(!check_rights(R_SPAWN))
				return
			var/mob/living/carbon/human/H = locate(href_list["copyoutfit"]) in GLOB.carbon_list
			if(istype(H))
				H.copy_outfit()
		else if(href_list["modquirks"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["modquirks"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return

			var/list/options = list("Clear"="Clear")
			for(var/x in subtypesof(/datum/quirk))
				var/datum/quirk/T = x
				var/qname = initial(T.name)
				options[H.has_quirk(T) ? "[qname] (Remove)" : "[qname] (Add)"] = T

			var/result = input(usr, "Choose quirk to add/remove","Quirk Mod") as null|anything in options
			if(result)
				if(result == "Clear")
					for(var/datum/quirk/q in H.roundstart_quirks)
						H.remove_quirk(q.type)
				else
					var/T = options[result]
					if(H.has_quirk(T))
						H.remove_quirk(T)
					else
						H.add_quirk(T,TRUE)

	//Finally, refresh if something modified the list.
	if(href_list["datumrefresh"])
		var/datum/DAT = locate(href_list["datumrefresh"])
		if(istype(DAT, /datum) || istype(DAT, /client))
			debug_variables(DAT)

