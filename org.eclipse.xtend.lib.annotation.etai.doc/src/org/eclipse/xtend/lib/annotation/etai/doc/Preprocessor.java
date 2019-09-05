package org.eclipse.xtend.lib.annotation.etai.doc;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

/**
 * <p>This preprocesor can parse a text file and resolve includes.</p>
 * 
 * <p>Format: [!include <filename>]</p>
 * 
 * <p>Specific includes for Pandoc (e.g. include_code) are supported as well. In this
 * case, additional steps for preprocessing are performed.</p>
 */
public class Preprocessor {

	static String readFile(String filename) throws IOException {

		List<String> lines = Files.readAllLines(Paths.get(filename), Charset.defaultCharset());
		return String.join("\r\n", lines);

	}

	static String preprocess(String data, String baseDir) throws IOException {

		int indexInclude;

		do {

			// search include part
			indexInclude = data.indexOf("[!include");
			if (indexInclude != -1) {

				// analyse include part
				int indexIncludeEnd = data.indexOf("]", indexInclude);
				String includeString = data.substring(indexInclude, indexIncludeEnd + 1);

				// check if it is a special include
				boolean isCodeFile = includeString.indexOf("!include_code") != -1;

				// load included file
				String filename = includeString.replaceAll("\\[\\!include(_code)? (.*)\\]", "$2");
				String loadedData = readFile(baseDir + File.separator + filename);

				// process special includes
				if (isCodeFile) {

					// separate different code segments
					String loadedCodeSegments[] = loadedData.split("---SPLIT---");

					loadedData = "";
					for (String loadedCodeSegment : loadedCodeSegments)
						loadedData += "```java\r\n" + loadedCodeSegment.trim() + "\r\n```\r\n";

				}

				// include loaded file
				data = data.substring(0, indexInclude) + loadedData
						+ data.substring(indexIncludeEnd + 1, data.length());

			}

		} while (indexInclude != -1);

		return data;

	}

	static public void main(String[] args) throws IOException {

		String inputDir = args[0];
		String outputDir = args[1];
		String filename = args[2];

		try (PrintWriter out = new PrintWriter(outputDir + File.separator + filename)) {
			out.println(preprocess(readFile(inputDir + File.separator + filename), inputDir));
		}

	}

}
