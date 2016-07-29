<<<<<<< HEAD
/* Runtime Condenser by Nodrak
 * Cleaned up and refactored by MrStonedOne
 * This will sum up identical runtimes into one, giving a total of how many times it occured. The first occurance
 * of the runtime will log the source, usr and src, the rest will just add to the total. Infinite loops will
 * also be caught and displayed (if any) above the list of runtimes.
 *
 * How to use:
 * 1) Copy and paste your list of runtimes from Dream Daemon into input.exe
 * 2) Run RuntimeCondenser.exe
 * 3) Open output.txt for a condensed report of the runtimes
 * 
 * How to compile:
 * Requires visual c++ compiler 2012 or any linux compiler with c++11 support.
 * Windows:
 *	Normal: cl.exe /EHsc /Ox /Qpar Main.cpp
 *	Debug: cl.exe /EHsc /Zi Main.cpp
 * Linux:
 *	Normal: g++ -O3 -std=c++11 Main.cpp -o rc
 *	Debug: g++ -g -Og -std=c++11 Main.cpp -o rc
 * Any Compile errors most likely indicate lack of c++11 support. Google how to upgrade or nag coderbus for help..
 */

#include <iostream>
#include <fstream>
#include <cstring>
#include <cstdio>
#include <string>
#include <sstream>
#include <unordered_map>
#include <vector>
#include <algorithm>
#include <ctime>


#define PROGRESS_FPS 10
#define PROGRESS_BAR_INNER_WIDTH 50
#define LINEBUFFER (512*1024) //512KiB

using namespace std;

struct runtime {
	string text;
	string proc;
	string source;
	string usr;
	string src;
	string loc;
	unsigned int count;
};
struct harddel {
	string type;
	unsigned int count;
};
//What we use to read input
string * lastLine = new string();
string * currentLine = new string();
string * nextLine = new string();

//Stores lines we want to keep to print out
unordered_map<string,runtime> storedRuntime;
unordered_map<string,runtime> storedInfiniteLoop;
unordered_map<string,harddel> storedHardDel;

//Stat tracking stuff for output
unsigned int totalRuntimes = 0;
unsigned int totalInfiniteLoops = 0;
unsigned int totalHardDels = 0;


bool endofbuffer = false;
//like substr, but returns an empty string if the string is smaller then start, rather then an exception.
inline string safe_substr(string * S, size_t start = 0, size_t end = string::npos) {
	if (start > S->length())
		start = S->length();
	return S->substr(start, end);
}
//getline() is slow as fucking balls. this is quicker because we prefill a buffer rather then read 1 byte at a time searching for newlines, lowering on i/o calls and overhead. (110MB/s vs 40MB/s on a 1.8GB file pre-filled into the disk cache)
//if i wanted to make it even faster, I'd use a reading thread, a new line searching thread, another thread or four for searching for runtimes in the list to see if they are unique, and finally the main thread for displaying the progress bar. but fuck that noise.
inline string * readline(FILE * f) {
	static char buf[LINEBUFFER];
	static size_t pos = 0;
	static size_t size = 0;

	for (size_t i = pos; i < LINEBUFFER; i++) {
		char c = buf[i];
		if (i >= size && (pos || i < LINEBUFFER-1)) {
			if (feof(f) || ferror(f))
				break;
			if (size && pos) { //move current stuff to start of buffer
				size -= pos;
				i -= pos;
				memmove(buf, &buf[pos], size);
			}
			//fill remaining buffer
			size += fread(&buf[i], 1, LINEBUFFER-size-1, f);
			pos = 0;
			c = buf[i];
		}
		if (c == '\n') {
			//trim off any newlines from the start
			while (i > pos && (buf[pos] == '\r' || buf[pos] == '\n'))
				pos++;
			string * s = new string(&buf[pos], i-pos);
			pos = i+1;
			return s;
		}
		
	}
	string * s = new string(&buf[pos], size-pos);
	pos = 0;
	size = 0;
	endofbuffer = true;
	return s;
}

