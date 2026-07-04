package com.daenamu.episode.client;

import com.daenamu.episode.dto.PlaybackResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
public class PlaybackClient {

	private final RestClient playbackRestClient;

	public PlaybackClient(RestClient playbackRestClient) {
		this.playbackRestClient = playbackRestClient;
	}

	public PlaybackResponse getPlayback(String episodeId) {
		return playbackRestClient.get()
				.uri("/api/playback/{episodeId}", episodeId)
				.retrieve()
				.body(PlaybackResponse.class);
	}
}
