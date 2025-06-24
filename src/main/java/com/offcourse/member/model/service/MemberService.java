package com.offcourse.member.model.service;

import com.offcourse.member.model.dto.Member;

public interface MemberService {

    int insertMember(Member member);

    Member selectMemberById(String memberId);

    int updateMember(Member member);

    int deleteMember(Long memberSeq);

    Member findByEmail(String memberEmail);

    Member findByIdAndEmail(String memberId, String memberEmail);

    int updatePassword(String memberId, String memberPwd);

}
