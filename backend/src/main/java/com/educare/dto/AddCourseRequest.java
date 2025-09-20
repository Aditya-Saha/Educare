package com.educare.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class AddCourseRequest {
    private String title;
    private String description;
    private BigDecimal price;
    private boolean published;  // simpler
    public boolean isPublished() { return published; }
    public void setPublished(boolean published) { this.published = published; }

}
