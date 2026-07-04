package com.daenamu.catalog.controller;

import java.util.List;

import com.daenamu.catalog.dto.DramaDetailResponse;
import com.daenamu.catalog.dto.DramaSummaryResponse;
import com.daenamu.catalog.service.CatalogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Catalog", description = "Drama catalog APIs")
@RestController
@RequestMapping("/api/catalog/dramas")
public class CatalogController {

	private final CatalogService catalogService;

	public CatalogController(CatalogService catalogService) {
		this.catalogService = catalogService;
	}

	@Operation(summary = "List dramas", description = "Returns dramas stored in the catalog database.")
	@GetMapping
	public List<DramaSummaryResponse> getDramas() {
		return catalogService.getDramas();
	}

	@Operation(summary = "Get drama detail", description = "Returns one drama and calls the episode service for episode summaries.")
	@GetMapping("/{dramaId}")
	public DramaDetailResponse getDrama(
			@Parameter(description = "Drama ID", example = "drama-001")
			@PathVariable String dramaId
	) {
		return catalogService.getDrama(dramaId);
	}
}
