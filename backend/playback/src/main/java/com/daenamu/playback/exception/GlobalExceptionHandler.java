package com.daenamu.playback.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

	@ExceptionHandler(PlaybackNotFoundException.class)
	public ProblemDetail handlePlaybackNotFound(PlaybackNotFoundException exception) {
		ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, exception.getMessage());
		problemDetail.setTitle("Playback not found");
		return problemDetail;
	}

	@ExceptionHandler(PlaybackFailureException.class)
	public ProblemDetail handlePlaybackFailure(PlaybackFailureException exception) {
		ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(HttpStatus.SERVICE_UNAVAILABLE, exception.getMessage());
		problemDetail.setTitle("Playback failure injected");
		return problemDetail;
	}
}
