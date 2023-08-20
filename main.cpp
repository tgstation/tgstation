#include <link.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>

struct DungServer {
	void* vtable = 0;
	char* sleepingProcs = 0;

	DungServer(void* vtable): vtable(vtable) {}
};

void receivedStatus(DungServer* server, char* message) {
	server->sleepingProcs = new char[strlen(message) + 1];
	strcpy(server->sleepingProcs, message);
}

typedef void (__attribute__((cdecl)) *DungServer_RequestStatus)(DungServer*);

extern "C" const char* get_status(int argc, char* argv[]) {
	void* handle = dlopen("libbyond.so", RTLD_NOW);
	if (!handle) {
		printf("error: could not open libbyond.so\n");
		return nullptr;
	}

	DungServer_RequestStatus requestStatus = reinterpret_cast<DungServer_RequestStatus>(dlsym(handle, "_ZN10DungServer13RequestStatusEv"));
	if (!requestStatus) {
		printf("error: could not find DungServer::RequestStatus\n");
		return nullptr;
	}

	void* vtable[26] = { 0 };
	vtable[25] = (void*)&receivedStatus;

	DungServer* dungServer = new DungServer(vtable);

	requestStatus(dungServer);

	return dungServer->sleepingProcs;
}
