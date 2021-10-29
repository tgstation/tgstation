//Custom Holoimages//
/datum/preset_holoimage/spider
	nonhuman_mobtype = /mob/living/simple_animal/hostile/giant_spider

//Custom Holodisks//
/obj/item/disk/holodisk/woospider //No special markings on this disk, should be a fun maint loot surprise.
	preset_image_type = /datum/preset_holoimage/spider
	preset_record_text = {"
	NAME Spider
	DELAY 10
	SAY Woo
	DELAY 20"}
