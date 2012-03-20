/obj/structure/closet
	name = "Closet"
	desc = "It's a closet."
	icon = 'closet.dmi'
	icon_state = "closed"
	density = 1
	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/opened = 0
	var/welded = 0
	var/wall_mounted = 0 //never solid (You can always pass over it)
	flags = FPRINT
	var/health = 100	//Might be a bit much, dono can always change later	//Nerfed -Pete
	var/lastbang	//
	var/lasttry = 0
	layer = 2.98

/obj/structure/closet/detective
	name = "Detective's Closet"
	desc = "Holds the detective's clothes while his coat rack is being repaired."

/obj/structure/closet/acloset
	name = "Strange closet"
	desc = "It looks weird."
	icon_state = "acloset"
	icon_closed = "acloset"
	icon_opened = "aclosetopen"

/obj/structure/closet/cabinet
	name = "Cabinet"
	desc = "Old will forever be in fashion."
	icon_state = "cabinet_closed"
	icon_closed = "cabinet_closed"
	icon_opened = "cabinet_open"

/obj/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'items.dmi'
	icon_state = "strangepresent"
	density = 1
	anchored = 0

/obj/structure/closet/gmcloset
	name = "Formal closet"
	desc = "A bulky (yet mobile) closet. Comes with formal clothes."

/obj/structure/closet/emcloset
	name = "Emergency Closet"
	desc = "A bulky (yet mobile) closet. Comes prestocked with a gasmask and o2 tank for emergencies."
	icon_state = "emergency"
	icon_closed = "emergency"
	icon_opened = "emergencyopen"

/obj/structure/closet/firecloset
	name = "Fire Closet"
	desc = "A bulky (yet mobile) closet. Comes with supplies to fight fire."
	icon_state = "firecloset"
	icon_closed = "firecloset"
	icon_opened = "fireclosetopen"

/obj/structure/closet/hydrant //wall mounted fire closet
	name = "Fire Closet"
	desc = "A wall mounted closet which comes with supplies to fight fire."
	icon_state = "hydrant"
	icon_closed = "hydrant"
	icon_opened = "hydrant_open"
	anchored = 1
	density = 0
	wall_mounted = 1

/obj/structure/closet/medical_wall //wall mounted medical closet
	name = "First Aid Closet"
	desc = "A wall mounted closet which should have some first aid."
	icon_state = "medical_wall"
	icon_closed = "medical_wall"
	icon_opened = "medical_wall_open"
	anchored = 1
	density = 0
	wall_mounted = 1

/obj/structure/closet/fireaxecabinet
	name = "Fire Axe Cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe."
	var/obj/item/weapon/fireaxe/fireaxe = new/obj/item/weapon/fireaxe
	icon_state = "fireaxe1000"
	icon_closed = "fireaxe1000"
	icon_opened = "fireaxe1100"
	anchored = 1
	density = 0
	var/localopened = 0 //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = 1
	var/hitstaken = 0
	var/locked = 1
	var/smashed = 0

	attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
		//..() //That's very useful, Erro

		var/hasaxe = 0       //gonna come in handy later~
		if(fireaxe)
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
			if(!fireaxe)
				if(O.wielded)
					user << "\red Unwield the axe first."
					return
				fireaxe = O
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
		if(fireaxe)
			hasaxe = 1

		if(src.locked)
			user <<"\red The cabinet won't budge!"
			return
		if(localopened)
			if(fireaxe)
				user.put_in_hand(fireaxe)
				fireaxe = null
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
			if(fireaxe)
				usr.put_in_hand(fireaxe)
				fireaxe = null
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
		if(fireaxe)
			hasaxe = 1
		icon_state = text("fireaxe[][][][]",hasaxe,src.localopened,src.hitstaken,src.smashed)

	open()
		return

	close()
		return



/obj/structure/closet/toolcloset
	name = "Tool Closet"
	desc = "A bulky (yet mobile) closet. Contains tools."
	icon_state = "toolcloset"
	icon_closed = "toolcloset"
	icon_opened = "toolclosetopen"

/obj/structure/closet/jcloset
	name = "Custodial Closet"
	desc = "A bulky (yet mobile) closet. Contains the janitor's gear."

/obj/structure/closet/jcloset2
	name = "Cleaner's Closet"
	desc = "A bulky (yet mobile) closet. Contains various items for cleaning."

/obj/structure/closet/lawcloset
	name = "Legal Closet"
	desc = "A bulky (yet mobile) closet. Comes with lawyer apparel and items."

/obj/structure/closet/coffin
	name = "coffin"
	desc = "A burial receptacle for the dearly departed."
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"

/obj/structure/closet/bombcloset
	name = "EOD closet"
	desc = "A bulky (yet mobile) closet. Comes prestocked with a level 4 bombsuit."
	icon_state = "bombsuit"
	icon_closed = "bombsuit"
	icon_opened = "bombsuitopen"

