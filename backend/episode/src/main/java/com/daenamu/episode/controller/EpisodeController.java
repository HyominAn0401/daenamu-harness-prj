package com.daenamu.episode.controller;

import java.util.List;

import com.daenamu.episode.dto.EpisodeDetailResponse;
import com.daenamu.episode.dto.EpisodeSummaryResponse;
import com.daenamu.episode.service.EpisodeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Episode", description = "Drama episode APIs")
@RestController
@RequestMapping("/api/episodes")
public class EpisodeController {

	private final EpisodeService episodeService;

	public EpisodeController(EpisodeService episodeService) {
		this.episodeService = episodeService;
	}

	@Operation(summary = "List episodes", description = "Returns episode summaries for a drama.")
	@GetMapping
	public List<EpisodeSummaryResponse> getEpisodes(
			@Parameter(description = "Drama ID", example = "drama-001")
			@RequestParam String dramaId
	) {
		return episodeService.getEpisodes(dramaId);
	}

	@Operation(summary = "Get episode detail", description = "Returns one episode and calls the playback service for playback information.")
	@GetMapping("/{episodeId}")
	public EpisodeDetailResponse getEpisode(
			@Parameter(description = "Episode ID", example = "episode-001-01")
			@PathVariable String episodeId
	) {
		return episodeService.getEpisode(episodeId);
	}
}
