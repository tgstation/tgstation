//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/item/weapon
	name = "weapon"
	icon = 'weapons.dmi'

/obj/item/weapon/shield
	name = "shield"

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'weapons.dmi'
	icon_state = "riot"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BACK
	force = 5.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	g_amt = 7500
	m_amt = 1000
	origin_tech = "materials=2"

	IsShield()
		return 1

/obj/item/weapon/shield/energy
	name = "energy combat shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	icon = 'weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = 1
	origin_tech = "materials=4;magnets=3;syndicate=4"
	var/active = 0


/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of Nar-Sie's followers."
	icon_state = "nullrod"
	item_state = "nullrod"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	force = 10
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	w_class = 1

/obj/item/weapon/nullrod/attack(mob/M as mob, mob/living/user as mob)

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	log_admin("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	message_admins("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return

	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red The rod slips out of your hand and hits your head."
		user.take_organ_damage(10)
		user.Paralyse(20)
		return

	if (M.stat !=2)
		if((M.mind in ticker.mode.cult) && prob(33))
			M << "\red The power of [src] clears your mind of the cult's influence!"
			user << "\red You wave [src] over [M]'s head and see their eyes become clear, their mind returning to normal."
			ticker.mode.remove_cultist(M.mind)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] waves [] over []'s head.", user, src, M), 1)
		else if(prob(10))
			user << "\red The rod slips in your hand."
			..()
		else
			user << "\red The rod appears to do nothing."
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] waves [] over []'s head.", user, src, M), 1)
			return

/obj/item/weapon/nullrod/afterattack(atom/A, mob/user as mob)
	if (istype(A, /turf/simulated/floor))
		user << "\blue You hit the floor with the [src]."
		call(/obj/effect/rune/proc/revealrunes)(src)

/*/obj/item/weapon/sord
	name = "\improper SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	force = 2
	throwforce = 1
	w_class = 3*/

/obj/item/weapon/claymore
	name = "claymore"
	desc = "BLOOD FOR THE BLOOD GOD."	//SKULLS FOR THE SKULL THRONE. --SkyMarshal
	icon_state = "claymore"
	item_state = "claymore"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	force = 40
	throwforce = 10
	w_class = 3

	IsShield()
		return 1

/obj/item/weapon/bodybag
	name = "body bag"
	desc = "A bag used to deal with a corpse."
	icon = 'closet.dmi'
	icon_state = "bodybag"
	force = 5.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = 1.0
	g_amt = 7500
	m_amt = 1000
	origin_tech = "materials=2"

/obj/item/weapon/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/mode = 1
	flags = TABLEPASS
	w_class = 3.0

/obj/item/weapon/rsp
	name = "\improper Rapid-Seed-Producer (RSP)"
	desc = "A device used to rapidly deploy seeds."
	icon = 'items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/mode = 1
	flags = TABLEPASS
	w_class = 3.0

/obj/item/weapon/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = "materials=2"
	m_amt = 30000
	g_amt = 15000
	var/ammo = 10

/obj/item/weapon/rcd_ammo/large
	name = "super compressed matter cartridge"
	ammo = 30

/obj/item/weapon/money
	name = "stack of credits"
	desc = "A pile of 1 credit."
	gender = PLURAL
	icon = 'items.dmi'
	icon_state = "spacecash"
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 2
	w_class = 1.0
	var/currency
	var/worth
	var/split = 5
	var/round = 0.01
	var/access = list()
	access = ACCESS_CRATE_CASH

/obj/item/weapon/spacecash
	New() // Just in case
		spawn(1)
			new/obj/item/weapon/money(loc)
			del src

/obj/item/weapon/money/proc/updatedesc()
	name = "stack of [currency]"
	desc = "A pile of [worth] [currency]"

/obj/item/weapon/money/New(var/nloc, var/nworth=1,var/ncurrency  = "credits")
	if(!worth)
		worth = nworth
	if(!currency)
		currency = ncurrency
	split = round(worth/2,round)
	updatedesc()
	return ..(nloc)

/obj/item/weapon/money/c10
	icon_state = "spacecash10"
	access = ACCESS_CRATE_CASH
	desc = "A pile of 10 credits."
	worth = 10

/obj/item/weapon/money/c20
	icon_state = "spacecash20"
	access = ACCESS_CRATE_CASH
	desc = "A pile of 20 credits."
	worth = 20

/obj/item/weapon/money/c50
	icon_state = "spacecash50"
	access = ACCESS_CRATE_CASH
	desc = "A pile of 50 credits."
	worth = 50

/obj/item/weapon/money/c100
	icon_state = "spacecash100"
	access = ACCESS_CRATE_CASH
	desc = "A pile of 100 credits."
	worth = 100

/obj/item/weapon/money/c200
	icon_state = "spacecash200"
	access = ACCESS_CRATE_CASH
	desc = "A pile of 200 credits."
	worth = 200

/obj/item/weapon/money/c500
	icon_state = "spacecash500"
	access = ACCESS_CRATE_CASH
	desc = "A pile of 500 credits."
	worth = 500

/obj/item/weapon/money/c1000
	icon_state = "spacecash1000"
	access = ACCESS_CRATE_CASH
	desc = "A pile of 1000 credits."
	worth = 1000

/obj/item/weapon/money/attack_self(var/mob/user)
	interact(user)

/obj/item/weapon/money/proc/interact(var/mob/user)

	user.machine = src

	var/dat

	dat += "<BR>[worth] [currency]"
	dat += "<BR>New pile:"

	dat += "<A href='?src=\ref[src];sd=5'>-</a>"
	dat += "<A href='?src=\ref[src];sd=1'>-</a>"
	if(round<=0.1)
		dat += "<A href='?src=\ref[src];sd=0.1'>-</a>"
		if(round<=0.01)
			dat += "<A href='?src=\ref[src];sd=0.01'>-</a>"
	dat += "[split]"
	if(round<=0.01)
		dat += "<A href='?src=\ref[src];su=0.01'>+</a>"
	if(round<=0.1)
		dat += "<A href='?src=\ref[src];su=0.1'>+</a>"
	dat += "<A href='?src=\ref[src];su=1'>+</a>"
	dat += "<A href='?src=\ref[src];su=5'>+</a>"
	dat += "<BR><A href='?src=\ref[src];split=1'>split</a>"


	user << browse(dat, "window=computer;size=400x500")

	onclose(user, "computer")
	return

/obj/item/weapon/money/Topic(href, href_list)
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

		if (href_list["su"])
			var/samt = text2num(href_list["su"])
			if(split+samt<worth)
				split+=samt
		if (href_list["sd"])
			var/samt = text2num(href_list["sd"])
			if(split-samt>0)
				split-=samt
		if(href_list["split"])
			new /obj/item/weapon/money(get_turf(src),split,currency)
			worth-=split
			split = round(worth/2,round)
			updatedesc()


		src.add_fingerprint(usr)
	src.updateUsrDialog()
	for (var/mob/M in viewers(1, src.loc))
		if (M.client && M.machine == src)
			src.attack_self(M)
	return

