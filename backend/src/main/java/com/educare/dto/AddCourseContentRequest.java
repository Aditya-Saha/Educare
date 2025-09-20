package com.educare.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AddCourseContentRequest {

    @NotBlank
    private String title;

    @NotBlank
    private String fileType; // VIDEO, PPT, PDF, DOC

    @NotBlank
    private String fileUrl;

    private Integer durationSeconds; // optional
}
