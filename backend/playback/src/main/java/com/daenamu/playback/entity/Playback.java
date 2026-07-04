package com.daenamu.playback.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "playbacks")
public class Playback {

	@Id
	private String episodeId;

	@Column(nullable = false)
	private String streamUrl;

	@Column(nullable = false)
	private String status;

	protected Playback() {
	}

	public Playback(String episodeId, String streamUrl, String status) {
		this.episodeId = episodeId;
		this.streamUrl = streamUrl;
		this.status = status;
	}

	public String getEpisodeId() {
		return episodeId;
	}

	public String getStreamUrl() {
		return streamUrl;
	}

	public String getStatus() {
		return status;
	}
}
