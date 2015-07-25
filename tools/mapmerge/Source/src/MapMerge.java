import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.Reader;
import java.nio.charset.Charset;
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
			String to_save = selected_map + ".temp";
			String[] passInto = { "-clean", backup_map, edited_map, to_save };
			MapPatcher.main(passInto);
			System.out.println("MapMerge has finished, starting tgm conversion.");
			MapMerge.dmm2tgm(selected_map);
			System.out.println("Finished with tgm conversion.");
		}
	}
	

	public static void dmm2tgm(String file) throws IOException {
		Charset encoding = Charset.defaultCharset();
		File selected_map = new File(file);
		PrintWriter writer = new PrintWriter(selected_map);
		try {
			InputStream in = new FileInputStream(selected_map + ".temp");
			Reader reader = new InputStreamReader(in, encoding);
			Reader buffer = new BufferedReader(reader);
			int char_index;
			while ((char_index = buffer.read()) != -1) {
				char ch = (char) char_index;
				
				if (ch == '(') {
					writer.print(ch + "\n\t");
				} else if(ch ==')'){
					writer.print(ch + "\n");
				}else if (ch == '{') {
					writer.print(ch + "\n\t\t");
				} else if (ch == '}') {
					writer.print("\n\t" + ch);
				} else if (ch == ',') {
					writer.print(ch + "\n\t");
				} else if (ch == ';') {
					writer.print(ch + "\n\t");
				} else {
					writer.print(ch);
				}
			}
			
			writer.close();
			buffer.close();
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println(
					"Something went wrong with conversion to tgm, the map has still been merged and can be found in the .temp file.");
		}
	}
}