// Add custom items you give to people here, and put their icons in custom_items.dmi
// Remember to change 'icon = 'custom_items.dmi'' for items not using /obj/item/fluff as a base
// Clothing item_state doesn't use custom_items.dmi. Just add them to the normal clothing files.

/obj/item/fluff // so that they don't spam up the object tree
	icon = 'custom_items.dmi'
	w_class = 1.0

//////////////////////////////////
////////// Fluff Items ///////////
//////////////////////////////////

/obj/item/fluff/wes_solari_1 //tzefa: Wes Solari
	name = "family photograph"
	desc = "A family photograph of a couple and a young child, Written on the back it says \"See you soon Dad -Roy\"."
	icon_state = "wes_solari_1"

/obj/item/fluff/sarah_calvera_1 //fniff: Sarah Calvera
	name = "old photo"
	desc = "Looks like it was made on a really old, cheap camera. Low quality. The camera shows a young hispanic looking girl with red hair wearing a white dress is standing in front of\
 an old looking wall. On the back there is a note in black marker that reads \"Sara, Siempre pensé que eras tan linda con ese vestido. Tu hermano, Carlos.\""
	icon_state = "sarah_calvera_1"

/obj/item/fluff/angelo_wilkerson_1 //fniff: Angleo Wilkerson
	name = "fancy watch"
	desc = "An old and expensive pocket watch. Engraved on the bottom is \"Odium est Source De Dolor\". On the back, there is an engraving that does not match the bottom and looks more recent.\
 \"Angelo, If you find this, you shall never see me again. Please, for your sake, go anywhere and do anything but stay. I'm proud of you and I will always love you. Your father, Jacob Wilkerson.\"\
  Jacob Wilkerson... Wasn't he that serial killer?"
	icon_state = "angelo_wilkerson_1"

/obj/item/fluff/sarah_carbrokes_1 //gvazdas: Sarah Carbrokes
	name = "locket"
	desc = "A grey locket with a picture of a black haired man in it. The text above it reads: \"Edwin Carbrokes\"."
	icon_state = "sarah_carbrokes_1"

/obj/item/fluff/ethan_way_1 //whitellama: Ethan Way
	name = "old ID"
	desc = "A scratched and worn identification card; it appears too damaged to inferface with any technology. You can almost make out \"Tom Cabinet\" in the smeared ink."
	icon_state = "ethan_way_1"

/obj/item/fluff/val_mcneil_1 //silentthunder: Val McNeil
	name = "rosary pendant"
	desc = "A cross on a ring of beads, has McNeil etched onto the back."
	icon_state = "val_mcneil_1"

/obj/item/fluff/steve_johnson_1 //thebreadbocks: Steve Johnson
	name = "bottle of hair dye"
	desc = "A bottle of pink hair dye. So that's how he gets his beard so pink..."
	icon_state = "steve_johnson_1"
	item_state = "steve_johnson_1"

/obj/item/fluff/david_fanning_1 //sicktrigger: David Fanning
	name = "golden scalpel"
	desc = "A fine surgical cutting tool covered in thin gold leaf. Does not seem able to cut anything."
	icon_state = "david_fanning_1"
	item_state = "david_fanning_1"

//////////////////////////////////
////////// Usable Items //////////
//////////////////////////////////

/obj/item/weapon/pen/fluff/multi //spaceman96: Trenna Seber
	name = "multicolor pen"
	desc = "It's a cool looking pen. Lots of colors!"

/obj/item/weapon/pen/fluff/fancypen //orangebottle: Lillian Levett, Lilliana Reade
	name = "fancy pen"
	desc = "A fancy metal pen. It uses blue ink. An inscription on one side reads,\"L.L. - L.R.\""
	icon = 'custom_items.dmi'
	icon_state = "fancypen"

/obj/item/fluff/victor_kaminsky_1 //chinsky: Victor Kaminski
	name = "golden detective's badge"
	desc = "NanoTrasen Security Department detective's badge, made from gold. Badge number is 564."
	icon_state = "victor_kaminsky_1"

/obj/item/fluff/victor_kaminsky_1/attack_self(mob/user as mob)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("[] shows you: \icon[] [].", user, src, src.name), 1)
	src.add_fingerprint(user)

