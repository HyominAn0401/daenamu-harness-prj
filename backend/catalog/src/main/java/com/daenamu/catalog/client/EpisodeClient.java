package com.daenamu.catalog.client;

import java.util.List;

import com.daenamu.catalog.dto.EpisodeResponse;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
public class EpisodeClient {

	private final RestClient episodeRestClient;

	public EpisodeClient(RestClient episodeRestClient) {
		this.episodeRestClient = episodeRestClient;
	}

	public List<EpisodeResponse> getEpisodes(String dramaId) {
		List<EpisodeResponse> episodes = episodeRestClient.get()
				.uri("/api/episodes?dramaId={dramaId}", dramaId)
				.retrieve()
				.body(new ParameterizedTypeReference<>() {
				});

		if (episodes == null) {
			return List.of();
		}

		return episodes;
	}

	public EpisodeResponse getEpisode(String episodeId) {
		return episodeRestClient.get()
				.uri("/api/episodes/{episodeId}", episodeId)
				.retrieve()
				.body(EpisodeResponse.class);
	}
}
