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
import java.util.List;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/teacher")
@RequiredArgsConstructor
public class CourseController {

    private final CourseService courseService;
    private final UserService userService; // provides currently logged-in user

    @PostMapping("/courses")
    public ResponseEntity<ApiResponse<Course>> addCourse(@RequestBody @Valid AddCourseRequest request) {
        User teacher = userService.getCurrentUser(); // teacher from JWT
        Course savedCourse = courseService.addCourse(teacher, request);
        return ResponseEntity.ok(ApiResponse.ok("Course added successfully", savedCourse));
    }
    @GetMapping("/courses")
    public ResponseEntity<ApiResponse<List<Course>>> getAllCourses() {
        List<Course> courses = courseService.getAllCourses();
        return ResponseEntity.ok(ApiResponse.ok("Courses fetched successfully", courses));
    }

}