/obj/item/weapon/clipboard/fluff/smallnote //lexusjjss: Lexus Langg, Zachary Tomlinson
	name = "small notebook"
	desc = "A generic small spiral notebook that flips upwards."
	icon = 'custom_items.dmi'
	icon_state = "smallnotetext"
	item_state = "smallnotetext"

/obj/item/weapon/storage/fluff/maye_daye_1 //morrinn: Maye Day
	name = "pristine lunchbox"
	desc = "A pristine stainless steel lunch box. The initials M.D. are engraved on the inside of the lid."
	icon = 'custom_items.dmi'
	icon_state = "maye_daye_1"

/obj/item/weapon/reagent_containers/food/drinks/flask/fluff/johann_erzatz_1 //leonheart11:  Johann Erzatz
	name = "vintage thermos"
	desc = "An older thermos with a faint shine."
	icon = 'custom_items.dmi'
	icon_state = "johann_erzatz_1"
	volume = 50

/obj/item/weapon/lighter/zippo/fluff/li_matsuda_1 //mangled: Li Matsuda
	name = "blue zippo lighter"
	desc = "A zippo lighter made of some blue metal."
	icon = 'custom_items.dmi'
	icon_state = "bluezippo"
	icon_on = "bluezippoon"
	icon_off = "bluezippo"

/obj/item/weapon/lighter/zippo/fluff/riley_rohtin_1 //rawrtaicho: Riley Rohtin
	name = "Riley's black zippo"
	desc = "A black zippo lighter, which holds some form of sentimental value."
	icon = 'custom_items.dmi'
	icon_state = "blackzippo"
	icon_on = "blackzippoon"
	icon_off = "blackzippo"

/obj/item/weapon/lighter/zippo/fluff/sniperyeti_1 //sniperyeti: Patrick Harris/Susan Harris
	name = "red black zippo"
	desc = "A shiny red zippo lighter that looks like it's in perfect condition."
	icon = 'custom_items.dmi'
	icon_state = "redzippo"
	icon_on = "redzippoon"
	icon_off = "redzippo"

/obj/item/weapon/lighter/zippo/fluff/executivekill_1 //executivekill: Hunter Duke
	name = "Gonzo Fist zippo"
	desc = "A Zippo lighter with the iconic Gonzo Fist on a matte black finish."
	icon = 'custom_items.dmi'
	icon_state = "gonzozippo"
	icon_on = "gonzozippoon"
	icon_off = "gonzozippo"

/obj/item/weapon/fluff/cado_keppel_1 //sparklysheep: Cado Keppel
	name = "purple comb"
	desc = "A pristine purple comb made from flexible plastic. It has a small K etched into its side."
	w_class = 1.0
	icon = 'custom_items.dmi'
	icon_state = "purplecomb"
	item_state = "purplecomb"

	attack_self(mob/user)
		if(user.r_hand == src || user.l_hand == src)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] uses [] to comb their hair with incredible style and sophistication. What a guy.", user, src), 1)
		return

/obj/item/weapon/fluff/hugo_cinderbacth_1 //thatoneguy: Hugo Cinderbatch
	name = "Old Cane"
	desc = "An old brown cane made from wood. It has a a large, itallicized H on it's handle."
	icon = 'custom_items.dmi'
	icon_state = "special_cane"

/obj/item/weapon/camera_test/fluff/orange //chinsky: Summer Springfield
	name = "orange camera"
	icon = 'custom_items.dmi'
	desc = "A modified detective's camera, painted in bright orange. On the back you see \"Have fun\" written in small accurate letters with something black."
	icon_state = "orangecamera"
	pictures_left = 30

/obj/item/weapon/card/id/fluff/lifetime	//fastler: Fastler Greay; it seemed like something multiple people would have
	name = "Lifetime ID Card"
	desc = "A modified ID card given only to those people who have devoted their lives to the better interests of NanoTrasen. It sparkles blue."
	icon = 'custom_items.dmi'
	icon_state = "lifetimeid"

