package com.educare.controller;

import com.educare.dto.AddCourseRequest;
import com.educare.dto.ApiResponse;
import com.educare.entity.Course;
import com.educare.entity.User;
import com.educare.service.CourseService;
import com.educare.service.UserService; // service to get logged-in user
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.List;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/teacher")
@RequiredArgsConstructor
public class CourseController {

    private final CourseService courseService;
    private final UserService userService; // provides currently logged-in user

    @PostMapping("/courses")
    public ResponseEntity<ApiResponse<Course>> addCourse(
            @RequestBody @Valid AddCourseRequest request,
            @AuthenticationPrincipal User currentUser) {

        if (currentUser == null) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("User not authenticated"));
        }

        Course savedCourse = courseService.addCourse(currentUser, request);
        return ResponseEntity.ok(ApiResponse.ok("Course added successfully", savedCourse));
    }

    @GetMapping("/courses")
    public ResponseEntity<ApiResponse<List<Course>>> getAllCourses() {
        List<Course> courses = courseService.getAllCourses();
        return ResponseEntity.ok(ApiResponse.ok("Courses fetched successfully", courses));
    }
    @PutMapping("/courses/{id}")
    public ResponseEntity<ApiResponse<Course>> editCourse(
            @PathVariable Long id,
            @RequestBody @Valid AddCourseRequest request, @AuthenticationPrincipal User currentUser) {

        if (currentUser == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("User not authenticated"));
        }

        Course course = courseService.getCourseById(id);
        if (!course.getTeacher().getId().equals(currentUser.getId())) {
        return ResponseEntity
                .status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error("You are not allowed to edit this course"));
        }

        Course updatedCourse = courseService.updateCourse(course, request);
        return ResponseEntity.ok(ApiResponse.ok("Course updated successfully", updatedCourse));
    }
    @GetMapping("/courses/{id}")
    public ResponseEntity<ApiResponse<Course>> getCourseById(@PathVariable Long id) {
        Course course = courseService.getCourseById(id);
        if (course == null) {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("Course not found"));
        }
        return ResponseEntity.ok(ApiResponse.ok("Course fetched successfully", course));
    }



}
