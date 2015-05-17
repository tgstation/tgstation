var/global/list/datum/pipe_network/pipe_networks = list()
var/global/list/obj/machinery/atmospherics/atmos_machines = list()

/datum/controller/process/pipenet
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/pipenet/setup()
	name = "pipenet"


/datum/controller/process/pipenet/doWork()
	for(var/obj/machinery/atmospherics/atmosmachinery in atmos_machines)
		ASSERT(istype(atmosmachinery))
		if(!atmosmachinery.disposed)
			if(atmosmachinery.process())
				scheck()
	for(var/datum/pipe_network/pipeNetwork in pipe_networks)
		ASSERT(istype(pipeNetwork))
		if(!pipeNetwork.disposed)
			pipeNetwork.process()
			scheck()
			continue

		pipe_networks.Remove(pipeNetwork)