/obj/item/weapon/reagent_containers/food/drinks/flask/fluff/shinyflask //lexusjjss: Lexus Langg & Zachary Tomlinson
	name = "shiny flask"
	desc = "A shiny metal flask. It appears to have a Greek symbol inscribed on it."
	icon = 'custom_items.dmi'
	icon_state = "shinyflask"
	volume = 50

/obj/item/weapon/storage/pill_bottle/fluff/listermedbottle //compactninja: Lister Black
	name = "Pill bottle (anti-depressants)"
	desc = "Contains pills used to deal with depression. They appear to be prescribed to Lister Black"
	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )

/obj/item/weapon/reagent_containers/pill/fluff/listermed
	name = "anti-depressant pill"
	desc = "Used to deal with depression."
	icon_state = "pill9"
	New()
		..()
		reagents.add_reagent("stoxin", 5)
		reagents.add_reagent("sugar", 10)
		reagents.add_reagent("ethanol", 5)

/obj/item/clothing/mask/fluff/electriccig //CubeJackal: Barry Sharke
	name = "Electronic cigarette"
	desc = "An electronic cigarette. Most of the relief of a real cigarette with none of the side effects. Often used by smokers who are trying to quit the habit."
	icon = 'custom_items.dmi'
	icon_state = "cigon"
	throw_speed = 0.5
	item_state = "ciglit"
	w_class = 1
	body_parts_covered = null
	flags = FPRINT|TABLEPASS

//Strange penlight, Nerezza: Asher Spock

/obj/item/weapon/reagent_containers/hypospray/fluff/asher_spock_1
	name = "strange penlight"
	desc = "Besides the coloring, this penlight looks rather normal and innocent. However, you get a nagging feeling whenever you see it..."
	icon = 'custom_items.dmi'
	icon_state = "asher_spock_1"
	amount_per_transfer_from_this = 5
	volume = 15

/obj/item/weapon/reagent_containers/hypospray/fluff/asher_spock_1/New()
	..()
	reagents.remove_reagent("tricordrazine", 30)
	reagents.add_reagent("oxycodone", 15)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/fluff/asher_spock_1/attack_self(mob/user as mob)
	user << "\blue You click \the [src] but get no reaction. Must be dead."

/obj/item/weapon/reagent_containers/hypospray/fluff/asher_spock_1/attack(mob/M as mob, mob/user as mob)
	if (user.ckey != "nerezza") //Because this can end up in the wrong hands, let's make it useless for them!
		user << "\blue You click \the [src] but get no reaction. Must be dead."
		return
	if(!reagents.total_volume)
		user << "\red \The [src] is empty."
		return
	if (!( istype(M, /mob) ))
		return
	if (reagents.total_volume)
		if (M == user && user.ckey == "nerezza") //Make sure this is being used by the right person, for the right reason (self injection)
			visible_message("\blue [user] presses their \
				penlight against their skin, quickly clicking the button once.", \
				"\blue You press the disguised autoinjector against your skin and click the button. There's a sharp pain at the injection site that rapidly fades.", \
				"You hear a rustle as someone moves nearby, then a sharp click.")
		if (M != user && user.ckey == "nerezza") //Woah now, you better be careful partner
			user << "\blue You don't want to contaminate the autoinjector."
			return
		src.reagents.reaction(M, INGEST)
		if(M.reagents)
			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			user << "\blue [trans] units injected. [reagents.total_volume] units remaining in \the [src]."
	return

/obj/item/weapon/reagent_containers/hypospray/fluff/asher_spock_1/examine(mob/user as mob)
	..()
	if(user.ckey != "nerezza") return //Only the owner knows how to examine the contents.
	if(reagents && reagents.reagent_list.len)
		for(var/datum/reagent/R in reagents.reagent_list)
			usr << "\blue You examine the penlight closely and see that it has [R.volume] units of [R.name] stored."
	else
		usr << "\blue You examine the penlight closely and see that it is currently empty."

//End strange penlight

/obj/item/weapon/card/id/fluff/asher_spock_2 //Nerezza: Asher Spock
	name = "Odysses Specialist ID card"
	desc = "A special identification card with a red cross signifying an emergency physician has specialised in Odysseus operations and maintenance.\nIt grants the owner recharge bay access."
	icon = 'custom_items.dmi'
	icon_state = "odysseus_spec_id"

