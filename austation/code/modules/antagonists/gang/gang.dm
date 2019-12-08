/datum/antagonist/gang
	name = "Gangster"
	roundend_category = "gangsters"
	can_coexist_with_others = FALSE
	job_rank = ROLE_GANG
	antagpanel_category = "Gang"
	var/hud_type = "gangster"
	var/message_name = "Gangster"
	var/datum/team/gang/gang

/datum/antagonist/gang/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		if(new_owner.unconvertable)
			return FALSE

/datum/antagonist/gang/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_gang_icons_added(M)

/datum/antagonist/gang/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_gang_icons_removed(M)

/datum/antagonist/gang/get_team()
	return gang

/datum/antagonist/gang/greet()
	gang.greet_gangster(owner)

/datum/antagonist/gang/farewell()
	if(ishuman(owner.current))
		owner.current.visible_message("<span class='deconversion_message'>[owner.current] looks like [owner.current.p_theyve()] just remembered [owner.current.p_their()] real allegiance!</span>", null, null, null, owner.current)
		to_chat(owner, "<span class='userdanger'>You are no longer a gangster!</span>")

/datum/antagonist/gang/on_gain()
	if(!gang)
		create_team()
	..()
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		if(owner.assigned_role == "Clown")
			to_chat(owner, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			H.dna.remove_mutation(CLOWNMUT)
	add_to_gang()
	owner.remove_antag_datum(/datum/antagonist/vigilante)
	if(istype(SSticker.mode, /datum/game_mode/hell_march))
		var/obj/item/gangtool/hell_march/HM = new(owner.current)
		HM.register_device(owner.current)

/datum/antagonist/gang/on_removal()
	remove_from_gang()
	for(var/obj/item/gangtool/hell_march/O in owner.current.GetAllContents())
		qdel(O)
	if(istype(SSticker.mode, /datum/game_mode/hell_march))
		owner.add_antag_datum(/datum/antagonist/vigilante)
	..()

/datum/antagonist/gang/create_team(team)
	if(!gang) // add_antag_datum calls create_team, so we need to avoid generating two gangs in that case
		if(team)
			gang = team
			return
		var/datum/team/gang/gangteam = pick_n_take(GLOB.possible_gangs)
		if(gangteam)
			gang = new gangteam

/datum/antagonist/gang/proc/equip_gang() // Bosses get equipped with their tools
	return

/datum/antagonist/gang/proc/update_gang_icons_added(mob/living/M)
	var/datum/atom_hud/antag/gang/ganghud = GLOB.huds[gang.hud_entry_num]
	if(!ganghud)
		ganghud = new/datum/atom_hud/antag/gang()
		gang.hud_entry_num = GLOB.huds.len+1 // this is the index the gang hud will be added at
		GLOB.huds += ganghud
	ganghud.color = gang.color
	ganghud.join_hud(M)
	set_antag_hud(M,hud_type)

/datum/antagonist/gang/proc/update_gang_icons_removed(mob/living/M)
	var/datum/atom_hud/antag/gang/ganghud = GLOB.huds[gang.hud_entry_num]
	if(ganghud)
		ganghud.leave_hud(M)
		set_antag_hud(M, null)

/datum/antagonist/gang/proc/can_be_converted(mob/living/candidate)
	if(!candidate.mind)
		return FALSE
	if(!can_be_owned(candidate.mind))
		return FALSE
	var/mob/living/carbon/human/H = candidate
	if(!istype(H)) //Can't nonhumans
		return FALSE
	return TRUE

/datum/antagonist/gang/proc/promote() // Bump up to boss
	var/datum/team/gang/old_gang = get_team()
	var/datum/mind/old_owner = owner
	var/datum/antagonist/gang/boss/lieutenant/new_boss = new
	var/datum/antagonist/gang/current_gang = src
	current_gang.silent = TRUE
	owner.remove_antag_datum(current_gang)
	new_boss.silent = TRUE
	old_owner.add_antag_datum(new_boss,old_gang)
	new_boss.silent = FALSE
	log_game("[key_name(old_owner)] has been promoted to Lieutenant in the [old_gang.name] Gang")
	to_chat(old_owner, "<FONT size=3 color=red><B>You have been promoted to Lieutenant!</B></FONT>")


// Admin commands
/datum/antagonist/gang/get_admin_commands()
	. = ..()
	.["Promote"] = CALLBACK(src,.proc/admin_promote)
	.["Set Influence"] = CALLBACK(src, .proc/admin_adjust_influence)
	if(gang.domination_time != NOT_DOMINATING)
		.["Set domination time left"] = CALLBACK(src, .proc/set_dom_time_left)

/datum/antagonist/gang/admin_add(datum/mind/new_owner,mob/admin)
	var/new_or_existing = input(admin, "Which gang do you want to be assigned to the user?", "Gangs") as null|anything in list("New","Existing")
	if(isnull(new_or_existing))
		return
	else if(new_or_existing == "New")
		var/newgang = input(admin, "Select a gang, or select random to pick a random one.", "New gang") as null|anything in GLOB.possible_gangs + "Random"
		if(isnull(newgang))
			return
		else if(newgang == "Random")
			var/datum/team/gang/G = pick_n_take(GLOB.possible_gangs)
			gang = new G
		else
			GLOB.possible_gangs -= newgang
			gang = new newgang
	else
		if(!GLOB.gangs.len) // no gangs exist
			to_chat(admin, "<span class='danger'>No gangs exist, please create a new one instead.</span>")
			return
		var/existinggang = input(admin, "Select a gang, or select random to pick a random one.", "Existing gang") as null|anything in GLOB.gangs + "Random"
		if(isnull(existinggang))
			return
		else if(existinggang == "Random")
			gang = pick(GLOB.gangs)
		else
			gang = existinggang
	..()
	return TRUE

/datum/antagonist/gang/proc/admin_promote(mob/admin)
	message_admins("[key_name_admin(admin)] has promoted [owner] to gang boss.")
	log_admin("[key_name(admin)] has promoted [owner] to boss.")
	promote()

/datum/antagonist/gang/proc/admin_adjust_influence()
	var/inf = input("Influence for [gang.name]","Gang influence", gang.influence) as null | num
	if(!isnull(inf))
		gang.influence = inf
		message_admins("[key_name_admin(usr)] changed [gang.name]'s influence to [inf].")
		log_admin("[key_name(usr)] changed [gang.name]'s influence to [inf].")

/datum/antagonist/gang/proc/add_to_gang()
	gang.add_member(owner)
	owner.current.log_message("<font color='red'>Has been converted to the [gang.name] gang!</font>", INDIVIDUAL_ATTACK_LOG)

/datum/antagonist/gang/proc/remove_from_gang()
	gang.remove_member(owner)
	owner.current.log_message("<font color='red'>Has been deconverted from the [gang.name] gang!</font>", INDIVIDUAL_ATTACK_LOG)

/datum/antagonist/gang/proc/set_dom_time_left(mob/admin)
	if(gang.domination_time == NOT_DOMINATING)
		return // an admin shouldn't need this
	var/seconds = input(admin, "Set the time left for the gang to win, in seconds", "Domination time left") as null|num
	if(seconds && seconds > 0)
		gang.domination_time = world.time + seconds*10
		gang.message_gangtools("Takeover shortened to [gang.domination_time_remaining()] seconds by your Syndicate benefactors.")

// Boss type. Those can use gang tools to buy items for their gang, in particular the Dominator, used to win the gamemode, along with more gang tools to promote fellow gangsters to boss status.
/datum/antagonist/gang/boss
	name = "Gang boss"
	hud_type = "gang_boss"
	message_name = "Leader"

/datum/antagonist/gang/boss/on_gain()
	..()
	if(gang)
		gang.leaders += owner

/datum/antagonist/gang/boss/on_removal()
	if(gang)
		gang.leaders -= owner
	..()

/datum/antagonist/gang/boss/antag_listing_name()
	return ..() + "(Boss)"

/datum/antagonist/gang/boss/equip_gang(gangtool = TRUE, pen = TRUE, spraycan = TRUE, hud = TRUE) // usually has to be called separately
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return

	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET,
		"hands" = ITEM_SLOT_HANDS
	)

	if(gangtool)
		var/obj/item/gangtool/G = new()
		var/where = H.equip_in_one_of_slots(G, slots)
		if (!where)
			to_chat(H, "Your Syndicate benefactors were unfortunately unable to get you a Gangtool.")
		else
			G.register_device(H)
			to_chat(H, "The <b>Gangtool</b> in your [where] will allow you to purchase weapons and equipment, send messages to your gang, and recall the emergency shuttle from anywhere on the station.")
			to_chat(H, "As the gang boss, you can also promote your gang members to <b>lieutenant</b>. Unlike regular gangsters, Lieutenants cannot be deconverted and are able to use recruitment pens and gangtools.")

	if(pen)
		var/obj/item/pen/gang/T = new()
		var/where2 = H.equip_in_one_of_slots(T, slots)
		if (!where2)
			to_chat(H, "Your Syndicate benefactors were unfortunately unable to get you a recruitment pen to start.")
		else
			to_chat(H, "The <b>recruitment pen</b> in your [where2] will help you get your gang started. Stab unsuspecting crew members with it to recruit them.")

	if(spraycan)
		var/obj/item/toy/crayon/spraycan/gang/SC = new(null,gang)
		var/where3 = H.equip_in_one_of_slots(SC, slots)
		if (!where3)
			to_chat(H, "Your Syndicate benefactors were unfortunately unable to get you a territory spraycan to start.")
		else
			to_chat(H, "The <b>territory spraycan</b> in your [where3] can be used to claim areas of the station for your gang. The more territory your gang controls, the more influence you get. All gangsters can use these, so distribute them to grow your influence faster.")

	if(hud)
		var/obj/item/clothing/glasses/hud/security/chameleon/C = new(null,gang)
		var/where4 = H.equip_in_one_of_slots(C, slots)
		if (!where4)
			to_chat(H, "Your Syndicate benefactors were unfortunately unable to get you a chameleon security HUD.")
		else
			to_chat(H, "The <b>chameleon security HUD</b> in your [where4] will help you keep track of who is mindshield-implanted, and unable to be recruited.")

