package com.daenamu.playback.controller;

import com.daenamu.playback.dto.PlaybackResponse;
import com.daenamu.playback.service.PlaybackService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/playback")
public class PlaybackController {

	private final PlaybackService playbackService;

	public PlaybackController(PlaybackService playbackService) {
		this.playbackService = playbackService;
	}

	@GetMapping("/{episodeId}")
	public PlaybackResponse getPlayback(
			@PathVariable String episodeId,
			@RequestParam(defaultValue = "0") long delayMs,
			@RequestParam(defaultValue = "false") boolean fail
	) {
		return playbackService.getPlayback(episodeId, delayMs, fail);
	}
}
