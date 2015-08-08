//This could either be split into the proper DM files or placed somewhere else all together, but it'll do for now -Nodrak

/*

A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message.

*/

var/list/world_uplinks = list()

/obj/item/device/uplink
	var/welcome = "Syndicate Uplink Console:"	// Welcoming menu message
	var/uses = 20								// Numbers of crystals
	// List of items not to shove in their hands.
	var/purchase_log = ""
	var/show_description = null
	var/active = 0

	var/uplink_owner = null//text-only
	var/used_TC = 0

/obj/item/device/uplink/New()
	..()
	world_uplinks+=src

/obj/item/device/uplink/Destroy()
	world_uplinks-=src
	..()

//Let's build a menu!
/obj/item/device/uplink/proc/generate_menu()

	var/dat = "<B>[src.welcome]</B><BR>"
	dat += "Tele-Crystals left: [src.uses]<BR>"
	dat += "<HR>"
	dat += "<B>Request item:</B><BR>"
	dat += "<I>Each item costs a number of tele-crystals as indicated by the number following their name.</I><br><BR>"

	var/list/buyable_items = get_uplink_items()

	// Loop through categories
	var/index = 0
	for(var/category in buyable_items)

		index++
		dat += "<b>[category]</b><br>"

		var/i = 0

		// Loop through items in category
		for(var/datum/uplink_item/item in buyable_items[category])
			i++
			var/desc = "[item.desc]"
			var/cost_text = ""
			if(item.cost > 0)
				cost_text = "([item.cost])"
			if(item.cost <= uses)
				dat += "<A href='byond://?src=\ref[src];buy_item=[category]:[i];'>[item.name]</A> [cost_text] "
			else
				dat += "<font color='grey'><i>[item.name] [cost_text] </i></font>"
			if(item.desc)
				if(show_description == item.type)
					dat += "<A href='byond://?src=\ref[src];show_desc=0'><font size=2>\[-\]</font></A><BR><font size=2>[desc]</font>"
				else
					dat += "<A href='byond://?src=\ref[src];show_desc=[item.type]'><font size=2>\[?\]</font></A>"
			dat += "<BR>"

		// Break up the categories, if it isn't the last.
		if(buyable_items.len != index)
			dat += "<br>"

	dat += "<HR>"
	return dat

// Interaction code. Gathers a list of items purchasable from the paren't uplink and displays it. It also adds a lock button.
/obj/item/device/uplink/interact(mob/user as mob)

	var/dat = "<body link='yellow' alink='white' bgcolor='#601414'><font color='white'>"
	dat += src.generate_menu()
	dat += "<A href='byond://?src=\ref[src];lock=1'>Lock</a>"
	dat += "</font></body>"
	user << browse(dat, "window=hidden")
	onclose(user, "hidden")
	return


/obj/item/device/uplink/Topic(href, href_list)
	..()

	if(!active)
		return

	if (href_list["buy_item"])

		var/item = href_list["buy_item"]
		var/list/split = text2list(item, ":") // throw away variable

		if(split.len == 2)
			// Collect category and number
			var/category = split[1]
			var/number = text2num(split[2])

			var/list/buyable_items = get_uplink_items()

			var/list/uplink = buyable_items[category]
			if(uplink && uplink.len >= number)
				var/datum/uplink_item/I = uplink[number]
				if(I)
					I.buy(src, usr)


	else if(href_list["show_desc"])

		var/type = text2path(href_list["show_desc"])
		show_description = type
		interact(usr)


// HIDDEN UPLINK - Can be stored in anything but the host item has to have a trigger for it.
/* How to create an uplink in 3 easy steps!

 1. All obj/item 's have a hidden_uplink var. By default it's null. Give the item one with "new(src)", it must be in it's contents. Feel free to add "uses".

 2. Code in the triggers. Use check_trigger for this, I recommend closing the item's menu with "usr << browse(null, "window=windowname") if it returns true.
 The var/value is the value that will be compared with the var/target. If they are equal it will activate the menu.

 3. If you want the menu to stay until the users locks his uplink, add an active_uplink_check(mob/user as mob) in your interact/attack_hand proc.
 Then check if it's true, if true return. This will stop the normal menu appearing and will instead show the uplink menu.
*/

/obj/item/device/uplink/hidden
	name = "hidden uplink."
	desc = "There is something wrong if you're examining this."

/obj/item/device/uplink/hidden/Topic(href, href_list)
	if(usr.stat || usr.restrained() || usr.paralysis || usr.stunned || usr.weakened)
		return 0		// To stop people using their uplink when they shouldn't be able to
	..()
	if(href_list["lock"])
		toggle()
		usr << browse(null, "window=hidden")
		return 1

// Toggles the uplink on and off. Normally this will bypass the item's normal functions and go to the uplink menu, if activated.
/obj/item/device/uplink/hidden/proc/toggle()
	active = !active

// Directly trigger the uplink. Turn on if it isn't already.
/obj/item/device/uplink/hidden/proc/trigger(mob/user)
	if(!active)
		toggle()
	interact(user)

// Checks to see if the value meets the target. Like a frequency being a traitor_frequency, in order to unlock a headset.
// If true, it accesses trigger() and returns 1. If it fails, it returns false. Use this to see if you need to close the
// current item's menu.
/obj/item/device/uplink/hidden/proc/check_trigger(mob/user, value, target)
	if(value == target)
		trigger(user)
		return 1
	return 0

// I placed this here because of how relevant it is.
// You place this in your uplinkable item to check if an uplink is active or not.
// If it is, it will display the uplink menu and return 1, else it'll return false.
// If it returns true, I recommend closing the item's normal menu with "user << browse(null, "window=name")"
/obj/item/proc/active_uplink_check(mob/user as mob)
	// Activates the uplink if it's active
	if(src.hidden_uplink)
		if(src.hidden_uplink.active)
			src.hidden_uplink.trigger(user)
			return 1
	return 0
//Refund proc for the borg teleporter (later I'll make a general refund proc if there is demand for it)
/obj/item/device/radio/uplink/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/antag_spawner/borg_tele))
		var/obj/item/weapon/antag_spawner/borg_tele/S = W
		if(!S.used)
			hidden_uplink.uses += S.TC_cost
			qdel(S)
			user << "<span class='notice'>Teleporter refunded.</span>"
		else
			user << "<span class='warning'>This teleporter is already used!</span>"

// PRESET UPLINKS
// A collection of preset uplinks.
//
// Includes normal radio uplink, multitool uplink,
// implant uplink (not the implant tool) and a preset headset uplink.

/obj/item/device/radio/uplink/New()
	hidden_uplink = new(src)
	icon_state = "radio"

/obj/item/device/radio/uplink/attack_self(mob/user)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/multitool/uplink/New()
	hidden_uplink = new(src)

/obj/item/device/multitool/uplink/attack_self(mob/user)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/radio/headset/uplink
	traitor_frequency = 1445

/obj/item/device/radio/headset/uplink/New()
	..()
	hidden_uplink = new(src)
	hidden_uplink.uses = 20