// Admin commands for bosses
/datum/antagonist/gang/boss/admin_add(datum/mind/new_owner,mob/admin)
	if(!new_owner.has_antag_datum(parent_type))
		..()
	equip_gang()
	log_admin("[key_name(admin)] has made [new_owner.current] a boss of the [gang.name] gang.")
	to_chat(new_owner.current, "<span class='userdanger'>You are a member of the [gang.name] Gang leadership now!</span>")
	return TRUE

/datum/antagonist/gang/boss/get_admin_commands()
	. = ..()
	. -= "Promote"
	.["Take gangtool"] = CALLBACK(src,.proc/admin_take_gangtool)
	.["Give gangtool"] = CALLBACK(src,.proc/admin_give_gangtool)
	.["Demote"] = CALLBACK(src,.proc/admin_demote)

/datum/antagonist/gang/boss/proc/demote()
	var/old_gang = gang
	var/datum/mind/old_owner = owner
	silent = TRUE
	owner.remove_antag_datum(/datum/antagonist/gang/boss)
	var/datum/antagonist/gang/new_gangster = new /datum/antagonist/gang()
	new_gangster.silent = TRUE
	old_owner.add_antag_datum(new_gangster,old_gang)
	new_gangster.silent = FALSE
	log_game("[key_name(old_owner)] has been demoted to Gangster in the [gang.name] Gang")
	to_chat(old_owner, "<span class='userdanger'>The gang has been disappointed of your leader traits! You are a regular gangster now!</span>")

