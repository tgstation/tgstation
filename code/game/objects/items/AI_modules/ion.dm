/*
CONTAINS:
/obj/item/ai_module/law/core/full/damaged
/obj/item/ai_module/law/toy_ai
*/

/obj/item/ai_module/law/core/full/damaged
	name = "damaged Core AI Module"
	desc = "An AI Module for programming laws to an AI. It looks slightly damaged."

/obj/item/ai_module/law/core/full/damaged/on_rack_install(obj/machinery/ai_law_rack/rack)
	laws += generate_ion_law()
	while(prob(75))
		laws += generate_ion_law()

/obj/item/ai_module/law/toy_ai // -- Incoming //No actual reason to inherit from ion boards here, either. *sigh* ~Miauw
	name = "toy AI"
	desc = "A little toy model AI core with real law uploading action!" //Note: subtle tell
	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "AI"
	laws = list("")

/obj/item/ai_module/law/toy_ai/apply_to_combined_lawset(datum/ai_laws/combined_lawset)
	combined_lawset.add_inherent_law(laws[1], 1)

/obj/item/ai_module/law/toy_ai/configure(mob/user)
	. = TRUE
	laws[1] = generate_ion_law()
	to_chat(user, span_notice("You press the button on [src]."))
	playsound(user, 'sound/machines/click.ogg', 20, TRUE)
	src.loc.visible_message(span_warning("[icon2html(src, viewers(loc))] [laws[1]]"))
