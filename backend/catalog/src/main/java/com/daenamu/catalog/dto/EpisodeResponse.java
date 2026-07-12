package com.daenamu.catalog.dto;

public record EpisodeResponse(
		String id,
		String dramaId,
		int episodeNumber,
		String title,
		Integer durationSeconds,
		String playbackUrl,
		PlaybackResponse playback
) {
}
