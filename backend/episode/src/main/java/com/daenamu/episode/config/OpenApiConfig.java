package com.daenamu.episode.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

	@Bean
	OpenAPI episodeOpenApi() {
		return new OpenAPI()
				.info(new Info()
						.title("DAENAMU Episode API")
						.description("Episode lookup API that connects catalog requests to playback.")
						.version("v1"));
	}
}