/obj/item/weapon/card/id/fluff/ian_colmid //Roaper: Ian Colm
	name = "Technician"
	desc = "An old ID with the words 'Ian Colm's Technician ID' printed on it.."
	icon = 'custom_items.dmi'
	icon_state = "technician_id"


/obj/item/weapon/clipboard/fluff/mcreary_journal //sirribbot: James McReary
	name = "McReary's journal"
	desc = "A journal with a warning sticker on the front cover. The initials \"J.M.\" are written on the back."
	icon = 'custom_items.dmi'
	icon_state = "mcreary_journal"
	item_state = "mcreary_journal"

/obj/item/device/flashlight/fluff/thejesster14_1 //thejesster14: Rosa Wolff
	name = "old red flashlight"
	desc = "A very old, childlike flashlight."
	icon = 'custom_items.dmi'
	icon_state = "wolfflight0"
	w_class = 2
	item_state = "wolfflight"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	m_amt = 50
	g_amt = 20
	on = 0
	brightness_on = 4 //luminosity when on
	icon_on = "wolfflight1"
	icon_off = "wolfflight0"

//////////////////////////////////
//////////// Clothing ////////////
//////////////////////////////////

//////////// Gloves ////////////

/obj/item/clothing/gloves/fluff/walter_brooks_1 //botanistpower: Walter Brooks
	name = "mittens"
	desc = "A pair of well worn, blue mittens."
	icon = 'custom_items.dmi'
	icon_state = "walter_brooks_1"
	item_state = "bluegloves"
	color="blue"

//////////// Eye Wear ////////////

/obj/item/clothing/glasses/meson/fluff/book_berner_1 //asanadas: Book Berner
	name = "bespectacled mesonic surveyors"
	desc = "One of the older meson scanner models retrofitted to perform like its modern counterparts."
	icon = 'custom_items.dmi'
	icon_state = "book_berner_1"

/obj/item/clothing/glasses/fluff/serithi_artalis_1 //serithi: Serithi Artalis
	name = "extranet HUD"
	desc = "A heads-up display with limited connectivity to the NanoTrasen Extranet, capable of displaying information from official NanoTrasen records."
	icon = 'custom_items.dmi'
	icon_state = "serithi_artalis_1"

//////////// Hats ////////////
//Removed by request
/*
/obj/item/clothing/head/helmet/hardhat/fluff/greg_anderson_1 //deusdactyl: Greg Anderson
	name = "old hard hat"
	desc = "An old dented hard hat with the nametag \"Anderson\". It seems to be backwards."
	icon_state = "hardhat0_dblue" //Already an in-game sprite
	item_state = "hardhat0_dblue"
	color = "dblue"
*/

/obj/item/clothing/head/secsoft/fluff/swatcap //deusdactyl: James Girard
	name = "\improper SWAT hat"
	desc = "A black hat.  The inside has the words, \"Lieutenant James Girard, LPD SWAT Team Four.\""
	icon = 'custom_items.dmi'
	icon_state = "swatcap"

/obj/item/clothing/head/helmet/welding/fluff/alice_mccrea_1 //madmalicemccrea: Alice McCrea
	name = "flame decal welding helmet"
	desc = "A welding helmet adorned with flame decals, and several cryptic slogans of varying degrees of legibility. \"Fly the Friendly Skies\" is clearly visible, written above the visor, for some reason."
	icon = 'custom_items.dmi'
	icon_state = "alice_mccrea_1"

/obj/item/clothing/head/helmet/welding/fluff/yuki_matsuda_1 //searif: Yuki Matsuda
	name = "white decal welding helmet"
	desc = "A white welding helmet with a character written across it."
	icon = 'custom_items.dmi'
	icon_state = "yuki_matsuda_1"

/obj/item/clothing/head/helmet/welding/fluff/norah_briggs_1 //bountylord13: Norah Briggs
	name = "blue flame decal welding helmet"
	desc = "A welding helmet with blue flame decals on it."
	icon = 'custom_items.dmi'
	icon_state = "norah_briggs_1"

