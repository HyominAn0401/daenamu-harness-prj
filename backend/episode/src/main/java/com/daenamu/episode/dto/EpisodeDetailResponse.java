package com.daenamu.episode.dto;

public record EpisodeDetailResponse(
		String id,
		String dramaId,
		int episodeNumber,
		String title,
		int durationSeconds,
		PlaybackResponse playback
) {
}
