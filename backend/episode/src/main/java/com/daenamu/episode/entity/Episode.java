package com.daenamu.episode.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "episodes")
public class Episode {

	@Id
	private String id;

	@Column(nullable = false)
	private String dramaId;

	@Column(nullable = false)
	private int episodeNumber;

	@Column(nullable = false)
	private String title;

	@Column(nullable = false)
	private int durationSeconds;

	protected Episode() {
	}

	public Episode(String id, String dramaId, int episodeNumber, String title, int durationSeconds) {
		this.id = id;
		this.dramaId = dramaId;
		this.episodeNumber = episodeNumber;
		this.title = title;
		this.durationSeconds = durationSeconds;
	}

	public String getId() {
		return id;
	}

	public String getDramaId() {
		return dramaId;
	}

	public int getEpisodeNumber() {
		return episodeNumber;
	}

	public String getTitle() {
		return title;
	}

	public int getDurationSeconds() {
		return durationSeconds;
	}
}
