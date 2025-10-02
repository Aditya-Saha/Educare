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

    @PostMapping(value = "/courses/{courseId}/contents", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<CourseContent>> addContent(
            @PathVariable Long courseId,
            @RequestPart("file") MultipartFile file,
            @RequestPart("title") String title,
            @RequestPart("isFree") boolean isFree) {
        CourseContent savedContent = courseContentService.addContent(courseId, file, title, isFree);

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
