//This could either be split into the proper DM files or placed somewhere else all together, but it'll do for now -Nodrak

/*

A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message.

*/

/obj/item/device/uplink
	var/welcome 					// Welcoming menu message
	var/items						// List of items
	var/item_data					// raw item text
	var/list/ItemList				// Parsed list of items
	var/uses 						// Numbers of crystals
	// List of items not to shove in their hands.
	var/list/NotInHand = list(/obj/machinery/singularity_beacon/syndicate)

/obj/item/device/uplink/New()
	welcome = ticker.mode.uplink_welcome
	if(!item_data)
		items = dd_replacetext(ticker.mode.uplink_items, "\n", "")	// Getting the text string of items
	else
		items = dd_replacetext(item_data)
	ItemList = dd_text2list(src.items, ";")	// Parsing the items text string
	uses = ticker.mode.uplink_uses

//Let's build a menu!
/obj/item/device/uplink/proc/generate_menu()

	var/dat = "<B>[src.welcome]</B><BR>"
	dat += "Tele-Crystals left: [src.uses]<BR>"
	dat += "<HR>"
	dat += "<B>Request item:</B><BR>"
	dat += "<I>Each item costs a number of tele-crystals as indicated by the number following their name.</I><br><BR>"

	var/cost
	var/item
	var/name
	var/path_obj
	var/path_text
	var/category_items = 1 //To prevent stupid :P

	for(var/D in ItemList)
		var/list/O = stringsplit(D, ":")
		if(O.len != 3)	//If it is not an actual item, make a break in the menu.
			if(O.len == 1)	//If there is one item, it's probably a title
				dat += "<b>[O[1]]</b><br>"
				category_items = 0
			else	//Else, it's a white space.
				if(category_items < 1)	//If there were no itens in the last category...
					dat += "<i>We apologize, as you could not afford anything from this category.</i><br>"
				dat += "<br>"
			continue

		path_text = O[1]
		cost = text2num(O[2])

		if(cost>uses)
			continue

		path_obj = text2path(path_text)
		item = new path_obj()
		name = O[3]
		del item

		dat += "<A href='byond://?src=\ref[src];buy_item=[path_text];cost=[cost]'>[name]</A> ([cost])<BR>"
		category_items++

	dat += "<A href='byond://?src=\ref[src];buy_item=random'>Random Item (??)</A><br>"
	dat += "<HR>"
	return dat

//If 'random' was selected
/obj/item/device/uplink/proc/chooseRandomItem()
	var/list/randomItems = list()

	//Sorry for all the ifs, but it makes it 1000 times easier for other people/servers to add or remove items from this list
	//Add only items the player can afford:
	if(uses > 19)
		randomItems.Add("/obj/item/weapon/circuitboard/teleporter") //Teleporter Circuit Board (costs 20, for nuke ops)

	if(uses > 9)
		randomItems.Add("/obj/item/toy/syndicateballoon")//Syndicate Balloon
		randomItems.Add("/obj/item/weapon/storage/syndie_kit/imp_uplink") //Uplink Implanter
		randomItems.Add("/obj/item/weapon/storage/box/syndicate") //Syndicate bundle

	//if(uses > 8)	//Nothing... yet.
	//if(uses > 7)	//Nothing... yet.

	if(uses > 6)
		randomItems.Add("/obj/item/weapon/aiModule/syndicate") //Hacked AI Upload Module
		randomItems.Add("/obj/item/device/radio/beacon/syndicate") //Singularity Beacon

	if(uses > 5)
		randomItems.Add("/obj/item/weapon/gun/projectile") //Revolver

	if(uses > 4)
		randomItems.Add("/obj/item/weapon/gun/energy/crossbow") //Energy Crossbow
		randomItems.Add("/obj/item/device/powersink") //Powersink

	if(uses > 3)
		randomItems.Add("/obj/item/weapon/melee/energy/sword") //Energy Sword
		randomItems.Add("/obj/item/clothing/mask/gas/voice") //Voice Changer
		randomItems.Add("/obj/item/device/chameleon") //Chameleon Projector

	if(uses > 2)
		randomItems.Add("/obj/item/weapon/storage/emp_kit") //EMP Grenades
		randomItems.Add("/obj/item/weapon/pen/paralysis") //Paralysis Pen
		randomItems.Add("/obj/item/weapon/cartridge/syndicate") //Detomatix Cartridge
		randomItems.Add("/obj/item/clothing/under/chameleon") //Chameleon Jumpsuit
		randomItems.Add("/obj/item/weapon/card/id/syndicate") //Agent ID Card
		randomItems.Add("/obj/item/weapon/card/emag") //Cryptographic Sequencer
		randomItems.Add("/obj/item/weapon/storage/syndie_kit/space") //Syndicate Space Suit
		randomItems.Add("/obj/item/device/encryptionkey/binary") //Binary Translator Key
		randomItems.Add("/obj/item/weapon/storage/syndie_kit/imp_freedom") //Freedom Implant
		randomItems.Add("/obj/item/clothing/glasses/thermal/syndi") //Thermal Imaging Goggles

	if(uses > 1)
