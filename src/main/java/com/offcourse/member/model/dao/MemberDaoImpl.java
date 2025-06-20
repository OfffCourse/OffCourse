package com.offcourse.member.model.dao;

import com.offcourse.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class MemberDaoImpl implements MemberDao {

    private final SqlSession sqlSession;

    private static final String NAMESPACE = "member.";

    @Override
    public int insertMember(Member member) {
        return sqlSession.insert(NAMESPACE + "insertMember", member);
    }

    @Override
    public Member selectMemberById(String memberId) {
        return sqlSession.selectOne(NAMESPACE + "selectMemberById", memberId);
    }

    @Override
    public int updateMember(Member member) {
        return sqlSession.update(NAMESPACE + "updateMember", member);
    }

    @Override
    public int deleteMember(Long memberSeq) {
        return sqlSession.update(NAMESPACE + "deleteMember", memberSeq);
    }
}
