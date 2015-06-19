package org.daisy.pipeline.braille.common;

import java.net.URI;
import java.net.URL;

public interface ResourceResolver {
	
	/**
	 * Resolve a resource from a URI.
	 * @param resource
	 * @return The resolved URL, or null if the resource cannot be resolved.
	 */
	public URL resolve(URI resource);
	
	public static abstract class MemoizingResolver extends Memoizing<URI,URL> implements ResourceResolver {
		public URL resolve(URI resource) {
			return apply(resource);
		}
	}
}