/*
		var/list/usrItems = usr.get_contents() //Checks to see if the user has a revolver before giving ammo
		var/hasRevolver = 0
		for(var/obj/I in usrItems) //Only add revolver ammo if the user has a gun that can shoot it
			if(istype(I,/obj/item/weapon/gun/projectile))
				hasRevolver = 1

		if(hasRevolver) randomItems.Add("/obj/item/ammo_magazine/a357") //Revolver ammo
*/
		randomItems.Add("/obj/item/ammo_magazine/a357") //Revolver ammo
		randomItems.Add("/obj/item/clothing/shoes/syndigaloshes") //No-Slip Syndicate Shoes
		randomItems.Add("/obj/item/weapon/plastique") //C4

	if(uses > 0)
		randomItems.Add("/obj/item/weapon/soap/syndie") //Syndicate Soap
		randomItems.Add("/obj/item/weapon/storage/toolbox/syndicate") //Syndicate Toolbox

	if(!randomItems.len)
		del(randomItems)
		return 0
	else
		var/buyItem = pick(randomItems)

		switch(buyItem) //Ok, this gets a little messy, sorry.
			if("/obj/item/weapon/circuitboard/teleporter")
				uses -= 20
			if("/obj/item/toy/syndicateballoon" , "/obj/item/weapon/storage/syndie_kit/imp_uplink" , "/obj/item/weapon/storage/box/syndicate")
				uses -= 10
			if("/obj/item/weapon/aiModule/syndicate" , "/obj/item/device/radio/beacon/syndicate")
				uses -= 7
			if("/obj/item/weapon/gun/projectile")
				uses -= 6
			if("/obj/item/weapon/gun/energy/crossbow" , "/obj/item/device/powersink")
				uses -= 5
			if("/obj/item/weapon/melee/energy/sword" , "/obj/item/clothing/mask/gas/voice" , "/obj/item/device/chameleon")
				uses -= 4
			if("/obj/item/weapon/storage/emp_kit" , "/obj/item/weapon/pen/paralysis" , "/obj/item/weapon/cartridge/syndicate" , "/obj/item/clothing/under/chameleon" , \
			"/obj/item/weapon/card/id/syndicate" , "/obj/item/weapon/card/emag" , "/obj/item/weapon/storage/syndie_kit/space" , "/obj/item/device/encryptionkey/binary" , \
			"/obj/item/weapon/storage/syndie_kit/imp_freedom" , "/obj/item/clothing/glasses/thermal/syndi")
				uses -= 3
			if("/obj/item/ammo_magazine/a357" , "/obj/item/clothing/shoes/syndigaloshes" , "/obj/item/weapon/plastique")
				uses -= 2
			if("/obj/item/weapon/soap/syndie" , "/obj/item/weapon/storage/toolbox/syndicate")
				uses -= 1
		del(randomItems)
		return buyItem

