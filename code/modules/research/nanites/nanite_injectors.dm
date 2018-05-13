//Names are intentionally all the same - track your nanites, or use a hand labeler
//This also means that you can give flesh melting nanites to your victims if you feel like it

/obj/item/reagent_containers/hypospray/medipen/nanite
	name = "nanite medipen"
	desc = "A medipen containing pattern nanites, that activate idle nanites inside the bloodstream. Can be programmed using a Nanite Programming Console."
	volume = 2
	amount_per_transfer_from_this = 2
	list_reagents = list("idle_nanites" = 2)

/obj/item/reagent_containers/hypospray/medipen/nanite/regenerative
	list_reagents = list("regenerative_nanites" = 2)

/obj/item/reagent_containers/hypospray/medipen/nanite/shock
	list_reagents = list("shock_nanites" = 2)

/obj/item/reagent_containers/hypospray/medipen/nanite/monitoring
	list_reagents = list("monitoring_nanites" = 2)

/obj/item/reagent_containers/hypospray/medipen/nanite/relay
	list_reagents = list("relay_nanites" = 2)