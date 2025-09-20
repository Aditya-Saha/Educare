package com.educare.service;

import com.educare.dto.AddCourseContentRequest;
import com.educare.entity.Course;
import com.educare.entity.CourseContent;
import com.educare.repository.CourseContentRepository;
import com.educare.repository.CourseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CourseContentService {

    private final CourseContentRepository courseContentRepository;
    private final CourseRepository courseRepository;

    public CourseContent addContent(Long courseId, AddCourseContentRequest request) {
        Optional<Course> courseOpt = courseRepository.findById(courseId);
        if (courseOpt.isEmpty()) return null;

        CourseContent content = CourseContent.builder()
                .course(courseOpt.get())
                .title(request.getTitle())
                .fileType(request.getFileType())
                .fileUrl(request.getFileUrl())
                .durationSeconds(request.getDurationSeconds())
                .build();

        return courseContentRepository.save(content);
    }

    public CourseContent getContentById(Long id) {
        return courseContentRepository.findById(id).orElse(null);
    }
}
