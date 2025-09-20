package com.educare.controller;

import com.educare.dto.ApiResponse;
import com.educare.dto.FileUploadResponse;
import com.educare.service.FileStorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/teacher/course-content")
@RequiredArgsConstructor
public class FileUploadController {

    private final FileStorageService fileStorageService;

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<FileUploadResponse>> uploadFile(
            @RequestParam("file") MultipartFile file) {

        try {
            // Store file and get accessible URL
            String fileUrl = fileStorageService.storeFile(file);

            // Determine file type
            String fileType = fileStorageService.getFileType(file);

            FileUploadResponse response = new FileUploadResponse(fileUrl, fileType);
            return ResponseEntity.ok(ApiResponse.ok("File uploaded successfully", response));
        } catch (Exception e) {
            return ResponseEntity
                    .badRequest()
                    .body(ApiResponse.error("File upload failed: " + e.getMessage()));
        }
    }
}
