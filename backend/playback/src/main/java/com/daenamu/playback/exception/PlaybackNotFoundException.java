package com.daenamu.playback.exception;

public class PlaybackNotFoundException extends RuntimeException {

	public PlaybackNotFoundException(String episodeId) {
		super("Playback not found: " + episodeId);
	}
}
