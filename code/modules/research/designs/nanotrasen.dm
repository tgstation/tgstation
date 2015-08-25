/datum/design/hookshot
	name = "Hookshot"
	desc = "A very recent design, we're still far from finding out its full potential."
	id = "hookshot"
	req_tech = list("materials" = 2,"engineering" = 3,"magnets" = 2,"nanotrasen" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000)
	category = "Nanotrasen"
	build_path = /obj/item/weapon/gun/hookshot

/datum/design/ricochet
	name = "Ricochet Rifle"
	desc = "Here's a tip, get yourself an ablative armor before you start firing this one randomly."
	id = "ricochet"
	req_tech = list("materials" = 3,"powerstorage" = 3,"combat" = 3,"nanotrasen" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000, MAT_URANIUM = 1000)
	category = "Nanotrasen"
	build_path = /obj/item/weapon/gun/energy/ricochet
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/gravitywell
	name = "Gravity Well Gun"
	desc = "After years of studying the Singularity, our engineers have come up with a way to produce a similar graviational anomaly that automatically decays after a bit less than a minute. Use with extreme caution!"
	id = "gravitywell"
	req_tech = list("materials" = 7,"bluespace" = 5,"magnets" = 5,"nanotrasen" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 7000, MAT_GLASS = 5000, MAT_DIAMOND = 3000, MAT_SILVER = 7000, MAT_URANIUM = 12000)
	category = "Nanotrasen"
	build_path = /obj/item/weapon/gun/gravitywell
	locked = 1
	req_lock_access = list(access_rd)