/obj/item/weapon/money/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I,/obj/item/weapon/money))
		var/mob/living/carbon/c = user
		if(!uppertext(I:currency)==uppertext(currency))
			c<<"You can't mix currencies!"
			return ..()
		else
			worth+=I:worth
			c<<"You combine the piles."
			updatedesc()
			del I
	return ..()


/obj/item/device/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	name = "mass-spectrometer"
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = 2.0
	flags = FPRINT | TABLEPASS| CONDUCT | OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=2;biotech=2"
	var/details = 0
	var/recent_fail = 0

/obj/item/device/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=2"

/*/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "The Captain is first and all other heads are last."
	icon_state = "chainofcommand"
	item_state = "chainofcommand"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	var/charges = 50.0
	var/maximum_charges = 50.0
	var/status = 1
	origin_tech = "combat=4"*/

/obj/item/weapon/melee/energy
	var/active = 0

/obj/item/weapon/melee/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	force = 40.0
	throwforce = 25.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | CONDUCT | NOSHIELD | TABLEPASS
	origin_tech = "combat=3"

/obj/item/weapon/melee/energy/sword
	color
	name = "energy sword"
	desc = "It cuts AND cooks at the same time!"
	icon_state = "sword0"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD
	origin_tech = "magnets=3;syndicate=4"

/obj/item/weapon/melee/energy/sword/chainsword
	color = "chain"
	New()
		return

/obj/item/weapon/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"

/obj/item/weapon/melee/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	force = 40.0//Normal attacks deal very high damage.
	throwforce = 1//Throwing or dropping the item deletes it.
	throw_speed = 1
	throw_range = 1
	w_class = 4.0//So you can't hide it in your pocket or some such.
	flags = FPRINT | TABLEPASS | NOSHIELD
	var/datum/effect/effect/system/spark_spread/spark_system

/obj/item/weapon/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 1.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon = 'harvest.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = 1.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'items.dmi'
	icon_state = "soap"
	w_class = 1.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/soap/nanotrasen
	desc = "A NanoTrasen brand bar of soap. Smells of plasma."
	icon_state = "soapnt"

/obj/item/weapon/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap." //What is this I don't even. "Smells of comdoms." --SkyMarshal
	icon_state = "soapdeluxe"

/obj/item/weapon/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"

/obj/item/weapon/bedsheet
	name = "bedsheet"
	desc = "Nice, linen bedsheet. Perfect to put on a bed."
	icon = 'items.dmi'
	icon_state = "sheet"
	layer = 4.0
	item_state = "bedsheet"
	throwforce = 1
	w_class = 1.0
	throw_speed = 2
	throw_range = 10
	color = "white"

/obj/item/weapon/bedsheet/blue
	icon_state = "sheetblue"
	color = "blue"

/obj/item/weapon/bedsheet/green
	icon_state = "sheetgreen"
	color = "green"

/obj/item/weapon/bedsheet/orange
	icon_state = "sheetorange"
	color = "orange"

/obj/item/weapon/bedsheet/purple
	icon_state = "sheetpurple"
	color = "purple"

/obj/item/weapon/bedsheet/rainbow
	icon_state = "sheetrainbow"
	color = "rainbow"

/obj/item/weapon/bedsheet/red
	icon_state = "sheetred"
	color = "red"

/obj/item/weapon/bedsheet/yellow
	icon_state = "sheetyellow"
	color = "yellow"

/obj/item/weapon/bedsheet/mime
	icon_state = "sheetmime"
	color = "mime"

/obj/item/weapon/bedsheet/clown
	icon_state = "sheetclown"
	color = "clown"

/obj/item/weapon/bedsheet/captain
	icon_state = "sheetcaptain"
	color = "captain"

/obj/item/weapon/bedsheet/rd
	icon_state = "sheetrd"
	color = "director"

/obj/item/weapon/bedsheet/medical
	icon_state = "sheetmedical"
	color = "medical"

/obj/item/weapon/bedsheet/hos
	icon_state = "sheethos"
	color = "hosred"

/obj/item/weapon/bedsheet/hop
	icon_state = "sheethop"
	color = "hop"

/obj/item/weapon/bedsheet/ce
	icon_state = "sheetce"
	color = "chief"

/obj/item/weapon/bedsheet/brown
	icon_state = "sheetbrown"
	color = "brown"

/obj/item/weapon/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 3
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	var/spam_flag = 0

/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'items.dmi'
	amount = 5 //To compensate for wounds
	max_amount = 5
	w_class = 1
	throw_speed = 4
	throw_range = 20
	var/heal_brute = 0
	var/heal_burn = 0

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "roll of gauze"
	desc = "A roll of gauze for sealing up wounds."
	icon_state = "brutepack"
	heal_brute = 7
	origin_tech = "biotech=1"

/obj/item/stack/medical/bruise_pack/tajaran
	name = "\improper S'rendarr's Hand leaf"
	singular_name = "S'rendarr's Hand leaf"
	desc = "A soft leaf that is rubbed on bruises."
	icon = 'harvest.dmi'
	icon_state = "cabbage"
	heal_brute = 7

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	heal_burn = 7
	origin_tech = "biotech=1"

/obj/item/stack/medical/ointment/tajaran
	name = "\improper Messa's Tear leaf"
	singular_name = "Messa's Tear leaf"
	desc = "A cold leaf that is rubbed on burns."
	icon = 'harvest.dmi'
	icon_state = "ambrosiavulgaris"
	heal_burn = 7

/obj/item/stack/medical/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = 12
	origin_tech = "biotech=1"

/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	heal_burn = 12
	origin_tech = "biotech=1"

/obj/item/stack/medical/splint
	name = "medical splint"
	singular_name = "medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5

/obj/item/stack/medical/splint/single
	amount = 1

/obj/item/weapon/c_tube
	name = "cardboard tube"
	desc = "A tube made of cardboard."
	icon = 'items.dmi'
	icon_state = "c_tube"
	throwforce = 1
	w_class = 1.0
	throw_speed = 4
	throw_range = 5

/obj/item/weapon/camera
	name = "camera"
	desc = "Use this to take pictures."
	icon_state = "camera"
	var/last_pic = 1.0
	item_state = "wrench"
	w_class = 2.0
	origin_tech = "magnets=1"

/obj/item/weapon/card
	name = "card"
	desc = "Does card things."
	icon = 'card.dmi'
	w_class = 1.0

	var/list/files = list(  )

/obj/item/weapon/card/data
	name = "data disk"
	desc = "A disk of data."
	icon_state = "data"
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"

/obj/item/weapon/card/data/clown
	name = "coordinates to clown planet"
	icon_state = "data"
	item_state = "card-id"
	layer = 3
	level = 2
	desc = "This card contains coordinates to the fabled Clown Planet. Handle with care."
	function = "teleporter"
	data = "Clown Land"

/obj/item/weapon/card/emag
	desc = "An identification card. Seems to have some funny chip on it, though."
	name = "modified identification card"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"
	var/uses = 5

