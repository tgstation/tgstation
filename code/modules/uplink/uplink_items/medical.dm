/datum/uplink_category/medical
	name = "Medical"
	weight = 5

/datum/uplink_item/medical
	category = /datum/uplink_category/medical
	surplus = 0


/datum/uplink_item/medical/changelingextract
	name = "Changeling Extract"
	desc = "A medipen containing a highly complex regenerative chemical donated to us by the Tiger Cooperative Fanatics. \
			Upon it's application, the user will near-instanteously regrow all of their limbs and organs."
	item = /obj/item/reagent_containers/hypospray/medipen/limborganregen
	cost = 4
	surplus = 10

/datum/uplink_item/medical/surgerybag
	name = "Syndicate Surgery Duffel Bag"
	desc = "The Syndicate surgery duffel bag is a toolkit containing all surgery tools, surgical drapes, \
			a Syndicate brand MMI, a straitjacket, and a muzzle."
	item = /obj/item/storage/backpack/duffelbag/syndie/surgery
	cost = 3
	surplus = 66

/datum/uplink_item/medical/medical_variety_pack
	name = "Medical Variety Pack"
	desc = "A bluespace-compressed medkit containing one first aid kit and potentially some variety first aid kits such as brute and toxin."
	item = /obj/item/storage/medkit/medical_variety_pack
	cost = 2
	surplus = 35
	illegal_tech = FALSE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/medical/deluxe_medical_variety_pack
	name = "Deluxe Medical Variety Pack"
	desc = "A bluespace-compressed medkit containing one of each variety of first aid kits. Contains some bottles of liquid medicines, pill bottles and and potentially medipens."
	item = /obj/item/storage/medkit/deluxe_medical_variety_pack
	cost = 5
	surplus = 30
	illegal_tech = FALSE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/medical/medipenkit
	name = "Medipen Kit"
	desc = "A bluespace-compressed medkit containing multiple medicinal medipens filled with various reagents. Useful in a pinch."
	item = /obj/item/storage/medkit/medipenkit
	cost = 2
	surplus = 35
	illegal_tech = FALSE

/datum/uplink_item/medical/combatmedipen
	name = "Combat Medipens"
	desc = "Three medipens loaded with 25 units of Omnizine and 5 units of Tranexamic Acid. Useful in a pinch."
	item = /obj/item/storage/medkit/emergency/combatmedipens
	cost = 3
	surplus = 40
	illegal_tech = FALSE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/medical/combistimpack
	name = "Chemical Combi-Stimpack Bag"
	desc = "A bag containing one combat medipen loaded with 25 units of Omnizine and 5 units of Tranexamic Acid. \
			Two cardiac combi-stimpacks loaded with epinephrine and saline-glucose solution, \
			Two bloodloss combi-stimpacks loaded with filgrastim and proconvertin, and \
			Two lifesupport combi-stimpacks loaded with salbutamol and mannitol. \
			Each combi-stimpack is 25 units of each chemical with 10 doses."
	item = /obj/item/storage/bag/chemistry/syndimedipens
	cost = 3
	surplus = 0
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/medical/combistimpackdeluxe
	name = "Deluxe Combi-Stimpack Bag"
	desc = "A bag containing three medipens loaded with 25 units of Omnizine and 5 units of Tranexamic Acid. \
			Two cardiac combi-stimpacks loaded with epinephrine and saline-glucose solution, \
			Two bloodloss combi-stimpacks loaded with filgrastim and proconvertin, and \
			Two lifesupport combi-stimpacks loaded with salbutamol and mannitol. \
			Each combi-stimpack is 25 units of each chemical with 10 doses."
	item = /obj/item/storage/bag/chemistry/syndimedipens/deluxe
	cost = 6
	surplus = 15
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/medical/restorationnaniteinjector
	name = "Restoration Nanite Injector"
	desc = "A single medipen loaded with 20u's of one of our most effective medical nanite strands to date. \
			It's capable of mending a large amount of damage of all types quickly, and mending many of your essential organs back together."
	item = /obj/item/reagent_containers/hypospray/medipen/restorationnaniteinjector
	cost = 3
	surplus = 60