inline void forward_progress(FILE * inputFile) {
	delete(lastLine);
	lastLine = currentLine;
	currentLine	= nextLine;
	nextLine = readline(inputFile);
	//strip out any timestamps.
	if (nextLine->length() >= 10) {
		if ((*nextLine)[0] == '[' && (*nextLine)[3] == ':' && (*nextLine)[6] == ':' && (*nextLine)[9] == ']')
			nextLine->erase(0, 10);
	}
}
//deallocates to, copys from to to.
inline void string_send(string * &from, string * &to) {
	delete(to);
	to = new string(*from);
}
inline void printprogressbar(unsigned short progress /*as percent*/) {
	double const modifer = 100.0L/(double)PROGRESS_BAR_INNER_WIDTH;
	size_t bars = (double)progress/modifer;
	cout << "\r[" << string(bars, '=') << ((progress < 100) ? ">" : "") << string(PROGRESS_BAR_INNER_WIDTH-(bars+((progress < 100) ? 1 : 0)), ' ') << "] " << progress << "%";
	cout.flush();
}

bool readFromFile() {
	//Open file to read
	FILE * inputFile = fopen("Input.txt", "r");

	if (ferror(inputFile))
		return false;

	fseek(inputFile, 0, SEEK_END);
	long long fileLength = ftell(inputFile);
	fseek(inputFile, 0, SEEK_SET);
	clock_t nextupdate = clock();
	if (feof(inputFile))
		return false; //empty file
	do {
		//Update our lines
		forward_progress(inputFile);
		//progress bar
		if (clock() >= nextupdate) {
			int dProgress = (int)(((long double)ftell(inputFile) / (long double)fileLength) * 100.0L);
			printprogressbar(dProgress);
			nextupdate = clock() + (CLOCKS_PER_SEC/PROGRESS_FPS);
		}
		//Found a runtime!
		if (safe_substr(currentLine, 0, 14) == "runtime error:") {
			if (currentLine->length() <= 17) { //empty runtime, check next line.
				//runtime is on the line before this one. (byond bug)
				if (nextLine->length() < 2) {
					string_send(lastLine, nextLine);
				}
				forward_progress(inputFile);
				string * tmp = new string("runtime error: " + *currentLine);
				string_send(tmp, currentLine);
				delete(tmp);
			}
			//we assign this to the right container in a moment.
			unordered_map<string,runtime> * storage_container;
			
			//runtime is actually an infinite loop
			if (safe_substr(currentLine, 15, 23) == "Infinite loop suspected" || safe_substr(currentLine, 15, 31) == "Maximum recursion level reached") {
				//use our infinite loop container.
				storage_container = &storedInfiniteLoop;
				totalInfiniteLoops++;
				// skip the line about world.loop_checks
				forward_progress(inputFile);
				string_send(lastLine, currentLine);
			} else {
				//use the runtime container
				storage_container = &storedRuntime;
				totalRuntimes++;
			}
			
			string key = *currentLine;
			bool procfound = false; //so other things don't have to bother checking for this again.
			if (safe_substr(nextLine, 0, 10) == "proc name:") {
				key += *nextLine;
				procfound = true;
			}
			
			//(get the address of a runtime from (a pointer to a container of runtimes)) to then store in a pointer to a runtime.
			//(and who said pointers were hard.)
			runtime* R = &((*storage_container)[key]);
			
			//new
			if (R->text != *currentLine) {
				R->text = *currentLine;
				if (procfound) {
					R->proc = *nextLine;
					forward_progress(inputFile);
				}
				R->count = 1;

				//search for source file info
				if (safe_substr(nextLine, 2, 12) == "source file:") {
					R->source = *nextLine;
					//skip again
					forward_progress(inputFile);
				}
				//If we find this, we have new stuff to store
				if (safe_substr(nextLine, 2, 4) == "usr:") {
					forward_progress(inputFile);
					forward_progress(inputFile);
					//Store more info
					R->usr = *lastLine;
					R->src = *currentLine;
					if (safe_substr(nextLine, 2, 8) == "src.loc:") {
						R->loc = *nextLine;
						forward_progress(inputFile);
					}
				}
			
			} else { //existed already
				R->count++;
				if (procfound)
					forward_progress(inputFile);
			}
			
		} else if (safe_substr(currentLine, 0, 7) == "Path : ") {
			string deltype = safe_substr(currentLine, 7);
			if (deltype.substr(deltype.size()-1,1) == " ") //some times they have a single trailing space.
				deltype = deltype.substr(0, deltype.size()-1);
			
			unsigned int failures = strtoul(safe_substr(nextLine, 11).c_str(), NULL, 10);
			if (failures <= 0)
				continue;
			
			totalHardDels += failures;
			harddel* D = &storedHardDel[deltype];
			if (D->type != deltype) {
				D->type = deltype;
				D->count = failures;
			} else {
				D->count += failures;
			}
		}
	} while (!feof(inputFile) || !endofbuffer); //Until end of file
	printprogressbar(100);
	cout << endl;
	return true;
}
bool runtimeComp(const runtime &a, const runtime &b) {
    return a.count > b.count;
}

