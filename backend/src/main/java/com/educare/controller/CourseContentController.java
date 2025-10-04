package com.educare.controller;

import com.educare.dto.AddCourseContentRequest;
import com.educare.dto.ApiResponse;
import com.educare.entity.CourseContent;
import com.educare.service.CourseContentService;
import com.educare.repository.CourseContentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.educare.entity.CourseContent;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.MediaType;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/teacher")
@RequiredArgsConstructor
public class CourseContentController {

    private final CourseContentService courseContentService;
    private final CourseContentRepository courseContentRepository;

    @GetMapping("/courses/{courseId}/contents")
    public List<CourseContent> getContents(Long userId, Long courseId, String role) {
        if (role.equals("TEACHER") || role.equals("ADMIN")) {
            return courseContentRepository.findByCourseId(courseId);
        } else {
            return courseContentRepository.findAccessibleContentsForStudent(userId, courseId);
        }
    }

    @PostMapping(value = "/courses/{courseId}/contents")
    public ResponseEntity<ApiResponse<CourseContent>> addContent(
            @PathVariable Long courseId,
            @RequestBody AddCourseContentRequest request) {

        CourseContent savedContent = courseContentService.addContent(
            courseId,
            request.getTitle(),
            request.getFileType(),
            request.getFileUrl(),
            request.getDurationSeconds(),
            request.isFree());

        if (savedContent == null) {
            return ResponseEntity
                    .badRequest()
                    .body(ApiResponse.error("Course not found with id: " + courseId));
        }

        return ResponseEntity.ok(ApiResponse.ok("Content added successfully", savedContent));
    }
    @PutMapping("/courses/{courseId}/contents/{contentId}")
    public ResponseEntity<ApiResponse<CourseContent>> updateContent(
            @PathVariable Long courseId,
            @PathVariable Long contentId,
            @RequestBody AddCourseContentRequest request) {

        CourseContent updatedContent = courseContentService.updateContent(
                courseId,
                contentId,
                request.getTitle(),
                request.getFileType(),
                request.getFileUrl(),
                request.getDurationSeconds(),
                request.isFree()
        );

        if (updatedContent == null) {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("Content not found with id: " + contentId));
        }

        return ResponseEntity.ok(ApiResponse.ok("Content updated successfully", updatedContent));
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
