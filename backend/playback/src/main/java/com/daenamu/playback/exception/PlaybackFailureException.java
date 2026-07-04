package com.daenamu.playback.exception;

public class PlaybackFailureException extends RuntimeException {

	public PlaybackFailureException(String episodeId) {
		super("Playback failure injected for episode: " + episodeId);
	}
}
