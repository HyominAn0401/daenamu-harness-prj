package com.daenamu.playback.repository;

import com.daenamu.playback.entity.Playback;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlaybackRepository extends JpaRepository<Playback, String> {
}
