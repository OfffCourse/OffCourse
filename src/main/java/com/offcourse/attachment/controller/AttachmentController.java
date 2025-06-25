package com.offcourse.attachment.controller;

import com.offcourse.attachment.model.dto.Attachment;
import com.offcourse.attachment.model.service.AttachmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;
import java.io.*;
import java.net.URL;
import java.nio.file.Files;

@Controller
@RequiredArgsConstructor
public class AttachmentController {

    private final AttachmentService service;

    @PostMapping("/uploadChunk")
    public ResponseEntity<?> uploadChunk(
            @RequestParam("chunk") MultipartFile chunk,
            @RequestParam("index") int index,
            @RequestParam("total") int total,
            @RequestParam("lectureId") Long lectureId,
            HttpSession session) {

        // 1. 실제 경로 얻기 (webapp 아래에 저장)
        String tempPath = session.getServletContext().getRealPath("/resources/upload/lecture/temp/");
        String finalPath = session.getServletContext().getRealPath("/resources/upload/lecture/video/");
        System.out.println("실제 temp 경로: " + tempPath);

        // 2. 디렉토리 생성
        File tempDir = new File(tempPath);
        if (!tempDir.exists()) tempDir.mkdirs();
        File finalDir = new File(finalPath);
        if (!finalDir.exists()) finalDir.mkdirs();

        try {
            // 3. 청크 저장
            String tempChunkName = lectureId + "_" + index + ".part";
            File tempChunkFile = new File(tempDir, tempChunkName);
            chunk.transferTo(tempChunkFile);

            // 4. 마지막 청크일 경우 병합
            if (index == total - 1) {
                String mergedFileName = "lecture_" + lectureId + ".webm";
                File mergedFile = new File(finalDir, mergedFileName);
                try (FileOutputStream fos = new FileOutputStream(mergedFile, true)) {
                    for (int i = 0; i < total; i++) {
                        File part = new File(tempDir, lectureId + "_" + i + ".part");
                        Files.copy(part.toPath(), fos);
                        part.delete(); // 청크 파일 삭제
                    }
                }

                File convertedMp4File = new File(finalDir, "lecture_" + lectureId + ".mp4");
                URL exePath=getClass().getResource("/ffmpeg/bin/ffmpeg.exe");
//                System.out.println("resources경로 :  "+exePath);
                ProcessBuilder pb = new ProcessBuilder(exePath.getPath(),
                        "-i", mergedFile.getAbsolutePath(),
                        "-c:v", "libx264",
                        "-c:a", "aac",
                        "-strict", "-2",  // 일부 FFmpeg 버전용
                        convertedMp4File.getAbsolutePath());

                pb.redirectErrorStream(true);
                Process process = pb.start();

                try (BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        System.out.println("[ffmpeg] " + line); // 변환 로그 출력
                    }
                }

                int exitCode = process.waitFor();
                if (exitCode != 0) {
                    throw new RuntimeException("ffmpeg 변환 실패: 코드 " + exitCode);
                }

                System.out.println("🎉 변환 완료: " + convertedMp4File.getAbsolutePath());

                // 병합 완료 후 DB 저장 처리
                Attachment attachment = Attachment.builder()
                        .attOriName("lecture_" + lectureId + ".webm")
                        .attRenamedName(mergedFile.getName())
                        .attType("2")
                        .episodeSeq(lectureId)
                        .build();

                service.insertAttachment(attachment);

            }

            return ResponseEntity.ok("청크 업로드 성공");

        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("청크 업로드 실패");
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }

}
