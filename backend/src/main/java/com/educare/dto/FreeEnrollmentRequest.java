package com.educare.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class FreeEnrollmentRequest {

    @NotNull
    private Long studentId;

    @NotNull
    private Long courseId;
}
