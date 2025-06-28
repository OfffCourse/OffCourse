package com.offcourse.attachment.model.dao;

import com.offcourse.attachment.model.dto.Attachment;
import com.offcourse.attachment.model.dto.AttachmentViewResponse;
import lombok.RequiredArgsConstructor;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class AttachmentDao {

    private final SqlSessionTemplate session;

    public List<AttachmentViewResponse> getAttachments(Long courseSeq) {
        return session.selectList("attachment.selectAttachmentsByCourseSeq", courseSeq);
    }
    public int insertAttachment(Attachment attachment) {
        return session.insert("attachment.insertAttachment",attachment);
    }


}
