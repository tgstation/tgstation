/datum/antag_faction/venezia
	name = "Venezia"
	description = "A definite rising star, this medical company rose to immense success following a daring plunge in the saturated gene-mod market. Mapping the genome of several obscure species, they were able to stand out from the crowd. A series of innovative marketing campaigns elevated their designer gene-mods into displays of high status. Today, a sizable media empire backs their unique brand of exotic treatements. \
	However, pushing boundaries is not done without a fuss. Indeed, Venezia is relentless in it's pursuit of acquiring anything from new species to unique samples. From their conception, they've employed all manner of agents to stay on top of any medical and genetic advancements, through subterfuge, force and always proxies."
	antagonist_types = list(/datum/antagonist/traitor, /datum/antagonist/spy)
	faction_category = /datum/uplink_category/faction_special/venezia
	entry_line = span_boldnotice("Venezian subcontractor: authorized. You have (probably) been hired by the 9LP's sister-rival-bloodfeud-crew, Echoes-Dark-Locations, to complete your contracts. Please consult your allocated uplink device for extra modificiation kits authorized for your current mission.")

/datum/uplink_category/faction_special/venezia
	name = "Authorized Short-Term Venezian Enhancements"
	weight = 100

/datum/antag_faction_item/venezia
	faction = /datum/antag_faction/venezia

// Items

// alien organs + autosurgeon

/obj/item/storage/organbox/preloaded/venezia_covert_kit
	name = "\"Necronom IV\" Covert Gene Kit"
	desc = "Non-lethal biological weaponry, unapparelled terrain manipulation and a formidable acid glands make these discrete tailored organs uniquely suited for kidnapping and escapes."

/obj/item/storage/organbox/preloaded/venezia_covert_kit/PopulateContents()
	new /obj/item/organ/alien/plasmavessel(src)
	new /obj/item/organ/alien/hivenode(src)
	new /obj/item/organ/alien/resinspinner(src)
	new /obj/item/organ/alien/acid(src)
	new /obj/item/organ/alien/neurotoxin(src)

/obj/item/autosurgeon/syndicate/venezia
	uses = 5

/obj/item/storage/box/syndie_kit/venezia_covert_holder
	name = "biohazard-wrapped box"
	desc = "Contains 'experimental organelles'. What does that even mean?"

/obj/item/storage/box/syndie_kit/venezia_covert_holder/PopulateContents()
	new /obj/item/storage/organbox/preloaded/venezia_covert_kit(src)
	new /obj/item/autosurgeon/syndicate/venezia(src)

/datum/antag_faction_item/venezia/covert_gene_kit
	name = "\"Necronom IV\" Covert Gene Kit"
	description = "Non-lethal biological weaponry, unparalleled terrain manipulation and a formidable acid glands make these discrete tailored organs uniquely suited for kidnapping and escapes."
	item = /obj/item/storage/box/syndie_kit/venezia_covert_holder
	cost = 15

// laser-eyes genemod
/obj/item/dnainjector/lasereyesmut/venezia
	name = "\"L'Ecarlate\" Self-Defense Optic Genemod"
	desc = "Developed as an exotic yet efficient self defense genemod,it enables optic organs to project energy blasts at will. Its development was halted due to it's side effects- a permanent, intense glow from the pupils, and hefty migraines."

/datum/antag_faction_item/venezia/self_defense_optics
	name = "\"L'Ecarlate\" Self-Defense Optic Genemod"
	description = "Developed as an exotic yet efficient self defense genemod, it enables optic organs to project energy blasts at will. Its development was halted due to it's side effects- a permanent, intense glow from the pupils, and hefty migraines."
	item = /obj/item/dnainjector/lasereyesmut/venezia
	cost = 11
