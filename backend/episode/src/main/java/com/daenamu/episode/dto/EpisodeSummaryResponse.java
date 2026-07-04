package com.daenamu.episode.dto;

public record EpisodeSummaryResponse(
		String id,
		String dramaId,
		int episodeNumber,
		String title,
		int durationSeconds,
		String playbackUrl
) {
}
