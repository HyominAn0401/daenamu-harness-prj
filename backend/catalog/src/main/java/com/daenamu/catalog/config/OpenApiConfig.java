package com.daenamu.catalog.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

	@Bean
	OpenAPI catalogOpenApi() {
		return new OpenAPI()
				.info(new Info()
						.title("DAENAMU Catalog API")
						.description("Drama catalog entrypoint API for the DAENAMU call-chain experiment.")
						.version("v1"));
	}
}
