/* Runtime Condenser by Nodrak
 * Cleaned up and refactored by MrStonedOne
 * This will sum up identical runtimes into one, giving a total of how many times it occured. The first occurance
 * of the runtime will log the proc, source, usr and src, the rest will just add to the total. Infinite loops will
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
#include <string>
#include <sstream>
#include <unordered_map>
#include <vector>
#include <algorithm>

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
string lastLine = "";
string currentLine = "";
string nextLine = "";

//Stores lines we want to keep to print out
unordered_map<string,runtime*> storedRuntime;
unordered_map<string,runtime*> storedInfiniteLoop;
unordered_map<string,harddel*> storedHardDel;

//Stat tracking stuff for output
unsigned int totalRuntimes = 0;
unsigned int totalUniqueRuntimes = 0;
unsigned int totalInfiniteLoops = 0;
unsigned int totalUniqueInfiniteLoops = 0;
unsigned int totalHardDels = 0;
unsigned int totalUniqueHardDels = 0;

//Misc
runtime* currentRuntime = NULL; //for storing the current runtime when we want to read the extra info on the next lines.

//like substr, but returns an empty string if the string is smaller then start, rather then an exception.
inline string safe_substr(string S, size_t start = 0, size_t end = string::npos) {
	if (start > S.length())
		start = S.length();
	return S.substr(start, end);
}
inline void forward_progress(ifstream &inputFile) {
	lastLine = currentLine;
	currentLine	= nextLine;
	getline(inputFile, nextLine);
	//strip out any timestamps.
	if (nextLine.length() >= 10)
		if (nextLine[0] == '[' && nextLine[3] == ':' && nextLine[6] == ':' && nextLine[9] == ']')
			nextLine = nextLine.substr(10);
}	
bool readFromFile() {
	//Open file to read
	ifstream inputFile("Input.txt");

	if (inputFile.is_open()) {
		while (!inputFile.eof()) { //Until end of file
			//Update our lines
			forward_progress(inputFile);

			//After finding a new runtime, check to see if there are extra values to store
			if (currentRuntime) {
				//Skip ahead
				forward_progress(inputFile);

				//If we find this, we have new stuff to store
				if (safe_substr(nextLine, 2, 4) == "usr:") {
					//Skip ahead
					forward_progress(inputFile);
					
					//Store more info
					currentRuntime->source = lastLine;
					currentRuntime->usr = currentLine;
					currentRuntime->src = nextLine;
					
					//Skip ahead again
					forward_progress(inputFile);

					if (safe_substr(nextLine, 2, 8) == "src.loc:")
						currentRuntime->loc = nextLine;
					
				}
				currentRuntime = NULL;
			}

			//Found an infinite loop!
			if (safe_substr(currentLine, 0, 23) == "Infinite loop suspected" || safe_substr(currentLine, 0, 31) == "Maximum recursion level reached") {
				totalInfiniteLoops++;
				runtime* R = storedInfiniteLoop[currentLine];
				if (!R || R->text != currentLine) {
					R = new runtime;
					storedInfiniteLoop[currentLine] = R;
					R->text = currentLine;
					forward_progress(inputFile);
					R->proc = nextLine;
					R->count = 1;
					currentRuntime = R;
					totalUniqueInfiniteLoops++;
				} else { //existed already
					R->count++;
				}
				
			}
			//Found a runtime!
			else if (safe_substr(currentLine, 0, 14) == "runtime error:") {
				if (currentLine.length() <= 17) { //empty runtime, check next line.
					if (nextLine.length() < 2) //runtime is on the line before this one. (byond bug)
						nextLine = lastLine;
					forward_progress(inputFile);
					currentLine = "runtime error: " + currentLine;
				}
				totalRuntimes++;
				runtime* R = storedRuntime[currentLine];
				if (!R || R->text != currentLine) {
					R = new runtime;
					storedRuntime[currentLine] = R;
					R->text = currentLine;
					R->proc = nextLine;
					R->count = 1;
					currentRuntime = R;
					totalUniqueRuntimes++;
				} else { //existed already
					R->count++;
				}
			}
			
			//Found a hard del!
			else if (safe_substr(currentLine, 0, 7) == "Path : ") {
				string deltype = safe_substr(currentLine, 7);
				if (deltype.substr(deltype.size()-1,1) == " ") //some times they have a single trailing space.
					deltype = deltype.substr(0, deltype.size()-1);
				
				unsigned int failures = strtoul(safe_substr(nextLine, 11).c_str(), NULL, 10);
				if (failures <= 0)
					continue;
				
				totalHardDels += failures;
				harddel * D = storedHardDel[deltype];
				if (!D || D->type != deltype) {
					D = new harddel;
					storedHardDel[deltype] = D;
					D->type = deltype;
					D->count = failures;
					totalUniqueHardDels++;
				} else {
					D->count += failures;
				}
			}
		}
	} else {
		return false;
	}
	return true;
}
bool runtimeComp(const runtime* a, const runtime* b) {
    return a->count > b->count;
}

bool hardDelComp(const harddel* a, const harddel* b) {
    return a->count > b->count;
}
bool writeToFile() {
	//Open and clear the file
	ofstream outputFile("Output.txt", ios::trunc);

	if(outputFile.is_open()) {
		outputFile << "Note: The proc name, source file, src and usr are all from the FIRST of the identical runtimes. Everything else is cropped.\n\n";
		if(totalUniqueInfiniteLoops > 0)
			outputFile << "Total unique infinite loops: " << totalUniqueInfiniteLoops << endl;

		if(totalInfiniteLoops > 0) 
			outputFile << "Total infinite loops: " << totalInfiniteLoops << endl << endl;

		outputFile << "Total unique runtimes: " << totalUniqueRuntimes << endl;
		outputFile << "Total runtimes: " << totalRuntimes << endl << endl;
		if(totalUniqueHardDels > 0)
			outputFile << "Total unique hard deletions: " << totalUniqueHardDels << endl;

		if(totalHardDels > 0)
			outputFile << "Total hard deletions: " << totalHardDels << endl << endl;


		//If we have infinite loops, display them first.
		if(totalInfiniteLoops > 0) {
			vector<runtime*> infiniteLoops;
			infiniteLoops.reserve(storedInfiniteLoop.size());
			for (unordered_map<string,runtime*>::iterator it=storedInfiniteLoop.begin(); it != storedInfiniteLoop.end(); it++)
				infiniteLoops.push_back(it->second);
			sort(infiniteLoops.begin(), infiniteLoops.end(), runtimeComp);
			outputFile << "** Infinite loops **";
			for (int i=0; i < infiniteLoops.size(); i++) {
				runtime* R = infiniteLoops[i];
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
		vector<runtime*> runtimes;
		runtimes.reserve(storedRuntime.size());
		for (unordered_map<string,runtime*>::iterator it=storedRuntime.begin(); it != storedRuntime.end(); it++)
			runtimes.push_back(it->second);
		sort(runtimes.begin(), runtimes.end(), runtimeComp);
		for (int i=0; i < runtimes.size(); i++) {
			runtime* R = runtimes[i];
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
			vector<harddel*> hardDels;
			hardDels.reserve(storedHardDel.size());
			for (unordered_map<string,harddel*>::iterator it=storedHardDel.begin(); it != storedHardDel.end(); it++)
				hardDels.push_back(it->second);
			sort(hardDels.begin(), hardDels.end(), hardDelComp);
			for(int i=0; i < hardDels.size(); i++) {
				harddel* D = hardDels[i];
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
	char exit; //Used to stop the program from immediately exiting

	if(readFromFile()) {
		cout << "Input read successfully!\n";
	} else {
		cout << "Input failed to open, shutting down.\n";
		cout << "\nEnter any letter to quit.\n";
		cin >> exit;
		return 1;
	}



	if(writeToFile()) {
		cout << "Output was successful!\n";
		cout << "\nEnter any letter to quit.\n";
		cin >> exit;
		return 0;
	} else {
		cout << "The output file could not be opened, shutting down.\n";
		cout << "\nEnter any letter to quit.\n";
		cin >> exit;
		return 0;
	}

	return 0;
}