/obj/structure/closet/bombclosetsecurity
	name = "EOD closet"
	desc = "A bulky (yet mobile) closet. Comes prestocked with a level 4 bombsuit."
	icon_state = "bombsuitsec"
	icon_closed = "bombsuitsec"
	icon_opened = "bombsuitsecopen"

/obj/structure/closet/l3closet
	name = "Level 3 Biohazard Suit"
	desc = "A bulky (yet mobile) closet. Comes prestocked with level 3 biohazard gear for emergencies."
	icon_state = "bio"
	icon_closed = "bio"
	icon_opened = "bioopen"

/obj/structure/closet/l3closet/general
	name = "Level 3 Biohazard Suit"
	desc = "A bulky (yet mobile) closet. Comes prestocked with level 3 biohazard gear for emergencies."
	icon_state = "bio_general"
	icon_closed = "bio_general"
	icon_opened = "bio_generalopen"

/obj/structure/closet/l3closet/virology
	name = "Level 3 Biohazard Suit"
	desc = "A bulky (yet mobile) closet. Comes prestocked with level 3 biohazard gear for emergencies."
	icon_state = "bio_virology"
	icon_closed = "bio_virology"
	icon_opened = "bio_virologyopen"

/obj/structure/closet/l3closet/security
	name = "Level 3 Biohazard Suit"
	desc = "A bulky (yet mobile) closet. Comes prestocked with level 3 biohazard gear for emergencies."
	icon_state = "bio_security"
	icon_closed = "bio_security"
	icon_opened = "bio_securityopen"

/obj/structure/closet/l3closet/janitor
	name = "Level 3 Biohazard Suit"
	desc = "A bulky (yet mobile) closet. Comes prestocked with level 3 biohazard gear for emergencies."
	icon_state = "bio_janitor"
	icon_closed = "bio_janitor"
	icon_opened = "bio_janitoropen"

/obj/structure/closet/l3closet/scientist
	name = "Level 3 Biohazard Suit"
	desc = "A bulky (yet mobile) closet. Comes prestocked with level 3 biohazard gear for emergencies."
	icon_state = "bio_scientist"
	icon_closed = "bio_scientist"
	icon_opened = "bio_scientistopen"

/obj/structure/closet/syndicate
	name = "Weapons Closet"
	desc = "Why is this here?"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/structure/closet/syndicate/personal
	name = "Gear Closet"
	desc = "Gear preperations closet."

/obj/structure/closet/syndicate/nuclear
	name = "Nuclear Closet"
	desc = "Nuclear preperations closet."

	// Inserting the gimmick clothing stuff here for generic items, IE Tacticool stuff

/obj/structure/closet/extinguisher
	name = "Extinguisher closet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon_state = "extinguisher10"
	icon_opened = "extinguisher11"
	icon_closed = "extinguisher10"
	opened = 1
	anchored = 1
	density = 0
	var/obj/item/weapon/extinguisher/EXTINGUISHER = new/obj/item/weapon/extinguisher
	var/localopened = 1

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


/obj/structure/closet/gimmick
	name = "Administrative Supply Closet"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Closet of things that have no right being here."
	anchored = 0

/obj/structure/closet/gimmick/russian
	name = "Russian Surplus"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Russian Surplus Closet"

/obj/structure/closet/gimmick/tacticool
	name = "Tacticool Gear"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Tacticool Gear Closet"

/obj/structure/closet/thunderdome
	desc = "Everything you need!"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"
	name = "Thunderdome closet"
	anchored = 1

/obj/structure/closet/thunderdome/tdred
	desc = "Everything you need!"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"
	name = "Thunderdome closet"

/obj/structure/closet/thunderdome/tdgreen
	desc = "Everything you need!"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	name = "Thunderdome closet"

/obj/structure/closet/malf/suits
	desc = "Gear preparations closet"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/structure/closet/wardrobe
	desc = "A bulky (yet mobile) wardrobe closet. Comes prestocked with 6 changes of clothes."
	name = "Wardrobe"
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/wardrobe/black
	name = "Black Wardrobe"
	desc = "Contains black jumpsuits."
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/wardrobe/chaplain_black
	name = "Chaplain Wardrobe"
	desc = "Closet of basic chaplain clothes."
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/wardrobe/green
	name = "Green Wardrobe"
	desc = "Contains green jumpsuits."
	icon_state = "green"
	icon_closed = "green"

/obj/structure/closet/wardrobe/mixed
	name = "Mixed Wardrobe"
	desc = "This appears to contain several different sets of clothing."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/wardrobe/orange
	name = "Prisoner's Wardrobe"
	desc = "Contains orange jumpsuits."
	icon_state = "orange"
	icon_closed = "orange"

/obj/structure/closet/wardrobe/pink
	name = "Pink Wardrobe"
	desc = "Contains pink jumpsuits."
	icon_state = "pink"
	icon_closed = "pink"

/obj/structure/closet/wardrobe/red
	name = "Red Wardrobe"
	desc = "Contains red security jumpsuits."
	icon_state = "red"
	icon_closed = "red"

/obj/structure/closet/wardrobe/warden
	name = "Warden's Wardrobe"
	desc = "Contains the warden's security uniform."
	icon_state = "red"
	icon_closed = "red"

