GLOBAL_LIST_EMPTY_TYPED(compressor_recipe_previews, /image)

/datum/compressor_recipe
	var/list/required_oozes = list()
	var/obj/item/output_item
	var/created_amount = 1

/datum/compressor_recipe/crossbreed

/proc/create_compressor_previews()
	. = list()
	for(var/datum/compressor_recipe/recipe as anything in subtypesof(/datum/compressor_recipe))
		var/output_type = recipe::output_item
		if(!ispath(output_type, /obj/item))
			continue
		var/obj/item/preview = new output_type(null)
		.[recipe] = image(getFlatIcon(preview))
		qdel(preview)
