package com.offcourse.attachment.model.dao;

import com.offcourse.attachment.model.dto.Attachment;
import com.offcourse.attachment.model.dto.AttachmentViewResponse;
import com.offcourse.course.model.dto.Episode;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.RowBounds;
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
        return session.insert("attachment.insertAttachment", attachment);
    }

    public List<Episode> getEpisodeByCourseSeq(Long courseSeq, int cPage, int numPerPage) {
        RowBounds rowBounds
                = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        return session.selectList("course.getEpisodeByCourseSeq", courseSeq, rowBounds);
    }

    public List<Attachment> getAttachByEpisodeSeq(Long episodeSeq) {
        return session.selectList("attachment.getAttachByEpisodeSeq", episodeSeq);
    }

    public List<Attachment> getVideoFile(Long episodeSeq) {
        return session.selectList("attachment.getVideoFile", episodeSeq);
    }

    public int deleteAttachmentBySeq(Long attachSeq) {
        return session.delete("attachment.deleteBySeq", attachSeq);
    }

    public List<Long> findMemberSeqListByEpisodeSeq(Long episodeSeq) {
        return session.selectList("attachment.findMemberSeqListByEpisodeSeq", episodeSeq);
    }
}
