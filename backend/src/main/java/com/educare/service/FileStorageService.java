package com.educare.service;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.*;

@Service
public class FileStorageService {

    private final String uploadDir = "uploads"; // change to your desired path

    public String storeFile(MultipartFile file) throws IOException {
        String originalFilename = StringUtils.cleanPath(file.getOriginalFilename());

        // Create directory if it doesn't exist
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Copy file
        Path targetLocation = uploadPath.resolve(originalFilename);
        Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

        // Return URL (adjust base URL to your server/domain)
        return "/uploads/" + originalFilename;
    }

    public String getFileType(MultipartFile file) {
        String extension = StringUtils.getFilenameExtension(file.getOriginalFilename()).toUpperCase();
        switch (extension) {
            case "MP4":
            case "AVI":
            case "MOV":
                return "VIDEO";
            case "PDF":
                return "PDF";
            case "PPT":
            case "PPTX":
                return "PPT";
            case "DOC":
            case "DOCX":
                return "DOC";
            default:
                return "UNKNOWN";
        }
    }
}
