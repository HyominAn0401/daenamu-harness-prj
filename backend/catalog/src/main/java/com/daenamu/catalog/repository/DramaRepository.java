package com.daenamu.catalog.repository;

import com.daenamu.catalog.entity.Drama;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DramaRepository extends JpaRepository<Drama, String> {
}
