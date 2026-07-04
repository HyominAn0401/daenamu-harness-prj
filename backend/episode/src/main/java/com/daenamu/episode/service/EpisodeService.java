package com.daenamu.episode.service;

import java.util.List;

import com.daenamu.episode.client.PlaybackClient;
import com.daenamu.episode.dto.EpisodeDetailResponse;
import com.daenamu.episode.dto.EpisodeSummaryResponse;
import com.daenamu.episode.entity.Episode;
import com.daenamu.episode.exception.EpisodeNotFoundException;
import com.daenamu.episode.repository.EpisodeRepository;
import org.springframework.stereotype.Service;

@Service
public class EpisodeService {

	private final EpisodeRepository episodeRepository;
	private final PlaybackClient playbackClient;

	public EpisodeService(EpisodeRepository episodeRepository, PlaybackClient playbackClient) {
		this.episodeRepository = episodeRepository;
		this.playbackClient = playbackClient;
	}

	public List<EpisodeSummaryResponse> getEpisodes(String dramaId) {
		return episodeRepository.findByDramaIdOrderByEpisodeNumber(dramaId).stream()
				.map(this::toSummary)
				.toList();
	}

	public EpisodeDetailResponse getEpisode(String episodeId) {
		Episode episode = findEpisode(episodeId);

		return new EpisodeDetailResponse(
				episode.getId(),
				episode.getDramaId(),
				episode.getEpisodeNumber(),
				episode.getTitle(),
				episode.getDurationSeconds(),
				playbackClient.getPlayback(episodeId)
		);
	}

	private Episode findEpisode(String episodeId) {
		return episodeRepository.findById(episodeId)
				.orElseThrow(() -> new EpisodeNotFoundException(episodeId));
	}

	private EpisodeSummaryResponse toSummary(Episode episode) {
		return new EpisodeSummaryResponse(
				episode.getId(),
				episode.getDramaId(),
				episode.getEpisodeNumber(),
				episode.getTitle(),
				episode.getDurationSeconds(),
				"/api/playback/" + episode.getId()
		);
	}
}
