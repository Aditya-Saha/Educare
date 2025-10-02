package com.educare.service;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import lombok.RequiredArgsConstructor;  
import com.educare.repository.CourseContentRepository;
import com.educare.repository.CourseRepository;
import com.educare.service.YouTubeUploadService;
import com.educare.entity.CourseContent;
import com.educare.entity.Course;

import java.util.List;
import java.io.IOException;
import java.io.File;

@Service
@RequiredArgsConstructor
public class CourseContentService {

    private final CourseRepository courseRepository;
    private final CourseContentRepository courseContentRepository;
    private final FileStorageService fileStorageService;
    private final YouTubeUploadService youtubeUploadService;

    private String getFileType(String filename) {
        String lower = filename.toLowerCase();
        if (lower.endsWith(".mp4") || lower.endsWith(".mkv") || lower.endsWith(".mov")) {
            return "VIDEO";
        } else if (lower.endsWith(".ppt") || lower.endsWith(".pptx")) {
            return "PPT";
        } else if (lower.endsWith(".pdf")) {
            return "PDF";
        } else if (lower.endsWith(".doc") || lower.endsWith(".docx")) {
            return "DOC";
        } else {
            throw new IllegalArgumentException("Unsupported file type: " + filename);
        }
    }

    public CourseContent addContent(Long courseId, MultipartFile file, String title, boolean isFree) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        String fileType = getFileType(file.getOriginalFilename());
        String fileUrl;

        if ("VIDEO".equals(fileType)) {
            try {
                File convFile = new File(System.getProperty("java.io.tmpdir") + "/" + file.getOriginalFilename());
                file.transferTo(convFile);

                fileUrl = youtubeUploadService.uploadVideo(convFile.getAbsolutePath(), file.getOriginalFilename(), "Uploaded via Educare" ,new String[]{"Education"}, "private");
            } catch (IOException e) {
                throw new RuntimeException("Failed to process file upload", e);
            }

        } else {
            try {
                fileUrl = fileStorageService.storeFile(file); // local storage
            } catch (IOException e) {
                throw new RuntimeException("Failed to store file", e);
            }
        }

        CourseContent content = CourseContent.builder()
                .course(course)
                .title(title)
                .fileType(fileType)
                .fileUrl(fileUrl)
                .durationSeconds(null) // optional
                .isFree(isFree)
                .build();

        return courseContentRepository.save(content);
    }

    public CourseContent getContentById(Long id) {
        return courseContentRepository.findById(id)
                .orElse(null); // return null if not found (controller handles 404)
    }

    public List<CourseContent> getContentsByCourseId(Long courseId) {
        return courseContentRepository.findByCourseId(courseId);
    }

}
