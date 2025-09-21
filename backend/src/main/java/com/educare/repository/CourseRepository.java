package com.educare.repository;

import com.educare.entity.Course;
import com.educare.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface CourseRepository extends JpaRepository<Course, Long> {
    List<Course> findByTeacher(User teacher);
    List<Course> findByIsPublishedTrue();

    Optional<Course> findByIdAndIsPublishedTrue(Long id);
}
