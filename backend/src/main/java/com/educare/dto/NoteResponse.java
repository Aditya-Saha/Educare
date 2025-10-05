package com.educare.dto;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class NoteResponse {
    private Long id;
    private String title;
    private String content;
    private Long courseId;
    private Long parentNoteId; // 👈 add this
    private Long userId;
    private String userName;
    private LocalDateTime createdAt;
    private List<ReplyResponse> replies;
}

