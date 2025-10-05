package com.educare.service;

import com.educare.dto.AddNoteRequest;
import com.educare.dto.NoteResponse;
import com.educare.dto.ReplyResponse;
import com.educare.entity.Course;
import com.educare.entity.Note;
import com.educare.entity.User;
import com.educare.repository.CourseRepository;
import com.educare.repository.NoteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class NoteService {

    @Autowired
    private NoteRepository noteRepository;

    @Autowired
    private CourseRepository courseRepository;

    /**
     * Add a new note or reply
     */
    public NoteResponse addNote(AddNoteRequest request, User currentUser) {
        Course course = courseRepository.findById(request.getCourseId())
                .orElseThrow(() -> new RuntimeException("Course not found"));

        Note note = new Note();
        note.setCourse(course);
        note.setUser(currentUser);
        note.setTitle(request.getTitle());
        note.setContent(request.getContent());
        note.setCreatedAt(LocalDateTime.now());
        note.setUpdatedAt(LocalDateTime.now());

        // Handle reply case
        if (request.getParentNoteId() != null) {
            Note parentNote = noteRepository.findById(request.getParentNoteId())
                    .orElseThrow(() -> new RuntimeException("Parent note not found"));
            note.setParentNote(parentNote);
        }

        note = noteRepository.save(note);
        return toNoteResponse(note);
    }

    /**
     * Convert Note entity → DTO
     */
    private NoteResponse toNoteResponse(Note note) {
        NoteResponse dto = new NoteResponse();
        dto.setId(note.getId());
        dto.setTitle(note.getTitle());
        dto.setContent(note.getContent());
        dto.setCourseId(note.getCourse().getId());
        dto.setParentNoteId(note.getParentNote() != null ? note.getParentNote().getId() : null);
        dto.setUserId(note.getUser().getId());
        dto.setUserName(note.getUser().getName());
        dto.setCreatedAt(note.getCreatedAt());

        if (note.getReplies() != null && !note.getReplies().isEmpty()) {
            dto.setReplies(
                    note.getReplies().stream()
                            .map(this::toReplyResponse)
                            .collect(Collectors.toList())
            );
        }

        return dto;
    }

    /**
     * Convert a reply → ReplyResponse DTO
     */
    private ReplyResponse toReplyResponse(Note reply) {
        ReplyResponse r = new ReplyResponse();
        r.setId(reply.getId());
        r.setContent(reply.getContent());
        r.setUserId(reply.getUser().getId());
        r.setUserName(reply.getUser().getName());
        r.setCreatedAt(reply.getCreatedAt());
        return r;
    }

    /**
     * Fetch all main notes for a course with replies
     */
    public List<NoteResponse> getNotesByCourse(Long courseId) {
        List<Note> mainNotes = noteRepository.findByCourseIdAndParentNoteIsNull(courseId);

        return mainNotes.stream()
                .map(this::toNoteResponse)
                .collect(Collectors.toList());
    }
    /**
     * Get a single note by ID
     */
    public NoteResponse getNoteById(Long noteId) {
        Note note = noteRepository.findById(noteId)
                .orElseThrow(() -> new RuntimeException("Note not found"));
        return toNoteResponse(note);
    }

    /**
     * Update note (only by the note owner)
     */
    public NoteResponse updateNote(Long noteId, AddNoteRequest request, User currentUser) {
        Note note = noteRepository.findById(noteId)
                .orElseThrow(() -> new RuntimeException("Note not found"));

        // Allow only the note creator to edit
        if (!note.getUser().getId().equals(currentUser.getId())) {
            throw new RuntimeException("You are not authorized to edit this note");
        }

        if (request.getTitle() != null) note.setTitle(request.getTitle());
        if (request.getContent() != null) note.setContent(request.getContent());
        note.setUpdatedAt(LocalDateTime.now());

        note = noteRepository.save(note);
        return toNoteResponse(note);
    }

}
