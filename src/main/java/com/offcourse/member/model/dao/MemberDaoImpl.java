package com.offcourse.member.model.dao;

import com.offcourse.admin.model.dto.MemberAll;
import com.offcourse.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.RowBounds;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class MemberDaoImpl implements MemberDao {

    private final SqlSession sqlSession;

    private static final String NAMESPACE = "memberDao.";

    @Override
    public int existsById(String memberId) {
        return sqlSession.selectOne(NAMESPACE + "existsById", memberId);
    }

    @Override
    public int existsByEmail(String memberEmail) {
        return sqlSession.selectOne(NAMESPACE + "existsByEmail", memberEmail);
    }

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

    @Override
    public Member findByEmail(String memberEmail) {
        return sqlSession.selectOne(NAMESPACE + "findByEmail", memberEmail);
    }

    // MemberDaoImpl
    @Override
    public Member findByIdAndEmail(Map<String, Object> paramMap) {
        return sqlSession.selectOne(
                NAMESPACE + "findByIdAndEmail",
                paramMap
        );
    }

    @Override
    public int updatePassword(Map<String, Object> paramMap) {
        return sqlSession.update(NAMESPACE + "updatePassword", paramMap);
    }

    @Override
    public long countMemberAll() {
        return sqlSession.selectOne(NAMESPACE + "countMemberAll");
    }

    @Override
    public long countTeacherAll() {
        return sqlSession.selectOne(NAMESPACE + "countTeacherAll");
    }

    @Override
    public List<MemberAll> getMemberAllByRole(Map param) {
        int cPage = (int) param.get("cPage");
        int numPerPage = (int) param.get("numPerPage");
        RowBounds rb = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        return sqlSession.selectList(NAMESPACE + "getMemberAllByRole", param, rb);
    }

    @Override
    public int countMemberAllByRole(Map param) {
        return sqlSession.selectOne(NAMESPACE + "countMemberAllByRole", param);
    }
}
