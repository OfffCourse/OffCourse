package com.offcourse.attachment.controller;

import com.offcourse.attachment.model.dto.Attachment;
import com.offcourse.attachment.model.service.AttachmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Controller
@RequiredArgsConstructor
@Slf4j
public class AttachmentController {
    private final AttachmentService service;

    @PostMapping("/uploadChunk")
    public ResponseEntity<?> uploadChunk(
            @RequestParam("chunk") MultipartFile chunk,
            @RequestParam("index") int index,
            @RequestParam("total") int total,
            @RequestParam("episodeSeq") Long episodeSeq,
            @RequestParam("courseSeq") Long courseSeq,
            @RequestParam(value = "videoTitle", required = false) String videoTitle,
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
            String tempChunkName = episodeSeq + "_" + index + ".part";
            File tempChunkFile = new File(tempDir, tempChunkName);
            chunk.transferTo(tempChunkFile);

            // 4. 마지막 청크일 경우 병합
            if (index == total - 1) {
                String mergedFileName = "episodeSeq_" + episodeSeq + ".webm";
                File mergedFile = new File(finalDir, mergedFileName);
                try (FileOutputStream fos = new FileOutputStream(mergedFile, true)) {
                    for (int i = 0; i < total; i++) {
                        File part = new File(tempDir, episodeSeq + "_" + i + ".part");
                        Files.copy(part.toPath(), fos);
                        part.delete(); // 청크 파일 삭제
                    }
                }

                String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
                int rnd = (int) (Math.random() * 1000) + 1;
                String renamedFileName = "offcourse_" + timeStamp + "_" + rnd + ".mp4";
                File convertedMp4File = new File(finalDir, renamedFileName);

                URL exePath = getClass().getResource("/ffmpeg/bin/ffmpeg.exe");
                ProcessBuilder pb = new ProcessBuilder(exePath.getPath(),
                        "-i", mergedFile.getAbsolutePath(),
                        "-c:v", "libx264",
                        "-preset", "fast",
                        "-crf", "28",
                        "-c:a", "aac",
                        convertedMp4File.getAbsolutePath());

                pb.redirectErrorStream(true);
                Process process = pb.start();

                try (BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        //System.out.println("[ffmpeg] " + line);
                    }
                }

                int exitCode = process.waitFor();
                if (exitCode != 0) {
                    throw new RuntimeException("ffmpeg 변환 실패: 코드 " + exitCode);
                }

                System.out.println("변환 완료: " + convertedMp4File.getAbsolutePath());
                mergedFile.delete();
                // 병합 완료 후 DB 저장 처리
                Attachment attachment = Attachment.builder()
                        .attOriName(videoTitle + ".mp4")
                        .attRenamedName(renamedFileName)
                        .attType("2")
                        .episodeSeq(episodeSeq)
                        .build();

                service.insertAttachment(attachment);
            }

            service.sendVideoNotifications(courseSeq, episodeSeq);
            return ResponseEntity.ok("청크 업로드 성공");

        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("청크 업로드 실패");
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }

    @PostMapping("/uploadattach")
    public String uploadAttachment(@RequestParam Long episodeSeq,
                                   @RequestParam Long courseSeq,
                                   @RequestParam("upFile") MultipartFile[] upFiles,
                                   HttpSession session,
                                   Model model) {
        String path = session.getServletContext().getRealPath("/resources/upload/lecture/attach/");
        List<Attachment> attachmentList = new ArrayList<>();
        if (upFiles != null) {
            for (MultipartFile upFile : upFiles) {
                String oriName = upFile.getOriginalFilename();
                String ext = oriName.substring(oriName.lastIndexOf("."));
                int rnd = (int) (Math.random() * 1000) + 1;
                Date d = new Date(System.currentTimeMillis());
                SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmss");
                String rename = "offcourse_" + sdf.format(d) + "_" + rnd + ext;

                File dir = new File(path);
                if (!dir.exists()) {
                    dir.mkdirs();
                }
                try {
                    upFile.transferTo(new File(dir, rename));
                    String attType = ext.equals(".pdf") ? "1" : "0";
                    Attachment file = Attachment.builder().attOriName(oriName)
                            .attRenamedName(rename).attType(attType).episodeSeq(episodeSeq).build();
                    attachmentList.add(file);

                } catch (IOException e) {
                    throw new IllegalArgumentException("업로드실패!");
                }
            }
        }
        int result = 0;
        for (Attachment file : attachmentList) {
            result += service.insertAttachment(file);
        }
        if (result > 0) {
            model.addAttribute("msg", "첨부파일 저장성공");
            model.addAttribute("loc", "/course/view?courseSeq=" + courseSeq);
            service.sendAttachNotifications(courseSeq, episodeSeq);
        } else {
            model.addAttribute("msg", "첨부파일 저장실패");
            model.addAttribute("loc", "/course/view?courseSeq=" + courseSeq);
        }
        return "common/msg";
    }

    @GetMapping("/downloadattach")
    public void fileDownload(@RequestParam(required = false) String oriname,
                             @RequestParam String rename,
                             @RequestParam(required = false, defaultValue = "lecture") String type,
                             HttpSession session,
                             @RequestHeader("user-agent") String header,
                             OutputStream out,
                             HttpServletResponse response) {
        String path;
        if ("portfolio".equals(type)) {
            path = session.getServletContext().getRealPath("/resources/upload/instructor/portfolio/");
            if (oriname == null || oriname.isBlank()) {
                oriname = "portfolio.pdf";
            }
        } else {
            path = session.getServletContext().getRealPath("/resources/upload/lecture/attach/");
        }

        File downloadFile = new File(path, rename);
        if (!downloadFile.exists()) {
            throw new IllegalArgumentException("파일이 존재하지않습니다");
        }
        try (FileInputStream fis = new FileInputStream(downloadFile);
             BufferedInputStream bis = new BufferedInputStream(fis);
             BufferedOutputStream bos = new BufferedOutputStream(out);) {
            boolean isMS = header.contains("Trident") || header.contains("MSIE");
            String encodeName = "";
            if (isMS) {
                encodeName = URLEncoder.encode(oriname, "UTF-8");
                encodeName = encodeName.replace("\\+", "%20");
            } else {
                encodeName = new String(oriname.getBytes("UTF-8"),
                        "ISO-8859-1");
            }
            response.setContentType("application/octet-stream;charset=utf-8");
            response.setHeader("Content-Disposition",
                    "attachment;filename=" + encodeName);
            int data = -1;
            while ((data = bis.read()) != -1) {
                bos.write(data);
            }

        } catch (IOException e) {
            e.printStackTrace();
        }


    }

    /*강사페이지에서 첨부파일자료조회*/
    @GetMapping("/lecture/attachments")
    @ResponseBody
    public List<Attachment> getAttachmentsByEpisode(@RequestParam Long episodeSeq) {
        return service.getAttachByEpisodeSeq(episodeSeq);
    }

    @GetMapping("/lecture/videofile")
    @ResponseBody
    public List<Attachment> getVideoFile(@RequestParam Long episodeSeq) {
        List<Attachment> renamedVideo = service.getVideoFile(episodeSeq);
        return renamedVideo;
    }

    @DeleteMapping("/lecture/attachment/{attachSeq}")
    @ResponseBody
    public ResponseEntity<Void> deleteAttachment(@PathVariable Long attachSeq) {
        int result = service.deleteAttachmentBySeq(attachSeq);
        return result == 1 ? ResponseEntity.ok().build() : ResponseEntity.badRequest().build();
    }

}
