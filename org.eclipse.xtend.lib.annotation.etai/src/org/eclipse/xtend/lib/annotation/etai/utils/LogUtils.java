package org.eclipse.xtend.lib.annotation.etai.utils;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import org.eclipse.xtend.lib.macro.services.Problem.Severity;

/**
 * <p>Utility class providing logging support.</p>
 */
public class LogUtils {

	// this setting can be changed in order to enable logging
	static String STANDARD_LOG_FILE = null;
	static int FILE_CLOSER_WAIT_TIME_MS = 10000;

	static int CURRENT_INDENTATION = 0;
	static Map<String, Writer> OPEN_FILE_WRITERS = new HashMap<String, Writer>();
	static Thread FILE_CLOSER_THREAD = null;
	static SimpleDateFormat DATE_FORMATTER = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
	static Date LAST_LOG = new Date();

	/**
	 * <p>Returns the session if of the current logging.</p>
	 */
	protected static String getSessionID() {
		return String.valueOf(System.identityHashCode(OPEN_FILE_WRITERS));
	}

	/**
	 * <p>Returns the session if of the current logging.</p>
	 */
	protected static String getLoggingPreamble() {

		String result = DATE_FORMATTER.format(new Date()) + " (SID: " + String.format("%1$10s", getSessionID())
				+ ", TID: " + String.format("%1$10s", Thread.currentThread().getId()) + ") --- ";

		for (int i = 0; i < getCurrentIndentation(); i++)
			result += ".";

		return result;

	}

	/**
	 * <p>Changes the indentation for the logging.</p>
	 */
	public static void changeIndentation(int delta) {

		if (CURRENT_INDENTATION + delta < 0)
			throw new IllegalStateException("Cannot change indentation to a value lower 0");

		CURRENT_INDENTATION += delta;

	}

	/**
	 * <p>Returns the current indentation.</p>
	 */
	public static int getCurrentIndentation() {

		return CURRENT_INDENTATION;

	}

	/**
	 * <p>Appends the given log message to the given file which is specified by the
	 * fully qualified name.</p>
	 */
	public static void logToFile(String filename, Severity logLevel, String message) {

		// either thread or this logging mechanism accesses files
		synchronized (OPEN_FILE_WRITERS) {

			// create thread which periodically closes open files
			if (FILE_CLOSER_THREAD == null) {

				FILE_CLOSER_THREAD = new Thread() {

					@Override
					public void run() {

						for (;;) {

							// sleep for some milliseconds
							try {
								Thread.sleep(600);
							} catch (InterruptedException e) {
								e.printStackTrace();
							}

							synchronized (OPEN_FILE_WRITERS) {

								// stop logging if nothing has been logged for
								// a longer time
								if ((new Date()).getTime() - LAST_LOG.getTime() >= FILE_CLOSER_WAIT_TIME_MS) {

									// close files
									for (Entry<String, Writer> openFileWriterEntry : OPEN_FILE_WRITERS.entrySet()) {
										Writer fileWriter = openFileWriterEntry.getValue();
										try {

											// write line that logging has
											// stopped
											fileWriter.write(getLoggingPreamble()
													+ " *** Logging has stopped (no more logging activity) ***\r\n");

											fileWriter.flush();

											fileWriter.close();

										} catch (IOException e) {
											e.printStackTrace();
										}
									}

									// reset open file writers and thread
									OPEN_FILE_WRITERS.clear();
									FILE_CLOSER_THREAD = null;

									return;

								}

							}

						}

					}
				};

				// start thread
				FILE_CLOSER_THREAD.start();

			}

			// check if there is already a writer in the cache
			Writer fileWriter = OPEN_FILE_WRITERS.get(filename);

			try {

				// open file for writing if not open, yet
				if (fileWriter == null) {

					// open file (buffered)
					File logFile = new File(filename);
					fileWriter = new BufferedWriter(new FileWriter(logFile, true));

					// put writer into cache
					OPEN_FILE_WRITERS.put(filename, fileWriter);

					// write line that logging has started
					fileWriter.write(getLoggingPreamble() + " *** Logging has started ***\r\n");

				}

				// write new line (log)
				fileWriter.write(getLoggingPreamble() + message + "\r\n");

				fileWriter.flush();

				// remember time of the last log
				LAST_LOG = new Date();

			} catch (IOException e) {

				e.printStackTrace();

			}

		}

	}

	/**
	 * <p>Appends the given log message to the standard log file. This method will do
	 * not log anything if no standard file has been configured.</p>
	 */
	public static void log(Severity logLevel, String message) {
		if (STANDARD_LOG_FILE != null && !STANDARD_LOG_FILE.isEmpty())
			logToFile(STANDARD_LOG_FILE, logLevel, message);
	}

}