/obj/item/weapon/card/id
	name = "identification card"
	desc = "An identification card."
	icon_state = "id"
	item_state = "card-id"
	var/access = list()
	var/registered_name = null // The name registered_name on the card
	slot_flags = SLOT_ID
	var/pin = 0
	var/money = 0
	var/assignment = null
	var/over_jumpsuit = 1 // If set to 0, it won't display on top of the mob's jumpsuit
	var/dorm = 0		// determines if this ID has claimed a dorm already
	var/obj/item/weapon/credit_card/card
	var/blood_type = "\[UNSET\]"
	var/dna_hash = "\[UNSET\]"
	var/fingerprint_hash = "\[UNSET\]"

/obj/item/weapon/card/id/silver
	name = "identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	item_state = "silver_id"

/obj/item/weapon/card/id/gold
	name = "identification card"
	desc = "A golden card which shows authority."
	icon_state = "gold"
	item_state = "gold_id"

/obj/item/weapon/card/id/syndicate
	name = "agent card"
//	desc = "Shhhhh."
	access = list(ACCESS_MAINT_TUNNELS)
	origin_tech = "syndicate=3"

/obj/item/weapon/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	assignment = "Syndicate Overlord"
	access = list(ACCESS_SYNDICATE)

/obj/item/weapon/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the Captain himself."
	icon_state = "gold"
	item_state = "gold_id"
	registered_name = "Captain"
	assignment = "Captain"
	New()
		access = get_access("Captain")
		..()

/obj/item/weapon/card/id/centcom
	name = "\improper CentCom. ID"
	desc = "An ID straight from Cent. Com."
	icon_state = "centcom"
	registered_name = "Central Command"
	assignment = "General"
	New()
		access = get_all_centcom_access()
		..()


/obj/item/weapon/clipboard
	name = "clipboard"
	desc = "Apply paper to this to write better. Can also hold pens."
	icon = 'items.dmi'
	icon_state = "clipboard00"
	var/obj/item/weapon/pen/pen = null
	item_state = "clipboard"
	throwforce = 0
	w_class = 2.0
	throw_speed = 3
	throw_range = 10
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT

/obj/item/weapon/clipboard/notebook
	name = "notebook"
	desc = "Holds paper and pens. Feels very noire."
	icon_state = "notebook00"

#define MAXCOIL 30
/obj/item/weapon/cable_coil
	name = "cable coil"
	icon = 'power.dmi'
	icon_state = "coil_red"
	var/amount = MAXCOIL
	color = "red"
	desc = "A coil of power cable."
	throwforce = 10
	w_class = 2.0
	throw_speed = 2
	throw_range = 5
	m_amt = 50
	g_amt = 20
	flags = TABLEPASS | USEDELAY | FPRINT | CONDUCT
	slot_flags = SLOT_BELT
	item_state = "coil_red"

/obj/item/weapon/cable_coil/cut
	item_state = "coil_red2"

/obj/item/weapon/cable_coil/yellow
	color = "yellow"
	icon_state = "coil_yellow"

/obj/item/weapon/cable_coil/blue
	color = "blue"
	icon_state = "coil_blue"

/obj/item/weapon/cable_coil/green
	color = "green"
	icon_state = "coil_green"

/obj/item/weapon/cable_coil/pink
	color = "pink"
	icon_state = "coil_pink"

/obj/item/weapon/cable_coil/orange
	color = "orange"
	icon_state = "coil_orange"

/obj/item/weapon/cable_coil/cyan
	color = "cyan"
	icon_state = "coil_cyan"

/obj/item/weapon/cable_coil/white
	color = "white"
	icon_state = "coil_white"

/obj/item/weapon/cable_coil/random/New()
	color = pick("red","yellow","green","blue","pink")
	icon_state = "coil_[color]"
	..()


/obj/item/weapon/crowbar
	name = "crowbar"
	desc = "Used to remove floor tiles."
	icon = 'items.dmi'
	icon_state = "crowbar"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	force = 5.0
	throwforce = 7.0
	item_state = "crowbar"
	w_class = 2.0
	m_amt = 50
	origin_tech = "engineering=1"

/obj/item/weapon/crowbar/red
	icon = 'items.dmi'
	icon_state = "red_crowbar"
	item_state = "crowbar_red"

/obj/item/weapon/cane
	name = "cane"
	desc = "A cane used by a true gentlemen."
	icon = 'weapons.dmi'
	icon_state = "cane"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 6.0
	throwforce = 7.0
	item_state = "browncane"
	w_class = 2.0
	m_amt = 50

/obj/item/weapon/cane/browncane
	name = " browncane"
	icon_state = "browncane"

/obj/item/weapon/disk
	name = "disk"
	icon = 'items.dmi'

/obj/item/weapon/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe, it can activate the nuke."
	icon_state = "nucleardisk"
	item_state = "card-id"
	w_class = 1.0

/obj/item/weapon/dummy
	name = "dummy"
	invisibility = 101.0
	anchored = 1.0
	flags = TABLEPASS

/obj/item/weapon/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'items.dmi'
	icon_state = "fire_extinguisher0"
	var/last_use = 1.0
	var/safety = 1
	hitsound = 'smash.ogg'
	flags = FPRINT | USEDELAY | TABLEPASS | CONDUCT
	throwforce = 10
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 15.0
	item_state = "fire_extinguisher"
	m_amt = 90

/obj/item/weapon/extinguisher/mini
	name = "fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	hitsound = null	//it is much lighter, after all.
	flags = FPRINT | USEDELAY | TABLEPASS
	throwforce = 5
	w_class = 2.0
	force = 6.0
	item_state = "miniFE"
	m_amt = 0

/obj/item/weapon/f_card
	name = "finger print card"
	desc = "Used to take fingerprints."
	icon = 'card.dmi'
	icon_state = "fingerprint0"
	var/amount = 10.0
	item_state = "paper"
	throwforce = 1
	w_class = 1.0
	throw_speed = 3
	throw_range = 5


/obj/item/weapon/fcardholder
	name = "fingerprint card case"
	desc = "Holds fingerprint cards."
	icon = 'items.dmi'
	icon_state = "fcardholder0"
	item_state = "clipboard"

/obj/item/weapon/flasks
	name = "flask"
	icon = 'Cryogenic2.dmi'
	var/oxygen = 0.0
	var/plasma = 0.0
	var/coolant = 0.0

/obj/item/weapon/flasks/coolant
	name = "light blue flask"
	icon_state = "coolant-c"
	coolant = 1000.0

/obj/item/weapon/flasks/oxygen
	name = "blue flask"
	icon_state = "oxygen-c"
	oxygen = 500.0

/obj/item/weapon/flasks/plasma
	name = "orange flask"
	icon_state = "plasma-c"
	plasma = 500.0

/obj/item/weapon/game_kit
	name = "Gaming Kit"
	icon = 'items.dmi'
	icon_state = "game_kit"
	var/selected = null
	var/board_stat = null
	var/data = ""
	var/base_url = "http://svn.slurm.us/public/spacestation13/misc/game_kit"
	item_state = "sheet-metal"
	w_class = 5.0

/obj/item/weapon/gift
	name = "gift"
	desc = "A wrapped item."
	icon = 'items.dmi'
	icon_state = "gift3"
	var/size = 3.0
	var/obj/item/gift = null
	item_state = "gift"
	w_class = 4.0

