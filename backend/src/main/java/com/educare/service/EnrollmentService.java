package com.educare.service;

import com.educare.dto.EnrollmentResponse;
import com.educare.dto.FreeEnrollmentRequest;
import com.educare.entity.Course;
import com.educare.entity.Enrollment;
import com.educare.entity.User;
import com.educare.repository.CourseRepository;
import com.educare.repository.EnrollmentRepository;
import com.educare.repository.UserRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.stream.Collectors;

import java.util.List;

@Service
public class EnrollmentService {

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private CourseRepository courseRepository;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public EnrollmentResponse giveFreeAccess(FreeEnrollmentRequest request, User teacher) {
        Course course = courseRepository.findById(request.getCourseId())
                .orElseThrow(() -> new RuntimeException("Course not found"));

        if (!course.getTeacher().getId().equals(teacher.getId())) {
            throw new RuntimeException("You are not the teacher of this course");
        }

        User student = userRepository.findById(request.getStudentId())
                .orElseThrow(() -> new RuntimeException("Student not found"));

        // Check if already enrolled
        enrollmentRepository.findByStudentAndCourse(student, course)
                .ifPresent(e -> { throw new RuntimeException("Student already enrolled"); });

        Enrollment enrollment = Enrollment.builder()
                .student(student)
                .course(course)
                .accessGrantedBy(teacher)
                .build();

        Enrollment saved = enrollmentRepository.save(enrollment);

        return EnrollmentResponse.builder()
                .id(saved.getId())
                .studentId(student.getId())
                .studentName(student.getName())
                .courseId(course.getId())
                .courseTitle(course.getTitle())
                .accessGrantedById(teacher.getId())
                .accessGrantedByName(teacher.getName())
                .enrolledAt(saved.getEnrolledAt())
                .build();
    }
    @Transactional
    public void revokeFreeEnrollment(Long enrollmentId, User teacher) {
        Enrollment enrollment = enrollmentRepository.findById(enrollmentId)
                .orElseThrow(() -> new RuntimeException("Enrollment not found"));

        // Only the teacher who granted the enrollment can revoke it
        if (enrollment.getAccessGrantedBy() == null || 
            !enrollment.getAccessGrantedBy().getId().equals(teacher.getId())) {
            throw new RuntimeException("You are not authorized to revoke this enrollment");
        }

        enrollmentRepository.delete(enrollment);
    }

    public EnrollmentResponse getEnrollment(Long id) {
        Enrollment e = enrollmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Enrollment not found"));

        return EnrollmentResponse.builder()
                .id(e.getId())
                .studentId(e.getStudent().getId())
                .studentName(e.getStudent().getName())
                .courseId(e.getCourse().getId())
                .courseTitle(e.getCourse().getTitle())
                .accessGrantedById(e.getAccessGrantedBy() != null ? e.getAccessGrantedBy().getId() : null)
                .accessGrantedByName(e.getAccessGrantedBy() != null ? e.getAccessGrantedBy().getName() : null)
                .enrolledAt(e.getEnrolledAt())
                .build();
    }
    /** ✅ 3. Get all enrollments for a course */
    public List<EnrollmentResponse> getEnrollmentsByCourse(Long courseId) {
        List<Enrollment> enrollments = enrollmentRepository.findByCourseId(courseId);
        return enrollments.stream().map(this::toDTO).collect(Collectors.toList());
    }

    private EnrollmentResponse toDTO(Enrollment enrollment) {
        EnrollmentResponse dto = new EnrollmentResponse();
        dto.setId(enrollment.getId());
        dto.setStudentId(enrollment.getStudent().getId());
        dto.setStudentName(enrollment.getStudent().getName());
        dto.setCourseId(enrollment.getCourse().getId());
        dto.setCourseTitle(enrollment.getCourse().getTitle());

        if (enrollment.getAccessGrantedBy() != null) {
            dto.setAccessGrantedById(enrollment.getAccessGrantedBy().getId());
            dto.setAccessGrantedByName(enrollment.getAccessGrantedBy().getName());
        }

        dto.setEnrolledAt(enrollment.getEnrolledAt());
        return dto;
    }
}
