package com.educare.service;

import com.educare.util.YouTubeAuth;
import com.google.api.client.http.InputStreamContent;
import com.google.api.services.youtube.YouTube;
import com.google.api.services.youtube.model.Video;
import com.google.api.services.youtube.model.VideoStatus;
import com.google.api.services.youtube.model.VideoSnippet;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;

import org.springframework.web.multipart.MultipartFile;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Arrays;

@Service
public class YouTubeUploadService {

    private final String clientId;
    private final String clientSecret;
    private final String refreshToken;

    private YouTube youtube; // not final, allow lazy init

    public YouTubeUploadService(
            @Value("${GOOGLE_REFRESH_TOKEN}") String refreshToken,
            @Value("${GOOGLE_CLIENT_ID}") String clientId,
            @Value("${GOOGLE_CLIENT_SECRET}") String clientSecret) {
        this.refreshToken = refreshToken;
        this.clientId = clientId;
        this.clientSecret = clientSecret;
    }

    private YouTube getService() throws IOException {
        if (this.youtube == null) {
            System.out.println("INSIDE ...................");
            this.youtube = YouTubeAuth.getYouTubeService(refreshToken, clientId, clientSecret);
        }
        return this.youtube;
    }

    /**
     * Uploads a video to YouTube.
     *
     * @param filePath     Path to the video file
     * @param title        Video title
     * @param description  Video description
     * @param tags         Video tags
     * @param privacy      Privacy status: "public", "private", or "unlisted"
     * @return Uploaded video ID
     * @throws IOException if upload fails
     */
    public String uploadVideo(
            String filePath,
            String title,
            String description,
            String[] tags,
            String privacy) throws IOException {

        // Create snippet
        VideoSnippet snippet = new VideoSnippet();
        snippet.setTitle(title);
        snippet.setDescription(description);
        snippet.setTags(Arrays.asList(tags));

        // Set status
        VideoStatus status = new VideoStatus();
        status.setPrivacyStatus(privacy);

        // Create Video object
        Video video = new Video();
        video.setSnippet(snippet);
        video.setStatus(status);

        // Upload
        try (FileInputStream fileInputStream = new FileInputStream(filePath)) {
            InputStreamContent mediaContent = new InputStreamContent("video/*", fileInputStream);

            String parts = "snippet,status";
            YouTube.Videos.Insert request = getService().videos().insert(parts, video, mediaContent);

            Video response = request.execute();
            return response.getId();
        }
    }
    public void uploadThumbnail(String videoId, MultipartFile thumbnail) throws IOException {
        InputStreamContent mediaContent = new InputStreamContent(
                thumbnail.getContentType(),
                thumbnail.getInputStream()
        );

        YouTube.Thumbnails.Set thumbnailRequest = youtube.thumbnails()
                .set(videoId, mediaContent);

        thumbnailRequest.execute();
    }
}
