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

/obj/closet/l3closet
	desc = "A bulky (yet mobile) closet. Comes prestocked with level 3 biohazard gear for emergencies."
	name = "Level 3 Biohazard Suit"
	icon_state = "bio"
	icon_closed = "bio"
	icon_opened = "bioopen"

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

/obj/closet/gimmick
	desc = "Administrative Supply Closet"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Closet of things that have no right being here."
	anchored = 0

/obj/closet/gimmick/russian
	desc = "Russian Surplus"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Russian Surplus Closet"

/obj/closet/gimmick/tacticool
	desc = "Tacticool Gear"
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
	desc = "Thunderdome closet."
	anchored = 1

/obj/closet/thunderdome/tdred
	desc = "Everything you need!"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"
	desc = "Thunderdome closet."

/obj/closet/thunderdome/tdgreen
	desc = "Everything you need!"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Thunderdome closet."

/obj/closet/malf/suits
	desc = "Gear preperations closet."
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
	name = "Medical Wardrobe"
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
	req_access = list(access_heads)

/obj/secure_closet/hos
	name = "Head Of Security"
	req_access = list(access_heads)

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
	name = "Medical Garb"
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
	name = "Meat Locker"

/obj/secure_closet/fridge
	name = "Refrigerator"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"

/obj/secure_closet/engineering_chief
	name = "Chief Engineer's Locker"
	req_access = list(access_heads)

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