bool hardDelComp(const harddel &a, const harddel &b) {
    return a.count > b.count;
}
bool writeToFile() {
	//Open and clear the file
	ofstream outputFile("Output.txt", ios::trunc);
	
	if(outputFile.is_open()) {
		outputFile << "Note: The source file, src and usr are all from the FIRST of the identical runtimes. Everything else is cropped.\n\n";
		if(storedInfiniteLoop.size() > 0)
			outputFile << "Total unique infinite loops: " << storedInfiniteLoop.size() << endl;

		if(totalInfiniteLoops > 0) 
			outputFile << "Total infinite loops: " << totalInfiniteLoops << endl << endl;

		outputFile << "Total unique runtimes: " << storedRuntime.size() << endl;
		outputFile << "Total runtimes: " << totalRuntimes << endl << endl;
		if(storedHardDel.size() > 0)
			outputFile << "Total unique hard deletions: " << storedHardDel.size() << endl;

		if(totalHardDels > 0)
			outputFile << "Total hard deletions: " << totalHardDels << endl << endl;


		//If we have infinite loops, display them first.
		if(storedInfiniteLoop.size() > 0) {
			vector<runtime> infiniteLoops;
			infiniteLoops.reserve(storedInfiniteLoop.size());
			for (unordered_map<string,runtime>::iterator it=storedInfiniteLoop.begin(); it != storedInfiniteLoop.end(); it++)
				infiniteLoops.push_back(it->second);
			storedInfiniteLoop.clear();
			sort(infiniteLoops.begin(), infiniteLoops.end(), runtimeComp);
			outputFile << "** Infinite loops **";
			for (int i=0; i < infiniteLoops.size(); i++) {
				runtime* R = &infiniteLoops[i];
				outputFile << endl << endl << "The following infinite loop has occurred " << R->count << " time(s).\n"; 
				outputFile << R->text << endl;
				if(R->proc.length()) 
					outputFile << R->proc << endl;
				if(R->source.length()) 
					outputFile << R->source << endl;
				if(R->usr.length()) 
					outputFile << R->usr << endl;
				if(R->src.length()) 
					outputFile << R->src << endl;
				if(R->loc.length()) 
					outputFile << R->loc << endl;
			}
			outputFile << endl << endl; //For spacing
		}


		//Do runtimes next
		outputFile << "** Runtimes **";
		vector<runtime> runtimes;
		runtimes.reserve(storedRuntime.size());
		for (unordered_map<string,runtime>::iterator it=storedRuntime.begin(); it != storedRuntime.end(); it++)
			runtimes.push_back(it->second);
		storedRuntime.clear();
		sort(runtimes.begin(), runtimes.end(), runtimeComp);
		for (int i=0; i < runtimes.size(); i++) {
			runtime* R = &runtimes[i];
			outputFile << endl << endl << "The following runtime has occurred " << R->count << " time(s).\n"; 
			outputFile << R->text << endl;
			if(R->proc.length()) 
				outputFile << R->proc << endl;
			if(R->source.length()) 
				outputFile << R->source << endl;
			if(R->usr.length()) 
				outputFile << R->usr << endl;
			if(R->src.length()) 
				outputFile << R->src << endl;
			if(R->loc.length()) 
				outputFile << R->loc << endl;
		}
		outputFile << endl << endl; //For spacing
		
		//and finally, hard deletes
		if(totalHardDels > 0) {
			outputFile << endl << "** Hard deletions **";
			vector<harddel> hardDels;
			hardDels.reserve(storedHardDel.size());
			for (unordered_map<string,harddel>::iterator it=storedHardDel.begin(); it != storedHardDel.end(); it++)
				hardDels.push_back(it->second);
			storedHardDel.clear();
			sort(hardDels.begin(), hardDels.end(), hardDelComp);
			for(int i=0; i < hardDels.size(); i++) {
				harddel* D = &hardDels[i];
				outputFile << endl << D->type << " - " << D->count << " time(s).\n";
			}
		}
		outputFile.close();
	} else {
		return false;
	}
	return true;
}

