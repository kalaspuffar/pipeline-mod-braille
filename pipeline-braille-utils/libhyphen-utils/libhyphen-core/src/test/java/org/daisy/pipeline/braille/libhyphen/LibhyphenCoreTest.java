package org.daisy.pipeline.braille.libhyphen;

import javax.inject.Inject;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.bundlesAndDependencies;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.forThisPlatform;
import static org.daisy.pipeline.pax.exam.Options.logbackBundles;
import static org.daisy.pipeline.pax.exam.Options.logbackConfigFile;
import static org.daisy.pipeline.pax.exam.Options.thisBundle;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertEquals;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

import static org.ops4j.pax.exam.CoreOptions.bundle;
import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.mavenBundle;
import static org.ops4j.pax.exam.CoreOptions.options;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class LibhyphenCoreTest {
	
	@Inject
	LibhyphenHyphenator.Provider provider;
	
	@Test
	public void testHyphenate() {
		assertEquals("foo\u00ADbar", provider.get("(table:'foobar.dic')").iterator().next().transform("foobar"));
		assertEquals("foo-\u200Bbar", provider.get("(table:'foobar.dic')").iterator().next().transform("foo-bar"));
	}
	
	@Configuration
	public Option[] config() {
		return options(
			logbackConfigFile(),
			domTraversalPackage(),
			logbackBundles(),
			felixDeclarativeServices(),
			mavenBundle().groupId("com.google.guava").artifactId("guava").versionAsInProject(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.daisy.bindings").artifactId("jhyphen").versionAsInProject(),
			mavenBundle().groupId("org.apache.servicemix.bundles").artifactId("org.apache.servicemix.bundles.antlr-runtime").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jstyleparser").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-css").versionAsInProject(),
			bundlesAndDependencies("org.daisy.pipeline.calabash-adapter"),
			brailleModule("common-utils"),
			brailleModule("css-core"),
			forThisPlatform(brailleModule("libhyphen-native")),
			thisBundle("org.daisy.pipeline.modules.braille", "libhyphen-core"),
			bundle("reference:file:" + PathUtils.getBaseDir() + "/target/test-classes/table_paths/"),
			junitBundles()
		);
	}
}