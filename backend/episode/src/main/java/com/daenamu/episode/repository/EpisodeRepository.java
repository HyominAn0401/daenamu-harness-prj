package com.daenamu.episode.repository;

import java.util.List;

import com.daenamu.episode.entity.Episode;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EpisodeRepository extends JpaRepository<Episode, String> {

	List<Episode> findByDramaIdOrderByEpisodeNumber(String dramaId);
}