/datum/uplink_item/medical/miraclesyringe
	name = "Miracle Syringe"
	desc = "Contains 5 units of nearly every effective medicine we could muster, included within are \
			bicaridine, dermaline, anti-toxin, omnizine, healing nanites, antihol, sanguirite, iron, and potassium iodide."
	item = /obj/item/reagent_containers/syringe/bluespace/miracle
	cost = 1
	surplus = 50
	illegal_tech = FALSE

/datum/uplink_item/medical/restore_nanite_kit
	name = "Restoration Nanite kit"
	desc = "A box containing 5 restoration nanite auto-injectors, when injected, they quickly heal the patients wounds \
			and mend many of their essential organs back together. More than enough for the whole squad in case of emergencies."
	item = /obj/item/storage/box/syndie_kit/restore_nanite_kit
	cost = 12
	surplus = 10
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	illegal_tech = FALSE

/datum/uplink_item/medical/stimpack
	name = "Stimpack"
	desc = "Stimpacks, the tool of many great heroes, make you nearly immune to stuns and knockdowns for about \
			5 minutes after injection. Additionally, it grants a 40% increase to grounded movement speed and \
			slight healing while injured but not in critical state."
	item = /obj/item/reagent_containers/hypospray/medipen/stimulants
	cost = 3
	surplus = 90

/datum/uplink_item/medical/experistimpack
	name = "Experimental Stimpack"
	desc = "One of our (in-development) Syndicate Stimpacks, they make you nearly immune to stuns and knockdowns for about 5 minutes after injection. \
			Additionally, it grants a 80% increase to grounded movement speed and 10% resistance to incoming brute and burn damage. Slowly heals brute and burn damage. \
			These drugs are POTENT and will slowly poison the host in addition to putting strain upon the heart. Refrain from using any more than 2 at a time."
	item = /obj/item/reagent_containers/hypospray/medipen/experistimulants
	cost = 5
	surplus = 50

/datum/uplink_item/medical/donkcostimpack
	name = "Donk Co. Stimpack"
	desc = "A certified Donk Co.(tm) Stimpack! Can be used up to SIX times to provide 160% increased movement speed, healing, \
			greater stun resistance, temporary blood restoration, quick oxyloss healing, and temperature stabilization. \
			Each dose only lasts around 10 seconds but the effects are POTENT. Side-effects may occur if more than one dose is used."
	item = /obj/item/reagent_containers/hypospray/medipen/donkcostim
	cost = 5
	surplus = 40

/datum/uplink_item/medical/juggernaut
	name = "Juggernaut Stimpack"
	desc = "The famous syndicate juggernaut stimpack, modeled after the even-more-famous regular stimpack, will nullify \
			all pain within the user and reduce incoming brute and burn damage by 20% while slowing healing those damage types."
	item = /obj/item/reagent_containers/hypospray/medipen/juggernaut
	cost = 8
	surplus = 65
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/medical/stimulant_kit
	name = "Stimpack kit"
	desc = "A box containing 5 random stimpacks, can include some stimpacks not normally available for sale."
	item = /obj/item/storage/box/syndie_kit/stimulant_kit
	cost = 15
	surplus = 30
	limited_stock = 1
	cant_discount = TRUE
	illegal_tech = FALSE
	progression_minimum = 20 MINUTES

/datum/uplink_item/medical/syndiecigs
	name = "Syndicate Smokes"
	desc = "Strong flavor, dense smoke, infused with omnizine."
	item = /obj/item/storage/fancy/cigarettes/cigpack_syndicate
	cost = 2
	illegal_tech = FALSE

/datum/uplink_item/medical/syndiecigsvarietypack
	name = "Syndicate Variety Cigarettes"
	desc = "Four different cigarette packs that resemble your regular nanotrasen approved brands. \
			Each packet of cigarettes contains one of the following: Salicylic Acid, Oxandrolone, Salbutamol, and Pentetic Acid."
	item = /obj/item/storage/medkit/syndiecigsvarietypack
	cost = 3
	surplus = 50
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	illegal_tech = FALSE

/datum/uplink_item/medical/syndiecigsvarietypackdeluxe
	name = "Syndicate Variety Cigarettes Deluxe Edition"
	desc = "Contains 9 cigarette packs that give up on stealth for increased benefits, but you get atleast 1 decent pack for healing brute, burn, toxins, and aspyxiation. \
			Additionally, we've included several other packs of cigarettes with varying useful chemicals. Also includes a lighter."
	item = /obj/item/storage/medkit/syndiecigsvarietypackdeluxe
	cost = 6
	surplus = 30
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	illegal_tech = FALSE