/obj/item/weapon/hand_tele
	name = "hand tele"
	desc = "A portable item using blue-space technology."
	icon = 'device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	throwforce = 5
	w_class = 2.0
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	origin_tech = "magnets=1;bluespace=3"

/obj/item/weapon/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'items.dmi'
	icon_state = "handcuff"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 5
	w_class = 2.0
	throw_speed = 2
	throw_range = 5
	m_amt = 500
	origin_tech = "materials=1"
	var/dispenser = 0
	var/breakouttime = 1200 //Deciseconds = 120s = 2 minutes

/obj/item/weapon/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff_red"
	breakouttime = 300 //Deciseconds = 30s

/obj/item/weapon/handcuffs/cable/red
	icon_state = "cuff_red"

/obj/item/weapon/handcuffs/cable/yellow
	icon_state = "cuff_yellow"

/obj/item/weapon/handcuffs/cable/blue
	icon_state = "cuff_blue"

/obj/item/weapon/handcuffs/cable/green
	icon_state = "cuff_green"

/obj/item/weapon/handcuffs/cable/pink
	icon_state = "cuff_pink"

/obj/item/weapon/handcuffs/cable/orange
	icon_state = "cuff_orange"

/obj/item/weapon/handcuffs/cable/cyan
	icon_state = "cuff_cyan"

/obj/item/weapon/handcuffs/cable/white
	icon_state = "cuff_white"

/obj/item/weapon/handcuffs/cyborg
	dispenser = 1


/obj/item/weapon/locator
	name = "locator"
	desc = "Used to track those with locater implants."
	icon = 'device.dmi'
	icon_state = "locator"
	var/temp = null
	var/frequency = 1451
	var/broadcasting = null
	var/listening = 1.0
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 400
	origin_tech = "magnets=1"

/obj/item/weapon/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'janitor.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS

/obj/item/weapon/caution/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon_state = "cone"

/obj/item/weapon/paper
	name = "\improper Paper"
	icon = 'paper.dmi'
	icon_state = "paper"
	var/info = null
	var/infoold = null
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	layer = 4
	var/list/stamped
	see_face = 1
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	heat_transfer_coefficient = 0.99
	gas_transfer_coefficient = 1
	permeability_coefficient = 0.99
	siemens_coefficient = 0.80
	var/iteration

/obj/item/weapon/directions
	name = "crumpled paper"
	gender = PLURAL
	desc = "This is a crumpled piece of paper."
	icon = 'weapons.dmi'
	icon_state = "crumpled"
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	//layer = 4

/obj/item/weapon/paper/Court
	name = "paper - 'Judgement'"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

//Please resist giving this to people who have not survived game breaking bugs.
/*Current recipients:
Searif: Survived infinite cold bug, body temp was "-nan", still alive.
eternal248: Found broken and buggy Z-levels 7-12, ended up leading to my discovery of that code and subsequent diking out.
*/
/obj/item/weapon/paper/certificate
	name = "paper - 'Certificate'"
	info = "Due to this person's unique actions in the past, we hereby certify that they are \"Well Qualified\"<br><br>----<b>Central Command</b><BR><i>This paper has been stamped with the central command rubber stamp.</i><BR>"
	stamped = list(/obj/item/weapon/stamp/centcom)
	overlays = list("paper_stamped_cent")

/obj/item/weapon/paper/Toxin
	name = "paper - 'Chemical Information'"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Plasma:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter plasma after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep toxins.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tSleep Toxin T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effect are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/weapon/paper/courtroom
	name = "paper - 'A Crash Course in Legal SOP on SS13'"
	info = "<B>Roles:</B><BR>\nThe Detective is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written authority from the Detective.<BR>\nThe Captain/HoP/Warden is ct as the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/weapon/paper/hydroponics
	name = "paper - 'Greetings from Billy Bob'"
	info = "<B>Hey fellow botanist!</B><BR>\n<BR>\nI didn't trust the station folk so I left<BR>\na couple of weeks ago. But here's some<BR>\ninstructions on how to operate things here.<BR>\nYou can grow plants and each iteration they become<BR>\nstronger, more potent and have better yield, if you<BR>\nknow which ones to pick. Use your botanist's analyzer<BR>\nfor that. You can turn harvested plants into seeds<BR>\nat the seed extractor, and replant them for better stuff!<BR>\nSometimes if the weed level gets high in the tray<BR>\nmutations into different mushroom or weed species have<BR>\nbeen witnessed. On the rare occassion even weeds mutate!<BR>\n<BR>\nEither way, have fun!<BR>\n<BR>\nBest regards,<BR>\nBilly Bob Johnson.<BR>\n<BR>\nPS.<BR>\nHere's a few tips:<BR>\nIn nettles, potency = damage<BR>\nIn amanitas, potency = deadliness + side effect<BR>\nIn Liberty caps, potency = drug power + effect<BR>\nIn chilis, potency = heat<BR>\n<B>Nutrients keep mushrooms alive!</B><BR>\n<B>Water keeps weeds such as nettles alive!</B><BR>\n<B>All other plants need both.</B>"

/obj/item/weapon/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = 1.0

/obj/item/weapon/paper/jobs
	name = "paper - 'Job Information'"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>\nThe data will be in the following form.<BR>\nGenerally lower ranking positions come first in this list.<BR>\n<BR>\n<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>\n\tJob Description<BR>\nJob Duties (in no particular order)<BR>\nTips (where applicable)<BR>\n<BR>\n<B>Research Assistant</B> 1>1-0-0<BR>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<BR>\n1. Assist the researchers.<BR>\n2. Clean up the labs.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Staff Assistant</B> 2>0-0-0<BR>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>\n1. Patrol ship/Guard key areas<BR>\n2. Assist security officer<BR>\n3. Perform other security duties.<BR>\n<BR>\n<B>Technical Assistant</B> 1>0-0-1<BR>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<BR>\n1. Assist Station technician and Engineers.<BR>\n2. Perform general maintenance of station.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Medical Assistant</B> 1>1-0-0<BR>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<BR>\n1. Assist the medical personnel.<BR>\n2. Update medical files.<BR>\n3. Prepare materials for medical operations.<BR>\n<BR>\n<B>Research Technician</B> 2>3-0-0<BR>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<BR>\n1. Inform superiors of research.<BR>\n2. Perform research alongside of official researchers.<BR>\n<BR>\n<B>Detective</B> 3>2-0-0<BR>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<BR>\n1. Perform crime-scene investigations/draw conclusions.<BR>\n2. Store and catalogue evidence properly.<BR>\n3. Testify to superiors/inquieries on findings.<BR>\n<BR>\n<B>Station Technician</B> 2>0-2-3<BR>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<BR>\n1. Maintain SS13 systems.<BR>\n2. Repair equipment.<BR>\n<BR>\n<B>Atmospheric Technician</B> 3>0-0-4<BR>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<BR>\n1. Maintain atmosphere on SS13<BR>\n2. Research atmospheres on the space station. (safely please!)<BR>\n<BR>\n<B>Engineer</B> 2>1-3-0<BR>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<BR>\n1. Upkeep the engine.<BR>\n2. Prevent fires in the engine.<BR>\n3. Maintain a safe orbit.<BR>\n<BR>\n<B>Medical Researcher</B> 2>5-0-0<BR>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<BR>\n1. Make sure the station is kept safe.<BR>\n2. Research medical properties of materials studied of Space Station 13.<BR>\n<BR>\n<B>Scientist</B> 2>5-0-0<BR>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Plasma Technicians as plasma is the material they routinly handle.<BR>\n1. Research plasma<BR>\n2. Make sure all plasma is properly handled.<BR>\n<BR>\n<B>Medical Doctor (Officer)</B> 2>0-0-0<BR>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<BR>\n1. Heal wounded people.<BR>\n2. Perform examinations of all personnel.<BR>\n3. Moniter usage of medical equipment.<BR>\n<BR>\n<B>Security Officer</B> 3>0-0-0<BR>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<BR>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>\n1. Maintain order.<BR>\n2. Assist others.<BR>\n3. Repair structural problems.<BR>\n<BR>\n<B>Head of Security</B> 4>5-2-2<BR>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<BR>\n1. Oversee security.<BR>\n2. Assign patrol duties.<BR>\n3. Protect the station and staff.<BR>\n<BR>\n<B>Head of Personnel</B> 4>4-2-2<BR>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<BR>\n1. Assign duties.<BR>\n2. Moderate personnel.<BR>\n3. Moderate research. <BR>\n<BR>\n<B>Captain</B> 5>5-5-5 (unrestricted station wide access)<BR>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<BR>\n1. Assign all positions on SS13<BR>\n2. Inspect the station for any problems.<BR>\n3. Perform administrative duties.<BR>\n"

