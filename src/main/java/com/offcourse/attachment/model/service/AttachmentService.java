package com.offcourse.attachment.model.service;

import com.offcourse.attachment.model.dao.AttachmentDao;
import com.offcourse.attachment.model.dto.Attachment;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AttachmentService {

    private final AttachmentDao dao;

    @Transactional
    public int insertAttachment(Attachment attachment) {
        return dao.insertAttachment(attachment);
    }

    /*public List<EpisodeAttachmentGroup> getEpisodeAttachment(Long courseSeq){
        List<AttachmentViewResponse> all = dao.getAttachments(courseSeq);


    }*/


}
