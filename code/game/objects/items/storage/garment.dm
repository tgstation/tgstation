/obj/item/storage/bag/garment
	name = "garment bag"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "garment_bag"
	desc = "A bag for storing extra clothes and shoes."
	slot_flags = NONE
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/garment/clothing/captain
	name = "captain's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the captain."

/obj/item/storage/bag/garment/clothing/hos
	name = "head of security's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of security."

/obj/item/storage/bag/garment/clothing/warden
	name = "warden's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the warden."

/obj/item/storage/bag/garment/clothing/hop
	name = "head of personnel's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of personnel."

/obj/item/storage/bag/garment/clothing/research_director
	name = "research director's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the research director."

/obj/item/storage/bag/garment/clothing/chief_medical
	name = "chief medical officer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief medical officer."

/obj/item/storage/bag/garment/clothing/engineering_chief
	name = "chief engineer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief engineer."

/obj/item/storage/bag/garment/clothing/quartermaster
	name = "quartermasters's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the quartermaster."

/obj/item/storage/bag/garment/clothing/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.numerical_stacking = FALSE
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 17
	atom_storage.insert_preposition = "in"
	atom_storage.set_holdable(/obj/item/clothing)

/obj/item/storage/bag/garment/clothing/captain/PopulateContents()
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/under/rank/captain/skirt(src)
	new /obj/item/clothing/under/rank/captain/parade(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/captains_formal(src)
	new /obj/item/clothing/suit/hooded/wintercoat/captain(src)
	new /obj/item/clothing/suit/jacket/capjacket(src)
	new /obj/item/clothing/glasses/sunglasses/gar/giga(src)
	new /obj/item/clothing/gloves/captain(src)
	new /obj/item/clothing/head/costume/crown/fancy(src)
	new /obj/item/clothing/head/hats/caphat(src)
	new /obj/item/clothing/head/hats/caphat/parade(src)
	new /obj/item/clothing/neck/cloak/cap(src)
	new /obj/item/clothing/shoes/laceup(src)

/obj/item/storage/bag/garment/clothing/hop/PopulateContents()
	new /obj/item/clothing/under/rank/civilian/head_of_personnel(src)
	new /obj/item/clothing/under/rank/civilian/head_of_personnel/skirt(src)
	new /obj/item/clothing/suit/armor/vest/hop(src)
	new /obj/item/clothing/suit/hooded/wintercoat/hop(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/head/hats/hopcap(src)
	new /obj/item/clothing/neck/cloak/hop(src)
	new /obj/item/clothing/shoes/laceup(src)

/obj/item/storage/bag/garment/clothing/hos/PopulateContents()
	new /obj/item/clothing/under/rank/security/head_of_security/skirt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/alt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/alt/skirt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/grey(src)
	new /obj/item/clothing/under/rank/security/head_of_security/parade(src)
	new /obj/item/clothing/under/rank/security/head_of_security/parade/female(src)
	new /obj/item/clothing/gloves/tackler/combat(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/suit/armor/hos/hos_formal(src)
	new /obj/item/clothing/suit/armor/hos/trenchcoat/winter(src)
	new /obj/item/clothing/suit/armor/vest/leather(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/gars/giga(src)
	new /obj/item/clothing/head/hats/hos/beret(src)
	new /obj/item/clothing/head/hats/hos/cap(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)
	new /obj/item/clothing/neck/cloak/hos(src)

/obj/item/storage/bag/garment/clothing/warden/PopulateContents()
	new /obj/item/clothing/suit/armor/vest/warden(src)
	new /obj/item/clothing/head/hats/warden(src)
	new /obj/item/clothing/head/hats/warden/drill(src)
	new /obj/item/clothing/head/beret/sec/navywarden(src)
	new /obj/item/clothing/suit/armor/vest/warden/alt(src)
	new /obj/item/clothing/under/rank/security/warden/formal(src)
	new /obj/item/clothing/under/rank/security/warden/skirt(src)
	new /obj/item/clothing/gloves/krav_maga/sec(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/mask/gas/sechailer(src)

/obj/item/storage/bag/garment/clothing/research_director/PopulateContents()
	new /obj/item/clothing/under/rank/rnd/research_director(src)
	new /obj/item/clothing/under/rank/rnd/research_director/skirt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/alt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/alt/skirt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/turtleneck(src)
	new /obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt(src)
	new /obj/item/clothing/suit/hooded/wintercoat/science/rd(src)
	new /obj/item/clothing/head/beret/science/rd(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/neck/cloak/rd(src)
	new /obj/item/clothing/shoes/jackboots(src)

/obj/item/storage/bag/garment/clothing/chief_medical/PopulateContents()
	new /obj/item/clothing/under/rank/medical/chief_medical_officer(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/skirt(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/scrubs(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck/skirt(src)
	new /obj/item/clothing/suit/hooded/wintercoat/medical/cmo(src)
	new /obj/item/clothing/suit/toggle/labcoat/cmo(src)
	new /obj/item/clothing/gloves/latex/nitrile(src)
	new /obj/item/clothing/head/beret/medical/cmo(src)
	new /obj/item/clothing/head/utility/surgerycap/cmo(src)
	new /obj/item/clothing/neck/cloak/cmo(src)
	new /obj/item/clothing/shoes/sneakers/blue (src)

/obj/item/storage/bag/garment/clothing/engineering_chief/PopulateContents()
	new /obj/item/clothing/under/rank/engineering/chief_engineer(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer/skirt(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer/turtleneck(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer/turtleneck/skirt(src)
	new /obj/item/clothing/suit/hooded/wintercoat/engineering/ce(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/clothing/gloves/chief_engineer(src)
	new /obj/item/clothing/head/utility/hardhat/white(src)
	new /obj/item/clothing/head/utility/hardhat/welding/white(src)
	new /obj/item/clothing/neck/cloak/ce(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)

/obj/item/storage/bag/garment/clothing/quartermaster/PopulateContents()
	new /obj/item/clothing/under/rank/cargo/qm(src)
	new /obj/item/clothing/under/rank/cargo/qm/skirt(src)
	new /obj/item/clothing/suit/hooded/wintercoat/cargo/qm(src)
	new /obj/item/clothing/suit/utility/fire/firefighter(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/suit/jacket/quartermaster(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/neck/cloak/qm(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)

//Curator Garments (holds items too)
/obj/item/storage/bag/garment/hero
	name = "Courageous Tomb Raider - 1940's."
	desc = "This legendary figure of still dubious historical accuracy is thought to have been a world-famous archeologist who embarked on countless adventures in far away lands, along with his trademark whip and fedora hat."

/obj/item/storage/bag/garment/hero/PopulateContents()
	new /obj/item/clothing/head/fedora/curator(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/suit/jacket/curator(src)
	new /obj/item/clothing/under/rank/civilian/curator/treasure_hunter(src)
	new /obj/item/melee/curator_whip(src)

/obj/item/storage/bag/garment/hero/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.numerical_stacking = FALSE
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 17
	atom_storage.insert_preposition = "in"

/obj/item/storage/bag/garment/hero/astronaut
	name = "First Man on the Moon - 1960's."
	desc = "One small step for a man, one giant leap for mankind. Relive the beginnings of space exploration with this fully functional set of vintage EVA equipment."

/obj/item/storage/bag/garment/hero/astronaut/PopulateContents()
	new /obj/item/clothing/suit/space/nasavoid(src)
	new /obj/item/clothing/head/helmet/space/nasavoid(src)
	new /obj/item/tank/internals/oxygen(src)
	new /obj/item/gps(src)

/obj/item/storage/bag/garment/hero/scottish
	name = "Braveheart, the Scottish rebel - 1300's."
	desc = "Seemingly a legendary figure in the battle for Scottish independence, this historical figure is closely associated with blue facepaint, big swords, strange man skirts, and his ever enduring catchphrase: 'FREEDOM!!'"

/obj/item/storage/bag/garment/hero/scottish/PopulateContents()
	new /obj/item/claymore/weak/ceremonial(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/under/costume/kilt(src)
	new /obj/item/toy/crayon/spraycan(src)

/obj/item/storage/bag/garment/hero/carphunter
	name = "Carp Hunter, Wildlife Expert - 2506."
	desc = "Despite his nickname, this wildlife expert was mainly known as a passionate environmentalist and conservationist, often coming in contact with dangerous wildlife to teach about the beauty of nature."

/obj/item/storage/bag/garment/hero/carphunter/PopulateContents()
	new /obj/item/clothing/mask/gas/carp(src)
	new /obj/item/clothing/suit/hooded/carp_costume/spaceproof/old(src)
	new /obj/item/knife/hunting(src)
	new /obj/item/storage/box/papersack/meat(src)

/obj/item/storage/bag/garment/hero/mothpioneer
	name = "Mothic Fleet Pioneer - 2429."
	desc = "Some claim that the fleet engineers are directly responsible for most modern advancements in spacefaring designs. Although the exact details of their past contributions are somewhat fuzzy, their ingenuity remains unmatched and unquestioned to this day."

/obj/item/storage/bag/garment/hero/mothpioneer/PopulateContents()
	new /obj/item/clothing/head/mothcap/original(src)
	new /obj/item/clothing/suit/mothcoat/original(src)
	new /obj/item/crowbar(src)
	new /obj/item/flashlight/lantern(src)
	new /obj/item/screwdriver(src)
	new /obj/item/stack/sheet/glass/fifty(src)
	new /obj/item/stack/sheet/iron/fifty(src)
	new /obj/item/wrench(src)

/obj/item/storage/bag/garment/hero/etherealwarden
	name = "Ethereal Trailwarden - 2450's."
	desc = "Many fantastical stories are told of valiant trail wardens, even by offworlders who, thanks to their guidance, avoided an untimely demise while traveling the sometimes treacherous roads of Sprout. In truth their job entails far more walking and fixing roads than slaying dragons, but it is no less important and well respected: keeping the roads and trails safe and well maintained is for many settlements a matter of survival."

/obj/item/storage/bag/garment/hero/etherealwarden/PopulateContents()
	new /obj/item/clothing/suit/hooded/ethereal_raincoat/trailwarden(src)
	new /obj/item/clothing/under/ethereal_tunic/trailwarden(src)
	new /obj/item/storage/backpack/saddlepack(src)

/obj/item/storage/bag/garment/hero/journalist
	name = "Assassinated by CIA - 1984." // Literally
	desc = "Many courageous individuals risked their lives to report on events the government sought to keep hidden from the public, ensuring that the truth remained buried and unheard. These garments are replicas of the clothing worn by one such 'journalist,' a silent sentinel in the fight for truth."

/obj/item/storage/bag/garment/hero/journalist/PopulateContents()
	new /obj/item/clothing/under/costume/buttondown/slacks(src)
	new /obj/item/clothing/suit/toggle/suspenders(src)
	new /obj/item/clothing/neck/tie/red(src)
	new /obj/item/clothing/head/fedora/beige/press(src)
	new /obj/item/clothing/accessory/press_badge(src)
	new /obj/item/clothing/suit/hazardvest/press(src)
	new /obj/item/radio/entertainment/microphone/physical(src)
	new /obj/item/radio/entertainment/speakers/physical(src)
	new /obj/item/clipboard(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)
	new /obj/item/wallframe/telescreen/entertainment(src)