/obj/item/weapon/paper/photograph
	name = "photo"
	icon_state = "photo"
	var/photo_id = 0.0
	item_state = "paper"

/obj/item/weapon/paper/sop
	name = "paper - 'Standard Operating Procedure'"
	info = "Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alrms in front of ship.<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-<BR>\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/weapon/paper/armoury
	name = "paper - 'Armoury Inventory'"
	info = "<div align='center'><img src='http://i265.photobucket.com/albums/ii207/Mr_Bombastic_Bucket/WikiLogo.png'><br><b><h1>Armoury Inventory</h1></b></div><hr><br><div align='center'><table border='3'><tr><td>Item</td><td>Stock</td><td>In Use</td><td>Notes</td></tr><tr><td>Ablative Armour Vest</td><td>1</td><td>0</td><td>-</td></tr><tr><td>Beanbag Shells</td><td>12</td><td>0</td><td>-</td></tr><tr><td>Body Bags</td><td>1</td><td>0</td><td>-</td></tr><tr><td>Bulletproof Vest</td><td>1</td><td>0</td><td>-</td></tr><tr><td>Chemical Implant Kit</td><td>1</td><td>0</td><td>-</td></tr><tr><td>Combat Shotguns</td><td>2</td><td>0</td><td>-</td></tr><tr><td>Deployable Barrier</td><td>9</td><td>0</td><td>-</td></tr><tr><td>Deployable Flashers</td><td>4</td><td>0</td><td>-</td></tr><tr><td>Energy Gun</td><td>6</td><td>0</td><td>-</td></tr><tr><td>Flashbangs</td><td>7</td><td>0</td><td>-</td></tr><tr><td>Gas Mask</td><td>3</td><td>0</td><td>-</td></tr><tr><td>Handcuffs</td><td>7</td><td>0</td><td>-</td></tr><tr><td>Ion Rifle</td><td>1</td><td>0</td><td>-</td></tr><tr><td>L3 Biohazard Suit</td><td>1</td><td>0</td><td>-</td></tr><tr><td>L4 EOD Suit</td><td>1</td><td>0</td><td>-</td></tr><tr><td>Laser Gun</td><td>1</td><td>0</td><td>-</td></tr><tr><td>Lockbox</td><td>1</td><td>0</td><td>-</td></tr><tr><td>Loyalty Implants Lockbox</td><td>1</td><td>0</td><td>-</td></tr><tr><td>Pepper Sprayers</td><td>2</td><td>0</td><td>-</td></tr><tr><td>RIG Helmet</td><td>1</td><td>0</td><td>-</td></tr><tr><td>RIG Suit</td><td>1</td><td>0</td><td>-</td></tr><tr><td>Riot Helmet</td><td>3</td><td>0</td><td>-</td></tr><tr><td>Riot Shield</td><td>3</td><td>0</td><td>-</td></tr><tr><td>Riot Suit</td><td>3</td><td>0</td><td>-</td></tr><tr><td>Stun Baton</td><td>5</td><td>0</td><td>-</td></tr><tr><td>Taser</td><td>3</td><td>0</td><td>-</td></tr><tr><td>Tracking Implant Kit</td><td>1</td><td>0</td><td>-</td></tr></table></div><br/><hr/><br/><div align='center'><table border='3'><tr><td>Officer Name</td><td>Items Withdrawn</td><td>Notes</td></tr><tr><td><INSERT OFFICER NAME HERE></td><td><INSERT ITEMS WITHDRAWN HERE></td><td>-</td></tr><tr><td><INSERT OFFICER NAME HERE></td><td><INSERT ITEMS WITHDRAWN HERE></td><td>-</td></tr><tr><td><INSERT OFFICER NAME HERE></td><td><INSERT ITEMS WITHDRAWN HERE></td><td>-</td></tr></table><br/><hr/><br/><p><i>List maintained by NSS Exodus, Warden, <INSERT WARDEN NAME HERE></i></p></div>"

/obj/item/weapon/paper_bin
	name = "Paper Bin"
	desc = "This contains many papers."
	icon = 'paper.dmi'
	icon_state = "paper_bin1"
	var/amount = 30.0
	item_state = "sheet-metal"
	throwforce = 1
	w_class = 3.0
	throw_speed = 3
	throw_range = 7

/obj/item/weapon/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'paper.dmi'
	icon_state = "pen"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	m_amt = 10
	var/text_size = 2
	var/text_color = "#000000"
	var/text_bold = 0
	var/text_italic = 0
	var/text_underline = 0
	var/text_break = 0

/obj/item/weapon/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	text_color = "#00000F"

/obj/item/weapon/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	text_color = "#FF0000"

/obj/item/weapon/pen/feather
	name = "feathery pen"
	desc = "A gold pen disguised as a quill. How quaint."
	icon_state = "featherpen"

/obj/item/weapon/banhammer
	desc = "A banhammer"
	name = "banhammer"
	icon = 'items.dmi'
	icon_state = "toyhammer"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15

/obj/item/weapon/pen/sleepypen
	desc = "It's a normal black ink pen with a sharp point."
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;biotech=1;syndicate=7"

/obj/item/weapon/pen/paralysis
	desc = "It's a normal black ink pen with a sharp point."
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;biotech=1;syndicate=5"

/obj/item/weapon/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'items.dmi'
	icon_state = "rack_parts"
	flags = FPRINT | TABLEPASS| CONDUCT
	m_amt = 3750

/obj/item/weapon/rubber_chicken
	name = "rubber chicken"
	desc = "A rubber chicken, isn't that hilarious?"
	icon = 'items.dmi'
	icon_state = "rubber_chicken"
	item_state = "rubber_chicken"
	w_class = 2.0

