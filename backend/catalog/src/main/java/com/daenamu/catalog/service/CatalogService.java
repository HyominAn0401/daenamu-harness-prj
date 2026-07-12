package com.daenamu.catalog.service;

import java.util.List;

import com.daenamu.catalog.client.EpisodeClient;
import com.daenamu.catalog.dto.DramaDetailResponse;
import com.daenamu.catalog.dto.DramaSummaryResponse;
import com.daenamu.catalog.entity.Drama;
import com.daenamu.catalog.exception.DramaNotFoundException;
import com.daenamu.catalog.repository.DramaRepository;
import org.springframework.stereotype.Service;

@Service
public class CatalogService {

	private final DramaRepository dramaRepository;
	private final EpisodeClient episodeClient;

	public CatalogService(DramaRepository dramaRepository, EpisodeClient episodeClient) {
		this.dramaRepository = dramaRepository;
		this.episodeClient = episodeClient;
	}

	public List<DramaSummaryResponse> getDramas() {
		return dramaRepository.findAll().stream()
				.map(this::toSummary)
				.toList();
	}

	public DramaDetailResponse getDrama(String dramaId) {
		Drama drama = findDrama(dramaId);
		List<com.daenamu.catalog.dto.EpisodeResponse> episodes = episodeClient.getEpisodes(dramaId).stream()
				.map(episode -> episodeClient.getEpisode(episode.id()))
				.toList();

		return new DramaDetailResponse(
				drama.getId(),
				drama.getTitle(),
				drama.getGenre(),
				drama.getDescription(),
				drama.getReleaseDate(),
				episodes
		);
	}

	private Drama findDrama(String dramaId) {
		return dramaRepository.findById(dramaId)
				.orElseThrow(() -> new DramaNotFoundException(dramaId));
	}

	private DramaSummaryResponse toSummary(Drama drama) {
		return new DramaSummaryResponse(
				drama.getId(),
				drama.getTitle(),
				drama.getGenre(),
				drama.getReleaseDate()
		);
	}
}
