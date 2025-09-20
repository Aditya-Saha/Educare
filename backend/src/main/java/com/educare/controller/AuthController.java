package com.educare.controller;

import com.educare.dto.*;
import com.educare.service.AuthService;
import com.educare.dto.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import com.educare.model.User;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<?>> register(@RequestBody @Valid RegisterRequest request) {
        User savedUser = authService.register(request);
        return ResponseEntity.ok(ApiResponse.ok("Registration successful", savedUser));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<?>> login(@RequestBody @Valid LoginRequest request) {
        LoginResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.ok("Login successful", response));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(@RequestHeader("Authorization") String authHeader) {
        // Remove "Bearer " prefix if present
        String token = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;

        // authService.logout(token);
        return ResponseEntity.ok(ApiResponse.ok("Logout successful", null));
    }
}
