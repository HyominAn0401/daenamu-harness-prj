package com.daenamu.catalog.dto;

import java.time.LocalDate;
import java.util.List;

public record DramaDetailResponse(
		String id,
		String title,
		String genre,
		String description,
		LocalDate releaseDate,
		List<EpisodeResponse> episodes
) {
}