/datum/uplink_item/medical/eternalomnizine
	name = "Eternal Flask of Omnizine"
	desc = "A bottle that's only glass-like in appearance. The container itself harbors redspace technology \
			that will fill the container slowly over time with Omnizine for a maximum of 50 units."
	item = /obj/item/reagent_containers/cup/bottle/eternal/omnizine
	cost = 6
	surplus = 25

/datum/uplink_item/medical/mutationkit
	name = "Mutation Toxin Kit"
	desc = "A kit containing 8 syringes each filled with 15 units of a different mutation toxin. \
			Excellent for mulligan tactics or if you intend to benefit from a particular race's biology."
	item = /obj/item/storage/medkit/mutatekit
	cost = 4
	surplus = 35
	illegal_tech = FALSE

/datum/uplink_item/medical/enchantedgoldenapple
	name = "Enchanted Golden Apple"
	desc = "An extremely potent magical apple, rumored to have originated from another universe. It grants the one who eats it incredible regeneration, increased health, extreme resistance to fire, and resistance against all damage for 4 minutes."
	item = /obj/item/food/grown/apple/gold/notch/enchanted
	cost = 10
	surplus = 5
	illegal_tech = FALSE // NT and it's destructive analyzers likely can't figure this shit out. It's a magical apple.

/datum/uplink_item/medical/resurrector
	name = "Resurrector Nanite Serum"
	desc = "A single-use autoinjector which dispenses nanites designed and capable of restoring a corpse back to life very quickly. Has no effect on a living person. \
			You'll likely be using this to bring your fellow agents back from the grave. THE REAGENTS WITHIN WILL NOT REPAIR THE CORPSE -- SURGERY WILL BE REQUIRED."
	item = /obj/item/reagent_containers/hypospray/medipen/resurrector
	cost = 2
	surplus = 0
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/medical/syndihealvirus
	name = "Syndicate Augmented Healing Virus"
	desc = "A autoinjector filled with 5 units of blood. However, within that 5 units of blood contains our most powerful healing virus ever concieved. \
			Symptoms include: Nocturnal Regeneration, Tissue Hydration, Starlight Condensation, Plasma Fixation, Radioactive Resonance and Self-Respiration. \
			Not guaranteed to work if used directly on silicon-based humanoids such as androids but may persist through mutation."
	item = /obj/item/reagent_containers/hypospray/medipen/syndicatevirus
	cost = 8
	surplus = 5
	limited_stock = 1
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/medical/syndihealvirusnukie
	name = "Syndicate Augmented Healing Virus"
	desc = "A autoinjector filled with 5 units of blood. However, within that 5 units of blood contains our most powerful healing virus ever concieved. \
			Symptoms include: Nocturnal Regeneration, Tissue Hydration, Starlight Condensation, Plasma Fixation, Radioactive Resonance and Self-Respiration. \
			Not guaranteed to work if used directly on silicon-based humanoids such as androids but may persist through mutation."
	item = /obj/item/reagent_containers/hypospray/medipen/syndicatevirus
	cost = 15
	surplus = 0
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/medical/hackedhypo
	name = "Hacked Hypospray"
	desc = "A DeForest Medical brand hypospray, we've hacked the electronics for you -- disabling it's reagent dispensement limiter. \
			This hypospray is capable of injecting or spraying reagents in 30 unit amounts. \
			The hypospray's design was also modified to hold more reagents than normal."
	item = /obj/item/reagent_containers/hypospray/hacked
	cost = 4
	surplus = 40
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS | UPLINK_SPY) // The gorlex hypo is the better version fo this, spies should be forced to earn it. Why? Cuz' it's funny (and cool seeing as how tots cant get it)
	illegal_tech = TRUE

/datum/uplink_item/medical/gorlexhypo
	name = "Gorlex Hypospray"
	desc = "A Vahlen Pharmaceuticals brand hypospray, it's features include an expanded reagent container, the ability to dispense reagents quickly, \
			and comes filled with various healing chemicals. Has a diamond-tipped needle to penetrate armor."
	item = /obj/item/reagent_containers/hypospray/gorlex
	cost = 8
	surplus = 0
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	illegal_tech = TRUE
