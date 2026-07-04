package com.daenamu.episode.dto;

public record PlaybackResponse(
		String episodeId,
		String streamUrl,
		String status
) {
}