/obj/item/device/uplink/proc/handleStatTracking(var/boughtItem)
//For stat tracking, sorry for making it so ugly
	if(!boughtItem) return

	switch(boughtItem)
		if("/obj/item/weapon/circuitboard/teleporter")
			feedback_add_details("traitor_uplink_items_bought","TP")
		if("/obj/item/toy/syndicateballoon")
			feedback_add_details("traitor_uplink_items_bought","BS")
		if("/obj/item/weapon/storage/syndie_kit/imp_uplink")
			feedback_add_details("traitor_uplink_items_bought","UI")
		if("/obj/item/weapon/storage/box/syndicate")
			feedback_add_details("traitor_uplink_items_bought","BU")
		if("/obj/item/weapon/aiModule/syndicate")
			feedback_add_details("traitor_uplink_items_bought","AI")
		if("/obj/item/device/radio/beacon/syndicate")
			feedback_add_details("traitor_uplink_items_bought","SB")
		if("/obj/item/weapon/gun/projectile")
			feedback_add_details("traitor_uplink_items_bought","RE")
		if("/obj/item/weapon/gun/energy/crossbow")
			feedback_add_details("traitor_uplink_items_bought","XB")
		if("/obj/item/device/powersink")
			feedback_add_details("traitor_uplink_items_bought","PS")
		if("/obj/item/weapon/melee/energy/sword")
			feedback_add_details("traitor_uplink_items_bought","ES")
		if("/obj/item/clothing/mask/gas/voice")
			feedback_add_details("traitor_uplink_items_bought","VC")
		if("/obj/item/device/chameleon")
			feedback_add_details("traitor_uplink_items_bought","CP")
		if("/obj/item/weapon/storage/emp_kit")
			feedback_add_details("traitor_uplink_items_bought","EM")
		if("/obj/item/weapon/pen/paralysis")
			feedback_add_details("traitor_uplink_items_bought","PP")
		if("/obj/item/weapon/cartridge/syndicate")
			feedback_add_details("traitor_uplink_items_bought","DC")
		if("/obj/item/clothing/under/chameleon")
			feedback_add_details("traitor_uplink_items_bought","CJ")
		if("/obj/item/weapon/card/id/syndicate")
			feedback_add_details("traitor_uplink_items_bought","AC")
		if("/obj/item/weapon/card/emag")
			feedback_add_details("traitor_uplink_items_bought","EC")
		if("/obj/item/weapon/storage/syndie_kit/space")
			feedback_add_details("traitor_uplink_items_bought","SS")
		if("/obj/item/device/encryptionkey/binary")
			feedback_add_details("traitor_uplink_items_bought","BT")
		if("/obj/item/weapon/storage/syndie_kit/imp_freedom")
			feedback_add_details("traitor_uplink_items_bought","FI")
		if("/obj/item/clothing/glasses/thermal/syndi")
			feedback_add_details("traitor_uplink_items_bought","TM")
		if("/obj/item/ammo_magazine/a357")
			feedback_add_details("traitor_uplink_items_bought","RA")
		if("/obj/item/clothing/shoes/syndigaloshes")
			feedback_add_details("traitor_uplink_items_bought","SH")
		if("/obj/item/weapon/plastique")
			feedback_add_details("traitor_uplink_items_bought","C4")
		if("/obj/item/weapon/soap/syndie")
			feedback_add_details("traitor_uplink_items_bought","SP")
		if("/obj/item/weapon/storage/toolbox/syndicate")
			feedback_add_details("traitor_uplink_items_bought","ST")

/obj/item/device/uplink/Topic(href, href_list)

	if (href_list["buy_item"])
		if(href_list["buy_item"] == "random")
			var/boughtItem = chooseRandomItem()
			if(boughtItem)
				href_list["buy_item"] = boughtItem
				feedback_add_details("traitor_uplink_items_bought","RN")
				return 1
			else
				return 0

		else
			if(text2num(href_list["cost"]) > uses) // Not enough crystals for the item
				return 0

			//if(usr:mind && ticker.mode.traitors[usr:mind])
				//var/datum/traitorinfo/info = ticker.mode.traitors[usr:mind]
				//info.spawnlist += href_list["buy_item"]

			uses -= text2num(href_list["cost"])
			handleStatTracking(href_list["buy_item"]) //Note: chooseRandomItem handles it's own stat tracking. This proc is not meant for 'random'.
		return 1