/obj/item/clothing/head/helmet/greenbandana/fluff/taryn_kifer_1 //themij: Taryn Kifer
	name = "orange bandana"
	desc = "Hey, I think we're missing a hazard vest..."
	icon = 'custom_items.dmi'
	icon_state = "taryn_kifer_1"

/obj/item/clothing/head/fluff/enos_adlai_1 //roaper: Enos Adlai
	name = "comfy cap"
	desc = "Because when you're the toughest Mother Hubbard on the station, nobody's criticizing your fashion sense."
	icon = 'custom_items.dmi'
	icon_state = "enos_adlai_1"

//////////// Suits ////////////

/obj/item/clothing/suit/storage/labcoat/fluff/pink //spaceman96: Trenna Seber
	name = "pink labcoat"
	desc = "A suit that protects against minor chemical spills. Has a pink stripe down from the shoulders."
	icon = 'custom_items.dmi'
	icon_state = "labcoat_pink_open"

/obj/item/clothing/suit/storage/det_suit/fluff/graycoat //vinceluk: Seth Sealis
	name = "gray coat"
	desc = "Old, worn out coat. It's seen better days."
	icon = 'custom_items.dmi'
	icon_state = "graycoat"
	item_state = "graycoat"
	color = "graycoat"

/obj/item/clothing/suit/storage/det_suit/fluff/leatherjack //atomicdog92: Seth Sealis
	name = "leather jacket"
	desc = "A black leather coat, popular amongst punks, greasers, and other galactic scum."
	icon = 'custom_items.dmi'
	icon_state = "leatherjack"
	item_state = "leatherjack"
	color = "leatherjack"

/obj/item/clothing/suit/storage/labcoat/fluff/burnt //Jamini: Edwin Atweeke
	name = "burnt labcoat"
	desc = "This lab coat has clearly seen better, less burnt, days."
	icon = 'custom_items.dmi'
	icon_state = "labcoat_burnt_open"

/obj/item/clothing/suit/armor/vest/fluff/deus_blueshield //deusdactyl
	name = "blue shield security armor"
	desc = "An armored vest with the badge of a Blue Shield Security lieutenant."
	icon = 'custom_items.dmi'
	icon_state = "deus_blueshield"
	item_state = "deus_blueshield"

//////////// Uniforms ////////////

/obj/item/clothing/under/fluff/jumpsuitdown //searif: Yuki Matsuda
	name = "rolled down jumpsuit"
	desc = "A rolled down jumpsuit. Great for mechanics."
	icon = 'custom_items.dmi'
	icon_state = "jumpsuitdown"
	item_state = "jumpsuitdown"
	color = "jumpsuitdown"

/obj/item/clothing/under/fluff/olddressuniform //desiderium: Momiji Inubashiri
	name = "retired dress uniform"
	desc = "A retired Station Head of Staff uniform, phased out twenty years ago for the newer jumpsuit design, but still acceptable dress. Lovingly maintained."
	icon = 'custom_items.dmi'
	icon_state = "olddressuniform"
	item_state = "olddressuniform"
	color = "olddressuniform"

/obj/item/clothing/under/rank/security/fluff/jeremy_wolf_1 //whitewolf41: Jeremy Wolf
	name = "worn officer's uniform"
	desc = "An old red security jumpsuit. Seems to have some slight modifications."
	icon = 'custom_items.dmi'
	icon_state = "jeremy_wolf_1"
	color = "jeremy_wolf_1"

/obj/item/clothing/under/fluff/tian_dress //phaux: Tian Yinhu
	name = "purple dress"
	desc = "A nicely tailored purple dress made for the taller woman."
	icon = 'custom_items.dmi'
	icon_state = "tian_dress"
	item_state = "tian_dress"
	color = "tian_dress"

/obj/item/clothing/under/rank/bartender/fluff/classy	//searif: Ara Al-Jazari
	name = "classy bartender uniform"
	desc = "A prim and proper uniform that looks very similar to a bartender's, the only differences being a red tie, waistcoat and a rag hanging out of the back pocket."
	icon = 'custom_items.dmi'
	icon_state = "ara_bar_uniform"
	item_state = "ara_bar_uniform"
	color = "ara_bar_uniform"

