package com.daenamu.catalog.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
public class CatalogClientConfig {

	@Bean
	RestClient.Builder restClientBuilder() {
		return RestClient.builder();
	}

	@Bean
	RestClient episodeRestClient(
			RestClient.Builder restClientBuilder,
			@Value("${daenamu.episode.base-url}") String episodeBaseUrl
	) {
		return restClientBuilder
				.baseUrl(episodeBaseUrl)
				.build();
	}
}
