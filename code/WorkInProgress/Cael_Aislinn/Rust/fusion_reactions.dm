datum/fusion_reaction
	var/primary_reactant = ""
	var/secondary_reactant = ""
	var/energy_consumption = 0
	var/energy_production = 0
	var/radiation = 0
	var/list/products = list()

/datum/controller/game_controller/var/list/fusion_reactions

proc/get_fusion_reaction(var/primary_reactant, var/secondary_reactant)
	if(!master_controller.fusion_reactions)
		populate_fusion_reactions()
	if(master_controller.fusion_reactions.Find(primary_reactant))
		var/list/secondary_reactions = master_controller.fusion_reactions[primary_reactant]
		if(secondary_reactions.Find(secondary_reactant))
			return master_controller.fusion_reactions[primary_reactant][secondary_reactant]

proc/populate_fusion_reactions()
	if(!master_controller.fusion_reactions)
		master_controller.fusion_reactions = list()
		for(var/cur_reaction_type in typesof(/datum/fusion_reaction) - /datum/fusion_reaction)
			var/datum/fusion_reaction/cur_reaction = new cur_reaction_type()
			if(!master_controller.fusion_reactions[cur_reaction.primary_reactant])
				master_controller.fusion_reactions[cur_reaction.primary_reactant] = list()
			master_controller.fusion_reactions[cur_reaction.primary_reactant][cur_reaction.secondary_reactant] = cur_reaction
			if(!master_controller.fusion_reactions[cur_reaction.secondary_reactant])
				master_controller.fusion_reactions[cur_reaction.secondary_reactant] = list()
			master_controller.fusion_reactions[cur_reaction.secondary_reactant][cur_reaction.primary_reactant] = cur_reaction

//Fake elements and fake reactions, but its nicer gameplay-wise
//Deuterium
//Tritium
//Uridium-3
//Obdurium
//Solonium
//Rodinium-6
//Dilithium
//Trilithium
//Pergium
//Stravium-7

//Primary Production Reactions

datum/fusion_reaction/tritium_deuterium
	primary_reactant = "Tritium"
	secondary_reactant = "Deuterium"
	energy_consumption = 1
	energy_production = 5
	radiation = 0

//Secondary Production Reactions

datum/fusion_reaction/deuterium_deuterium
	primary_reactant = "Deuterium"
	secondary_reactant = "Deuterium"
	energy_consumption = 1
	energy_production = 4
	radiation = 1
	products = list("Obdurium" = 2)

datum/fusion_reaction/tritium_tritium
	primary_reactant = "Tritium"
	secondary_reactant = "Tritium"
	energy_consumption = 1
	energy_production = 4
	radiation = 1
	products = list("Solonium" = 2)

//Cleanup Reactions

datum/fusion_reaction/rodinium6_obdurium
	primary_reactant = "Rodinium-6"
	secondary_reactant = "Obdurium"
	energy_consumption = 1
	energy_production = 2
	radiation = 2

datum/fusion_reaction/rodinium6_solonium
	primary_reactant = "Rodinium-6"
	secondary_reactant = "Solonium"
	energy_consumption = 1
	energy_production = 2
	radiation = 2

//Breeder Reactions

datum/fusion_reaction/dilithium_obdurium
	primary_reactant = "Dilithium"
	secondary_reactant = "Obdurium"
	energy_consumption = 1
	energy_production = 1
	radiation = 3
	products = list("Deuterium" = 1, "Dilithium" = 1)

datum/fusion_reaction/dilithium_solonium
	primary_reactant = "Dilithium"
	secondary_reactant = "Solonium"
	energy_consumption = 1
	energy_production = 1
	radiation = 3
	products = list("Tritium" = 1, "Dilithium" = 1)

//Breeder Inhibitor Reactions

datum/fusion_reaction/stravium7_dilithium
	primary_reactant = "Stravium-7"
	secondary_reactant = "Dilithium"
	energy_consumption = 2
	energy_production = 1
	radiation = 4

//Enhanced Breeder Reactions

datum/fusion_reaction/trilithium_obdurium
	primary_reactant = "Trilithium"
	secondary_reactant = "Obdurium"
	energy_consumption = 1
	energy_production = 2
	radiation = 5
	products = list("Dilithium" = 1, "Trilithium" = 1, "Deuterium" = 1)

datum/fusion_reaction/trilithium_solonium
	primary_reactant = "Trilithium"
	secondary_reactant = "Solonium"
	energy_consumption = 1
	energy_production = 2
	radiation = 5
	products = list("Dilithium" = 1, "Trilithium" = 1, "Tritium" = 1)

//Control Reactions

datum/fusion_reaction/pergium_deuterium
	primary_reactant = "Pergium"
	secondary_reactant = "Deuterium"
	energy_consumption = 5
	energy_production = 0
	radiation = 5

datum/fusion_reaction/pergium_tritium
	primary_reactant = "Pergium"
	secondary_reactant = "Tritium"
	energy_consumption = 5
	energy_production = 0
	radiation = 5

datum/fusion_reaction/pergium_deuterium
	primary_reactant = "Pergium"
	secondary_reactant = "Obdurium"
	energy_consumption = 5
	energy_production = 0
	radiation = 5

datum/fusion_reaction/pergium_tritium
	primary_reactant = "Pergium"
	secondary_reactant = "Solonium"
	energy_consumption = 5
	energy_production = 0
	radiation = 5
