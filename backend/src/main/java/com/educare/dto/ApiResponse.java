package com.educare.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Builder;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ApiResponse<T> {
    private String status;
    private String msg;
    private T data;

    // OK with data
    public static <T> ApiResponse<T> ok(String msg, T data) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus("ok");
        response.setMsg(msg);
        response.setData(data);
        return response;
    }

    // OK without data
    public static <T> ApiResponse<T> ok(String msg) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus("ok");
        response.setMsg(msg);
        response.setData(null);
        return response;
    }

    // Error
    public static <T> ApiResponse<T> error(String msg) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus("error");
        response.setMsg(msg);
        response.setData(null);
        return response;
    }
}
