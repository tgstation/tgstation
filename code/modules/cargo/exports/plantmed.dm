/datum/export/plantmedicine
        cost = 1 //Gets multiplied based on healing chems inside of seed
        unit_name = Medicine
        export_types = list(/obj/item/seeds)
        var/CurrentSupplyPoints

/datum/export/plantmed/get_cost(obj/O)
        var/obj/item/seeds/S = O
        
        S.has_reagent("omnizine, 1)
