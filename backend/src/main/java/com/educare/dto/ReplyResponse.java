package com.educare.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ReplyResponse {
    private Long id;
    private String content;
    private Long userId;
    private String userName;
    private LocalDateTime createdAt;
}
