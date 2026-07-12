package com.daenamu.catalog.dto;

public record PlaybackResponse(
		String episodeId,
		String streamUrl,
		String status
) {
}
