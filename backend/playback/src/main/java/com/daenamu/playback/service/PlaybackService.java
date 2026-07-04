package com.daenamu.playback.service;

import com.daenamu.playback.dto.PlaybackResponse;
import com.daenamu.playback.entity.Playback;
import com.daenamu.playback.exception.PlaybackFailureException;
import com.daenamu.playback.exception.PlaybackNotFoundException;
import com.daenamu.playback.repository.PlaybackRepository;
import org.springframework.stereotype.Service;

@Service
public class PlaybackService {

	private final PlaybackRepository playbackRepository;

	public PlaybackService(PlaybackRepository playbackRepository) {
		this.playbackRepository = playbackRepository;
	}

	public PlaybackResponse getPlayback(String episodeId, long delayMs, boolean fail) {
		applyDelay(delayMs);

		if (fail) {
			throw new PlaybackFailureException(episodeId);
		}

		Playback playback = playbackRepository.findById(episodeId)
				.orElseThrow(() -> new PlaybackNotFoundException(episodeId));

		return new PlaybackResponse(
				playback.getEpisodeId(),
				playback.getStreamUrl(),
				playback.getStatus()
		);
	}

	private void applyDelay(long delayMs) {
		if (delayMs <= 0) {
			return;
		}

		try {
			Thread.sleep(delayMs);
		} catch (InterruptedException exception) {
			Thread.currentThread().interrupt();
		}
	}
}
