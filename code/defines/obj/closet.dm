/obj/closet
	desc = "It's a closet!"
	name = "Closet"
	icon = 'closet.dmi'
	icon_state = "closed"
	density = 1
	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/opened = 0
	var/welded = 0
	flags = FPRINT

/obj/spresent
	desc = "It's a ... present?"
	name = "strange present"
	icon = 'items.dmi'
	icon_state = "strangepresent"
	density = 1
	anchored = 0

/obj/closet/gmcloset
	desc = "A bulky (yet mobile) closet. Comes with formal clothes"
	name = "Formal closet"

/obj/closet/emcloset
	desc = "A bulky (yet mobile) closet. Comes prestocked with a gasmask and o2 tank for emergencies."
	name = "Emergency Closet"
	icon_state = "emergency"
	icon_closed = "emergency"
	icon_opened = "emergencyopen"

/obj/closet/firecloset
	desc = "A bulky (yet mobile) closet. Comes with supplies to fight fire."
	name = "Fire Closet"
	icon_state = "firecloset"
	icon_closed = "firecloset"
	icon_opened = "fireclosetopen"

/obj/closet/hydrant //wall mounted fire closet
	desc = "A wall mounted closet which comes with supplies to fight fire."
	name = "Fire Closet"
	icon_state = "hydrant"
	icon_closed = "hydrant"
	icon_opened = "hydrant_open"

/obj/closet/fireaxecabinet
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
				//playsound(user, 'lockreset.wav', 50, 1) -- Causes Compiling Errors -Superxpdude
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
					//playsound(user, 'lockenable.wav', 50, 1) -- Causes Compiling Errors -Superxpdude
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



/obj/closet/toolcloset
	desc = "A bulky (yet mobile) closet. Contains tools."
	name = "Tool Closet"
	icon_state = "toolcloset"
	icon_closed = "toolcloset"
	icon_opened = "toolclosetopen"

/obj/closet/jcloset
	desc = "A bulky (yet mobile) closet. Comes with janitor's clothes and biohazard gear."
	name = "Custodial Closet"

/obj/closet/lawcloset
	desc = "A bulky (yet mobile) closet. Comes with lawyer apparel and items."
	name = "Legal Closet"

/obj/closet/coffin
	desc = "A burial receptacle for the dearly departed."
	name = "coffin"
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"

/obj/closet/bombcloset
	desc = "A bulky (yet mobile) closet. Comes prestocked with a level 4 bombsuit."
	name = "EOD closet"
	icon_state = "bombsuit"
	icon_closed = "bombsuit"
	icon_opened = "bombsuitopen"

/obj/closet/bombclosetsecurity
	desc = "A bulky (yet mobile) closet. Comes prestocked with a level 4 bombsuit."
	name = "EOD closet"
	icon_state = "bombsuitsec"
	icon_closed = "bombsuitsec"
	icon_opened = "bombsuitsecopen"

/obj/closet/l3closet
	desc = "A bulky (yet mobile) closet. Comes prestocked with level 3 biohazard gear for emergencies."
	name = "Level 3 Biohazard Suit"
	icon_state = "bio"
	icon_closed = "bio"
	icon_opened = "bioopen"

/obj/closet/l3closet/general
	icon_state = "bio_general"
	icon_closed = "bio_general"
	icon_opened = "bio_generalopen"

/obj/closet/l3closet/virology
	icon_state = "bio_virology"
	icon_closed = "bio_virology"
	icon_opened = "bio_virologyopen"

/obj/closet/l3closet/security
	icon_state = "bio_security"
	icon_closed = "bio_security"
	icon_opened = "bio_securityopen"

/obj/closet/l3closet/janitor
	icon_state = "bio_janitor"
	icon_closed = "bio_janitor"
	icon_opened = "bio_janitoropen"

/obj/closet/l3closet/scientist
	icon_state = "bio_scientist"
	icon_closed = "bio_scientist"
	icon_opened = "bio_scientistopen"

/obj/closet/syndicate
	desc = "Why is this here?"
	name = "Weapons Closet"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/closet/syndicate/personal
	desc = "Gear preperations closet."

/obj/closet/syndicate/nuclear
	desc = "Nuclear preperations closet."

	// Inserting the gimmick clothing stuff here for generic items, IE Tacticool stuff

/obj/closet/extinguisher
	name = "Extinguisher closet"
	var/obj/item/weapon/extinguisher/EXTINGUISHER = new/obj/item/weapon/extinguisher
	icon_state = "extinguisher10"
	icon_opened = "extinguisher11"
	icon_closed = "extinguisher10"
	opened = 1
	var/localopened = 1
	desc = "Sure was nice of CentCom to install these everywhere."
	anchored = 1

	open()
		return

	close()
		return

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		//..() don't want it to behave like a normal closet.

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


/obj/closet/gimmick
	name = "Administrative Supply Closet"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Closet of things that have no right being here."
	anchored = 0

/obj/closet/gimmick/russian
	name = "Russian Surplus"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Russian Surplus Closet"

/obj/closet/gimmick/tacticool
	name = "Tacticool Gear"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Tacticool Gear Closet"

	// Ending of my edit. ~Sillazi

/obj/closet/thunderdome
	desc = "Everything you need!"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"
	name = "Thunderdome closet."
	anchored = 1

