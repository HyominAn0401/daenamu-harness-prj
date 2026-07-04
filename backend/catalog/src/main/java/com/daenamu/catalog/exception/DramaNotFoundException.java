package com.daenamu.catalog.exception;

public class DramaNotFoundException extends RuntimeException {

	public DramaNotFoundException(String dramaId) {
		super("Drama not found: " + dramaId);
	}
}
