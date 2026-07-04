package com.daenamu.playback.controller;

import com.daenamu.playback.dto.PlaybackResponse;
import com.daenamu.playback.service.PlaybackService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Playback", description = "Playback URL and fault-injection APIs")
@RestController
@RequestMapping("/api/playback")
public class PlaybackController {

	private final PlaybackService playbackService;

	public PlaybackController(PlaybackService playbackService) {
		this.playbackService = playbackService;
	}

	@Operation(summary = "Get playback URL", description = "Returns playback information. Use delayMs and fail to inject latency or failures.")
	@GetMapping("/{episodeId}")
	public PlaybackResponse getPlayback(
			@Parameter(description = "Episode ID", example = "episode-001-01")
			@PathVariable String episodeId,
			@Parameter(description = "Artificial delay in milliseconds", example = "1000")
			@RequestParam(defaultValue = "0") long delayMs,
			@Parameter(description = "When true, returns a 503 error after the optional delay", example = "false")
			@RequestParam(defaultValue = "false") boolean fail
	) {
		return playbackService.getPlayback(episodeId, delayMs, fail);
	}
}