/obj/item/weapon/screwdriver
	name = "screwdriver"
	desc = "Used for screwing."
	icon = 'items.dmi'
	icon_state = "screwdriver"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	force = 5.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	g_amt = 0
	m_amt = 75

/obj/item/weapon/shard
	name = "shard"
	icon = 'shards.dmi'
	icon_state = "large"
	desc = "Could probably be used as ... a throwing weapon?"
	w_class = 1.0
	force = 7.0
	throwforce = 15.0
	item_state = "shard-glass"
	g_amt = 3750

/obj/item/weapon/SWF_uplink
	name = "station-bounced radio"
	desc = "used to comunicate it appears."
	icon = 'radio.dmi'
	icon_state = "radio"
	var/temp = null
	var/uses = 4.0
	var/selfdestruct = 0.0
	var/traitor_frequency = 0.0
	var/obj/item/device/radio/origradio = null
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	item_state = "radio"
	throwforce = 5
	w_class = 2.0
	throw_speed = 4
	throw_range = 20
	m_amt = 100
	origin_tech = "magnets=1"

/obj/item/weapon/spellbook
	name = "spell book"
	desc = "The legendary book of spells of a wizard."
	icon = 'library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	var/uses = 5.0
	var/temp = null
	var/spell_type = "verb"
	var/max_uses = 5
	var/op = 1

/obj/item/weapon/spellbook/object_type_spells //used for giving out object spells as opposed to verb spells
	spell_type = "object"

/obj/item/weapon/staff
	name = "wizards staff"
	desc = "Apparently a staff used by a wizard."
	icon = 'wizard.dmi'
	icon_state = "staff"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD


/obj/item/weapon/staff/stick
	name = "stick"
	desc = "A great tool to drag someone else's drinks across the bar."
	icon = 'weapons.dmi'
	icon_state = "stick"
	item_state = "stick"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD

/obj/item/weapon/table_parts
	name = "table parts"
	desc = "Parts of a table. Poor table."
	gender = PLURAL
	icon = 'items.dmi'
	icon_state = "table_parts"
	m_amt = 3750
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/weapon/table_parts/reinforced
	name = "reinforced table parts"
	desc = "Hard table parts. Well...harder..."
	icon = 'items.dmi'
	icon_state = "reinf_tableparts"
	m_amt = 7500
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/weapon/table_parts/wood
	name = "wooden table parts"
	desc = "Keep away from fire."
	icon_state = "wood_tableparts"
	flags = null

/obj/item/weapon/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll for moving around."
	icon = 'wizard.dmi'
	icon_state = "scroll"
	var/uses = 4.0
	flags = FPRINT | TABLEPASS
	w_class = 2.0
	item_state = "paper"
	throw_speed = 4
	throw_range = 20
	origin_tech = "bluespace=4"

/obj/item/weapon/wire
	desc = "This is just a simple piece of regular insulated wire."
	name = "wire"
	icon = 'power.dmi'
	icon_state = "item_wire"
	var/amount = 1.0
	var/laying = 0.0
	var/old_lay = null
	m_amt = 40

/obj/item/weapon/wrapping_paper
	name = "wrapping paper"
	desc = "You can use this to wrap items in."
	icon = 'items.dmi'
	icon_state = "wrap_paper"
	var/amount = 20.0

/obj/item/weapon/cell
	name = "power cell"
	desc = "A rechargable electrochemical power cell."
	icon = 'power.dmi'
	icon_state = "cell"
	item_state = "cell"
	origin_tech = "powerstorage=1"
	flags = FPRINT|TABLEPASS
	force = 10.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	w_class = 3.0
	pressure_resistance = 80
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 1000
	m_amt = 700
	g_amt = 50
	var/rigged = 0		// true if rigged to explode
	var/minor_fault = 0 //If not 100% reliable, it will build up faults.
	var/construction_cost = list("metal"=750,"glass"=75)
	var/construction_time=100

/obj/item/weapon/cell/crap
	name = "\improper NanoTrasen Brand Rechargable AA Battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	origin_tech = "powerstorage=0"
	maxcharge = 500
	g_amt = 40

/obj/item/weapon/cell/crap/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/secborg
	name = "\improper Security borg rechargable D battery"
	origin_tech = "powerstorage=0"
	maxcharge = 600	//600 max charge / 100 charge per shot = six shots
	g_amt = 40

/obj/item/weapon/cell/secborg/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/high
	name = "high-capacity power cell"
	origin_tech = "powerstorage=2"
	icon_state = "hcell"
	maxcharge = 10000
	g_amt = 60

/obj/item/weapon/cell/high/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/super
	name = "super-capacity power cell"
	origin_tech = "powerstorage=5"
	icon_state = "scell"
	maxcharge = 20000
	g_amt = 70
	construction_cost = list("metal"=750,"glass"=100)

/obj/item/weapon/cell/super/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/hyper
	name = "hyper-capacity power cell"
	origin_tech = "powerstorage=6"
	icon_state = "hpcell"
	maxcharge = 30000
	g_amt = 80
	construction_cost = list("metal"=500,"glass"=150,"gold"=200,"silver"=200)

/obj/item/weapon/cell/hyper/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	origin_tech =  null
	maxcharge = 30000
	g_amt = 80
	use()
		return 1

/obj/item/weapon/cell/potato
	name = "potato battery"
	desc = "A rechargable starch based power cell."
	origin_tech = "powerstorage=1"
	icon = 'power.dmi' //'harvest.dmi'
	icon_state = "cell" //"potato_battery"
	charge = 100
	maxcharge = 300
	m_amt = 0
	g_amt = 0
	minor_fault = 1

/obj/item/weapon/camera_bug/attack_self(mob/usr as mob)
	var/list/cameras = new/list()
	for (var/obj/machinery/camera/C in world)
		if (C.bugged && C.status)
			cameras.Add(C)
	if (length(cameras) == 0)
		usr << "\red No bugged functioning cameras found."
		return

	var/list/friendly_cameras = new/list()

	for (var/obj/machinery/camera/C in cameras)
		friendly_cameras.Add(C.c_tag)

	var/target = input("Select the camera to observe.", null) as null|anything in friendly_cameras
	if (!target)
		return
	for (var/obj/machinery/camera/C in cameras)
		if (C.c_tag == target)
			target = C
			break
	if (usr.stat == 2) return

	usr.client.eye = target


/obj/item/weapon/module
	icon = 'module.dmi'
	icon_state = "std_module"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS|CONDUCT
	var/mtype = 1						// 1=electronic 2=hardware

/obj/item/weapon/module/card_reader
	name = "card reader module"
	icon_state = "card_mod"
	desc = "An electronic module for reading data and ID cards."

/obj/item/weapon/module/power_control
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."
	m_amt = 50
	g_amt = 50

/obj/item/weapon/module/id_auth
	name = "\improper ID authentication module"
	icon_state = "id_mod"
	desc = "A module allowing secure authorization of ID cards."

/obj/item/weapon/module/cell_power
	name = "power cell regulator module"
	icon_state = "power_mod"
	desc = "A converter and regulator allowing the use of power cells."

