package com.educare.entity;

import org.hibernate.annotations.BatchSize;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "notes")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Note {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // The course this note belongs to
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    // The user who created the note
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Parent note for replies; null for main notes
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_note_id")
    private Note parentNote;

    // Replies to this note
    @BatchSize(size = 50)
    @Builder.Default
    @OneToMany(mappedBy = "parentNote", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Note> replies = new ArrayList<>();

    // Optional title
    private String title;

    // Content of the note
    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
