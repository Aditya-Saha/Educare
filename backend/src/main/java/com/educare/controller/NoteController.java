package com.educare.controller;

import com.educare.dto.AddNoteRequest;
import com.educare.dto.NoteResponse;
import com.educare.entity.Note;
import com.educare.entity.User;
import com.educare.service.NoteService;
import com.educare.dto.ApiResponse;

import java.util.List;
import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/notes")
public class NoteController {

    @Autowired
    private NoteService noteService;

    @PostMapping("/add")
    public ResponseEntity<ApiResponse<NoteResponse>> addNote(
            @RequestBody @Valid AddNoteRequest request,
            @AuthenticationPrincipal User currentUser) {

        NoteResponse noteRes = noteService.addNote(request, currentUser);
        return ResponseEntity.ok(ApiResponse.ok("Note added successfully", noteRes));
    }

    @GetMapping("/courses/{courseId}")
    public ResponseEntity<ApiResponse<List<NoteResponse>>> getCourseNotes(@PathVariable Long courseId) {
        try {
            List<NoteResponse> notes = noteService.getNotesByCourse(courseId);
            return ResponseEntity.ok(ApiResponse.ok("Notes fetched successfully", notes));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Failed to fetch notes: " + e.getMessage()));
        }
    }

    @GetMapping("/{noteId}")
    public ResponseEntity<ApiResponse<NoteResponse>> getNoteById(@PathVariable Long noteId) {
        try {
            NoteResponse note = noteService.getNoteById(noteId);
            return ResponseEntity.ok(ApiResponse.ok("Note fetched successfully", note));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Note not found: " + e.getMessage()));
        }
    }

    /**
     * Edit (update) a note by ID
     */
    @PutMapping("/{noteId}")
    public ResponseEntity<ApiResponse<NoteResponse>> updateNote(
            @PathVariable Long noteId,
            @RequestBody @Valid AddNoteRequest request,
            @AuthenticationPrincipal User currentUser) {

        try {
            NoteResponse updatedNote = noteService.updateNote(noteId, request, currentUser);
            return ResponseEntity.ok(ApiResponse.ok("Note updated successfully", updatedNote));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Failed to update note: " + e.getMessage()));
        }
    }

}
