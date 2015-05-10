var/global/list/datum/pipe_network/pipe_networks = list()
var/global/list/obj/machinery/atmospherics/atmos_machines = list()

/datum/controller/process/pipenet/setup()
	name = "pipenet"
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/pipenet/doWork()
	//world << atmos_machines.len
	for(var/obj/machinery/atmosmachinery in atmos_machines)
		//world << "processing [atmosmachinery]"
		ASSERT(istype(atmosmachinery) || istype(atmosmachinery, /obj/machinery/portable_atmospherics))
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
