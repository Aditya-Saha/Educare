package com.educare.service;

import com.educare.dto.AddCourseRequest;
import com.educare.entity.Course;
import com.educare.entity.User;
import com.educare.repository.CourseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.time.LocalDateTime;
import java.math.BigDecimal;


@Service
@RequiredArgsConstructor
public class CourseService {

    private final CourseRepository courseRepository;

    public Course addCourse(User teacher, AddCourseRequest request) {
        System.out.println(request.isPublished());
        Course course = Course.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .price(request.getPrice() != null ? request.getPrice() : BigDecimal.valueOf(0.0))
                .teacher(teacher)
                .isPublished(request.isPublished())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .imageUrl(request.getImageUrl())
                .build();

        return courseRepository.save(course);
    }
    public List<Course> getAllCourses() {
        return courseRepository.findAll();
    }
    public Course getCourseById(Long id) {
        return courseRepository.findById(id).orElse(null);
    }


    public Course updateCourse(Course existingCourse, AddCourseRequest request) {
        existingCourse.setTitle(request.getTitle());
        existingCourse.setDescription(request.getDescription());
        if (request.getPrice() != null) existingCourse.setPrice(request.getPrice());
        existingCourse.setPublished(request.isPublished());
        existingCourse.setUpdatedAt(LocalDateTime.now());

        return courseRepository.save(existingCourse);
    }
    public List<Course> getAllPublishedCourses() {
        return courseRepository.findByIsPublishedTrue();
    }

    // Return a single published course by ID
    public Course getPublishedCourseById(Long id) {
        return courseRepository.findByIdAndIsPublishedTrue(id)
                .orElseThrow(() -> new RuntimeException("Course not found or not published"));
    }

}
