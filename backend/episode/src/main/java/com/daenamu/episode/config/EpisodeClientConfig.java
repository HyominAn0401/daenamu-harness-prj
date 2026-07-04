package com.daenamu.episode.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
public class EpisodeClientConfig {

	@Bean
	RestClient playbackRestClient(
			@Value("${daenamu.playback.base-url}") String playbackBaseUrl
	) {
		return RestClient.builder()
				.baseUrl(playbackBaseUrl)
				.build();
	}
}
