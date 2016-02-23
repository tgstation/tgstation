import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;

public class FileFinder extends SimpleFileVisitor<Path> {
	private PathMatcher matcher;
	public ArrayList<Path> foundPaths = new ArrayList<>();
	public FileFinder(String pattern) {
		matcher = FileSystems.getDefault().getPathMatcher("glob:" + pattern);
	}
	
	@Override
	public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
		Path name = file.getFileName();
		if (matcher.matches(name)) {
			foundPaths.add(file);
		}
		return FileVisitResult.CONTINUE;
	}
}