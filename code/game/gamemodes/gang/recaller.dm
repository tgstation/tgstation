//gangtool device
/obj/item/device/gangtool
	name = "suspicious device"
	desc = "A strange device of sorts. Hard to really make out what it actually does if you don't know how to operate it."
	icon_state = "gangtool-white"
	item_state = "walkietalkie"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	origin_tech = "programming=5;bluespace=2;syndicate=5"
	var/datum/gang/gang //Which gang uses this?
	var/recalling = 0
	var/outfits = 2
	var/free_pen = 0
	var/promotable = 0

/obj/item/device/gangtool/proc/register_device(mob/user)
	if(gang)	//It's already been registered!
		return
	if((promotable && (user.mind in SSticker.mode.get_gangsters())) || (user.mind in SSticker.mode.get_gang_bosses()))
		gang = user.mind.gang_datum
		gang.gangtools += src
		icon_state = "gangtool-[gang.color]"
		if(!(user.mind in gang.bosses))
			SSticker.mode.remove_gangster(user.mind, 0, 2)
			gang.bosses += user.mind
			user.mind.gang_datum = gang
			user.mind.special_role = "[gang.name] Gang Lieutenant"
			gang.add_gang_hud(user.mind)
			log_game("[key_name(user)] has been promoted to Lieutenant in the [gang.name] Gang")
			free_pen = 1
			gang.message_gangtools("[user] has been promoted to Lieutenant.")
			to_chat(user, "<FONT size=3 color=red><B>You have been promoted to Lieutenant!</B></FONT>")
			SSticker.mode.forge_gang_objectives(user.mind)
			SSticker.mode.greet_gang(user.mind,0)
			to_chat(user, "The <b>Gangtool</b> you registered will allow you to purchase weapons and equipment, and send messages to your gang.")
			to_chat(user, "Unlike regular gangsters, you may use <b>recruitment pens</b> to add recruits to your gang. Use them on unsuspecting crew members to recruit them. Don't forget to get your one free pen from the gangtool.")
	else
		to_chat(usr, "<span class='warning'>ACCESS DENIED: Unauthorized user.</span>")

/obj/item/device/gangtool/proc/recall(mob/user)
	if(!can_use(user))
		return 0

	if(SSshuttle.emergencyNoRecall)
		return 0

	if(recalling)
		to_chat(usr, "<span class='warning'>Error: Recall already in progress.</span>")
		return 0

	if(!gang.recalls)
		to_chat(usr, "<span class='warning'>Error: Unable to access communication arrays. Firewall has logged our signature and is blocking all further attempts.</span>")

	gang.message_gangtools("[usr] is attempting to recall the emergency shuttle.")
	recalling = 1
	to_chat(loc, "<span class='info'>\icon[src]Generating shuttle recall order with codes retrieved from last call signal...</span>")

	sleep(rand(100,300))

	if(SSshuttle.emergency.mode != SHUTTLE_CALL) //Shuttle can only be recalled when it's moving to the station
		to_chat(user, "<span class='warning'>\icon[src]Emergency shuttle cannot be recalled at this time.</span>")
		recalling = 0
		return 0
	to_chat(loc, "<span class='info'>\icon[src]Shuttle recall order generated. Accessing station long-range communication arrays...</span>")

	sleep(rand(100,300))

	if(!gang.dom_attempts)
		to_chat(user, "<span class='warning'>\icon[src]Error: Unable to access communication arrays. Firewall has logged our signature and is blocking all further attempts.</span>")
		recalling = 0
		return 0

	var/turf/userturf = get_turf(user)
	if(userturf.z != ZLEVEL_STATION) //Shuttle can only be recalled while on station
		to_chat(user, "<span class='warning'>\icon[src]Error: Device out of range of station communication arrays.</span>")
		recalling = 0
		return 0
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	if((100 * GLOB.start_state.score(end_state)) < 80) //Shuttle cannot be recalled if the station is too damaged
		to_chat(user, "<span class='warning'>\icon[src]Error: Station communication systems compromised. Unable to establish connection.</span>")
		recalling = 0
		return 0
	to_chat(loc, "<span class='info'>\icon[src]Comm arrays accessed. Broadcasting recall signal...</span>")

	sleep(rand(100,300))

	recalling = 0
	log_game("[key_name(user)] has tried to recall the shuttle with a gangtool.")
	message_admins("[key_name_admin(user)] has tried to recall the shuttle with a gangtool.", 1)
	userturf = get_turf(user)
	if(userturf.z == ZLEVEL_STATION) //Check one more time that they are on station.
		if(SSshuttle.cancelEvac(user))
			gang.recalls -= 1
			return 1

	to_chat(loc, "<span class='info'>\icon[src]No response recieved. Emergency shuttle cannot be recalled at this time.</span>")
	return 0

/obj/item/device/gangtool/spare
	outfits = 1

/obj/item/device/gangtool/spare/lt
	promotable = 1

///////////// Internal tool used by gang regulars ///////////

/obj/item/device/gangtool/soldier
	points = 5

/obj/item/device/gangtool/soldier/New(mob/user)
	. = ..()
	gang = user.mind.gang_datum
	gang.gangtools += src
	var/datum/action/innate/gang/tool/GT = new
	GT.Grant(user, src, gang)


/datum/action/innate/gang
	background_icon_state = "bg_spell"

/datum/action/innate/gang/IsAvailable()
	if(!owner.mind || !owner.mind in SSticker.mode.get_all_gangsters())
		return 0
	return ..()

/datum/action/innate/gang/tool
	name = "Personal Gang Tool"
	desc = "An implanted gang tool that lets you purchase gear"
	background_icon_state = "bg_mime"
	button_icon_state = "bolt_action"
	var/obj/item/device/gangtool/soldier/GT

/datum/action/innate/gang/tool/Grant(mob/user, obj/reg, datum/gang/G)
	. = ..()
	GT = reg
	button.color = G.color

/datum/action/innate/gang/tool/Activate()
	GT.attack_self(owner)
