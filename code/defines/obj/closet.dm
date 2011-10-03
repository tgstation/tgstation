/obj/station_objects/closet
	desc = "It's a closet!"
	name = "Closet"
	icon = 'closet.dmi'
	icon_state = "closed"
	density = 1
	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/opened = 0
	var/welded = 0
	var/wall_mounted = 0 //never solid (You can always pass over it)
	flags = FPRINT
	var/health = 200//Might be a bit much, dono can always change later

/obj/station_objects/closet/acloset
	desc = "It looks alien!"
	name = "Strange closet"
	icon_state = "acloset"
	icon_closed = "acloset"
	icon_opened = "aclosetopen"

/obj/station_objects/closet/cabinet
	desc = "Old will forever be in fashion."
	name = "Cabinet"
	icon_state = "cabinet_closed"
	icon_closed = "cabinet_closed"
	icon_opened = "cabinet_open"

/obj/effects/spresent
	desc = "It's a ... present?"
	name = "strange present"
	icon = 'items.dmi'
	icon_state = "strangepresent"
	density = 1
	anchored = 0

/obj/station_objects/closet/gmcloset
	desc = "A bulky (yet mobile) closet. Comes with formal clothes"
	name = "Formal closet"

/obj/station_objects/closet/emcloset
	desc = "A bulky (yet mobile) closet. Comes prestocked with a gasmask and o2 tank for emergencies."
	name = "Emergency Closet"
	icon_state = "emergency"
	icon_closed = "emergency"
	icon_opened = "emergencyopen"

/obj/station_objects/closet/firecloset
	desc = "A bulky (yet mobile) closet. Comes with supplies to fight fire."
	name = "Fire Closet"
	icon_state = "firecloset"
	icon_closed = "firecloset"
	icon_opened = "fireclosetopen"

/obj/station_objects/closet/hydrant //wall mounted fire closet
	anchored = 1
	desc = "A wall mounted closet which comes with supplies to fight fire."
	name = "Fire Closet"
	icon_state = "hydrant"
	icon_closed = "hydrant"
	icon_opened = "hydrant_open"
	wall_mounted = 1

/obj/station_objects/closet/medical_wall //wall mounted medical closet
	anchored = 1
	desc = "A wall mounted closet which should have some first aid."
	name = "First Aid Closet"
	icon_state = "medical_wall"
	icon_closed = "medical_wall"
	icon_opened = "medical_wall_open"
	wall_mounted = 1

