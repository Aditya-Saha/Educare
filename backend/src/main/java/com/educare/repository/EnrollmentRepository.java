package com.educare.repository;

import com.educare.entity.Enrollment;
import com.educare.entity.Course;
import com.educare.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;

public interface EnrollmentRepository extends JpaRepository<Enrollment, Long> {
    Optional<Enrollment> findByStudentAndCourse(User student, Course course);

    List<Enrollment> findByCourseId(Long courseId);

}