/datum/antagonist/gang/boss/proc/admin_take_gangtool(mob/admin)
	var/list/L = owner.current.get_contents()
	var/obj/item/gangtool/gangtool = locate() in L
	if (!gangtool)
		to_chat(admin, "<span class='danger'>Deleting gangtool failed!</span>")
		return
	qdel(gangtool)

/datum/antagonist/gang/boss/proc/admin_give_gangtool(mob/admin)
	equip_gang(TRUE, FALSE, FALSE, FALSE)

/datum/antagonist/gang/boss/proc/admin_demote(datum/mind/target,mob/user)
	message_admins("[key_name_admin(user)] has demoted [owner.current] from [name].")
	log_admin("[key_name(user)] has demoted [owner.current] from [name].")
	admin_take_gangtool(user)
	demote()

/datum/antagonist/gang/boss/lieutenant
	name = "Gang Lieutenant"
	message_name = "Lieutenant"

#define MAXIMUM_RECALLS 3
#define INFLUENCE_INTERVAL 1800
// Gang team datum. This handles the gang itself.
/datum/team/gang
	name = "Gang"
	member_name = "gangster"
	var/hud_entry_num // because if you put something other than a number in GLOB.huds, god have mercy on your fucking soul friend
	var/list/leaders = list() // bosses
	var/gateways = 0
	var/max_leaders = MAX_LEADERS_GANG
	var/list/territories = list() // territories owned by the gang.
	var/list/lost_territories = list() // territories lost by the gang.
	var/list/new_territories = list() // territories captured by the gang.
	var/list/gangtools = list()
	var/list/tags_by_mind = list() //Assoc list in format of tags_by_mind[mind_of_gangster] = list(tag1, tag2, tag3) where tags are the actual object decals.
	var/domination_time = NOT_DOMINATING
	var/dom_attempts = INITIAL_DOM_ATTEMPTS
	var/color
	var/influence = 0 // influence of the gang, based on how many territories they own. Can be used to buy weapons and tools from a gang uplink.
	var/winner // Once the gang wins with a dominator, this becomes true. For roundend credits purposes.
	var/list/inner_outfits = list()
	var/list/outer_outfits = list()
	var/next_point_time
	var/recalls = MAXIMUM_RECALLS // Once this reaches 0, this gang cannot force recall the shuttle with their gangtool anymore

