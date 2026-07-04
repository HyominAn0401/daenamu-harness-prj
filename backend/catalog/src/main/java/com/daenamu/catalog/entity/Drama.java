package com.daenamu.catalog.entity;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "dramas")
public class Drama {

	@Id
	private String id;

	@Column(nullable = false)
	private String title;

	@Column(nullable = false)
	private String genre;

	@Column(nullable = false, length = 1000)
	private String description;

	@Column(nullable = false)
	private LocalDate releaseDate;

	protected Drama() {
	}

	public Drama(String id, String title, String genre, String description, LocalDate releaseDate) {
		this.id = id;
		this.title = title;
		this.genre = genre;
		this.description = description;
		this.releaseDate = releaseDate;
	}

	public String getId() {
		return id;
	}

	public String getTitle() {
		return title;
	}

	public String getGenre() {
		return genre;
	}

	public String getDescription() {
		return description;
	}

	public LocalDate getReleaseDate() {
		return releaseDate;
	}
}
