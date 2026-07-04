package com.daenamu.playback.dto;

public record PlaybackResponse(
		String episodeId,
		String streamUrl,
		String status
) {
}