/obj/item/weapon/module/cell_power
	name = "power cell charger module"
	icon_state = "power_mod"
	desc = "Charging circuits for power cells."


/obj/item/weapon/a_gift
	name = "gift"
	desc = "A gift, it appears."
	icon = 'items.dmi'
	icon_state = "gift"
	item_state = "gift"
	pressure_resistance = 70


/obj/item/weapon/camera_bug
	name = "camera bug"
	icon = 'device.dmi'
	icon_state = "flash"
	w_class = 1.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20


/obj/item/weapon/kitchen
	icon = 'kitchen.dmi'

/obj/item/weapon/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to flatten dough."
	icon_state = "rolling_pin"
	force = 8.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 7
	w_class = 3.0

/obj/item/weapon/kitchenknife
	name = "kitchen knife"
	icon = 'kitchen.dmi'
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 10.0
	w_class = 3.0
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	origin_tech = "materials=1"

/obj/item/weapon/butch
	name = "butcher's cleaver"
	icon = 'kitchen.dmi'
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat."
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 15.0
	w_class = 2.0
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	origin_tech = "materials=1"

/obj/item/weapon/tray
	name = "tray"
	icon = 'food.dmi'
	icon_state = "tray"
	desc = "A metal tray to lay food on."
	throwforce = 12.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | TABLEPASS | CONDUCT
	m_amt = 3000
	/* // NOPE
	var/food_total= 0
	var/burger_amt = 0
	var/cheese_amt = 0
	var/fries_amt = 0
	var/classyalcdrink_amt = 0
	var/alcdrink_amt = 0
	var/bottle_amt = 0
	var/soda_amt = 0
	var/carton_amt = 0
	var/pie_amt = 0
	var/meatbreadslice_amt = 0
	var/salad_amt = 0
	var/miscfood_amt = 0
	*/
	var/list/carrying = list() // List of things on the tray. - Doohl
	var/max_carry = 10 // w_class = 1 -- takes up 1
					   // w_class = 2 -- takes up 3
					   // w_class = 3 -- takes up 5


/obj/item/weapon/kitchen/utensil
	force = 5.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	flags = FPRINT | TABLEPASS | CONDUCT
	origin_tech = "materials=1"


/obj/item/weapon/kitchen/utensil/fork
	name = "fork"
	desc = "Pointy."
	icon_state = "fork"
	var/obj/item/weapon/reagent_containers/food/snacks/bite

/obj/item/weapon/kitchen/utensil/knife
	name = "knife"
	desc = "Can cut through any food."
	icon_state = "knife"
	force = 10.0
	throwforce = 10.0

/obj/item/weapon/kitchen/utensil/spoon
	name = "spoon"
	desc = "SPOON!"
	icon_state = "spoon"

/obj/item/weapon/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'surgery.dmi'
	icon_state = "scalpel"
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 10.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'surgery.dmi'
	icon_state = "retractor"
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'surgery.dmi'
	icon_state = "hemostat"
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'surgery.dmi'
	icon_state = "cautery"
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'surgery.dmi'
	icon_state = "drill"
	hitsound = 'circsawhit.ogg'
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 15.0
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'surgery.dmi'
	icon_state = "saw3"
	hitsound = 'circsawhit.ogg'
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 15.0
	w_class = 1.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	m_amt = 20000
	g_amt = 10000
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/autopsy_scanner
	name = "autopsy scanner"
	desc = "Extracts information on wounds."
	icon = 'autopsy_scanner.dmi'
	icon_state = ""
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/syntiflesh
	name = "syntiflesh"
	desc = "Meat that appears...strange..."
	icon = 'food.dmi'
	icon_state = "meat"
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "biotech=2"

/obj/item/weapon/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon = 'weapons.dmi'
	icon_state = "hatchet"
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 12.0
	w_class = 1.0
	throwforce = 15.0
	throw_speed = 4
	throw_range = 4
	m_amt = 15000
	origin_tech = "materials=2;combat=1"

/obj/item/weapon/stamp
	desc = "A rubber stamp for stamping important documents."
	name = "rubber stamp"
	icon = 'paper.dmi'
	icon_state = "stamp-qm"
	item_state = "stamp"
	flags = FPRINT | TABLEPASS
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	m_amt = 60
	color = "cargo"

/obj/item/weapon/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	color = "captain"

/obj/item/weapon/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	color = "hop"

/obj/item/weapon/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	color = "hosred"

/obj/item/weapon/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	color = "chief"

/obj/item/weapon/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	color = "director"

/obj/item/weapon/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	color = "medical"

/obj/item/weapon/stamp/denied
	name = "DENIED rubber stamp"
	icon_state = "stamp-qm"
	color = "redcoat"

/obj/item/weapon/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	color = "clown"

/obj/item/weapon/stamp/centcom
	name = "central command rubber stamp"
	icon_state = "stamp-cent"
	color = "centcom"

/*
/obj/item/weapon/cigarpacket
	name = "Pete's Cuban Cigars"
	desc = "The most robust cigars on the planet."
	icon = 'cigarettes.dmi'
	icon_state = "cigarpacket"
	item_state = "cigarpacket"
	w_class = 1
	throwforce = 2
	var/cigarcount = 6
	flags = TABLEPASS
	slot_flags = SLOT_BELT*/


/obj/item/weapon/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon = 'weapons.dmi'
	icon_state = "mousetrap"
	item_state = "mousetrap"
	w_class = 1
	force = null
	throwforce = null
	var/armed = 0
	origin_tech = "combat=1"

/obj/item/weapon/mousetrap/armed
	icon_state = "mousetraparmed"
	armed = 1

/obj/item/weapon/dice/d4 // -- SkyMarshal
	name = "d4"
	desc = "A dice with four sides."
	sides = 4
	icon_state = "d20"
	item_state = "dice"

/obj/item/weapon/dice // -- TLE
	name = "d6"
	desc = "A dice with six sides."
	var/sides = 6
	icon = 'dice.dmi'
	icon_state = "d66"

/obj/item/weapon/dice/New()
	icon_state = "[name][rand(sides)]"

/obj/item/weapon/dice/d20 // -- TLE
	name = "d20"
	desc = "A dice with twenty sides."
	sides = 20
	icon_state = "d2020"

/obj/item/weapon/dice/d8 // -- SkyMarshal
	name = "d8"
	desc = "A dice with eight sides."
	sides = 8
	icon_state = "d20"
	item_state = "dice"

/obj/item/weapon/dice/d12 // -- SkyMarshal
	name = "d12"
	desc = "A dice with twelve sides."
	sides = 12
	icon_state = "d20"
	item_state = "dice"

/obj/item/weapon/pai_cable
	desc = "A flexible coated cable with a universal jack on one end."
	name = "data cable"
	icon = 'power.dmi'
	icon_state = "wire1"
	var/obj/machinery/machine

/obj/item/weapon/plastique
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole. Does not work on people."
	gender = PLURAL
	icon = 'assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	flags = FPRINT | TABLEPASS | USEDELAY
	w_class = 2.0
	origin_tech = "syndicate=2"
	var/timer = 10
	var/atom/target = null