/obj/structure/closet/wardrobe/hos
	name = "Head of Security's Wardrobe"
	desc = "Contains the Head of Security's uniform."
	icon_state = "red"
	icon_closed = "red"

/obj/structure/closet/wardrobe/hop
	name = "Head of Personnel's Wardrobe"
	desc = "Contains the Head of Personnel's uniform."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/wardrobe/white
	name = "White Wardrobe"
	desc = "Contains white jumpsuits."
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/toxins_white
	name = "Toxins Wardrobe"
	desc = "Contains toxins jumpsuits."
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/genetics_white
	name = "Genetics Wardrobe"
	desc = "Contains genetics jumpsuits."
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/medic_white
	name = "Doctor's Wardrobe"
	desc = "Contains medical jumpsuits."
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/chemistry_white
	name = "Chemistry Wardrobe"
	desc = "Contains chemistry jumpsuits."
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/nurse
	name = "Nurse's Wardrobe"
	desc = "Contains nurse uniforms."
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/cmo
	name = "Chief Medical Officer's Wardrobe"
	desc = "Contains the Chief Medical Officer's clothing."
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/rd
	name = "Research Director's Wardrobe"
	desc = "Contains the Research Director's clothing."
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/scientist
	name = "Scientist's Wardrobe"
	desc = "Contains the scientist's clothing."
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/virology_white
	name = "Virology Wardrobe"
	desc = "Contains virologist jumpsuits."
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/yellow
	name = "Yellow Wardrobe"
	desc = "Contains yellow jumpsuits."
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/structure/closet/wardrobe/engineering_yellow
	name = "Engineering Wardrobe"
	desc = "Contains engineering jumpsuits."
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/structure/closet/wardrobe/robotics_yellow
	name = "Robotics Wardrobe"
	desc = "Contains robotics jumpsuits."
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/structure/closet/wardrobe/atmospherics_yellow
	name = "Atmospherics Wardrobe"
	desc = "Contains atmospheric jumpsuits."
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/structure/closet/wardrobe/grey
	name = "Grey Wardrobe"
	desc = "Contains grey jumpsuits."
	icon_state = "grey"
	icon_closed = "grey"

/obj/structure/closet/wardrobe/bartender_black
	name = "Bartender's Wardrobe"
	desc = "Closet of basic bartending clothes."
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/wardrobe/chef_white
	name = "Chef's Wardrobe"
	desc = "Contains chef jumpsuits."
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/hydro_green
	name = "Hydroponics Wardrobe"
	desc = "Contains botanist jumpsuits."
	icon_state = "green"
	icon_closed = "green"

/obj/structure/closet/wardrobe/librarian_red
	name = "Librarian's Wardrobe"
	desc = "Contains librarian jumpsuits."
	icon_state = "red"
	icon_closed = "red"

/obj/structure/closet/wardrobe/cargo_yellow
	name = "Cargo Tech's Wardrobe"
	desc = "Contains cargo tech jumpsuits."
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/structure/closet/wardrobe/qm_yellow
	name = "Quartermaster's Wardrobe"
	desc = "Contains quartermaster jumpsuits."
	icon_state = "yellow"
	icon_closed = "yellow"



/obj/structure/closet/secure_closet
	desc = "An immobile card-locked storage closet."
	name = "Security Locker"
	icon = 'closet.dmi'
	icon_state = "secure1"
	density = 1
	opened = 0
	var/locked = 1
	var/broken = 0
	var/large = 1
	icon_closed = "secure"
	var/icon_locked = "secure1"
	icon_opened = "secureopen"
	var/icon_broken = "securebroken"
	var/icon_off = "secureoff"
	wall_mounted = 0 //never solid (You can always pass over it)
	health = 200

/obj/structure/closet/secure_closet/medical_wall
	name = "First Aid Closet"
	desc = "A wall mounted closet which --should-- contain medical supplies."
	icon_state = "medical_wall_locked"
	icon_closed = "medical_wall_unlocked"
	icon_locked = "medical_wall_locked"
	icon_opened = "medical_wall_open"
	icon_broken = "medical_wall_spark"
	icon_off = "medical_wall_off"
	anchored = 1
	density = 0
	wall_mounted = 1
	req_access = list(access_medical)

/obj/structure/closet/secure_closet/personal
	desc = "The first card swiped gains control."
	name = "Personal Closet"

/obj/structure/closet/secure_closet/personal/patient
	name = "Patient's closet"

/obj/structure/closet/secure_closet/kitchen
	name = "Kitchen Cabinet"
	req_access = list(access_kitchen)

/obj/structure/closet/secure_closet/kitchen/mining
	req_access = list()

/obj/structure/closet/secure_closet/meat
	name = "Meat Fridge"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"

/obj/structure/closet/secure_closet/fridge
	name = "Refrigerator"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"

/obj/structure/closet/secure_closet/money_freezer
	name = "Freezer"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"
	req_access = list(access_heads_vault)

/obj/structure/closet/secure_closet/wall
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