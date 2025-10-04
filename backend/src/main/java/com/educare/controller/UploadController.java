package com.educare.controller;

import com.educare.dto.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.MediaType;
import com.educare.service.YouTubeUploadService;

import java.io.*;
import java.nio.file.*;
import java.util.*;

@RestController
@RequestMapping("/api/teacher")
@RequiredArgsConstructor
public class UploadController {

    @Value("${app.upload.dir}")
    private String uploadDir;

    @Value("${app.base-url:http://localhost:8080}")
    private String baseUrl;

    // Stub for YouTube service (replace with actual)
    private final YouTubeUploadService youtubeUploadService;
    
    private static final Set<String> SUPPORTED_EXTENSIONS = Set.of(
            "mov", "mpeg4", "mp4", "avi", "wmv",
            "mpegps", "flv", "3gpp", "webm",
            "dnxhr", "prores", "cineform", "hevc"
    );

    

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadFile(
            @RequestParam("file") MultipartFile file, @RequestParam(value = "thumbnail", required = false) MultipartFile thumbnail) {
        System.out.println("------------HERE ................");
        try {
            String url;
            String fileType;
            String filename = file.getOriginalFilename();
            String extension = (filename != null && filename.contains("."))
                ? filename.substring(filename.lastIndexOf('.') + 1).toLowerCase()
                : "";

            // Detect file type from MIME type
            String contentType = file.getContentType(); // e.g., "video/mp4", "application/pdf"
            System.out.println("Content Type --------->" + contentType);
            if (contentType != null) {
                if (contentType.startsWith("video/")) {
                    if(!SUPPORTED_EXTENSIONS.contains(extension)) {
                        return ResponseEntity.badRequest().body(ApiResponse.error("Unsupported video format"));
                    }
                    String thumbContentType = thumbnail.getContentType();
                    if (thumbContentType == null || 
                        !(thumbContentType.equals("image/jpeg") ||
                        thumbContentType.equals("image/png") ||
                        thumbContentType.equals("image/gif"))) {
                        return ResponseEntity.badRequest().body(ApiResponse.error("Invalid thumbnail format. Allowed: JPG, PNG, GIF"));
                    }

                    if (thumbnail.getSize() > 2 * 1024 * 1024) {
                        return ResponseEntity.badRequest().body(ApiResponse.error("Thumbnail too large. Max 2MB allowed."));
                    }

                    // Save the MultipartFile temporarily
                    String tempFilePath = System.getProperty("java.io.tmpdir") + "/" + file.getOriginalFilename();
                    Files.copy(file.getInputStream(), Paths.get(tempFilePath), StandardCopyOption.REPLACE_EXISTING);

                    // Upload to YouTube as unlisted
                    String videoId = youtubeUploadService.uploadVideo(
                            tempFilePath,
                            file.getOriginalFilename(),
                            "Uploaded via Educare",
                            new String[]{},    // tags, empty for now
                            "unlisted"         // privacy
                    );

                    // Upload thumbnail if provided
                    if (thumbnail != null && !thumbnail.isEmpty()) {
                        youtubeUploadService.uploadThumbnail(videoId, thumbnail);
                    }

                    url = "https://youtu.be/" + videoId;

                    // Optional: delete temp file
                    Files.deleteIfExists(Paths.get(tempFilePath));

                    // String fakeYoutubeId = UUID.randomUUID().toString().substring(0, 8);
                    // url = "https://youtu.be/" + fakeYoutubeId;
                    fileType = "VIDEO";

                } else if (contentType.equals("application/pdf")) {
                    fileType = "PDF";
                    url = saveToFileSystem(file);

                } else if (contentType.equals("application/vnd.ms-powerpoint") ||
                        contentType.equals("application/vnd.openxmlformats-officedocument.presentationml.presentation")) {
                    fileType = "PPT";
                    url = saveToFileSystem(file);

                } else if (contentType.equals("application/msword") ||
                        contentType.equals("application/vnd.openxmlformats-officedocument.wordprocessingml.document")) {
                    fileType = "DOC";
                    url = saveToFileSystem(file);

                } else {
                    return ResponseEntity.badRequest().body(ApiResponse.error("Unsupported file type: " + contentType));
                }
            } else {
                return ResponseEntity.badRequest().body(ApiResponse.error("Cannot determine file type"));
            }

            Map<String, String> responseData = new HashMap<>();
            responseData.put("fileType", fileType);
            responseData.put("url", url);

            return ResponseEntity.ok(ApiResponse.ok("File uploaded successfully", responseData));

        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("File upload failed: " + e.getMessage()));
        }
    }

    // Helper method to save file
    private String saveToFileSystem(MultipartFile file) throws IOException {
        String filename = System.currentTimeMillis() + "-" + file.getOriginalFilename();
        Path path = Paths.get(uploadDir, filename);
        Files.createDirectories(path.getParent());
        Files.copy(file.getInputStream(), path, StandardCopyOption.REPLACE_EXISTING);
        return baseUrl + "/uploads/" + filename;
    }

}
