/datum/uplink_item/bundles_tc/eng_bundle
	name = "Engineer-kit"
	desc = "Syndicate Bundles, also known as Engineer-Kits, are specialized groups of items that arrive in a plain crate. \
			This set contains a special syndicate engineer uniform, vest, glove, a belt with a pistol and wrench, \
			and deployable turret included in this crate. \
			The Syndicate will only provide one Syndi-Kit per agent."
	item = /obj/structure/closet/crate/syndieeng_bundle
	cost = 20
	stock_key = UPLINK_SHARED_STOCK_KITS
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)
