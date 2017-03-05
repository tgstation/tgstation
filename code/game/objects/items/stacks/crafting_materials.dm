//Basic materials with little use outside of crafting.
/obj/item/stack/crafting
	name = "crafting material"
	desc = "This shouldn't exist, but it's pretty cool."
	singular_name = "sheet"
	icon_state = "sheet-plastic"
	w_class = WEIGHT_CLASS_SMALL

///////////////
// Adhesives //
///////////////

/obj/item/stack/crafting/tape //Office tape is tier 1 tape and isn't very good. It can hold some things together.
	name = "office tape"
	desc = "Basic, weak tape used to stick papers to doors and not much else. Can hold things together, but not very well."
	singular_name = "piece"
	amount = 100
	max_amount = 100

/obj/item/stack/crafting/tape/random/Initialize()
	..()
	amount = rand(40, 60)

/obj/item/stack/crafting/tape/electrical //Eletrical tape is tier 2 tape and stronger than office tape. It's used in all electrical constructions, and not usually as a standalone adhesive.
	name = "electrical tape"
	desc = "Semi-strong tape used for patching up wires and such. Can hold things together decently."

/obj/item/stack/crafting/tape/electrical/random/Initialize()
	..()
	amount = rand(40, 60)

/obj/item/stack/crafting/tape/duct //Duct tape is tier 3 tape and is the strongest tape available.
	name = "duct tape"
	desc = "Fix-it-all tape used to fix everything but ducts. Holds things together as well as you might expect."

obj/item/stack/crafting/tape/duct/random/Initialize()
	..()
	amount = rand(40, 60)

/////////////////
// Electronics //
/////////////////

/obj/item/stack/crafting/circuit
	name = "simple circuit"
	desc = "A barebones motherboard used for very basic electronics work."
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	singular_name = "board"
	max_amount = 5

/obj/item/stack/crafting/circuit/complex
	name = "complex circuit"
	desc = "A standard motherboard used for electronics work."
	icon_state = "id_mod"

/obj/item/stack/crafting/circuit/advanced
	name = "advanced circuit"
	desc = "A complex motherboard used for advanced electronics work."
	icon_state = "card_mod"
