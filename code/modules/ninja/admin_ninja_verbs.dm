
/*

Contents:
- Admin procs that make ninjas

*/


//ADMIN CREATE NINJA (From Player)
/client/proc/cmd_admin_ninjafy(mob/living/carbon/human/H in player_list)
	set category = null
	set name = "Make Space Ninja"

	if (!SSticker.mode)
		alert("Wait until the game starts")
		return

	if(!istype(H))
		return

	if(alert(src, "You sure?", "Confirm", "Yes", "No") != "Yes")
		return

	log_admin("[key_name(src)] turned [H.key] into a Space Ninja.")
	H.mind = create_ninja_mind(H.key)
	H.mind_initialize()
	H.equip_space_ninja(1)
	if(istype(H.wear_suit, /obj/item/clothing/suit/space/space_ninja))
		H.wear_suit:randomize_param()
		spawn(0)
			H.wear_suit:ninitialize(10,H)
	SSticker.mode.update_ninja_icons_added(H)


//ADMIN CREATE NINJA (From Ghost)
/client/proc/send_space_ninja()
	set category = "Fun"
	set name = "Spawn Space Ninja"
	set desc = "Spawns a space ninja for when you need a teenager with attitude."
	set popup_menu = 0

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!SSticker.mode)
		alert("The game hasn't started yet!")
		return
	if(alert("Are you sure you want to send in a space ninja?",,"Yes","No")=="No")
		return

	var/client/C = input("Pick character to spawn as the Space Ninja", "Key", "") as null|anything in clients
	if(!C)
		return

	// passing FALSE means the event doesn't start immediately
	var/datum/round_event/ghost_role/ninja/E = new(FALSE)
	E.priority_candidates += C
	E.processing = TRUE

	message_admins("<span class='notice'>[key_name_admin(key)] has spawned [key_name_admin(C.key)] as a Space Ninja.</span>")
	log_admin("[key] used Spawn Space Ninja.")

	return
