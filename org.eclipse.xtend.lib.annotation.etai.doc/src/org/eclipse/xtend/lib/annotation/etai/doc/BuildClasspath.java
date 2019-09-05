package org.eclipse.xtend.lib.annotation.etai.doc;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

/**
 * <p>Builds concrete classpath by given prefixes (no concrete version) and saves
 * it in a properties file for usage in further ANT processing.</p>
 * 
 * <p>It searches for JAR files in a given directory using the given prefixes.</p>
 */
public class BuildClasspath {

	static public void main(String[] args) throws IOException {

		String outputFile = args[0];
		String propertyName = args[1];
		String baseDir = args[2];

		List<String> foundFiles = new ArrayList<String>();

		// retrieve folder and list all files
		File[] fileEntries = new File(baseDir).listFiles();

		for (int i = 3; i < args.length; i++) {

			String filePrefix = args[i];

			// search for file
			for (final File fileEntry : fileEntries) {
				if (fileEntry.isFile() && fileEntry.getName().startsWith(filePrefix)) {
					String completeFileName = baseDir + "/" + fileEntry.getName();
					completeFileName = completeFileName.replaceAll("\\\\", "/");
					foundFiles.add(completeFileName);
					break;
				}
			}

		}

		try (PrintWriter out = new PrintWriter(outputFile)) {
			out.println(propertyName + "cc=" + baseDir);
			out.println(propertyName + "=" + String.join(";", foundFiles));
		}

	}

}
