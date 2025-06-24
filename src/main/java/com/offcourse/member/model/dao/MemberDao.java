package com.offcourse.member.model.dao;

import com.offcourse.member.model.dto.Member;

import java.util.Map;

public interface MemberDao {

    int insertMember(Member member);

    Member selectMemberById(String memberId);

    int updateMember(Member member);

    int deleteMember(Long memberSeq);

    Member findByEmail(String memberEmail);

    Member findByIdAndEmail(Map<String, Object> paramMap);

    int updatePassword(Map<String, Object> paramMap);

}
