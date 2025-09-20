package com.educare.controller;

import com.educare.dto.AddCourseContentRequest;
import com.educare.dto.ApiResponse;
import com.educare.entity.CourseContent;
import com.educare.service.CourseContentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/teacher")
@RequiredArgsConstructor
public class CourseContentController {

    private final CourseContentService courseContentService;

    @PostMapping("/courses/{courseId}/contents")
    public ResponseEntity<ApiResponse<CourseContent>> addContent(
            @PathVariable Long courseId,
            @RequestBody @Valid AddCourseContentRequest request) {

        CourseContent savedContent = courseContentService.addContent(courseId, request);

        if (savedContent == null) {
            return ResponseEntity
                    .badRequest()
                    .body(ApiResponse.error("Course not found with id: " + courseId));
        }

        return ResponseEntity.ok(ApiResponse.ok("Content added successfully", savedContent));
    }

    @GetMapping("/contents/{id}")
    public ResponseEntity<ApiResponse<CourseContent>> getContent(@PathVariable Long id) {
        CourseContent content = courseContentService.getContentById(id);

        if (content == null) {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("Content not found with id: " + id));
        }

        return ResponseEntity.ok(ApiResponse.ok("Content fetched successfully", content));
    }
}
