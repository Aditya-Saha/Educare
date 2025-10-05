package com.educare.controller;

import com.educare.dto.ApiResponse;
import com.educare.dto.EnrollmentResponse;
import com.educare.dto.FreeEnrollmentRequest;
import com.educare.entity.User;
import com.educare.service.EnrollmentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/enrollments")
public class EnrollmentController {

    @Autowired
    private EnrollmentService enrollmentService;

    @PostMapping("/free")
    public ResponseEntity<ApiResponse<EnrollmentResponse>> giveFreeEnrollment(
            @RequestBody @Valid FreeEnrollmentRequest request,
            @AuthenticationPrincipal User currentUser) {
        try {
            if (currentUser == null || !"TEACHER".equalsIgnoreCase(currentUser.getRole())) {
                return ResponseEntity.status(403)
                        .body(ApiResponse.error("Access denied: Only teachers can grant free enrollment"));
            }
            EnrollmentResponse response = enrollmentService.giveFreeAccess(request, currentUser);
            return ResponseEntity.ok(ApiResponse.ok("Free enrollment granted", response));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Failed: " + e.getMessage()));
        }
    }
    @DeleteMapping("/free/revoke")
    public ResponseEntity<ApiResponse<String>> revokeFreeEnrollment(
            @RequestParam Long enrollmentId,
            @AuthenticationPrincipal User currentUser) {

        try {
            if (currentUser == null || !"TEACHER".equalsIgnoreCase(currentUser.getRole())) {
                return ResponseEntity.status(403)
                        .body(ApiResponse.error("Access denied: Only teachers can revoke free enrollment"));
            }

            enrollmentService.revokeFreeEnrollment(enrollmentId, currentUser);
            return ResponseEntity.ok(ApiResponse.ok("Free enrollment revoked successfully", null));

        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Failed: " + e.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<EnrollmentResponse>> getEnrollmentById(@PathVariable Long id) {
        try {
            EnrollmentResponse response = enrollmentService.getEnrollment(id);
            return ResponseEntity.ok(ApiResponse.ok("Enrollment found", response));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Error: " + e.getMessage()));
        }
    }
     /** ✅ 3. Get all enrollments for a course (teacher view) */
    @GetMapping("/course/{courseId}")
    public ResponseEntity<ApiResponse<List<EnrollmentResponse>>> getEnrollmentsByCourse(@PathVariable Long courseId) {
        List<EnrollmentResponse> responses = enrollmentService.getEnrollmentsByCourse(courseId);
        return ResponseEntity.ok(ApiResponse.ok("Enrollments fetched successfully", responses));
    }
}