/obj/station_objects/closet/fireaxecabinet
	name = "Fire Axe Cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	var/obj/item/weapon/fireaxe/FIREAXE = new/obj/item/weapon/fireaxe
	icon_state = "fireaxe1000"
	icon_closed = "fireaxe1000"
	icon_opened = "fireaxe1100"
	anchored = 1
	var/localopened = 0 //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = 1
	var/hitstaken = 0
	var/locked = 1
	var/smashed = 0

	attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
		//..() //That's very useful, Erro

		var/hasaxe = 0       //gonna come in handy later~
		if(FIREAXE)
			hasaxe = 1

		if (isrobot(usr) || src.locked)
			if(istype(O, /obj/item/device/multitool))
				user << "\red Resetting circuitry..."
				playsound(user, 'lockreset.ogg', 50, 1)
				sleep(50) // Sleeping time~
				src.locked = 0
				user << "\blue You disable the locking modules."
				update_icon()
				return
			if(istype(O, /obj/item/weapon))
				var/obj/item/weapon/W = O
				if(src.smashed)
					return
				else
					playsound(user, 'Glasshit.ogg', 100, 1) //We don't want this playing every time
				if(W.force < 15)
					user << "\blue The cabinet's protective glass glances off the hit."
				else
					src.hitstaken++
					if(src.hitstaken == 4)
						playsound(user, 'Glassbr3.ogg', 100, 1) //Break cabinet, receive goodies. Cabinet's fucked for life after that.
						src.smashed = 1
						src.locked = 0
						src.localopened = 1
				update_icon()
			return
		if (istype(O, /obj/item/weapon/fireaxe) && src.localopened)
			if(!FIREAXE)
				if(O.wielded)
					user << "\red Unwield the axe first."
					return
				FIREAXE = O
				user.drop_item(O)
				src.contents += O
				user << "\blue You place the fire axe back in the [src.name]."
				update_icon()
			else
				if(src.smashed)
					return
				else
					localopened = !localopened
					if(localopened)
						icon_state = text("fireaxe[][][][]opening",hasaxe,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()
					else
						icon_state = text("fireaxe[][][][]closing",hasaxe,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()
		else
			if(src.smashed)
				return
			if(istype(O, /obj/item/device/multitool))
				if(localopened)
					localopened = 0
					icon_state = text("fireaxe[][][][]closing",hasaxe,src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()
					return
				else
					user << "\red Resetting circuitry..."
					sleep(50)
					src.locked = 1
					user << "\blue You re-enable the locking modules."
					playsound(user, 'lockenable.ogg', 50, 1)
					return
			else
				localopened = !localopened
				if(localopened)
					icon_state = text("fireaxe[][][][]opening",hasaxe,src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()
				else
					icon_state = text("fireaxe[][][][]closing",hasaxe,src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()




	attack_hand(mob/user as mob)

		var/hasaxe = 0
		if(FIREAXE)
			hasaxe = 1

		if(src.locked)
			user <<"\red The cabinet won't budge!"
			return
		if(localopened)
			if(FIREAXE)
				user.put_in_hand(FIREAXE)
				FIREAXE = null
				user << "\blue You take the fire axe from the [name]."
				src.add_fingerprint(user)
				update_icon()
			else
				if(src.smashed)
					return
				else
					localopened = !localopened
					if(localopened)
						src.icon_state = text("fireaxe[][][][]opening",hasaxe,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()
					else
						src.icon_state = text("fireaxe[][][][]closing",hasaxe,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()

		else
			localopened = !localopened //I'm pretty sure we don't need an if(src.smashed) in here. In case I'm wrong and it fucks up teh cabinet, **MARKER**. -Agouri
			if(localopened)
				src.icon_state = text("fireaxe[][][][]opening",hasaxe,src.localopened,src.hitstaken,src.smashed)
				spawn(10) update_icon()
			else
				src.icon_state = text("fireaxe[][][][]closing",hasaxe,src.localopened,src.hitstaken,src.smashed)
				spawn(10) update_icon()

	verb/toggle_openness() //nice name, huh? HUH?! -Erro //YEAH -Agouri
		set name = "Open/Close"
		set category = "Object"

		if (isrobot(usr) || src.locked || src.smashed)
			if(src.locked)
				usr << "\red The cabinet won't budge!"
			else if(src.smashed)
				usr << "\blue The protective glass is broken!"
			return

		localopened = !localopened
		update_icon()

	verb/remove_fire_axe()
		set name = "Remove Fire Axe"
		set category = "Object"

		if (isrobot(usr))
			return

		if (localopened)
			if(FIREAXE)
				usr.put_in_hand(FIREAXE)
				FIREAXE = null
				usr << "\blue You take the Fire axe from the [name]."
			else
				usr << "\blue The [src.name] is empty."
		else
			usr << "\blue The [src.name] is closed."
		update_icon()

	attack_paw(mob/user as mob)
		attack_hand(user)
		return

	attack_ai(mob/user as mob)
		if(src.smashed)
			user << "\red The security of the cabinet is compromised."
			return
		else
			locked = !locked
			if(locked)
				user << "\red Cabinet locked."
			else
				user << "\blue Cabinet unlocked."
			return

	update_icon() //Template: fireaxe[has fireaxe][is opened][hits taken][is smashed]. If you want the opening or closing animations, add "opening" or "closing" right after the numbers
		var/hasaxe = 0
		if(FIREAXE)
			hasaxe = 1
		icon_state = text("fireaxe[][][][]",hasaxe,src.localopened,src.hitstaken,src.smashed)

	open()
		return

	close()
		return



/obj/station_objects/closet/toolcloset
	desc = "A bulky (yet mobile) closet. Contains tools."
	name = "Tool Closet"
	icon_state = "toolcloset"
	icon_closed = "toolcloset"
	icon_opened = "toolclosetopen"

/obj/station_objects/closet/jcloset
	desc = "A bulky (yet mobile) closet. Comes with janitor's clothes and biohazard gear."
	name = "Custodial Closet"

/obj/station_objects/closet/lawcloset
	desc = "A bulky (yet mobile) closet. Comes with lawyer apparel and items."
	name = "Legal Closet"

/obj/station_objects/closet/coffin
	desc = "A burial receptacle for the dearly departed."
	name = "coffin"
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"

/obj/station_objects/closet/bombcloset
	desc = "A bulky (yet mobile) closet. Comes prestocked with a level 4 bombsuit."
	name = "EOD closet"
	icon_state = "bombsuit"
	icon_closed = "bombsuit"
	icon_opened = "bombsuitopen"

/obj/station_objects/closet/bombclosetsecurity
	desc = "A bulky (yet mobile) closet. Comes prestocked with a level 4 bombsuit."
	name = "EOD closet"
	icon_state = "bombsuitsec"
	icon_closed = "bombsuitsec"
	icon_opened = "bombsuitsecopen"

/obj/station_objects/closet/l3closet
	desc = "A bulky (yet mobile) closet. Comes prestocked with level 3 biohazard gear for emergencies."
	name = "Level 3 Biohazard Suit"
	icon_state = "bio"
	icon_closed = "bio"
	icon_opened = "bioopen"

/obj/station_objects/closet/l3closet/general
	icon_state = "bio_general"
	icon_closed = "bio_general"
	icon_opened = "bio_generalopen"

/obj/station_objects/closet/l3closet/virology
	icon_state = "bio_virology"
	icon_closed = "bio_virology"
	icon_opened = "bio_virologyopen"

/obj/station_objects/closet/l3closet/security
	icon_state = "bio_security"
	icon_closed = "bio_security"
	icon_opened = "bio_securityopen"

/obj/station_objects/closet/l3closet/janitor
	icon_state = "bio_janitor"
	icon_closed = "bio_janitor"
	icon_opened = "bio_janitoropen"

/obj/station_objects/closet/l3closet/scientist
	icon_state = "bio_scientist"
	icon_closed = "bio_scientist"
	icon_opened = "bio_scientistopen"

/obj/station_objects/closet/syndicate
	desc = "Why is this here?"
	name = "Weapons Closet"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/station_objects/closet/syndicate/personal
	desc = "Gear preperations closet."

/obj/station_objects/closet/syndicate/nuclear
	desc = "Nuclear preperations closet."

	// Inserting the gimmick clothing stuff here for generic items, IE Tacticool stuff

/obj/station_objects/closet/extinguisher
	name = "Extinguisher closet"
	var/obj/item/weapon/extinguisher/EXTINGUISHER = new/obj/item/weapon/extinguisher
	icon_state = "extinguisher10"
	icon_opened = "extinguisher11"
	icon_closed = "extinguisher10"
	opened = 1
	var/localopened = 1
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	anchored = 1

	open()
		return

	close()
		return

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if (isrobot(usr))
			return
		if (istype(O, /obj/item/weapon/extinguisher))
			if(!EXTINGUISHER)
				user.drop_item(O)
				src.contents += O
				EXTINGUISHER = O
				user << "\blue You place the extinguisher in the [src.name]."
			else
				localopened = !localopened
		else
			localopened = !localopened
		update_icon()

	attack_hand(mob/user as mob)
		if(localopened)
			if(EXTINGUISHER)
				user.put_in_hand(EXTINGUISHER)
				EXTINGUISHER = null
				user << "\blue You take the extinguisher from the [name]."
			else
				localopened = !localopened

		else
			localopened = !localopened
		update_icon()

	verb/toggle_openness() //nice name, huh? HUH?!
		set name = "Open/Close"
		set category = "Object"

		if (isrobot(usr))
			return

		localopened = !localopened
		update_icon()

	verb/remove_extinguisher()
		set name = "Remove Extinguisher"
		set category = "Object"

		if (isrobot(usr))
			return

		if (localopened)
			if(EXTINGUISHER)
				usr.put_in_hand(EXTINGUISHER)
				EXTINGUISHER = null
				usr << "\blue You take the extinguisher from the [name]."
			else
				usr << "\blue The [name] is empty."
		else
			usr << "\blue The [name] is closed."
		update_icon()

	attack_paw(mob/user as mob)
		attack_hand(user)
		return

	attack_ai(mob/user as mob)
		return

	update_icon()
		var/hasextinguisher = 0
		if(EXTINGUISHER)
			hasextinguisher = 1
		icon_state = text("extinguisher[][]",hasextinguisher,src.localopened)


/obj/station_objects/closet/gimmick
	name = "Administrative Supply Closet"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Closet of things that have no right being here."
	anchored = 0

/obj/station_objects/closet/gimmick/russian
	name = "Russian Surplus"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Russian Surplus Closet"

/obj/station_objects/closet/gimmick/tacticool
	name = "Tacticool Gear"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Tacticool Gear Closet"

/obj/station_objects/closet/thunderdome
	desc = "Everything you need!"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"
	name = "Thunderdome closet."
	anchored = 1

/obj/station_objects/closet/thunderdome/tdred
	desc = "Everything you need!"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"
	name = "Thunderdome closet."

/obj/station_objects/closet/thunderdome/tdgreen
	desc = "Everything you need!"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	name = "Thunderdome closet."

/obj/station_objects/closet/malf/suits
	desc = "Gear preparations closet."
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/station_objects/closet/wardrobe
	desc = "A bulky (yet mobile) wardrobe closet. Comes prestocked with 6 changes of clothes."
	name = "Wardrobe"
	icon_state = "blue"
	icon_closed = "blue"

/obj/station_objects/closet/wardrobe/black
	name = "Black Wardrobe"
	desc = "Contains black jumpsuits."
	icon_state = "black"
	icon_closed = "black"

/obj/station_objects/closet/wardrobe/chaplain_black
	name = "Chaplain Wardrobe"
	desc = "Closet of basic chaplain clothes."
	icon_state = "black"
	icon_closed = "black"

/obj/station_objects/closet/wardrobe/green
	name = "Green Wardrobe"
	desc = "Contains green jumpsuits."
	icon_state = "green"
	icon_closed = "green"

/obj/station_objects/closet/wardrobe/mixed
	name = "Mixed Wardrobe"
	desc = "This appears to contain several different sets of clothing."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/station_objects/closet/wardrobe/orange
	name = "Prisoners Wardrobe"
	desc = "Contains orange jumpsuits."
	icon_state = "orange"
	icon_closed = "orange"

/obj/station_objects/closet/wardrobe/pink
	name = "Pink Wardrobe"
	desc = "Contains pink jumpsuits."
	icon_state = "pink"
	icon_closed = "pink"

/obj/station_objects/closet/wardrobe/red
	name = "Red Wardrobe"
	desc = "Contains red jumpsuits."
	icon_state = "red"
	icon_closed = "red"

/obj/station_objects/closet/wardrobe/white
	name = "White Wardrobe"
	desc = "Contains white jumpsuits."
	icon_state = "white"
	icon_closed = "white"

/obj/station_objects/closet/wardrobe/toxins_white
	name = "Toxins Wardrobe"
	desc = "Contains toxins jumpsuits."
	icon_state = "white"
	icon_closed = "white"

/obj/station_objects/closet/wardrobe/genetics_white
	name = "Genetics Wardrobe"
	desc = "Contains genetics jumpsuits."
	icon_state = "white"
	icon_closed = "white"

/obj/station_objects/closet/wardrobe/yellow
	name = "Yellow Wardrobe"
	desc = "Contains yellow jumpsuits."
	icon_state = "wardrobe-y"
	icon_closed = "wardrobe-y"

/obj/station_objects/closet/wardrobe/engineering_yellow
	name = "Engineering Wardrobe"
	desc = "Contains engineering jumpsuits."
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/station_objects/closet/wardrobe/atmospherics_yellow
	name = "Atmospherics Wardrobe"
	desc = "Contains atmospheric jumpsuits."
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/station_objects/closet/wardrobe/grey
	name = "Grey Wardrobe"
	desc = "Contains grey jumpsuits."
	icon_state = "grey"
	icon_closed = "grey"



/obj/station_objects/secure_closet
	desc = "An immobile card-locked storage closet."
	name = "Security Locker"
	icon = 'closet.dmi'
	icon_state = "secure1"
	density = 1
	var/opened = 0
	var/locked = 1
	var/broken = 0
	var/large = 1
	var/icon_closed = "secure"
	var/icon_locked = "secure1"
	var/icon_opened = "secureopen"
	var/icon_broken = "securebroken"
	var/icon_off = "secureoff"
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/health = 300

/obj/station_objects/secure_closet/medical_wall
	anchored = 1
	name = "First Aid Closet"
	desc = "A wall mounted closet which --should-- contain medical supplies."
	icon_state = "medical_wall_locked"
	icon_closed = "medical_wall_unlocked"
	icon_locked = "medical_wall_locked"
	icon_opened = "medical_wall_open"
	icon_broken = "medical_wall_spark"
	icon_off = "medical_wall_off"
	req_access = list(access_medical)
	wall_mounted = 1

/obj/station_objects/secure_closet/personal
	desc = "The first card swiped gains control."
	name = "Personal Closet"

/obj/station_objects/secure_closet/personal/patient
	name = "Patient's closet"

/obj/station_objects/secure_closet/kitchen
	name = "Kitchen Cabinet"
	req_access = list(access_kitchen)

/obj/station_objects/secure_closet/kitchen/mining
	req_access = list()

/obj/station_objects/secure_closet/meat
	name = "Meat Fridge"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"

/obj/station_objects/secure_closet/fridge
	name = "Refrigerator"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"

/obj/station_objects/secure_closet/money_freezer
	name = "Freezer"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"
	req_access = list(access_heads_vault)

/obj/station_objects/secure_closet/wall
	name = "wall locker"
	req_access = list(access_security)
	icon_state = "wall-locker1"
	density = 1
	icon_closed = "wall-locker"
	icon_locked = "wall-locker1"
	icon_opened = "wall-lockeropen"
	icon_broken = "wall-lockerbroken"
	icon_off = "wall-lockeroff"

	//too small to put a man in
	large = 0