/datum/team/gang/New(starting_members)
	. = ..()
	GLOB.gangs += src
	if(starting_members)
		if(islist(starting_members))
			for(var/datum/mind/groveboss in starting_members)
				leaders += groveboss
				var/datum/antagonist/gang/boss/gb = new
				groveboss.add_antag_datum(gb, src)
				gb.equip_gang()

		else
			var/datum/mind/CJ = starting_members
			if(istype(CJ))
				leaders += CJ
				var/datum/antagonist/gang/boss/bossdatum = new
				CJ.add_antag_datum(bossdatum, src)
				bossdatum.equip_gang()
	next_point_time = world.time + INFLUENCE_INTERVAL
	addtimer(CALLBACK(src, .proc/handle_territories), INFLUENCE_INTERVAL)

/datum/team/gang/Destroy()
	GLOB.gangs -= src
	..()

/datum/team/gang/roundend_report()
	var/list/report = list()
	report += "<span class='header'>[name]:</span>"
	if(winner)
		report += "<span class='greentext'>The [name] gang was successful!</span>"
	else
		report += "<span class='redtext'>The [name] gang has failed!</span>"

	report += "The [name] gang bosses were:"
	report += printplayerlist(leaders)
	report += "The [name] [member_name]s were:"
	report += printplayerlist(members-leaders)

	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

/datum/team/gang/proc/greet_gangster(datum/mind/gangster)
	to_chat(gangster, "<FONT size=3 color=red><B>You are now a member of the [name] Gang!</B></FONT>")
	to_chat(gangster, "<font color='red'>Help your bosses take over the station by claiming territory with <b>special spraycans</b> only they can provide. Simply spray on any unclaimed area of the station.</font>")
	to_chat(gangster, "<font color='red'>Their ultimate objective is to take over the station with a Dominator machine.</font>")
	to_chat(gangster, "<font color='red'>You can identify your mates by their <b>large, bright \[G\] <font color='[color]'>icon</font></b>.</font>")
	gangster.store_memory("You are a member of the [name] Gang!")

/datum/team/gang/proc/get_soldier_territories(datum/mind/soldier)
	if(!islist(tags_by_mind[soldier]))	//They have no tagged territories!
		return 0
	var/list/tags = tags_by_mind[soldier]
	return tags.len