///////////////////////////////////////Stock Parts /////////////////////////////////

/obj/item/weapon/stock_parts
	name = "stock part"
	desc = "What?"
	gender = PLURAL
	icon = 'stock_parts.dmi'
	w_class = 2.0
	var/rating = 1
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

//Rank 1

/obj/item/weapon/stock_parts/console_screen
	name = "console screen"
	desc = "Used in the construction of computers and other devices with a interactive console."
	icon_state = "screen"
	origin_tech = "materials=1"
	g_amt = 200

/obj/item/weapon/stock_parts/capacitor
	name = "capacitor"
	desc = "A basic capacitor used in the construction of a variety of devices."
	icon_state = "capacitor"
	origin_tech = "powerstorage=1"
	m_amt = 50
	g_amt = 50

/obj/item/weapon/stock_parts/scanning_module
	name = "scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"
	origin_tech = "magnets=1"
	m_amt = 50
	g_amt = 20

/obj/item/weapon/stock_parts/manipulator
	name = "micro-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "micro_mani"
	origin_tech = "materials=1;programming=1"
	m_amt = 30

/obj/item/weapon/stock_parts/micro_laser
	name = "micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "micro_laser"
	origin_tech = "magnets=1"
	m_amt = 10
	g_amt = 20

/obj/item/weapon/stock_parts/matter_bin
	name = "matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "matter_bin"
	origin_tech = "materials=1"
	m_amt = 80

//Rank 2

/obj/item/weapon/stock_parts/capacitor/adv
	name = "advanced capacitor"
	desc = "An advanced capacitor used in the construction of a variety of devices."
	origin_tech = "powerstorage=3"
	rating = 2
	m_amt = 50
	g_amt = 50

/obj/item/weapon/stock_parts/scanning_module/adv
	name = "advanced scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"
	origin_tech = "magnets=3"
	rating = 2
	m_amt = 50
	g_amt = 20

/obj/item/weapon/stock_parts/manipulator/nano
	name = "nano-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "micro_mani"
	origin_tech = "materials=3,programming=2"
	rating = 2
	m_amt = 30

/obj/item/weapon/stock_parts/micro_laser/high
	name = "high-power micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "micro_laser"
	origin_tech = "magnets=3"
	rating = 2
	m_amt = 10
	g_amt = 20

/obj/item/weapon/stock_parts/matter_bin/adv
	name = "advanced matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "matter_bin"
	origin_tech = "materials=3"
	rating = 2
	m_amt = 80

//Rating 3

/obj/item/weapon/stock_parts/capacitor/super
	name = "super capacitor"
	desc = "A super-high capacity capacitor used in the construction of a variety of devices."
	origin_tech = "powerstorage=5;materials=4"
	rating = 3
	m_amt = 50
	g_amt = 50

/obj/item/weapon/stock_parts/scanning_module/phasic
	name = "phasic scanning module"
	desc = "A compact, high resolution phasic scanning module used in the construction of certain devices."
	origin_tech = "magnets=5"
	rating = 3
	m_amt = 50
	g_amt = 20

/obj/item/weapon/stock_parts/manipulator/pico
	name = "pico-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	origin_tech = "materials=5,programming=2"
	rating = 3
	m_amt = 30

/obj/item/weapon/stock_parts/micro_laser/ultra
	name = "ultra-high-power micro-laser"
	desc = "A tiny laser used in certain devices."
	origin_tech = "magnets=5"
	rating = 3
	m_amt = 10
	g_amt = 20

/obj/item/weapon/stock_parts/matter_bin/super
	name = "super matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	origin_tech = "materials=5"
	rating = 3
	m_amt = 80

// Subspace stock parts

/obj/item/weapon/stock_parts/subspace/ansible
	name = "subspace ansible"
	icon_state = "subspace_ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	origin_tech = "programming=3;magnets=5;materials=4;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/filter
	name = "hyperwave filter"
	icon_state = "hyperwave_filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."
	origin_tech = "programming=4;magnets=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/amplifier
	name = "subspace amplifier"
	icon_state = "subspace_amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	origin_tech = "programming=3;magnets=4;materials=4;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/treatment
	name = "subspace treatment disk"
	icon_state = "treatment_disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	origin_tech = "programming=3;magnets=2;materials=5;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/analyzer
	name = "subspace wavelength analyzer"
	icon_state = "wavelength_analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	origin_tech = "programming=3;magnets=4;materials=4;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/crystal
	name = "ansible crystal"
	icon_state = "ansible_crystal"
	desc = "A crystal made from pure glass used to transmit laser databursts to subspace."
	origin_tech = "magnets=4;materials=4;bluespace=2"
	g_amt = 50

/obj/item/weapon/stock_parts/subspace/transmitter
	name = "subspace transmitter"
	icon_state = "subspace_transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	origin_tech = "magnets=5;materials=5;bluespace=3"
	m_amt = 50

/obj/item/weapon/ectoplasm
	name = "ectoplasm"
	desc = "spooky"
	gender = PLURAL
	icon = 'wizard.dmi'
	icon_state = "ectoplasm"

/obj/item/weapon/research//Makes testing much less of a pain -Sieve
	name = "research"
	icon = 'stock_parts.dmi'
	icon_state = "capacitor"
	desc = "A debug item for research."
	origin_tech = "materials=8;programming=8;magnets=8;powerstorage=8;bluespace=8;combat=8;biotech=8;syndicate=8"

/obj/item/weapon/appendix
	name = "appendix"
	desc = "An appendix which looks perfectly healthy."
	icon = 'food.dmi'
	icon_state = "appendix"

/obj/item/weapon/appendixinflamed
	name = "inflamed appendix"
	desc = "An appendix which appears to be inflamed."
	icon = 'food.dmi'
	icon_state = "appendixinflamed"

/obj/item/weapon/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon = 'items.dmi'
	icon_state = "megaphone"
	var/cooldown = 0

/obj/item/weapon/flavor
	name = "bland flavoring packet"
	desc = "A sachet of flavoring, designed to be used with \"LiquidFood\" rations.  The flavor is indeterminable."
	icon = 'food_ingredients.dmi'
	var/descriptor = "disturbingly beige" //Description shown to onlookers.
	color = "beige" //Color the icon should take on when this is applied.  Also shown when it is mixed in.
	var/newDesc = "It posesses a strange and unidentifiable taste.  You try not to think to hard about it." //What gets pegged onto the description.

/obj/item/weapon/flavor/red
	name = "cherry flavoring packet"
	desc = "A sachet of cherry flavoring, designed to be used with \"LiquidFood\" rations."
	icon_state = "flavor-red"
	descriptor = "garrishly red"
	color = "red"
	newDesc = "It has a faintly cherry taste, but still is hard to stomach. Reminds you of cough syrup."

/obj/item/weapon/flavor/blue
	name = "berry flavoring packet"
	desc = "A sachet of berry flavoring, designed to be used with \"LiquidFood\" rations."
	icon_state = "flavor-blue"
	descriptor = "molted blue"
	color = "blue"
	newDesc = "It has a faint bitter berry taste, but still is hard to stomach. Strangely crunchy."
