var/list/global/blend_items = list (
	//Sheets
	/obj/item/stack/sheet/mineral/plasma = list("plasma" = 20),
	/obj/item/stack/sheet/metal = list("iron" = 20),
	/obj/item/stack/sheet/plasteel = list("iron" = 20, "plasma" = 20),
	/obj/item/stack/sheet/mineral/wood = list("carbon" = 20),
	/obj/item/stack/sheet/glass = list("silicon" = 20),
	/obj/item/stack/sheet/rglass = list("silicon" = 20, "iron" = 20),
	/obj/item/stack/sheet/mineral/uranium = list("uranium" = 20),
	/obj/item/stack/sheet/mineral/bananium = list("banana" = 20),
	/obj/item/stack/sheet/mineral/silver = list("silver" = 20),
	/obj/item/stack/sheet/mineral/gold = list("gold" = 20),
	/obj/item/weapon/coin/gold = list("gold" = 4),
	/obj/item/weapon/coin/silver = list("silver" = 4),
	/obj/item/weapon/coin/iron = list("iron" = 4),
	/obj/item/weapon/coin/plasma = list("plasma" = 4),
	/obj/item/weapon/coin/uranium = list("uranium" = 4),
	/obj/item/weapon/coin/clown = list("banana" = 4),
	/obj/item/stack/sheet/bluespace_crystal = list("bluespace = 20"),
	/obj/item/weapon/ore/bluespace_crystal = list("bluespace = 20"), //This isn't a sheet actually, but you break it off
	
	//Crayons (for overriding colours)
	/obj/item/toy/crayon/red = list("redcrayonpowder" = 50),
	/obj/item/toy/crayon/orange = list("orangecrayonpowder" = 50),
	/obj/item/toy/crayon/yellow = list("yellowcrayonpowder" = 50),
	/obj/item/toy/crayon/green = list("greencrayonpowder" = 50),
	/obj/item/toy/crayon/blue = list("bluecrayonpowder" = 50),
	/obj/item/toy/crayon/purple = list("purplecrayonpowder" = 50),
	/obj/item/toy/crayon/mime = list("invisiblecrayonpowder" = 50),
	/obj/item/toy/crayon/rainbow = list("colorful_reagent" = 100),

	//Blender Stuff
	/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = list("soymilk" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("ketchup" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list("cornoil" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/wheat = list("flour" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/oat = list("flour" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = list("cherryjelly" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries = list("bluecherryjelly" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/egg = list("eggyolk" = 20),

	//Grinder stuff, but only if dry. Add it to the dried list below.
	/obj/item/weapon/reagent_containers/food/snacks/grown/coffee = list("coffeepowder" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea = list("teapowder" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),


	//Juicer Stuff
	/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list("corn_starch" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("tomatojuice" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = list("carrotjuice" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/berries = list("berryjuice" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana = list("banana" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato = list("potato" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon = list("lemonjuice" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange = list("orangejuice" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime = list("limejuice" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon = list("watermelonjuice" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = list("watermelonjuice" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/berries/poison = list("poisonberryjuice" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin = list("pumpkinjuice" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/blumpkin = list("blumpkinjuice" = 0),

	//Random Meme-tier stuff!!
	/obj/item/organ/butt = list("fartium" = 20),
	/obj/item/weapon/storage/book/bible = list("holywater" = 100)
)

var/list/global/dried_items = list(
	//Grinder stuff, but only if dry,
	/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/coffee = list("coffeepowder" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea = list("teapowder" = 0)
)
