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

    public CourseContent addContent(Long courseId,  String title, String fileType, String fileUrl, Integer durationSeconds, boolean isFree) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));        

        CourseContent content = CourseContent.builder()
                .course(course)
                .title(title)
                .fileType(fileType)
                .fileUrl(fileUrl)
                .durationSeconds(durationSeconds != null ? durationSeconds : null)
                .isFree(isFree)
                .build();

        return courseContentRepository.save(content);
    }
    public CourseContent updateContent(Long courseId, Long contentId, String title, String fileType, String fileUrl, Integer durationSeconds, boolean isFree) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found with id: " + courseId));

        CourseContent content = courseContentRepository.findById(contentId)
                .orElse(null);

        if (content == null || !content.getCourse().getId().equals(courseId)) {
            return null; // either not found or not part of this course
        }

        // Update fields
        content.setTitle(title);
        content.setFileType(fileType);
        content.setFileUrl(fileUrl);
        content.setDurationSeconds(durationSeconds);
        content.setFree(isFree);

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
