var/global/list/datum/pipe_network/pipe_networks = list()
var/global/list/obj/machinery/atmospherics/atmos_machines = list()
var/event/on_pipenet_tick = new()

/datum/controller/process/pipenet
	schedule_interval = 29 // every 2 seconds

/datum/controller/process/pipenet/setup()
	name = "pipenet"
	global.on_pipenet_tick.holder = src

/datum/controller/process/pipenet/doWork()
	INVOKE_EVENT(global.on_pipenet_tick, list())
	for(var/obj/machinery/atmospherics/atmosmachinery in atmos_machines)
		if(istype(atmosmachinery))
			if(!atmosmachinery.disposed && !atmosmachinery.timestopped)
				if(atmosmachinery.process())
					scheck()
			continue
		atmos_machines -= atmosmachinery
	for(var/datum/pipe_network/pipeNetwork in pipe_networks)
		if(istype(pipeNetwork))
			if(!pipeNetwork.disposed)
				pipeNetwork.process()
				scheck()
				continue

		pipe_networks.Remove(pipeNetwork)