// HIDDEN UPLINK - Can be stored in anything but the host item has to have a trigger for it.
/* How to create an uplink in 3 easy steps!

 1. All obj/item 's have a hidden_uplink var. By default it's null. Give the item one with "new(src)", it must be in it's contents. Feel free to add "uses".

 2. Code in the triggers. Use check_trigger for this, I recommend closing the item's menu with "usr << browse(null, "window=windowname") if it returns true.
 The var/value is the value that will be compared with the var/target. If they are equal it will activate the menu.

 3. If you want the menu to stay until the users locks his uplink, add an active_uplink_check(mob/user as mob) in your interact/attack_hand proc.
 Then check if it's true, if true return. This will stop the normal menu appearing and will instead show the uplink menu.
*/

/obj/item/device/uplink/hidden
	name = "Hidden Uplink."
	desc = "There is something wrong if you're examining this."
	var/active = 0
	var/list/purchase_log = list()

// The hidden uplink MUST be inside an obj/item's contents.
/obj/item/device/uplink/hidden/New()
	spawn(2)
		if(!istype(src.loc, /obj/item))
			del(src)
	..()

// Toggles the uplink on and off. Normally this will bypass the item's normal functions and go to the uplink menu, if activated.
/obj/item/device/uplink/hidden/proc/toggle()
	active = !active

// Directly trigger the uplink. Turn on if it isn't already.
/obj/item/device/uplink/hidden/proc/trigger(mob/user as mob)
	if(!active)
		toggle()
	interact(user)

// Checks to see if the value meets the target. Like a frequency being a traitor_frequency, in order to unlock a headset.
// If true, it accesses trigger() and returns 1. If it fails, it returns false. Use this to see if you need to close the
// current item's menu.
/obj/item/device/uplink/hidden/proc/check_trigger(mob/user as mob, var/value, var/target)
	if(value == target)
		trigger(user)
		return 1
	return 0

// Interaction code. Gathers a list of items purchasable from the paren't uplink and displays it. It also adds a lock button.
/obj/item/device/uplink/hidden/proc/interact(mob/user as mob)

	var/dat = "<body link='yellow' alink='white' bgcolor='#601414'><font color='white'>"
	dat += src.generate_menu()
	dat += "<A href='byond://?src=\ref[src];lock=1'>Lock</a>"
	dat += "</font></body>"
	user << browse(dat, "window=hidden")
	onclose(user, "hidden")
	return

// The purchasing code.
/obj/item/device/uplink/hidden/Topic(href, href_list)

	if (usr.stat || usr.restrained())
		return

	if (!( istype(usr, /mob/living/carbon/human)))
		return 0

	if ((usr.contents.Find(src.loc) || (in_range(src.loc, usr) && istype(src.loc.loc, /turf))))
		usr.machine = src
		if(href_list["lock"])
			toggle()
			usr << browse(null, "window=hidden")
			return 1

		if(..(href, href_list) == 1)
			var/path_obj = text2path(href_list["buy_item"])
			var/obj/I = new path_obj(get_turf(usr))
			if(ishuman(usr))
				var/mob/living/carbon/human/A = usr
				A.put_in_any_hand_if_possible(I)
			purchase_log += "[usr] ([usr.ckey]) bought [I]."
	interact(usr)
	return

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

// PRESET UPLINKS
// A collection of preset uplinks.
//
// Includes normal radio uplink, multitool uplink,
// implant uplink (not the implant tool) and a preset headset uplink.

/obj/item/device/radio/uplink/New()
	hidden_uplink = new(src)

/obj/item/device/radio/uplink/attack_self(mob/user as mob)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/multitool/uplink/New()
	hidden_uplink = new(src)

/obj/item/device/multitool/uplink/attack_self(mob/user as mob)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/radio/headset/uplink
	traitor_frequency = 1445

/obj/item/device/radio/headset/uplink/New()
	..()
	hidden_uplink = new(src)
	hidden_uplink.uses = 10



