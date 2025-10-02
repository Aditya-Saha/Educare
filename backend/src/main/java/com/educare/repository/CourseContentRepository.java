package com.educare.repository;

import com.educare.entity.CourseContent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Query;

@Repository
public interface CourseContentRepository extends JpaRepository<CourseContent, Long> {
    
   @Query("""
        SELECT cc
        FROM CourseContent cc
        JOIN cc.course c
        WHERE c.id = :courseId
        AND (
            cc.isFree = true
            OR c.price = 0
            OR (c.price > 0 AND EXISTS (
                SELECT 1 FROM Payment p
                WHERE p.course = c
                AND p.student.id = :studentId
                AND p.status = 'SUCCESS'
            ))
        )
        ORDER BY cc.id
    """)
    List<CourseContent> findAccessibleContentsForStudent(@Param("studentId") Long studentId,
                                                        @Param("courseId") Long courseId);


    // Teacher/admin query: no restriction
    List<CourseContent> findByCourseId(Long courseId);
}
