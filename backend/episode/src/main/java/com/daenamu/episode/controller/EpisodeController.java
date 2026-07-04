package com.daenamu.episode.controller;

import java.util.List;

import com.daenamu.episode.dto.EpisodeDetailResponse;
import com.daenamu.episode.dto.EpisodeSummaryResponse;
import com.daenamu.episode.service.EpisodeService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/episodes")
public class EpisodeController {

	private final EpisodeService episodeService;

	public EpisodeController(EpisodeService episodeService) {
		this.episodeService = episodeService;
	}

	@GetMapping
	public List<EpisodeSummaryResponse> getEpisodes(@RequestParam String dramaId) {
		return episodeService.getEpisodes(dramaId);
	}

	@GetMapping("/{episodeId}")
	public EpisodeDetailResponse getEpisode(@PathVariable String episodeId) {
		return episodeService.getEpisode(episodeId);
	}
}