int main() {
	ios_base::sync_with_stdio(false);
	ios::sync_with_stdio(false);
	char exit; //Used to stop the program from immediately exiting
	cout << "Reading input.\n";
	if(readFromFile()) {
		cout << "Input read successfully!\n";
	} else {
		cout << "Input failed to open, shutting down.\n";
		cout << "\nEnter any letter to quit.\n";
		exit = cin.get();
		return 1;
	}


	cout << "Writing output.\n";
	if(writeToFile()) {
		cout << "Output was successful!\n";
		cout << "\nEnter any letter to quit.\n";
		exit = cin.get();
		return 0;
	} else {
		cout << "The output file could not be opened, shutting down.\n";
		cout << "\nEnter any letter to quit.\n";
		exit = cin.get();
		return 0;
	}

	return 0;
}
=======
/* Runtime Condenser by Nodrak
 * This will sum up identical runtimes into one, giving a total of how many times it occured. The first occurance
 * of the runtime will log the proc, source, usr and src, the rest will just add to the total. Infinite loops will
 * also be caught and displayed (if any) above the list of runtimes.
 *
 * How to use:
 * 1) Copy and paste your list of runtimes from Dream Daemon into input.exe
 * 2) Run RuntimeCondenser.exe
 * 3) Open output.txt for a condensed report of the runtimes
 */

#include <iostream>
#include <fstream>
#include <string>
using namespace std;

//Make all of these global. It's bad yes, but it's a small program so it really doesn't affect anything.
	//Because hardcoded numbers are bad :(
	const unsigned short maxStorage = 99; //100 - 1

	//What we use to read input
	string currentLine = "Blank";
	string nextLine = "Blank";

	//Stores lines we want to keep to print out
	string storedRuntime[maxStorage+1];
	string storedProc[maxStorage+1];
	string storedSource[maxStorage+1];
	string storedUsr[maxStorage+1];
	string storedSrc[maxStorage+1];

	//Stat tracking stuff for output
	unsigned int totalRuntimes = 0;
	unsigned int totalUniqueRuntimes = 0;
	unsigned int totalInfiniteLoops = 0;
	unsigned int totalUniqueInfiniteLoops = 0;

	//Misc
	unsigned int numRuntime[maxStorage+1]; //Number of times a specific runtime has occured
	bool checkNextLines = false; //Used in case byond has condensed a large number of similar runtimes
	int storedIterator = 0; //Used to remember where we stored the runtime

