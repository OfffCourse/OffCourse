package com.offcourse.member.model.dao;

import com.offcourse.member.model.dto.Member;

public interface MemberDao {

    int insertMember(Member member);

    Member selectMemberById(String memberId);

    int updateMember(Member member);

    int deleteMember(Long memberSeq);
}
