package org.daisy.pipeline.braille.liblouis.internal;

import java.io.File;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import static org.daisy.pipeline.braille.Utilities.Files.chmod775;
import static org.daisy.pipeline.braille.Utilities.Files.fileFromURL;
import static org.daisy.pipeline.braille.Utilities.Files.unpack;
import static org.daisy.pipeline.braille.Utilities.Strings.join;

import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;
import org.daisy.pipeline.braille.liblouis.Liblouisutdml;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LiblouisutdmlJniImpl implements Liblouisutdml {

	private final Iterable<URL> jarURLs;
	private final File nativeDirectory;
	private final LiblouisTableResolver tableResolver;
	private Object liblouisutdml;
	private Method setWriteablePath;
	private Method translateFile;
	private boolean loaded = false;
	
	public LiblouisutdmlJniImpl(Iterable<URL> jarURLs, Iterable<URL> nativeURLs, File unpackDirectory, LiblouisTableResolver tableResolver) {
		this.jarURLs = jarURLs;
		Iterator<URL> nativeURLsIterator = nativeURLs.iterator();
		if (!nativeURLsIterator.hasNext())
			throw new IllegalArgumentException("Argument nativeURLs must not be empty");
		for (File file : unpack(nativeURLsIterator, unpackDirectory))
			if (!file.getName().endsWith(".dll")) chmod775(file);
		nativeDirectory = unpackDirectory;
		this.tableResolver = tableResolver;
	}
	
	public LiblouisutdmlJniImpl load() {
		if (!loaded) {
			try {
				ClassLoader classLoader = new LiblouisutdmlJniClassLoader(jarURLs, nativeDirectory);
				Class<?> liblouisutdmlClass = classLoader.loadClass("org.liblouis.liblouisutdml");
				liblouisutdml = liblouisutdmlClass.getMethod("getInstance").invoke(null);
				setWriteablePath = liblouisutdmlClass.getMethod("setWriteablePath", String.class);
				translateFile = liblouisutdmlClass.getMethod("translateFile", String.class,
						String.class, String.class, String.class, String.class, int.class);
				logger.debug("Loading liblouisutdml service"); }
			catch (Exception e) {
				throw new RuntimeException("Could not load liblouisutdml service", e); }
			loaded = true; }
		return this;
	}
	
	public void unload() {
		if (!loaded) return;
		liblouisutdml = null;
		setWriteablePath = null;
		translateFile = null;
		System.gc();
		loaded = false;
	}
	
	/**
	 * {@inheritDoc}
	 */
	public void translateFile(
			List<String> configFiles,
			List<String> semanticFiles,
			URL table,
			Map<String,String> otherSettings,
			File input,
			File output,
			File configPath,
			File tempDir) {
		
		if (!loaded) load();
		
		try {
			
			if (configPath == null)
				configPath = tempDir;
			if (!Arrays.asList(configPath.list()).contains("liblouisutdml.ini"))
				throw new RuntimeException("liblouisutdml.ini must be on the configPath");
			if (configFiles != null)
				configFiles.remove("liblouisutdml.ini");
			
			String configFileList = configPath.getAbsolutePath() + File.separator +
					(configFiles != null ? join(configFiles, ",") : "");
			String inputFileName = input.getAbsolutePath();
			String outputFileName = output.getAbsolutePath();
			
			Map<String,String> settings = new HashMap<String,String>();
			if (semanticFiles != null)
				settings.put("semanticFiles", join(semanticFiles, ","));
			String tablePath = fileFromURL(tableResolver.resolveTable(table)).getCanonicalPath();
			settings.put("literaryTextTable", tablePath);
			settings.put("editTable", tablePath);
			if (otherSettings != null)
				settings.putAll(otherSettings);
			List<String> settingsList = new ArrayList<String>();
			for (String key : settings.keySet())
				settingsList.add(key + " " + settings.get(key));
			
			logger.debug("liblouisutdml conversion:" +
			"\n   configFiles: " + configFileList +
			"\n   inputFile: " + inputFileName +
			"\n   outputFile: " + outputFileName +
			"\n   settings: " + join(settingsList, " "));
			
			setWriteablePath.invoke(liblouisutdml, tempDir.getAbsolutePath());
			translateFile.invoke(liblouisutdml, configFileList, inputFileName, outputFileName,
					null, join(settingsList, "\n"), 0); }
		catch (Exception e) {
			throw new RuntimeException("Error during liblouisutdml conversion", e); }
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LiblouisutdmlJniImpl.class);
}