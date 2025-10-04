package com.educare.controller;

import com.educare.dto.ApiResponse;
import com.educare.entity.Course;
import com.educare.entity.CourseContent;
import com.educare.service.CourseContentService;
import com.educare.service.CourseService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/student")
@RequiredArgsConstructor
public class StudentCourseController {

    private final CourseService courseService;
    private final CourseContentService courseContentService;

    /**
     * Get all published courses
     */
    @GetMapping("/courses")
    public ResponseEntity<ApiResponse<List<Course>>> getAllCourses() {
        try {
            List<Course> courses = courseService.getAllPublishedCourses();
            return ResponseEntity.ok(ApiResponse.ok("Published courses fetched", courses));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Failed to fetch courses: " + e.getMessage()));
        }
    }

    /**
     * Get a single published course by ID
     */
    @GetMapping("/courses/{id}")
    public ResponseEntity<ApiResponse<Course>> getCourse(@PathVariable Long id) {
        try {
            Course course = courseService.getPublishedCourseById(id);
            return ResponseEntity.ok(ApiResponse.ok("Course fetched", course));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Course not found or not published"));
        }
    }

    /**
     * Get all content for a published course
     */
    @GetMapping("/courses/{id}/contents")
    public ResponseEntity<ApiResponse<List<CourseContent>>> getCourseContents(@PathVariable Long id) {
        try {
            List<CourseContent> contents = courseContentService.getContentsByCourseId(id);
            return ResponseEntity.ok(ApiResponse.ok("Course contents fetched", contents));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Failed to fetch course contents: " + e.getMessage()));
        }
    }
    @GetMapping("/courses/{courseId}/contents/{contentId}")
    public ResponseEntity<ApiResponse<CourseContent>> getCourseContentById(
            @PathVariable Long courseId,
            @PathVariable Long contentId) {

        try {
            CourseContent content = courseContentService.getPublishedCourseContentById(courseId, contentId);

            if (content == null) {
                return ResponseEntity.ok(ApiResponse.error("Course content not found or course not published"));
            }

            return ResponseEntity.ok(ApiResponse.ok("Course content fetched successfully", content));

        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Failed to fetch course content: " + e.getMessage()));
        }
    }

}