/datum/team/gang/proc/handle_territories()
	next_point_time = world.time + INFLUENCE_INTERVAL
	if(!leaders.len)
		return
	var/added_names = ""
	var/lost_names = ""

	//Re-add territories that were reclaimed, so if they got tagged over, they can still earn income if they tag it back before the next status report
	var/list/reclaimed_territories = new_territories & lost_territories
	territories |= reclaimed_territories
	new_territories -= reclaimed_territories
	lost_territories -= reclaimed_territories

	//Process lost territories
	for(var/area in lost_territories)
		if(lost_names != "")
			lost_names += ", "
		lost_names += "[lost_territories[area]]"
		territories -= area

	//Calculate and report influence growth

	//Process new territories
	for(var/area in new_territories)
		if(added_names != "")
			added_names += ", "
		added_names += "[new_territories[area]]"
		territories += area

	//Report territory changes
	var/message = "<b>[src] Gang Status Report:</b>.<BR>*---------*<BR>"
	message += "<b>[new_territories.len] new territories:</b><br><i>[added_names]</i><br>"
	message += "<b>[lost_territories.len] territories lost:</b><br><i>[lost_names]</i><br>"
	//Clear the lists
	new_territories = list()
	lost_territories = list()
	var/total_territories = total_claimable_territories()
	var/control = round((territories.len/total_territories)*100, 1)
	var/uniformed = check_clothing()
	message += "Your gang now has <b>[control]% control</b> of the station.<BR>*---------*<BR>"
	if(domination_time != NOT_DOMINATING)
		var/new_time = max(world.time, domination_time - (uniformed * 4) - (territories.len * 2))
		if(new_time < domination_time)
			message += "Takeover shortened by [(domination_time - new_time)*0.1] seconds for defending [territories.len] territories.<BR>"
			domination_time = new_time
		message += "<b>[domination_time_remaining()] seconds remain</b> in hostile takeover.<BR>"
	else
		if(locate(/obj/item/gangtool/hell_march) in gangtools) // this is a Gangmageddon gang
			for(var/obj/item/gangtool/hell_march/HM in gangtools)
				HM.pay_income()
		else
			var/new_influence = check_territory_income()
			if(new_influence != influence)
				message += "Gang influence has increased by [new_influence - influence] for defending [territories.len] territories and [uniformed] uniformed gangsters.<BR>"
			influence = new_influence
			message += "Your gang now has <b>[influence] influence</b>.<BR>"
	message_gangtools(message)
	addtimer(CALLBACK(src, .proc/handle_territories), INFLUENCE_INTERVAL)

/datum/team/gang/proc/total_claimable_territories()
	var/list/valid_territories = list()
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION)) //First, collect all area types on the station zlevel
		for(var/ar in SSmapping.areas_in_z["[z]"])
			var/area/A = ar
			if(!(A.type in valid_territories) && A.valid_territory)
				valid_territories |= A.type
	return valid_territories.len

/datum/team/gang/proc/check_territory_income()
	var/new_influence = min(999,influence + 15 + (check_clothing() * 2) + territories.len)
	return new_influence

/datum/team/gang/proc/check_clothing()
	//Count uniformed gangsters
	var/uniformed = 0
	for(var/datum/mind/gangmind in members)
		if(ishuman(gangmind.current))
			var/mob/living/carbon/human/gangster = gangmind.current
			//Gangster must be alive and on station
			if((gangster.stat == DEAD) || (is_station_level(gangster.z)))
				continue

			var/obj/item/clothing/outfit
			var/obj/item/clothing/gang_outfit
			if(gangster.w_uniform)
				outfit = gangster.w_uniform
				if(outfit.type in inner_outfits)
					gang_outfit = outfit
			if(gangster.wear_suit)
				outfit = gangster.wear_suit
				if(outfit.type in outer_outfits)
					gang_outfit = outfit

			if(gang_outfit)
				gangster << "<span class='notice'>The [src] Gang's influence grows as you wear [gang_outfit].</span>"
				uniformed++
	return uniformed

/datum/team/gang/proc/adjust_influence(value)
	influence = max(0, influence + value)

/datum/team/gang/proc/message_gangtools(message)
	if(!gangtools.len || !message)
		return
	for(var/i in gangtools)
		var/obj/item/gangtool/tool = i
		var/mob/living/mob = get(tool.loc, /mob/living)
		if(mob && mob.mind && mob.stat == CONSCIOUS)
			var/datum/antagonist/gang/gangster = mob.mind.has_antag_datum(/datum/antagonist/gang)
			if(gangster.gang == src)
				to_chat(mob, "<span class='warning'>[icon2html(tool, mob)] [message]</span>")
				playsound(mob.loc, 'sound/machines/twobeep.ogg', 50, 1)
			return

/datum/team/gang/proc/domination()
	domination_time = world.time + determine_domination_time()*10
	set_security_level("delta")

/datum/team/gang/proc/determine_domination_time() // calculates the value in seconds (this is the initial domination time!)
	var/total_territories = total_claimable_territories()
	return max(180,480 - (round((territories.len/total_territories)*100, 1) * 9))

/datum/team/gang/proc/domination_time_remaining() // retrieves the value from world.time based deciseconds to seconds
	var/diff = domination_time - world.time
	return round(diff * 0.1)


#undef MAXIMUM_RECALLS
#undef INFLUENCE_INTERVAL
