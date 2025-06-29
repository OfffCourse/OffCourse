package com.offcourse.attachment.model.service;

import com.offcourse.attachment.model.dao.AttachmentDao;
import com.offcourse.attachment.model.dto.Attachment;
import com.offcourse.course.model.dao.CourseDao;
import com.offcourse.course.model.dto.Episode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AttachmentService {

    private final AttachmentDao dao;
    private final CourseDao courseDao;

    @Transactional
    public int insertAttachment(Attachment attachment) {
        return dao.insertAttachment(attachment);
    }

    public List<Episode> getEpisodeByCourseSeq(Long courseSeq, int cPage, int numPerPage) {
        return dao.getEpisodeByCourseSeq(courseSeq, cPage, numPerPage);
    }

    public List<Attachment> getAttachByEpisodeSeq(Long episodeSeq) {
        return dao.getAttachByEpisodeSeq(episodeSeq);
    }

    public List<Attachment> getVideoFile(Long episodeSeq) {
        return dao.getVideoFile(episodeSeq);
    }

    @Transactional
    public int deleteAttachmentBySeq(Long attachSeq) {
        return dao.deleteAttachmentBySeq(attachSeq);
    }

}
