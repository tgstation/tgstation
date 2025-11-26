/*
CONTAINS:
/obj/item/ai_module/law/core/full/damaged
/obj/item/ai_module/law/toy_ai
*/

/obj/item/ai_module/law/core/full/damaged
	name = "damaged Core AI Module"
	desc = "An AI Module for programming laws to an AI. It looks slightly damaged."

/obj/item/ai_module/law/core/full/damaged/Initialize(mapload)
	. = ..()
	set_ioned(TRUE)

/obj/item/ai_module/law/core/full/damaged/proc/gen_laws()
	laws.Cut()
	laws += generate_ion_law()
	while(prob(75))
		laws += generate_ion_law()

/obj/item/ai_module/law/core/full/damaged/on_rack_install(obj/machinery/ai_law_rack/rack)
	gen_laws()

/obj/item/ai_module/law/core/full/damaged/multitool_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "repairing ion damage..?")
	if(!tool.use_tool(src, user, 4 SECONDS, volume = 25))
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "module repaired..?")
	gen_laws()
	if(istype(loc, /obj/machinery/ai_law_rack))
		var/obj/machinery/ai_law_rack/rack = loc
		rack.update_lawset()
	return ITEM_INTERACT_SUCCESS

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
