package com.daenamu.playback.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

	@Bean
	OpenAPI playbackOpenApi() {
		return new OpenAPI()
				.info(new Info()
						.title("DAENAMU Playback API")
						.description("Playback URL API with delay and failure injection controls.")
						.version("v1"));
	}
}