/obj/closet/thunderdome/tdred
	desc = "Everything you need!"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"
	name = "Thunderdome closet."

/obj/closet/thunderdome/tdgreen
	desc = "Everything you need!"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	name = "Thunderdome closet."

/obj/closet/malf/suits
	desc = "Gear preparations closet."
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/closet/wardrobe
	desc = "A bulky (yet mobile) wardrobe closet. Comes prestocked with 6 changes of clothes."
	name = "Wardrobe"
	icon_state = "blue"
	icon_closed = "blue"

/obj/closet/wardrobe/black
	name = "Black Wardrobe"
	icon_state = "black"
	icon_closed = "black"

/obj/closet/wardrobe/chaplain_black
	name = "Chaplain Wardrobe"
	icon_state = "black"
	icon_closed = "black"

/obj/closet/wardrobe/green
	name = "Green Wardrobe"
	icon_state = "green"
	icon_closed = "green"

/obj/closet/wardrobe/mixed
	name = "Mixed Wardrobe"
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/closet/wardrobe/orange
	name = "Prisoners Wardrobe"
	icon_state = "orange"
	icon_closed = "orange"

/obj/closet/wardrobe/pink
	name = "Pink Wardrobe"
	icon_state = "pink"
	icon_closed = "pink"

/obj/closet/wardrobe/red
	name = "Red Wardrobe"
	icon_state = "red"
	icon_closed = "red"

/obj/closet/wardrobe/forensics_red
	name = "Forensics Wardrobe"
	icon_state = "red"
	icon_closed = "red"


/obj/closet/wardrobe/white
	name = "White Wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/closet/wardrobe/toxins_white
	name = "Toxins Wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/closet/wardrobe/genetics_white
	name = "Genetics Wardrobe"
	icon_state = "white"
	icon_closed = "white"


/obj/closet/wardrobe/yellow
	name = "Yellow Wardrobe"
	icon_state = "wardrobe-y"
	icon_closed = "wardrobe-y"

/obj/closet/wardrobe/engineering_yellow
	name = "Engineering Wardrobe"
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/closet/wardrobe/atmospherics_yellow
	name = "Atmospherics Wardrobe"
	icon_state = "yellow"
	icon_closed = "yellow"


/obj/closet/wardrobe/grey
	name = "Grey Wardrobe"
	icon_state = "grey"
	icon_closed = "grey"


/obj/secure_closet
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

/obj/secure_closet/courtroom
	name = "Courtroom Locker"
	req_access = list(access_court)

/obj/secure_closet/animal
	name = "Animal Control"
	req_access = list(access_medical)

/obj/secure_closet/brig
	name = "Brig Locker"
	req_access = list(access_brig)
	var/id = null

/obj/secure_closet/highsec
	name = "Head of Personnel"
	req_access = list(access_hop)

/obj/secure_closet/hos
	name = "Head Of Security"
	req_access = list(access_hos)

/obj/secure_closet/injection
	name = "Lethal Injections"
	req_access = list(access_hos)

/obj/secure_closet/captains
	name = "Captain's Closet"
	req_access = list(access_captain)

/obj/secure_closet/medical1
	name = "Medicine Closet"
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medical1"
	req_access = list(access_medical)

/obj/secure_closet/chemical
	name = "Chemical Closet"
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medical1"
	req_access = list(access_medical)

/obj/secure_closet/medical2
	name = "Anesthetic"
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medical1"
	req_access = list(access_medical)

/obj/secure_closet/medical3
	name = "Medical Doctor's Locker"
	req_access = list(access_medical)

/obj/secure_closet/RD
	name = "Research Director"
	req_access = list(access_rd)

/obj/secure_closet/CMO
	name = "Chief Medical Officer"
	req_access = list(access_cmo)

/obj/secure_closet/personal
	desc = "The first card swiped gains control."
	name = "Personal Closet"

/obj/secure_closet/personal/patient
	name = "Patient's closet"

/obj/secure_closet/security1
	name = "Security Equipment"
	req_access = list(access_security)

/obj/secure_closet/security2
	name = "Forensics Locker"
	req_access = list(access_forensics_lockers)

/obj/secure_closet/scientist
	name = "Scientist Locker"

	req_access = list(access_tox_storage)
/obj/secure_closet/chemtoxin
	name = "Chemistry Locker"

	req_access = list(access_medical)
/obj/secure_closet/bar
	name = "Booze"
	req_access = list(access_bar)

/obj/secure_closet/kitchen
	name = "Kitchen Cabinet"
	req_access = list(access_kitchen)

/obj/secure_closet/meat
	name = "Meat Fridge"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"

/obj/secure_closet/fridge
	name = "Refrigerator"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"

/obj/secure_closet/money_freezer
	name = "Freezer"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"
	req_access = list(access_heads_vault)

/obj/secure_closet/engineering_chief
	name = "Chief Engineer's Locker"
	req_access = list(access_ce)

/obj/secure_closet/engineering_electrical
	name = "Electrical Supplies"
	req_access = list(access_engine)

/obj/secure_closet/engineering_welding
	name = "Welding Supplies"
	req_access = list(access_engine)

/obj/secure_closet/engineering_personal
	name = "Engineer's Locker"
	req_access = list(access_engine)

/obj/secure_closet/wall
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