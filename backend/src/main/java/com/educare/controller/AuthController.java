package com.educare.controller;

import com.educare.dto.*;
import com.educare.service.AuthService;
import com.educare.dto.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import com.educare.entity.User;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    @Value("${GOOGLE_CLIENT_ID}") 
    private String clientId;

    @Value("${GOOGLE_CLIENT_SECRET}")
    private String clientSecret;

    @Value("${google.redirect.uri}")
    private String redirectUri;

/*  https://accounts.google.com/o/oauth2/auth?
    scope=https://www.googleapis.com/auth/youtube.upload&
    access_type=offline&
    include_granted_scopes=true&
    response_type=code&
    redirect_uri=http://localhost:8080/api/auth/youtube/oauth/callback&
    client_id=967252627443-2i62bfrbg7v0hpf1f1kud1m7td1mrfoq.apps.googleusercontent.com */

    @GetMapping("/youtube/oauth/callback")
    public ResponseEntity<String> youtubeOAuthCallback(@RequestParam String code) {
        try {
            System.out.println("clientSecret------->" + clientSecret);
            TokenResponse response = new GoogleAuthorizationCodeTokenRequest(
                    new NetHttpTransport(),
                    GsonFactory.getDefaultInstance(),
                    clientId,
                    clientSecret,
                    code,
                    redirectUri)
                    .execute();

            
            String refreshToken = response.getRefreshToken();
            String accessToken = response.getAccessToken();

            // TODO: Save refreshToken in your database or secure storage
            System.out.println("Refresh token: " + refreshToken);
            System.out.println("Access token: " + accessToken);

            System.out.println(response);
            return ResponseEntity.ok("Refresh token saved successfully!");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

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
