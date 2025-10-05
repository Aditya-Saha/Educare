package com.educare.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AddNoteRequest {

    @NotNull(message = "Course ID is required")
    private Long courseId;

    // Optional: null if this is a reply
    private Long parentNoteId;

    // Optional title; mainly for main notes
    private String title;

    @NotBlank(message = "Content cannot be empty")
    private String content;
}