bool readFromFile()
{
	//Open file to read
	ifstream inputFile("input.txt");

	if(inputFile.is_open())
	{
		while(!inputFile.eof()) //Until end of file
		{
			//If we've run out of storage
			if(storedRuntime[maxStorage] != "Blank") break;

			//Update our lines
			currentLine	= nextLine;
			getline(inputFile, nextLine);

			//After finding a new runtime, check to see if there are extra values to store
			if(checkNextLines)
			{
				//Skip ahead
				currentLine = nextLine;
				getline(inputFile, nextLine);

				//If we find this, we have new stuff to store
				if(nextLine.find("usr:") != std::string::npos)
				{
					//Store more info
					storedSource[storedIterator] = currentLine;
					storedUsr[storedIterator] = nextLine;

					//Skip ahead again
					currentLine = nextLine;
					getline(inputFile, nextLine);

					//Store the last of the info
					storedSrc[storedIterator] = nextLine;
				}
				checkNextLines = false;
			}

			//Found an infinite loop!
			if(currentLine.find("Infinite loop suspected") != std::string::npos || currentLine.find("Maximum recursion level reached") != std::string::npos)
			{
				totalInfiniteLoops++;

				for(int i=0; i <= maxStorage; i++)
				{
					//We've already encountered this
					if(currentLine == storedRuntime[i])
					{
						numRuntime[i]++;
						break;
					}

					//We've never encoutnered this
					if(storedRuntime[i] == "Blank")
					{
						storedRuntime[i] = currentLine;
						currentLine = nextLine;
						getline(inputFile, nextLine); //Skip the "if this is not an infinite loop" line
						storedProc[i] = nextLine;
						numRuntime[i] = 1;
						checkNextLines = true;
						storedIterator = i;
						totalUniqueInfiniteLoops++;
						break;
					}
				}
			}
			//Found a runtime!
			else if(currentLine.find("runtime error:") != std::string::npos)
			{
				totalRuntimes++;
				for(int i=0; i <= maxStorage; i++)
				{
					//We've already encountered this
					if(currentLine == storedRuntime[i])
					{
						numRuntime[i]++;
						break;
					}

					//We've never encoutnered this
					if(storedRuntime[i] == "Blank")
					{
						storedRuntime[i] = currentLine;
						storedProc[i] = nextLine;
						numRuntime[i] = 1;
						checkNextLines = true;
						storedIterator = i;
						totalUniqueRuntimes++;
						break;
					}
				}
			}
		}
	}
	else
	{
		return false;
	}
	return true;
}

bool writeToFile()
{
	//Open and clear the file
	ofstream outputFile("Output.txt", ios::trunc);

	if(outputFile.is_open())
	{
		outputFile << "Note: The proc name, source file, src and usr are all from the FIRST of the identical runtimes. Everything else is cropped.\n\n";
		if(totalUniqueInfiniteLoops > 0)
		{
			outputFile << "Total unique infinite loops: " << totalUniqueInfiniteLoops << endl;
		}
		if(totalInfiniteLoops > 0)
		{
			outputFile << "Total infinite loops: " << totalInfiniteLoops << endl;
		}
		outputFile << "Total unique runtimes: " << totalUniqueRuntimes << endl;
		outputFile << "Total runtimes: " << totalRuntimes << endl << endl;

		//Display a warning if we've hit the maximum space we've allocated for storage
		if(totalUniqueRuntimes + totalUniqueInfiniteLoops >= maxStorage)
		{
			outputFile << "Warning: The maximum number of unique runtimes has been hit. If there were more, they have been cropped out.\n\n";
		}


		//If we have infinite loops, display them first.
		if(totalInfiniteLoops > 0)
		{
			outputFile << "** Infinite loops **";
			for(int i=0; i <= maxStorage; i++)
			{
				if(storedRuntime[i].find("Infinite loop suspected") != std::string::npos || storedRuntime[i].find("Maximum recursion level reached") != std::string::npos)
				{
					if(numRuntime[i] != 0) outputFile << endl << endl << "The following infinite loop has occured " << numRuntime[i] << " time(s).\n";
					if(storedRuntime[i] != "Blank") outputFile << storedRuntime[i] << endl;
					if(storedProc[i] != "Blank") outputFile << storedProc[i] << endl;
					if(storedSource[i] != "Blank") outputFile << storedSource[i] << endl;
					if(storedUsr[i] != "Blank") outputFile << storedUsr[i] << endl;
					if(storedSrc[i] != "Blank") outputFile << storedSrc[i] << endl;
				}
			}
			outputFile << endl << endl; //For spacing
		}


		//Do runtimes next
		outputFile << "** Runtimes **";
		for(int i=0; i <= maxStorage; i++)
		{
			if(storedRuntime[i].find("Infinite loop suspected") != std::string::npos || storedRuntime[i].find("Maximum recursion level reached") != std::string::npos) continue;

			if(numRuntime[i] != 0) outputFile << endl << endl << "The following runtime has occured " << numRuntime[i] << " time(s).\n";
			if(storedRuntime[i] != "Blank") outputFile << storedRuntime[i] << endl;
			if(storedProc[i] != "Blank") outputFile << storedProc[i] << endl;
			if(storedSource[i] != "Blank") outputFile << storedSource[i] << endl;
			if(storedUsr[i] != "Blank") outputFile << storedUsr[i] << endl;
			if(storedSrc[i] != "Blank") outputFile << storedSrc[i] << endl;
		}
		outputFile.close();
	}
	else
	{
		return false;
	}
	return true;
}

