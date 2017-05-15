/datum/export/plantmedicine
        cost = 2 //Gets multiplied based on healing chems inside of seed
        unit_name = Medicine
        export_types = list(/obj/item/weapon/reagent_containers/food/snacks/grown)

/datum/export/plantmed/get_cost(obj/O)
        var/obj/item/seeds/S = O
        if S.has_reagent("omnizine, 1)
                cost = S.reagents.get_reagent_amount("omnizine") * cost
                
        if S.has_reagent("earthsblood, 1)
                cost = S.reagents.get_reagent_amount("earthsblood") * cost
                
/datum/export/plantmed/sell_object(obj/O)
        if (SSshuttle.points >= 20000)
                cost = 0
