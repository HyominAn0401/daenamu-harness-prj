package com.daenamu.episode.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
public class EpisodeClientConfig {

	@Bean
	RestClient.Builder restClientBuilder() {
		return RestClient.builder();
	}

	@Bean
	RestClient playbackRestClient(
			RestClient.Builder restClientBuilder,
			@Value("${daenamu.playback.base-url}") String playbackBaseUrl
	) {
		return restClientBuilder
				.baseUrl(playbackBaseUrl)
				.build();
	}
}