//////////// Masks ////////////

/*
/obj/item/clothing/mask/fluff/flagmask //searif: Tsiokeriio Tarbell
	name = "\improper First Nations facemask"
	desc = "A simple cloth rag that bears the flag of the first nations."
	icon = 'custom_items.dmi'
	icon_state = "flagmask"
	item_state = "flagmask"
	flags = FPRINT|TABLEPASS|MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90
*/

/obj/item/clothing/mask/mara_kilpatrick_1 //staghorn: Mara Kilpatrick
	name = "shamrock pendant"
	desc = "A silver and emerald shamrock pendant. It has the initials \"M.K.\" engraved on the back."
	icon = 'custom_items.dmi'
	icon_state = "mara_kilpatrick_1"
	flags = FPRINT|TABLEPASS
	w_class = 1

//////////// Shoes ////////////

/obj/item/clothing/shoes/fluff/leatherboots //serithi: Serithi Artalis
	name = "leather boots"
	desc = "A pair of leather boots. Well-worn, but still kept in good condition. There is a small \"S\" scratched into the back of each boot."
	icon = 'custom_items.dmi'
	icon_state = "leatherboots"
	item_state = "jackboots"

//////////// Sets ////////////

////// CDC //deusdactyl: Roger Wiles
//Removed by request.
/*
/obj/item/clothing/under/rank/virologist/fluff/cdc_jumpsuit
	name = "\improper CDC jumpsuit"
	desc = "A modified standard-issue CDC jumpsuit made of a special fiber that gives special protection against biohazards.  It has a biohazard symbol sewn into the back."
	icon = 'custom_items.dmi'
	icon_state = "cdc_jumpsuit"
	color = "cdc_jumpsuit"

/obj/item/clothing/suit/storage/labcoat/fluff/cdc_labcoat
	name = "\improper CDC labcoat"
	desc = "A standard-issue CDC labcoat that protects against minor chemical spills.  It has the name \"Wiles\" sewn on to the breast pocket."
	icon = 'custom_items.dmi'
	icon_state = "labcoat_cdc_open"
*/
////// Short Sleeve Medical Outfit //erthilo: Farah Lants

/obj/item/clothing/under/rank/medical/fluff/short
	name = "short sleeve medical jumpsuit"
	desc = "Made of a special fiber that gives special protection against biohazards. Has a cross on the chest denoting that the wearer is trained medical personnel and short sleeves."
	icon = 'custom_items.dmi'
	icon_state = "medical_short"
	color = "medical_short"

/obj/item/clothing/suit/storage/labcoat/fluff/red
	name = "red labcoat"
	desc = "A suit that protects against minor chemical spills. Has a red stripe on the shoulders and rolled up sleeves."
	icon = 'custom_items.dmi'
	icon_state = "labcoat_red_open"

////// Retired Patrol Outfit //desiderium: Rook Maudlin

/obj/item/clothing/suit/storage/det_suit/fluff/retpolcoat
	name = "retired colony patrolman's coat"
	desc = "A clean, black nylon windbreaker with the words \"OUTER LIGHT POLICE\" embroidered in gold-dyed thread on the back. \"RETIRED\" is tastefully embroidered below in a smaller font."
	icon = 'custom_items.dmi'
	icon_state = "retpolcoat"
	item_state = "retpolcoat"
	color = "retpolcoat"

/obj/item/clothing/head/det_hat/fluff/retpolcap
	name = "retired colony patrolman's cap"
	desc = "A clean and properly creased colony police cap. The badge is shined and polished, the word \"RETIRED\" engraved professionally under the words \"OUTER LIGHT POLICE.\""
	icon = 'custom_items.dmi'
	icon_state = "retpolcap"

/obj/item/clothing/under/det/fluff/retpoluniform
	name = "retired colony patrolman's uniform"
	desc = "A meticulously clean police uniform belonging to Precinct 31, Outer Light Colony. The word \"RETIRED\" is engraved tastefully and professionally in the badge below the number, 501."
	icon = 'custom_items.dmi'
	icon_state = "retpoluniform"
	color = "retpoluniform"

