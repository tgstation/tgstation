#include <Windows.h>

extern "C" _declspec(dllexport) void TerminateSelf() {
	TerminateProcess(GetCurrentProcess(), 0);
}