void sortRuntimes()
{
	string tempRuntime[maxStorage+1];
	string tempProc[maxStorage+1];
	string tempSource[maxStorage+1];
	string tempUsr[maxStorage+1];
	string tempSrc[maxStorage+1];
	unsigned int tempNumRuntime[maxStorage+1];
	unsigned int highestCount = 0; //Used for descending order
//	int keepLooping = 0;

	//Move all of our data into temporary arrays. Also clear the stored data (not necessary but.. just incase)
	for(int i=0; i <= maxStorage; i++)
	{
		//Get the largest occurance of a single runtime
		if(highestCount < numRuntime[i])
		{
			highestCount = numRuntime[i];
		}

		tempRuntime[i] = storedRuntime[i];	storedRuntime[i] = "Blank";
		tempProc[i] = storedProc[i];		storedProc[i] = "Blank";
		tempSource[i] = storedSource[i];	storedSource[i] = "Blank";
		tempUsr[i] = storedUsr[i];			storedUsr[i] = "Blank";
		tempSrc[i] = storedSrc[i];			storedSrc[i] = "Blank";
		tempNumRuntime[i] = numRuntime[i];	numRuntime[i] = 0;
	}

	while(highestCount > 0)
	{
		for(int i=0; i <= maxStorage; i++) //For every runtime
		{
			if(tempNumRuntime[i] == highestCount) //If the number of occurances of that runtime is equal to our current highest
			{
				for(int j=0; j <= maxStorage; j++) //Find the next available slot and store the info
				{
					if(storedRuntime[j] == "Blank") //Found an empty spot
					{
						storedRuntime[j] = tempRuntime[i];
						storedProc[j] = tempProc[i];
						storedSource[j] = tempSource[i];
						storedUsr[j] = tempUsr[i];
						storedSrc[j] = tempSrc[i];
						numRuntime[j] = tempNumRuntime[i];
						break;
					}
				}
			}
		}
		highestCount--; //Lower our 'highest' by one and continue
	}
}


int main() {
	char exit; //Used to stop the program from immediatly exiting

	//Start everything fresh. "Blank" should never occur in the runtime logs on its own.
	for(int i=0; i <= maxStorage; i++)
	{
		storedRuntime[i] = "Blank";
		storedProc[i] = "Blank";
		storedSource[i] = "Blank";
		storedUsr[i] = "Blank";
		storedSrc[i] = "Blank";
		numRuntime[i] = 0;

	}

	if(readFromFile())
	{
		cout << "Input read successfully!\n";
	}
	else
	{
		cout << "Input failed to open, shutting down.\n";
		cout << "\nEnter any letter to quit.\n";
		cin >> exit;
		return 1;
	}

	sortRuntimes();

	if(writeToFile())
	{
		cout << "Output was successful!\n";
		cout << "\nEnter any letter to quit.\n";
		cin >> exit;
		return 0;
	}
	else
	{
		cout << "The output file could not be opened, shutting down.\n";
		cout << "\nEnter any letter to quit.\n";
		cin >> exit;
		return 0;
	}

	return 0;
}
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
