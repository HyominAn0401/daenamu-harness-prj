package com.daenamu.catalog.controller;

import java.util.List;

import com.daenamu.catalog.dto.DramaDetailResponse;
import com.daenamu.catalog.dto.DramaSummaryResponse;
import com.daenamu.catalog.service.CatalogService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/catalog/dramas")
public class CatalogController {

	private final CatalogService catalogService;

	public CatalogController(CatalogService catalogService) {
		this.catalogService = catalogService;
	}

	@GetMapping
	public List<DramaSummaryResponse> getDramas() {
		return catalogService.getDramas();
	}

	@GetMapping("/{dramaId}")
	public DramaDetailResponse getDrama(@PathVariable String dramaId) {
		return catalogService.getDrama(dramaId);
	}
}
