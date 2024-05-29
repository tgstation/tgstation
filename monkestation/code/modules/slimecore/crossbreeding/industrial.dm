// Ensure the output from an industrial extract is always layered below the extract
/obj/item/slimecross/industrial/do_after_spawn(obj/item/spawned)
	spawned.layer = min(spawned.layer, layer - 0.1)

/obj/item/slimecross/industrial/grey
	effect_desc = "Produces biocubes."
