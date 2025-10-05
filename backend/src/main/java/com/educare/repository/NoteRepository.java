package com.educare.repository;

import com.educare.entity.Note;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.EntityGraph;

import java.util.List;

@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {
    @EntityGraph(attributePaths = {"replies", "replies.user", "user"})
    // Fetch main notes for a course (parentNoteId is null)
    List<Note> findByCourseIdAndParentNoteIsNull(Long courseId);

    // Fetch replies for a parent note
    List<Note> findByParentNoteId(Long parentNoteId);
}
