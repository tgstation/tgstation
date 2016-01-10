import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Scanner;

public class MapMerge {

	private static Scanner input = new Scanner(System.in);
	private static Path pathToMaps;

	public static void main(String[] mapPath) throws IOException {
		pathToMaps = Paths.get(mapPath[0]);
		FileFinder dmmFinder = new FileFinder("*.dmm");
		Files.walkFileTree(pathToMaps, dmmFinder);
		ArrayList<Path> foundFiles = dmmFinder.foundPaths;
		if (foundFiles.size() > 0) {
			try {
				MapMerge.merge(foundFiles);
			} catch (Exception e) {
				System.out.println("Something went wrong.");
				e.printStackTrace();
			}
		} else {
			System.out.println("No files were found in provided directory!");
			System.out.print("Path to maps folder: ");
			pathToMaps = Paths.get(input.nextLine());
			dmmFinder = new FileFinder("*.dmm");
			Files.walkFileTree(pathToMaps, dmmFinder);
			foundFiles = dmmFinder.foundPaths;
			try {
				MapMerge.merge(foundFiles);
			} catch (Exception e) {
				System.out.println("Something went wrong.");
				e.printStackTrace();
			}
		}
	}

	public static void merge(ArrayList<Path> foundFiles) throws IOException {

		System.out.println("How many files do you want to merge?");
		int selection1;
		inputCheck: while (true) {
			while (!input.hasNextInt()) {
				String temp = input.next();
				System.out.println(temp + " is not a valid int.");
			}
			selection1 = input.nextInt();
			if (selection1 < 0) {
				System.out.println("Use a number greater than 0!");
				continue inputCheck;
			} else {
				break inputCheck;
			}
		}

		for (int numOfFiles = selection1; numOfFiles != 0; numOfFiles--) {

			for (int num = 0; num < foundFiles.size(); num++) {
				System.out.println(num + ": " + foundFiles.get(num));
			}

			System.out.print("File to use: ");
			int selection2;
			inputCheck: while (true) {
				while (!input.hasNextInt()) {
					String temp = input.next();
					System.out.println(temp + " is not a valid int.");
				}
				selection2 = input.nextInt();
				if ((selection2 < 0) || (selection2 >= foundFiles.size())) {
					if (selection2 < 0) {
						System.out.println("Use a number greater than 0!");
					} else {
						System.out.println("Use a number less than " + foundFiles.size() + "!");
					}
					continue inputCheck;
				} else {
					break inputCheck;
				}
			}

			String selected_map = foundFiles.get(selection2) + "";
			String backup_map = selected_map + ".backup";
			String edited_map = selected_map;
			String to_save = selected_map;
			String[] passInto = { "-clean", backup_map, edited_map, to_save };
			MapPatcher.main(passInto);
			
			// Will try to fix when I have time ~CorruptComputer
			/*try{
				Process process = new ProcessBuilder("dmm2tgm\\dmm2tgm.exe", selected_map).start();
			}catch(Exception e1){
				System.out.println("You are not on a windows machine, trying the .py");
				try{
					Process process = new ProcessBuilder("dmm2tgm\\Source\\dmm2tgm.py", selected_map).start();
				}catch(Exception e2){
					System.out.println("You do not have python 2.7.x installed.");
					System.out.println("Downloads can be found here: https://www.python.org/downloads/");
				}
			}
			*/
			
		}
	}
}