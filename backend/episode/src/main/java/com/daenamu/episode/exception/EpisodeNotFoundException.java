package com.daenamu.episode.exception;

public class EpisodeNotFoundException extends RuntimeException {

	public EpisodeNotFoundException(String episodeId) {
		super("Episode not found: " + episodeId);
	}
}
