// 20 of every ore.
/obj/structure/ore_box/hax
	New()
		..()
		for(var/ore_id in materials.storage)
			materials.addAmount(ore_id, 20)