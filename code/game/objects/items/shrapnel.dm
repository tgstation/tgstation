

/obj/item/shrapnel
	name = "shrapnel shard"
	desc = "A wicked shard of metal, you'd hate to see what this could do to someone at high speeds."
	embedding = list(embed_chance=100, ignore_throwspeed_threshold=TRUE)
	custom_materials = list(/datum/material/iron=500)
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"

/obj/item/buckshot_ball
	name = "buckshot ball bearing"
	desc = "A small ball of metal that's been fired out of a shotgun."
	embedding = list(embed_chance=100, ignore_throwspeed_threshold=TRUE)
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"

/obj/projectile/shrapnel
	name = "flying shrapnel shard"
	desc = "HEADS UP!"
	projectile_payload_type = /obj/item/shrapnel

