package com.daenamu.catalog.dto;

import java.time.LocalDate;

public record DramaSummaryResponse(
		String id,
		String title,
		String genre,
		LocalDate releaseDate
) {
}
